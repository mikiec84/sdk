// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:kernel/ast.dart' as ir;

import '../constants/values.dart';
import '../elements/entities.dart';
import '../js_model/elements.dart' show JField;
import '../js_model/js_world_builder.dart';
import '../kernel/element_map.dart';
import '../kernel/kernel_strategy.dart';
import '../kernel/kelements.dart' show KClass, KField, KConstructor;
import '../options.dart';
import '../serialization/serialization.dart';
import '../universe/member_usage.dart';
import '../world.dart';

abstract class FieldAnalysis {}

/// AllocatorAnalysis
///
/// Analysis to determine features of the allocator functions. The allocator
/// function takes parameters for each field initializer and initializes the
/// fields.  Parameters may be omitted if the initializer is always the same
/// constant value.  How the allocator is emitted will determine what kind of
/// constants can be handled.  The initial implementation only permits `null`.

// TODO(sra): Analysis to determine field order. Current field order is
// essentially declaration order, subclass first. We can reorder fields so that
// fields initialized with the same constant are together to allow chained
// initialization. Fields of a class and superclass can be reordered to allow
// chaining, e.g.
//
//     this.x = this.z = null;
//
class KFieldAnalysis implements FieldAnalysis {
  final KernelToElementMap _elementMap;

  final Map<KClass, ClassData> _classData = {};

  KFieldAnalysis(KernelFrontEndStrategy kernelStrategy)
      : _elementMap = kernelStrategy.elementMap;

  // Register class during resolution. Use simple syntactic analysis to find
  // null-initialized fields.
  void registerInstantiatedClass(KClass class_) {
    ir.Class classNode = _elementMap.getClassNode(class_);

    List<KConstructor> constructors = [];
    Map<KField, AllocatorData> fieldData = {};
    for (ir.Field field in classNode.fields) {
      if (!field.isInstanceMember) continue;

      FieldEntity fieldElement = _elementMap.getField(field);
      ir.Expression expression = field.initializer;
      ConstantValue value = _elementMap.getConstantValue(expression,
          requireConstant: false, implicitNull: true);
      if (value != null && value.isConstant) {
        fieldData[fieldElement] = new AllocatorData(value);
      }
    }

    for (ir.Constructor constructor in classNode.constructors) {
      KConstructor constructorElement = _elementMap.getConstructor(constructor);
      constructors.add(constructorElement);
      for (ir.Initializer initializer in constructor.initializers) {
        if (initializer is ir.FieldInitializer) {
          AllocatorData data =
              fieldData[_elementMap.getField(initializer.field)];
          if (data == null) {
            // TODO(johnniwinther): Support initializers with side-effects?

            // The field has a non-constant initializer.
            continue;
          }

          Initializer initializerValue = const Initializer.complex();
          ir.Expression value = initializer.value;
          ConstantValue constantValue = _elementMap.getConstantValue(value,
              requireConstant: false, implicitNull: true);
          if (constantValue != null && constantValue.isConstant) {
            initializerValue = new Initializer.direct(constantValue);
          } else if (value is ir.VariableGet) {
            ir.VariableDeclaration parameter = value.variable;
            int position =
                constructor.function.positionalParameters.indexOf(parameter);
            if (position != -1) {
              if (position >= constructor.function.requiredParameterCount) {
                constantValue = _elementMap.getConstantValue(
                    parameter.initializer,
                    requireConstant: false,
                    implicitNull: true);
                if (constantValue != null && constantValue.isConstant) {
                  initializerValue =
                      new Initializer.positional(position, constantValue);
                }
              }
            } else {
              position =
                  constructor.function.namedParameters.indexOf(parameter);
              if (position != -1) {
                constantValue = _elementMap.getConstantValue(
                    parameter.initializer,
                    requireConstant: false,
                    implicitNull: true);
                if (constantValue != null && constantValue.isConstant) {
                  initializerValue =
                      new Initializer.named(parameter.name, constantValue);
                }
              }
            }
          }
          data.initializers[constructorElement] = initializerValue;
        }
      }
    }

    _classData[class_] = new ClassData(constructors, fieldData);
  }

  AllocatorData getFixedInitializerForTesting(KField field) {
    return _classData[field.enclosingClass].fieldData[field];
  }
}

class ClassData {
  final List<KConstructor> constructors;
  final Map<KField, AllocatorData> fieldData;

  ClassData(this.constructors, this.fieldData);
}

class AllocatorData {
  final ConstantValue initialValue;
  final Map<KConstructor, Initializer> initializers = {};

  AllocatorData(this.initialValue);
}

enum InitializerKind {
  direct,
  positional,
  named,
  complex,
}

class Initializer {
  final InitializerKind kind;
  final int index;
  final String name;
  final ConstantValue value;

  Initializer.direct(this.value)
      : kind = InitializerKind.direct,
        index = null,
        name = null;

  Initializer.positional(this.index, this.value)
      : kind = InitializerKind.positional,
        name = null;

  Initializer.named(this.name, this.value)
      : kind = InitializerKind.named,
        index = null;

  const Initializer.complex()
      : kind = InitializerKind.complex,
        index = null,
        name = null,
        value = null;

  String get shortText {
    switch (kind) {
      case InitializerKind.direct:
        return value.toStructuredText();
      case InitializerKind.positional:
        return '$index:${value.toStructuredText()}';
      case InitializerKind.named:
        return '$name:${value.toStructuredText()}';
      case InitializerKind.complex:
        return '?';
    }
    throw new UnsupportedError('Unexpected kind $kind');
  }

  String toString() => shortText;
}

class JFieldAnalysis implements FieldAnalysis {
  /// Tag used for identifying serialized [JFieldAnalysis] objects in a
  /// debugging data stream.
  static const String tag = 'allocator-analysis';

  // --csp and --fast-startup have different constraints to the generated code.
  final Map<FieldEntity, ConstantValue> _fixedInitializers;

  final Map<FieldEntity, ConstantValue> _effectivelyConstantFields;

  final Set<FieldEntity> _elidedFields;

  JFieldAnalysis._(this._fixedInitializers, this._effectivelyConstantFields,
      this._elidedFields);

  /// Deserializes a [JFieldAnalysis] object from [source].
  factory JFieldAnalysis.readFromDataSource(
      DataSource source, CompilerOptions options) {
    source.begin(tag);
    Map<FieldEntity, ConstantValue> fixedInitializers =
        source.readMemberMap(source.readConstant);
    Map<FieldEntity, ConstantValue> effectivelyConstantFields =
        source.readMemberMap(source.readConstant);
    Set<FieldEntity> elidedFields = source.readMembers<FieldEntity>().toSet();
    source.end(tag);
    return new JFieldAnalysis._(
        fixedInitializers, effectivelyConstantFields, elidedFields);
  }

  /// Serializes this [JFieldAnalysis] to [sink].
  void writeToDataSink(DataSink sink) {
    sink.begin(tag);
    sink.writeMemberMap(_fixedInitializers, sink.writeConstant);
    sink.writeMemberMap(_effectivelyConstantFields, sink.writeConstant);
    sink.writeMembers(_elidedFields);
    sink.end(tag);
  }

  factory JFieldAnalysis.from(
      KClosedWorld closedWorld, JsToFrontendMap map, CompilerOptions options) {
    Map<FieldEntity, ConstantValue> fixedInitializers = {};
    Map<FieldEntity, ConstantValue> effectivelyConstantFields = {};
    Set<FieldEntity> elidedFields = new Set();

    bool canBeElided(FieldEntity field) {
      return !closedWorld.annotationsData.hasNoElision(field) &&
          !closedWorld.nativeData.isNativeMember(field);
    }

    closedWorld.fieldAnalysis._classData
        .forEach((ClassEntity cls, ClassData classData) {
      classData.fieldData.forEach((KField kField, AllocatorData data) {
        JField jField = map.toBackendMember(kField);
        if (jField == null) {
          return;
        }

        // TODO(johnniwinther): Should elided static fields be removed from the
        // J model? Static setters might still assign to them.

        MemberUsage memberUsage = closedWorld.liveMemberUsage[kField];
        if (!memberUsage.hasRead) {
          if (canBeElided(kField)) {
            elidedFields.add(jField);
          }
        } else {
          // TODO(johnniwinther): Use liveness of constructors and elided optional
          // parameters to recognize more constant initializers.
          if (data.initialValue != null) {
            ConstantValue initialValue;
            bool isTooComplex = false;

            void includeInitialValue(ConstantValue value) {
              if (isTooComplex) return;
              if (initialValue == null) {
                initialValue = value;
              } else if (initialValue != value) {
                initialValue = null;
                isTooComplex = true;
              }
            }

            bool inAllConstructors = true;
            for (KConstructor constructor in classData.constructors) {
              if (isTooComplex) {
                break;
              }

              MemberUsage constructorUsage =
                  closedWorld.liveMemberUsage[constructor];
              if (constructorUsage == null) return;
              ParameterStructure invokedParameters =
                  constructorUsage.invokedParameters;

              Initializer initializer = data.initializers[constructor];
              if (initializer == null) {
                inAllConstructors = false;
              } else {
                switch (initializer.kind) {
                  case InitializerKind.direct:
                    includeInitialValue(initializer.value);
                    break;
                  case InitializerKind.positional:
                    if (initializer.index >=
                        invokedParameters.positionalParameters) {
                      includeInitialValue(initializer.value);
                    } else {
                      isTooComplex = true;
                    }
                    break;
                  case InitializerKind.named:
                    if (!invokedParameters.namedParameters
                        .contains(initializer.name)) {
                      includeInitialValue(initializer.value);
                    } else {
                      isTooComplex = true;
                    }
                    break;
                  case InitializerKind.complex:
                    isTooComplex = true;
                    break;
                }
              }
            }
            if (!inAllConstructors) {
              includeInitialValue(data.initialValue);
            }
            if (!isTooComplex && initialValue != null) {
              ConstantValue value = map.toBackendConstant(initialValue);
              assert(value != null);
              if (!memberUsage.hasWrite && canBeElided(kField)) {
                elidedFields.add(jField);
                effectivelyConstantFields[jField] = value;
              } else if (value.isNull ||
                  value.isInt ||
                  value.isBool ||
                  value.isString) {
                // TODO(johnniwinther,sra): Support non-primitive constants in
                // allocators when it does cause allocators to deoptimized
                // because of deferred loading.
                fixedInitializers[jField] = value;
              }
            }
          }
        }
      });
    });

    // TODO(johnniwinther): Recognize effectively constant top level/static
    // fields.
    closedWorld.liveMemberUsage
        .forEach((MemberEntity member, MemberUsage memberUsage) {
      if (member.isField && !member.isInstanceMember) {
        if (!memberUsage.hasRead && canBeElided(member)) {
          elidedFields.add(map.toBackendMember(member));
        }
      }
    });

    return new JFieldAnalysis._(
        fixedInitializers, effectivelyConstantFields, elidedFields);
  }

  // TODO(sra): Add way to let injected fields be initialized to a constant in
  // allocator.

  /// Returns `true` if [field] is always initialized to a constant.
  bool isInitializedInAllocator(JField field) {
    return _fixedInitializers[field] != null;
  }

  /// Return the constant for a field initialized in allocator. Returns `null`
  /// for fields not initialized in allocator.
  ConstantValue initializerValue(JField field) {
    assert(isInitializedInAllocator(field));
    return _fixedInitializers[field];
  }

  /// Returns `true` if [field] can be elided from the output.
  ///
  /// This happens if a field is written to but never read.
  bool isElided(JField field) => _elidedFields.contains(field);

  /// Returns `true` if [field] is effectively constant and therefore only
  /// holds its [initializerValue].
  bool isEffectivelyConstant(JField field) =>
      _effectivelyConstantFields.containsKey(field);

  /// Returns the [ConstantValue] for the effectively constant [field].
  ConstantValue getConstantValue(JField field) {
    assert(isEffectivelyConstant(field));
    return _effectivelyConstantFields[field];
  }
}
