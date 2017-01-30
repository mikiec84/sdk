// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.core;

// Frequently used character codes.
const int _SPACE = 0x20;
const int _PERCENT = 0x25;
const int _PLUS = 0x2B;
const int _DOT = 0x2E;
const int _SLASH = 0x2F;
const int _COLON = 0x3A;
const int _UPPER_CASE_A = 0x41;
const int _UPPER_CASE_Z = 0x5A;
const int _LEFT_BRACKET = 0x5B;
const int _BACKSLASH = 0x5C;
const int _RIGHT_BRACKET = 0x5D;
const int _LOWER_CASE_A = 0x61;
const int _LOWER_CASE_F = 0x66;
const int _LOWER_CASE_Z = 0x7A;

const String _hexDigits = "0123456789ABCDEF";

/**
 * A parsed URI, such as a URL.
 *
 * **See also:**
 *
 * * [URIs][uris] in the [library tour][libtour]
 * * [RFC-3986](http://tools.ietf.org/html/rfc3986)
 *
 * [uris]: https://www.dartlang.org/docs/dart-up-and-running/ch03.html#uris
 * [libtour]: https://www.dartlang.org/docs/dart-up-and-running/contents/ch03.html
 */
abstract class Uri {
  /**
   * Returns the natural base URI for the current platform.
   *
   * When running in a browser this is the current URL of the current page
   * (from `window.location.href`).
   *
   * When not running in a browser this is the file URI referencing
   * the current working directory.
   */
  external static Uri get base;

  /**
   * Creates a new URI from its components.
   *
   * Each component is set through a named argument. Any number of
   * components can be provided. The [path] and [query] components can be set
   * using either of two different named arguments.
   *
   * The scheme component is set through [scheme]. The scheme is
   * normalized to all lowercase letters. If the scheme is omitted or empty,
   * the URI will not have a scheme part.
   *
   * The user info part of the authority component is set through
   * [userInfo]. It defaults to the empty string, which will be omitted
   * from the string representation of the URI.
   *
   * The host part of the authority component is set through
   * [host]. The host can either be a hostname, an IPv4 address or an
   * IPv6 address, contained in '[' and ']'. If the host contains a
   * ':' character, the '[' and ']' are added if not already provided.
   * The host is normalized to all lowercase letters.
   *
   * The port part of the authority component is set through
   * [port].
   * If [port] is omitted or `null`, it implies the default port for
   * the URI's scheme, and is equivalent to passing that port explicitly.
   * The recognized schemes, and their default ports, are "http" (80) and
   * "https" (443). All other schemes are considered as having zero as the
   * default port.
   *
   * If any of `userInfo`, `host` or `port` are provided,
   * the URI has an authority according to [hasAuthority].
   *
   * The path component is set through either [path] or
   * [pathSegments].
   * When [path] is used, it should be a valid URI path,
   * but invalid characters, except the general delimiters ':/@[]?#',
   * will be escaped if necessary.
   * When [pathSegments] is used, each of the provided segments
   * is first percent-encoded and then joined using the forward slash
   * separator.
   *
   * The percent-encoding of the path segments encodes all
   * characters except for the unreserved characters and the following
   * list of characters: `!$&'()*+,;=:@`. If the other components
   * necessitate an absolute path, a leading slash `/` is prepended if
   * not already there.
   *
   * The query component is set through either [query] or [queryParameters].
   * When [query] is used, the provided string should be a valid URI query,
   * but invalid characters, other than general delimiters,
   * will be escaped if necessary.
   * When [queryParameters] is used the query is built from the
   * provided map. Each key and value in the map is percent-encoded
   * and joined using equal and ampersand characters.
   * A value in the map must be either a string, or an [Iterable] of strings,
   * where the latter corresponds to multiple values for the same key.
   *
   * The percent-encoding of the keys and values encodes all characters
   * except for the unreserved characters, and replaces spaces with `+`.
   * If `query` is the empty string, it is equivalent to omitting it.
   * To have an actual empty query part,
   * use an empty map for `queryParameters`.
   *
   * If both `query` and `queryParameters` are omitted or `null`,
   * the URI has no query part.
   *
   * The fragment component is set through [fragment].
   * It should be a valid URI fragment, but invalid characters other than
   * general delimiters, are escaped if necessary.
   * If `fragment` is omitted or `null`, the URI has no fragment part.
   */
  factory Uri({String scheme,
               String userInfo,
               String host,
               int port,
               String path,
               Iterable<String> pathSegments,
               String query,
               Map<String, dynamic/*String|Iterable<String>*/> queryParameters,
               String fragment}) = _Uri;

  /**
   * Creates a new `http` URI from authority, path and query.
   *
   * Examples:
   *
   * ```
   * // http://example.org/path?q=dart.
   * new Uri.http("google.com", "/search", { "q" : "dart" });
   *
   * // http://user:pass@localhost:8080
   * new Uri.http("user:pass@localhost:8080", "");
   *
   * // http://example.org/a%20b
   * new Uri.http("example.org", "a b");
   *
   * // http://example.org/a%252F
   * new Uri.http("example.org", "/a%2F");
   * ```
   *
   * The `scheme` is always set to `http`.
   *
   * The `userInfo`, `host` and `port` components are set from the
   * [authority] argument. If `authority` is `null` or empty,
   * the created `Uri` has no authority, and isn't directly usable
   * as an HTTP URL, which must have a non-empty host.
   *
   * The `path` component is set from the [unencodedPath]
   * argument. The path passed must not be encoded as this constructor
   * encodes the path.
   *
   * The `query` component is set from the optional [queryParameters]
   * argument.
   */
  factory Uri.http(String authority,
                   String unencodedPath,
                   [Map<String, String> queryParameters]) = _Uri.http;

  /**
   * Creates a new `https` URI from authority, path and query.
   *
   * This constructor is the same as [Uri.http] except for the scheme
   * which is set to `https`.
   */
  factory Uri.https(String authority,
                    String unencodedPath,
                    [Map<String, String> queryParameters]) = _Uri.https;

  /**
   * Creates a new file URI from an absolute or relative file path.
   *
   * The file path is passed in [path].
   *
   * This path is interpreted using either Windows or non-Windows
   * semantics.
   *
   * With non-Windows semantics the slash ("/") is used to separate
   * path segments.
   *
   * With Windows semantics, backslash ("\\") and forward-slash ("/")
   * are used to separate path segments, except if the path starts
   * with "\\\\?\\" in which case, only backslash ("\\") separates path
   * segments.
   *
   * If the path starts with a path separator an absolute URI is
   * created. Otherwise a relative URI is created. One exception from
   * this rule is that when Windows semantics is used and the path
   * starts with a drive letter followed by a colon (":") and a
   * path separator then an absolute URI is created.
   *
   * The default for whether to use Windows or non-Windows semantics
   * determined from the platform Dart is running on. When running in
   * the standalone VM this is detected by the VM based on the
   * operating system. When running in a browser non-Windows semantics
   * is always used.
   *
   * To override the automatic detection of which semantics to use pass
   * a value for [windows]. Passing `true` will use Windows
   * semantics and passing `false` will use non-Windows semantics.
   *
   * Examples using non-Windows semantics:
   *
   * ```
   * // xxx/yyy
   * new Uri.file("xxx/yyy", windows: false);
   *
   * // xxx/yyy/
   * new Uri.file("xxx/yyy/", windows: false);
   *
   * // file:///xxx/yyy
   * new Uri.file("/xxx/yyy", windows: false);
   *
   * // file:///xxx/yyy/
   * new Uri.file("/xxx/yyy/", windows: false);
   *
   * // C:
   * new Uri.file("C:", windows: false);
   * ```
   *
   * Examples using Windows semantics:
   *
   * ```
   * // xxx/yyy
   * new Uri.file(r"xxx\yyy", windows: true);
   *
   * // xxx/yyy/
   * new Uri.file(r"xxx\yyy\", windows: true);
   *
   * file:///xxx/yyy
   * new Uri.file(r"\xxx\yyy", windows: true);
   *
   * file:///xxx/yyy/
   * new Uri.file(r"\xxx\yyy/", windows: true);
   *
   * // file:///C:/xxx/yyy
   * new Uri.file(r"C:\xxx\yyy", windows: true);
   *
   * // This throws an error. A path with a drive letter is not absolute.
   * new Uri.file(r"C:", windows: true);
   *
   * // This throws an error. A path with a drive letter is not absolute.
   * new Uri.file(r"C:xxx\yyy", windows: true);
   *
   * // file://server/share/file
   * new Uri.file(r"\\server\share\file", windows: true);
   * ```
   *
   * If the path passed is not a legal file path [ArgumentError] is thrown.
   */
  factory Uri.file(String path, {bool windows}) = _Uri.file;

  /**
   * Like [Uri.file] except that a non-empty URI path ends in a slash.
   *
   * If [path] is not empty, and it doesn't end in a directory separator,
   * then a slash is added to the returned URI's path.
   * In all other cases, the result is the same as returned by `Uri.file`.
   */
  factory Uri.directory(String path, {bool windows}) = _Uri.directory;

  /**
   * Creates a `data:` URI containing the [content] string.
   *
   * Converts the content to a bytes using [encoding] or the charset specified
   * in [parameters] (defaulting to US-ASCII if not specified or unrecognized),
   * then encodes the bytes into the resulting data URI.
   *
   * Defaults to encoding using percent-encoding (any non-ASCII or non-URI-valid
   * bytes is replaced by a percent encoding). If [base64] is true, the bytes
   * are instead encoded using [BASE64].
   *
   * If [encoding] is not provided and [parameters] has a `charset` entry,
   * that name is looked up using [Encoding.getByName],
   * and if the lookup returns an encoding, that encoding is used to convert
   * [content] to bytes.
   * If providing both an [encoding] and a charset [parameter], they should
   * agree, otherwise decoding won't be able to use the charset parameter
   * to determine the encoding.
   *
   * If [mimeType] and/or [parameters] are supplied, they are added to the
   * created URI. If any of these contain characters that are not allowed
   * in the data URI, the character is percent-escaped. If the character is
   * non-ASCII, it is first UTF-8 encoded and then the bytes are percent
   * encoded. An omitted [mimeType] in a data URI means `text/plain`, just
   * as an omitted `charset` parameter defaults to meaning `US-ASCII`.
   *
   * To read the content back, use [UriData.contentAsString].
   */
  factory Uri.dataFromString(String content,
                             {String mimeType,
                              Encoding encoding,
                              Map<String, String> parameters,
                              bool base64: false}) {
    UriData data =  new UriData.fromString(content,
                                           mimeType: mimeType,
                                           encoding: encoding,
                                           parameters: parameters,
                                           base64: base64);
    return data.uri;
  }

  /**
   * Creates a `data:` URI containing an encoding of [bytes].
   *
   * Defaults to Base64 encoding the bytes, but if [percentEncoded]
   * is `true`, the bytes will instead be percent encoded (any non-ASCII
   * or non-valid-ASCII-character byte is replaced by a percent encoding).
   *
   * To read the bytes back, use [UriData.contentAsBytes].
   *
   * It defaults to having the mime-type `application/octet-stream`.
   * The [mimeType] and [parameters] are added to the created URI.
   * If any of these contain characters that are not allowed
   * in the data URI, the character is percent-escaped. If the character is
   * non-ASCII, it is first UTF-8 encoded and then the bytes are percent
   * encoded.
   */
  factory Uri.dataFromBytes(List<int> bytes,
                            {mimeType: "application/octet-stream",
                             Map<String, String> parameters,
                             percentEncoded: false}) {
    UriData data = new UriData.fromBytes(bytes,
                                         mimeType: mimeType,
                                         parameters: parameters,
                                         percentEncoded: percentEncoded);
    return data.uri;
  }

  /**
   * The scheme component of the URI.
   *
   * Returns the empty string if there is no scheme component.
   *
   * A URI scheme is case insensitive.
   * The returned scheme is canonicalized to lowercase letters.
   */
  String get scheme;

  /**
   * Returns the authority component.
   *
   * The authority is formatted from the [userInfo], [host] and [port]
   * parts.
   *
   * Returns the empty string if there is no authority component.
   */
  String get authority;

  /**
   * Returns the user info part of the authority component.
   *
   * Returns the empty string if there is no user info in the
   * authority component.
   */
  String get userInfo;

  /**
   * Returns the host part of the authority component.
   *
   * Returns the empty string if there is no authority component and
   * hence no host.
   *
   * If the host is an IP version 6 address, the surrounding `[` and `]` is
   * removed.
   *
   * The host string is case-insensitive.
   * The returned host name is canonicalized to lower-case
   * with upper-case percent-escapes.
   */
  String get host;

  /**
   * Returns the port part of the authority component.
   *
   * Returns the default port if there is no port number in the authority
   * component. That's 80 for http, 443 for https, and 0 for everything else.
   */
  int get port;

  /**
   * Returns the path component.
   *
   * The returned path is encoded. To get direct access to the decoded
   * path use [pathSegments].
   *
   * Returns the empty string if there is no path component.
   */
  String get path;

  /**
   * Returns the query component. The returned query is encoded. To get
   * direct access to the decoded query use [queryParameters].
   *
   * Returns the empty string if there is no query component.
   */
  String get query;

  /**
   * Returns the fragment identifier component.
   *
   * Returns the empty string if there is no fragment identifier
   * component.
   */
  String get fragment;

  /**
   * Returns the URI path split into its segments. Each of the segments in the
   * returned list have been decoded. If the path is empty the empty list will
   * be returned. A leading slash `/` does not affect the segments returned.
   *
   * The returned list is unmodifiable and will throw [UnsupportedError] on any
   * calls that would mutate it.
   */
  List<String> get pathSegments;

  /**
   * Returns the URI query split into a map according to the rules
   * specified for FORM post in the [HTML 4.01 specification section
   * 17.13.4](http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4 "HTML 4.01 section 17.13.4").
   * Each key and value in the returned map has been decoded.
   * If there is no query the empty map is returned.
   *
   * Keys in the query string that have no value are mapped to the
   * empty string.
   * If a key occurs more than once in the query string, it is mapped to
   * an arbitrary choice of possible value.
   * The [queryParametersAll] getter can provide a map
   * that maps keys to all of their values.
   *
   * The returned map is unmodifiable.
   */
  Map<String, String> get queryParameters;

  /**
   * Returns the URI query split into a map according to the rules
   * specified for FORM post in the [HTML 4.01 specification section
   * 17.13.4](http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4 "HTML 4.01 section 17.13.4").
   * Each key and value in the returned map has been decoded. If there is no
   * query the empty map is returned.
   *
   * Keys are mapped to lists of their values. If a key occurs only once,
   * its value is a singleton list. If a key occurs with no value, the
   * empty string is used as the value for that occurrence.
   *
   * The returned map and the lists it contains are unmodifiable.
   */
  Map<String, List<String>> get queryParametersAll;

  /**
   * Returns whether the URI is absolute.
   *
   * A URI is an absolute URI in the sense of RFC 3986 if it has a scheme
   * and no fragment.
   */
  bool get isAbsolute;

  /**
   * Returns whether the URI has a [scheme] component.
   */
  bool get hasScheme => scheme.isNotEmpty;

  /**
   * Returns whether the URI has an [authority] component.
   */
  bool get hasAuthority;

  /**
   * Returns whether the URI has an explicit port.
   *
   * If the port number is the default port number
   * (zero for unrecognized schemes, with http (80) and https (443) being
   * recognized),
   * then the port is made implicit and omitted from the URI.
   */
  bool get hasPort;

  /**
   * Returns whether the URI has a query part.
   */
  bool get hasQuery;

  /**
   * Returns whether the URI has a fragment part.
   */
  bool get hasFragment;

  /**
   * Returns whether the URI has an empty path.
   */
  bool get hasEmptyPath;

  /**
   * Returns whether the URI has an absolute path (starting with '/').
   */
  bool get hasAbsolutePath;

  /**
   * Returns the origin of the URI in the form scheme://host:port for the
   * schemes http and https.
   *
   * It is an error if the scheme is not "http" or "https", or if the host name
   * is missing or empty.
   *
   * See: http://www.w3.org/TR/2011/WD-html5-20110405/origin-0.html#origin
   */
  String get origin;

  /// Whether the scheme of this [Uri] is [scheme].
  ///
  /// The [scheme] should be the same as the one returned by [Uri.scheme],
  /// but doesn't have to be case-normalized to lower-case characters.
  ///
  /// Example:
  /// ```dart
  /// var uri = Uri.parse("http://example.com/");
  /// print(uri.isScheme("HTTP"));  // Prints true.
  /// ```
  ///
  /// A `null` or empty [scheme] string matches a URI with no scheme
  /// (one where [hasScheme] returns false).
  bool isScheme(String scheme);

  /**
   * Returns the file path from a file URI.
   *
   * The returned path has either Windows or non-Windows
   * semantics.
   *
   * For non-Windows semantics the slash ("/") is used to separate
   * path segments.
   *
   * For Windows semantics the backslash ("\\") separator is used to
   * separate path segments.
   *
   * If the URI is absolute the path starts with a path separator
   * unless Windows semantics is used and the first path segment is a
   * drive letter. When Windows semantics is used a host component in
   * the uri in interpreted as a file server and a UNC path is
   * returned.
   *
   * The default for whether to use Windows or non-Windows semantics
   * determined from the platform Dart is running on. When running in
   * the standalone VM this is detected by the VM based on the
   * operating system. When running in a browser non-Windows semantics
   * is always used.
   *
   * To override the automatic detection of which semantics to use pass
   * a value for [windows]. Passing `true` will use Windows
   * semantics and passing `false` will use non-Windows semantics.
   *
   * If the URI ends with a slash (i.e. the last path component is
   * empty) the returned file path will also end with a slash.
   *
   * With Windows semantics URIs starting with a drive letter cannot
   * be relative to the current drive on the designated drive. That is
   * for the URI `file:///c:abc` calling `toFilePath` will throw as a
   * path segment cannot contain colon on Windows.
   *
   * Examples using non-Windows semantics (resulting of calling
   * toFilePath in comment):
   *
   *     Uri.parse("xxx/yyy");  // xxx/yyy
   *     Uri.parse("xxx/yyy/");  // xxx/yyy/
   *     Uri.parse("file:///xxx/yyy");  // /xxx/yyy
   *     Uri.parse("file:///xxx/yyy/");  // /xxx/yyy/
   *     Uri.parse("file:///C:");  // /C:
   *     Uri.parse("file:///C:a");  // /C:a
   *
   * Examples using Windows semantics (resulting URI in comment):
   *
   *     Uri.parse("xxx/yyy");  // xxx\yyy
   *     Uri.parse("xxx/yyy/");  // xxx\yyy\
   *     Uri.parse("file:///xxx/yyy");  // \xxx\yyy
   *     Uri.parse("file:///xxx/yyy/");  // \xxx\yyy/
   *     Uri.parse("file:///C:/xxx/yyy");  // C:\xxx\yyy
   *     Uri.parse("file:C:xxx/yyy");  // Throws as a path segment
   *                                   // cannot contain colon on Windows.
   *     Uri.parse("file://server/share/file");  // \\server\share\file
   *
   * If the URI is not a file URI calling this throws
   * [UnsupportedError].
   *
   * If the URI cannot be converted to a file path calling this throws
   * [UnsupportedError].
   */
  // TODO(lrn): Deprecate and move functionality to File class or similar.
  // The core libraries should not worry about the platform.
  String toFilePath({bool windows});

  /**
   * Access the structure of a `data:` URI.
   *
   * Returns a [UriData] object for `data:` URIs and `null` for all other
   * URIs.
   * The [UriData] object can be used to access the media type and data
   * of a `data:` URI.
   */
  UriData get data;

  /// Returns a hash code computed as `toString().hashCode`.
  ///
  /// This guarantees that URIs with the same normalized
  int get hashCode;

  /// A URI is equal to another URI with the same normalized representation.
  bool operator==(Object other);

  /// Returns the normalized string representation of the URI.
  String toString();

  /**
   * Returns a new `Uri` based on this one, but with some parts replaced.
   *
   * This method takes the same parameters as the [new Uri] constructor,
   * and they have the same meaning.
   *
   * At most one of [path] and [pathSegments] must be provided.
   * Likewise, at most one of [query] and [queryParameters] must be provided.
   *
   * Each part that is not provided will default to the corresponding
   * value from this `Uri` instead.
   *
   * This method is different from [Uri.resolve] which overrides in a
   * hierarchical manner,
   * and can instead replace each part of a `Uri` individually.
   *
   * Example:
   *
   *     Uri uri1 = Uri.parse("a://b@c:4/d/e?f#g");
   *     Uri uri2 = uri1.replace(scheme: "A", path: "D/E/E", fragment: "G");
   *     print(uri2);  // prints "A://b@c:4/D/E/E/?f#G"
   *
   * This method acts similarly to using the `new Uri` constructor with
   * some of the arguments taken from this `Uri` . Example:
   *
   *     Uri uri3 = new Uri(
   *         scheme: "A",
   *         userInfo: uri1.userInfo,
   *         host: uri1.host,
   *         port: uri1.port,
   *         path: "D/E/E",
   *         query: uri1.query,
   *         fragment: "G");
   *     print(uri3);  // prints "A://b@c:4/D/E/E/?f#G"
   *     print(uri2 == uri3);  // prints true.
   *
   * Using this method can be seen as a shorthand for the `Uri` constructor
   * call above, but may also be slightly faster because the parts taken
   * from this `Uri` need not be checked for validity again.
   */
  Uri replace({String scheme,
               String userInfo,
               String host,
               int port,
               String path,
               Iterable<String> pathSegments,
               String query,
               Map<String, dynamic/*String|Iterable<String>*/> queryParameters,
               String fragment});

  /**
   * Returns a `Uri` that differs from this only in not having a fragment.
   *
   * If this `Uri` does not have a fragment, it is itself returned.
   */
  Uri removeFragment();

  /**
   * Resolve [reference] as an URI relative to `this`.
   *
   * First turn [reference] into a URI using [Uri.parse]. Then resolve the
   * resulting URI relative to `this`.
   *
   * Returns the resolved URI.
   *
   * See [resolveUri] for details.
   */
  Uri resolve(String reference);

  /**
   * Resolve [reference] as an URI relative to `this`.
   *
   * Returns the resolved URI.
   *
   * The algorithm "Transform Reference" for resolving a reference is described
   * in [RFC-3986 Section 5](http://tools.ietf.org/html/rfc3986#section-5 "RFC-1123").
   *
   * Updated to handle the case where the base URI is just a relative path -
   * that is: when it has no scheme or authority and the path does not start
   * with a slash.
   * In that case, the paths are combined without removing leading "..", and
   * an empty path is not converted to "/".
   */
  Uri resolveUri(Uri reference);

  /**
   * Returns a URI where the path has been normalized.
   *
   * A normalized path does not contain `.` segments or non-leading `..`
   * segments.
   * Only a relative path with no scheme or authority may contain
   * leading `..` segments,
   * a path that starts with `/` will also drop any leading `..` segments.
   *
   * This uses the same normalization strategy as `new Uri().resolve(this)`.
   *
   * Does not change any part of the URI except the path.
   *
   * The default implementation of `Uri` always normalizes paths, so calling
   * this function has no effect.
   */
  Uri normalizePath();

  /**
   * Creates a new `Uri` object by parsing a URI string.
   *
   * If [start] and [end] are provided, only the substring from `start`
   * to `end` is parsed as a URI.
   *
   * If the string is not valid as a URI or URI reference,
   * a [FormatException] is thrown.
   */
  static Uri parse(String uri, [int start = 0, int end]) {
    // This parsing will not validate percent-encoding, IPv6, etc.
    // When done splitting into parts, it will call, e.g., [_makeFragment]
    // to do the final parsing.
    //
    // Important parts of the RFC 3986 used here:
    // URI           = scheme ":" hier-part [ "?" query ] [ "#" fragment ]
    //
    // hier-part     = "//" authority path-abempty
    //               / path-absolute
    //               / path-rootless
    //               / path-empty
    //
    // URI-reference = URI / relative-ref
    //
    // absolute-URI  = scheme ":" hier-part [ "?" query ]
    //
    // relative-ref  = relative-part [ "?" query ] [ "#" fragment ]
    //
    // relative-part = "//" authority path-abempty
    //               / path-absolute
    //               / path-noscheme
    //               / path-empty
    //
    // scheme        = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
    //
    // authority     = [ userinfo "@" ] host [ ":" port ]
    // userinfo      = *( unreserved / pct-encoded / sub-delims / ":" )
    // host          = IP-literal / IPv4address / reg-name
    // port          = *DIGIT
    // reg-name      = *( unreserved / pct-encoded / sub-delims )
    //
    // path          = path-abempty    ; begins with "/" or is empty
    //               / path-absolute   ; begins with "/" but not "//"
    //               / path-noscheme   ; begins with a non-colon segment
    //               / path-rootless   ; begins with a segment
    //               / path-empty      ; zero characters
    //
    // path-abempty  = *( "/" segment )
    // path-absolute = "/" [ segment-nz *( "/" segment ) ]
    // path-noscheme = segment-nz-nc *( "/" segment )
    // path-rootless = segment-nz *( "/" segment )
    // path-empty    = 0<pchar>
    //
    // segment       = *pchar
    // segment-nz    = 1*pchar
    // segment-nz-nc = 1*( unreserved / pct-encoded / sub-delims / "@" )
    //               ; non-zero-length segment without any colon ":"
    //
    // pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
    //
    // query         = *( pchar / "/" / "?" )
    //
    // fragment      = *( pchar / "/" / "?" )
    end ??= uri.length;

    // Special case data:URIs. Ignore case when testing.
    if (end >= start + 5) {
      int dataDelta = _startsWithData(uri, start);
      if (dataDelta == 0) {
        // The case is right.
        if (start > 0 || end < uri.length) uri = uri.substring(start, end);
        return UriData._parse(uri, 5, null).uri;
      } else if (dataDelta == 0x20) {
        return UriData._parse(uri.substring(start + 5, end), 0, null).uri;
      }
      // Otherwise the URI doesn't start with "data:" or any case variant of it.
    }

    // The following index-normalization belongs with the scanning, but is
    // easier to do here because we already have extracted variables from the
    // indices list.
    var indices = new List<int>(8);//new List<int>.filled(8, start - 1);

    // Set default values for each position.
    // The value will either be correct in some cases where it isn't set
    // by the scanner, or it is clearly recognizable as an unset value.
    indices
      ..[0] = 0
      ..[_schemeEndIndex] = start - 1
      ..[_hostStartIndex] = start - 1
      ..[_notSimpleIndex] = start - 1
      ..[_portStartIndex] = start
      ..[_pathStartIndex] = start
      ..[_queryStartIndex] = end
      ..[_fragmentStartIndex] = end;
    var state = _scan(uri, start, end, _uriStart, indices);
    // Some states that should be non-simple, but the URI ended early.
    // Paths that end at a ".." must be normalized to end in "../".
    if (state >= _nonSimpleEndStates) {
      indices[_notSimpleIndex] = end;
    }
    int schemeEnd = indices[_schemeEndIndex];
    if (schemeEnd >= start) {
      // Rescan the scheme part now that we know it's not a path.
      state = _scan(uri, start, schemeEnd, _schemeStart, indices);
      if (state == _schemeStart) {
        // Empty scheme.
        indices[_notSimpleIndex] = schemeEnd;
      }
    }
    // The returned positions are limited by the scanners ability to write only
    // one position per character, and only the current position.
    // Scanning from left to right, we only know whether something is a scheme
    // or a path when we see a `:` or `/`, and likewise we only know if the first
    // `/` is part of the path or is leading an authority component when we see
    // the next character.

    int hostStart     = indices[_hostStartIndex] + 1;
    int portStart     = indices[_portStartIndex];
    int pathStart     = indices[_pathStartIndex];
    int queryStart    = indices[_queryStartIndex];
    int fragmentStart = indices[_fragmentStartIndex];

    // We may discover scheme while handling special cases.
    String scheme;

    // Derive some positions that weren't set to normalize the indices.
    // If pathStart isn't set (it's before scheme end or host start), then
    // the path is empty.
    if (fragmentStart < queryStart) queryStart = fragmentStart;
    if (pathStart < hostStart || pathStart <= schemeEnd) {
      pathStart = queryStart;
    }
    // If there is an authority with no port, set the port position
    // to be at the end of the authority (equal to pathStart).
    // This also handles a ":" in a user-info component incorrectly setting
    // the port start position.
    if (portStart < hostStart) portStart = pathStart;

    assert(hostStart == start || schemeEnd <= hostStart);
    assert(hostStart <= portStart);
    assert(schemeEnd <= pathStart);
    assert(portStart <= pathStart);
    assert(pathStart <= queryStart);
    assert(queryStart <= fragmentStart);

    bool isSimple = indices[_notSimpleIndex] < start;

    if (isSimple) {
      // Check/do normalizations that weren't detected by the scanner.
      // This includes removal of empty port or userInfo,
      // or scheme specific port and path normalizations.
      if (hostStart > schemeEnd + 3) {
        // Always be non-simple if URI contains user-info.
        // The scanner doesn't set the not-simple position in this case because
        // it's setting the host-start position instead.
        isSimple = false;
      } else if (portStart > start && portStart + 1 == pathStart) {
        // If the port is empty, it should be omitted.
        // Pathological case, don't bother correcting it.
        isSimple = false;
      } else if (queryStart < end &&
                 (queryStart == pathStart + 2 &&
                  uri.startsWith("..", pathStart)) ||
                 (queryStart > pathStart + 2 &&
                  uri.startsWith("/..", queryStart - 3))) {
        // The path ends in a ".." segment. This should be normalized to "../".
        // We didn't detect this while scanning because a query or fragment was
        // detected at the same time (which is why we only need to check this
        // if there is something after the path).
        isSimple = false;
      } else {
        // There are a few scheme-based normalizations that
        // the scanner couldn't check.
        // That means that the input is very close to simple, so just do
        // the normalizations.
        if (schemeEnd == start + 4) {
          // Do scheme based normalizations for file, http.
          if (uri.startsWith("file", start)) {
            scheme = "file";
            if (hostStart <= start) {
              // File URIs should have an authority.
              // Paths after an authority should be absolute.
              String schemeAuth = "file://";
              int delta = 2;
              if (!uri.startsWith("/", pathStart)) {
                schemeAuth = "file:///";
                delta = 3;
              }
              uri = schemeAuth + uri.substring(pathStart, end);
              schemeEnd -= start;
              hostStart = 7;
              portStart = 7;
              pathStart = 7;
              queryStart += delta - start;
              fragmentStart += delta - start;
              start = 0;
              end = uri.length;
            } else if (pathStart == queryStart) {
              // Uri has authority and empty path. Add "/" as path.
              if (start == 0 && end == uri.length) {
                uri = uri.replaceRange(pathStart, queryStart, "/");
                queryStart += 1;
                fragmentStart += 1;
                end += 1;
              } else {
                uri = "${uri.substring(start, pathStart)}/"
                      "${uri.substring(queryStart, end)}";
                schemeEnd -= start;
                hostStart -= start;
                portStart -= start;
                pathStart -= start;
                queryStart += 1 - start;
                fragmentStart += 1 - start;
                start = 0;
                end = uri.length;
              }
            }
          } else if (uri.startsWith("http", start)) {
            scheme = "http";
            // HTTP URIs should not have an explicit port of 80.
            if (portStart > start && portStart + 3 == pathStart &&
                uri.startsWith("80", portStart + 1)) {
              if (start == 0 && end == uri.length) {
                uri = uri.replaceRange(portStart, pathStart, "");
                pathStart -= 3;
                queryStart -= 3;
                fragmentStart -= 3;
                end -= 3;
              } else {
                uri = uri.substring(start, portStart) +
                      uri.substring(pathStart, end);
                schemeEnd -= start;
                hostStart -= start;
                portStart -= start;
                pathStart -= 3 + start;
                queryStart -= 3 + start;
                fragmentStart -= 3 + start;
                start = 0;
                end = uri.length;
              }
            }
          }
        } else if (schemeEnd == start + 5 && uri.startsWith("https", start)) {
          scheme = "https";
          // HTTPS URIs should not have an explicit port of 443.
          if (portStart > start && portStart + 4 == pathStart &&
              uri.startsWith("443", portStart + 1)) {
            if (start == 0 && end == uri.length) {
              uri = uri.replaceRange(portStart, pathStart, "");
              pathStart -= 4;
              queryStart -= 4;
              fragmentStart -= 4;
              end -= 3;
            } else {
              uri = uri.substring(start, portStart) +
                    uri.substring(pathStart, end);
              schemeEnd -= start;
              hostStart -= start;
              portStart -= start;
              pathStart -= 4 + start;
              queryStart -= 4 + start;
              fragmentStart -= 4 + start;
              start = 0;
              end = uri.length;
            }
          }
        }
      }
    }

    if (isSimple) {
      if (start > 0 || end < uri.length) {
        uri = uri.substring(start, end);
        schemeEnd -= start;
        hostStart -= start;
        portStart -= start;
        pathStart -= start;
        queryStart -= start;
        fragmentStart -= start;
      }
      return new _SimpleUri(uri, schemeEnd, hostStart, portStart, pathStart,
                            queryStart, fragmentStart, scheme);

    }

    return new _Uri.notSimple(uri, start, end, schemeEnd, hostStart, portStart,
                              pathStart, queryStart, fragmentStart, scheme);
  }

  /**
   * Encode the string [component] using percent-encoding to make it
   * safe for literal use as a URI component.
   *
   * All characters except uppercase and lowercase letters, digits and
   * the characters `-_.!~*'()` are percent-encoded. This is the
   * set of characters specified in RFC 2396 and the which is
   * specified for the encodeUriComponent in ECMA-262 version 5.1.
   *
   * When manually encoding path segments or query components remember
   * to encode each part separately before building the path or query
   * string.
   *
   * For encoding the query part consider using
   * [encodeQueryComponent].
   *
   * To avoid the need for explicitly encoding use the [pathSegments]
   * and [queryParameters] optional named arguments when constructing
   * a [Uri].
   */
  static String encodeComponent(String component) {
    return _Uri._uriEncode(_Uri._unreserved2396Table, component, UTF8, false);
  }

  /**
   * Encode the string [component] according to the HTML 4.01 rules
   * for encoding the posting of a HTML form as a query string
   * component.
   *
   * Encode the string [component] according to the HTML 4.01 rules
   * for encoding the posting of a HTML form as a query string
   * component.

   * The component is first encoded to bytes using [encoding].
   * The default is to use [UTF8] encoding, which preserves all
   * the characters that don't need encoding.

   * Then the resulting bytes are "percent-encoded". This transforms
   * spaces (U+0020) to a plus sign ('+') and all bytes that are not
   * the ASCII decimal digits, letters or one of '-._~' are written as
   * a percent sign '%' followed by the two-digit hexadecimal
   * representation of the byte.

   * Note that the set of characters which are percent-encoded is a
   * superset of what HTML 4.01 requires, since it refers to RFC 1738
   * for reserved characters.
   *
   * When manually encoding query components remember to encode each
   * part separately before building the query string.
   *
   * To avoid the need for explicitly encoding the query use the
   * [queryParameters] optional named arguments when constructing a
   * [Uri].
   *
   * See http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2 for more
   * details.
   */
  static String encodeQueryComponent(String component,
                                     {Encoding encoding: UTF8}) {
    return _Uri._uriEncode(_Uri._unreservedTable, component, encoding, true);
  }

  /**
   * Decodes the percent-encoding in [encodedComponent].
   *
   * Note that decoding a URI component might change its meaning as
   * some of the decoded characters could be characters with are
   * delimiters for a given URI component type. Always split a URI
   * component using the delimiters for the component before decoding
   * the individual parts.
   *
   * For handling the [path] and [query] components consider using
   * [pathSegments] and [queryParameters] to get the separated and
   * decoded component.
   */
  static String decodeComponent(String encodedComponent) {
    return _Uri._uriDecode(encodedComponent, 0, encodedComponent.length,
                           UTF8, false);
  }

  /**
   * Decodes the percent-encoding in [encodedComponent], converting
   * pluses to spaces.
   *
   * It will create a byte-list of the decoded characters, and then use
   * [encoding] to decode the byte-list to a String. The default encoding is
   * UTF-8.
   */
  static String decodeQueryComponent(
      String encodedComponent,
      {Encoding encoding: UTF8}) {
    return _Uri._uriDecode(encodedComponent, 0, encodedComponent.length,
                           encoding, true);
  }

  /**
   * Encode the string [uri] using percent-encoding to make it
   * safe for literal use as a full URI.
   *
   * All characters except uppercase and lowercase letters, digits and
   * the characters `!#$&'()*+,-./:;=?@_~` are percent-encoded. This
   * is the set of characters specified in in ECMA-262 version 5.1 for
   * the encodeURI function .
   */
  static String encodeFull(String uri) {
    return _Uri._uriEncode(_Uri._encodeFullTable, uri, UTF8, false);
  }

  /**
   * Decodes the percent-encoding in [uri].
   *
   * Note that decoding a full URI might change its meaning as some of
   * the decoded characters could be reserved characters. In most
   * cases an encoded URI should be parsed into components using
   * [Uri.parse] before decoding the separate components.
   */
  static String decodeFull(String uri) {
    return _Uri._uriDecode(uri, 0, uri.length, UTF8, false);
  }

  /**
   * Returns the [query] split into a map according to the rules
   * specified for FORM post in the [HTML 4.01 specification section
   * 17.13.4](http://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4 "HTML 4.01 section 17.13.4").
   * Each key and value in the returned map has been decoded. If the [query]
   * is the empty string an empty map is returned.
   *
   * Keys in the query string that have no value are mapped to the
   * empty string.
   *
   * Each query component will be decoded using [encoding]. The default encoding
   * is UTF-8.
   */
  static Map<String, String> splitQueryString(String query,
                                              {Encoding encoding: UTF8}) {
    return query.split("&").fold({}, (map, element) {
      int index = element.indexOf("=");
      if (index == -1) {
        if (element != "") {
          map[decodeQueryComponent(element, encoding: encoding)] = "";
        }
      } else if (index != 0) {
        var key = element.substring(0, index);
        var value = element.substring(index + 1);
        map[decodeQueryComponent(key, encoding: encoding)] =
            decodeQueryComponent(value, encoding: encoding);
      }
      return map;
    });
  }


  /**
   * Parse the [host] as an IP version 4 (IPv4) address, returning the address
   * as a list of 4 bytes in network byte order (big endian).
   *
   * Throws a [FormatException] if [host] is not a valid IPv4 address
   * representation.
   */
  static List<int> parseIPv4Address(String host) =>
       _parseIPv4Address(host, 0, host.length);

  /// Implementation of [parseIPv4Address] that can work on a substring.
  static List<int> _parseIPv4Address(String host, int start, int end) {
    void error(String msg, int position) {
      throw new FormatException('Illegal IPv4 address, $msg', host, position);
    }

    var result = new Uint8List(4);
    int partIndex = 0;
    int partStart = start;
    for (int i = start; i < end; i++) {
      int char = host.codeUnitAt(i);
      if (char != _DOT) {
        if (char ^ 0x30 > 9) {
          // Fail on a non-digit character.
          error("invalid character", i);
        }
      } else {
        if (partIndex == 3) {
          error('IPv4 address should contain exactly 4 parts', i);
        }
        int part = int.parse(host.substring(partStart, i));
        if (part > 255) {
          error("each part must be in the range 0..255", partStart);
        }
        result[partIndex++] = part;
        partStart = i + 1;
      }
    }

    if (partIndex != 3) {
      error('IPv4 address should contain exactly 4 parts', end);
    }

    int part = int.parse(host.substring(partStart, end));
    if (part > 255) {
      error("each part must be in the range 0..255", partStart);
    }
    result[partIndex] = part;

    return result;
  }

  /**
   * Parse the [host] as an IP version 6 (IPv6) address, returning the address
   * as a list of 16 bytes in network byte order (big endian).
   *
   * Throws a [FormatException] if [host] is not a valid IPv6 address
   * representation.
   *
   * Acts on the substring from [start] to [end]. If [end] is omitted, it
   * defaults ot the end of the string.
   *
   * Some examples of IPv6 addresses:
   *  * ::1
   *  * FEDC:BA98:7654:3210:FEDC:BA98:7654:3210
   *  * 3ffe:2a00:100:7031::1
   *  * ::FFFF:129.144.52.38
   *  * 2010:836B:4179::836B:4179
   */
  static List<int> parseIPv6Address(String host, [int start = 0, int end]) {
    if (end == null) end = host.length;
    // An IPv6 address consists of exactly 8 parts of 1-4 hex digits, separated
    // by `:`'s, with the following exceptions:
    //
    //  - One (and only one) wildcard (`::`) may be present, representing a fill
    //    of 0's. The IPv6 `::` is thus 16 bytes of `0`.
    //  - The last two parts may be replaced by an IPv4 "dotted-quad" address.

    // Helper function for reporting a badly formatted IPv6 address.
    void error(String msg, [position]) {
      throw new FormatException('Illegal IPv6 address, $msg', host, position);
    }

    // Parse a hex block.
    int parseHex(int start, int end) {
      if (end - start > 4) {
        error('an IPv6 part can only contain a maximum of 4 hex digits', start);
      }
      int value = int.parse(host.substring(start, end), radix: 16);
      if (value < 0 || value > 0xFFFF) {
        error('each part must be in the range of `0x0..0xFFFF`', start);
      }
      return value;
    }

    if (host.length < 2) error('address is too short');
    List<int> parts = [];
    bool wildcardSeen = false;
    // Set if seeing a ".", suggesting that there is an IPv4 address.
    bool seenDot = false;
    int partStart = start;
    // Parse all parts, except a potential last one.
    for (int i = start; i < end; i++) {
      int char = host.codeUnitAt(i);
      if (char == _COLON) {
        if (i == start) {
          // If we see a `:` in the beginning, expect wildcard.
          i++;
          if (host.codeUnitAt(i) != _COLON) {
            error('invalid start colon.', i);
          }
          partStart = i;
        }
        if (i == partStart) {
          // Wildcard. We only allow one.
          if (wildcardSeen) {
            error('only one wildcard `::` is allowed', i);
          }
          wildcardSeen = true;
          parts.add(-1);
        } else {
          // Found a single colon. Parse [partStart..i] as a hex entry.
          parts.add(parseHex(partStart, i));
        }
        partStart = i + 1;
      } else if (char == _DOT) {
        seenDot = true;
      }
    }
    if (parts.length == 0) error('too few parts');
    bool atEnd = (partStart == end);
    bool isLastWildcard = (parts.last == -1);
    if (atEnd && !isLastWildcard) {
      error('expected a part after last `:`', end);
    }
    if (!atEnd) {
      if (!seenDot) {
        parts.add(parseHex(partStart, end));
      } else {
        List<int> last = _parseIPv4Address(host, partStart, end);
        parts.add(last[0] << 8 | last[1]);
        parts.add(last[2] << 8 | last[3]);
      }
    }
    if (wildcardSeen) {
      if (parts.length > 7) {
        error('an address with a wildcard must have less than 7 parts');
      }
    } else if (parts.length != 8) {
      error('an address without a wildcard must contain exactly 8 parts');
    }
    List<int> bytes = new Uint8List(16);
    for (int i = 0, index = 0; i < parts.length; i++) {
      int value = parts[i];
      if (value == -1) {
        int wildCardLength = 9 - parts.length;
        for (int j = 0; j < wildCardLength; j++) {
          bytes[index] = 0;
          bytes[index + 1] = 0;
          index += 2;
        }
      } else {
        bytes[index] = value >> 8;
        bytes[index + 1] = value & 0xff;
        index += 2;
      }
    }
    return bytes;
  }
}

class _Uri implements Uri {
  // We represent the missing scheme as an empty string.
  // A valid scheme cannot be empty.
  final String scheme;

  /**
   * The user-info part of the authority.
   *
   * Does not distinguish between an empty user-info and an absent one.
   * The value is always non-null.
   * Is considered absent if [_host] is `null`.
   */
  final String _userInfo;

  /**
   * The host name of the URI.
   *
   * Set to `null` if there is no authority in the URI.
   * The host name is the only mandatory part of an authority, so we use
   * it to mark whether an authority part was present or not.
   */
  final String _host;

  /**
   * The port number part of the authority.
   *
   * The port. Set to null if there is no port. Normalized to null if
   * the port is the default port for the scheme.
   */
  int _port;

  /**
   * The path of the URI.
   *
   * Always non-null.
   */
  String _path;

  // The query content, or null if there is no query.
  final String _query;

  // The fragment content, or null if there is no fragment.
  final String _fragment;

  /**
   * Cache the computed return value of [pathSegments].
   */
  List<String> _pathSegments;

  /**
   * Cache of the full normalized text representation of the URI.
   */
  String _text;

  /**
   * Cache of the hashCode of [_text].
   *
   * Is null until computed.
   */
  int _hashCodeCache;

  /**
   * Cache the computed return value of [queryParameters].
   */
  Map<String, String> _queryParameters;
  Map<String, List<String>> _queryParameterLists;

  /// Internal non-verifying constructor. Only call with validated arguments.
  _Uri._internal(this.scheme,
                 this._userInfo,
                 this._host,
                 this._port,
                 this._path,
                 this._query,
                 this._fragment);

  /// Create a [_Uri] from parts of [uri].
  ///
  /// The parameters specify the start/end of particular components of the URI.
  /// The [scheme] may contain a string representing a normalized scheme
  /// component if one has already been discovered.
  factory _Uri.notSimple(String uri, int start, int end, int schemeEnd,
                        int hostStart, int portStart, int pathStart,
                        int queryStart, int fragmentStart, String scheme) {
    if (scheme == null) {
      scheme = "";
      if (schemeEnd > start) {
        scheme = _makeScheme(uri, start, schemeEnd);
      } else if (schemeEnd == start) {
        _fail(uri, start, "Invalid empty scheme");
      }
    }
    String userInfo = "";
    String host;
    int port;
    if (hostStart > start) {
      int userInfoStart = schemeEnd + 3;
      if (userInfoStart < hostStart) {
        userInfo = _makeUserInfo(uri, userInfoStart, hostStart - 1);
      }
      host = _makeHost(uri, hostStart, portStart, false);
      if (portStart + 1 < pathStart) {
        // Should throw because invalid.
        port = int.parse(uri.substring(portStart + 1, pathStart), onError: (_) {
          throw new FormatException("Invalid port", uri, portStart + 1);
        });
        port = _makePort(port, scheme);
      }
    }
    String path = _makePath(uri, pathStart, queryStart, null,
                            scheme, host != null);
    String query;
    if (queryStart < fragmentStart) {
      query = _makeQuery(uri, queryStart + 1, fragmentStart, null);
    }
    String fragment;
    if (fragmentStart < end) {
      fragment = _makeFragment(uri, fragmentStart + 1, end);
    }
    return new _Uri._internal(scheme,
                              userInfo,
                              host,
                              port,
                              path,
                              query,
                              fragment);
  }

  /// Implementation of [Uri.Uri].
  factory _Uri({String scheme,
                String userInfo,
                String host,
                int port,
                String path,
                Iterable<String> pathSegments,
                String query,
                Map<String, dynamic/*String|Iterable<String>*/> queryParameters,
                String fragment}) {
    scheme = _makeScheme(scheme, 0, _stringOrNullLength(scheme));
    userInfo = _makeUserInfo(userInfo, 0, _stringOrNullLength(userInfo));
    host = _makeHost(host, 0, _stringOrNullLength(host), false);
    // Special case this constructor for backwards compatibility.
    if (query == "") query = null;
    query = _makeQuery(query, 0, _stringOrNullLength(query), queryParameters);
    fragment = _makeFragment(fragment, 0, _stringOrNullLength(fragment));
    port = _makePort(port, scheme);
    bool isFile = (scheme == "file");
    if (host == null &&
        (userInfo.isNotEmpty || port != null || isFile)) {
      host = "";
    }
    bool hasAuthority = (host != null);
    path = _makePath(path, 0, _stringOrNullLength(path), pathSegments,
                     scheme, hasAuthority);
    if (scheme.isEmpty && host == null && !path.startsWith('/')) {
      bool allowScheme = scheme.isNotEmpty || host != null;
      path = _normalizeRelativePath(path, allowScheme);
    } else {
      path = _removeDotSegments(path);
    }
    if (host == null && path.startsWith("//")) {
      host = "";
    }
    return new _Uri._internal(scheme, userInfo, host, port,
                              path, query, fragment);
  }

  /// Implementation of [Uri.http].
  factory _Uri.http(String authority,
                    String unencodedPath,
                    [Map<String, String> queryParameters]) {
    return _makeHttpUri("http", authority, unencodedPath, queryParameters);
  }

  /// Implementation of [Uri.https].
  factory _Uri.https(String authority,
                     String unencodedPath,
                     [Map<String, String> queryParameters]) {
    return _makeHttpUri("https", authority, unencodedPath, queryParameters);
  }

  String get authority {
    if (!hasAuthority) return "";
    var sb = new StringBuffer();
    _writeAuthority(sb);
    return sb.toString();
  }

  String get userInfo => _userInfo;

  String get host {
    if (_host == null) return "";
    if (_host.startsWith('[')) {
      return _host.substring(1, _host.length - 1);
    }
    return _host;
  }

  int get port {
    if (_port == null) return _defaultPort(scheme);
    return _port;
  }

  // The default port for the scheme of this Uri.
  static int _defaultPort(String scheme) {
    if (scheme == "http") return 80;
    if (scheme == "https") return 443;
    return 0;
  }

  String get path => _path;

  String get query => _query ?? "";

  String get fragment => _fragment ?? "";

  bool isScheme(String scheme) {
    String thisScheme = this.scheme;
    if (scheme == null) return thisScheme.isEmpty;
    if (scheme.length != thisScheme.length) return false;
    return _compareScheme(scheme, thisScheme);
  }

  /// Compares scheme characters in [scheme] and at the start of [uri].
  ///
  /// Returns `true` if [scheme] represents the same scheme as the start of
  /// [uri]. That means having the same characters, but possibly different case
  /// for letters.
  ///
  /// This function doesn't check that the characters are valid URI scheme
  /// characters. The [uri] is assumed to be valid, so if [scheme] matches
  /// it, it has to be valid too.
  ///
  /// The length should be tested before calling this function,
  /// so the scheme part of [uri] is known to have the same length as [scheme].
  static bool _compareScheme(String scheme, String uri) {
    for (int i = 0; i < scheme.length; i++) {
      int schemeChar = scheme.codeUnitAt(i);
      int uriChar = uri.codeUnitAt(i);
      int delta = schemeChar ^ uriChar;
      if (delta != 0) {
        if (delta == 0x20) {
          // Might be a case difference.
          int lowerChar = uriChar | delta;
          if (0x61 /*a*/ <= lowerChar && lowerChar <= 0x7a /*z*/) {
            continue;
          }
        }
        return false;
      }
    }
    return true;
  }

  // Report a parse failure.
  static void _fail(String uri, int index, String message) {
    throw new FormatException(message, uri, index);
  }

  static Uri _makeHttpUri(String scheme,
                          String authority,
                          String unencodedPath,
                          Map<String, String> queryParameters) {
    var userInfo = "";
    var host = null;
    var port = null;

    if (authority != null && authority.isNotEmpty) {
      var hostStart = 0;
      // Split off the user info.
      bool hasUserInfo = false;
      for (int i = 0; i < authority.length; i++) {
        const int atSign = 0x40;
        if (authority.codeUnitAt(i) == atSign) {
          hasUserInfo = true;
          userInfo = authority.substring(0, i);
          hostStart = i + 1;
          break;
        }
      }
      var hostEnd = hostStart;
      if (hostStart < authority.length &&
          authority.codeUnitAt(hostStart) == _LEFT_BRACKET) {
        // IPv6 host.
        for (; hostEnd < authority.length; hostEnd++) {
          if (authority.codeUnitAt(hostEnd) == _RIGHT_BRACKET) break;
        }
        if (hostEnd == authority.length) {
          throw new FormatException("Invalid IPv6 host entry.",
                                    authority, hostStart);
        }
        Uri.parseIPv6Address(authority, hostStart + 1, hostEnd);
        hostEnd++;  // Skip the closing bracket.
        if (hostEnd != authority.length &&
            authority.codeUnitAt(hostEnd) != _COLON) {
          throw new FormatException("Invalid end of authority",
                                    authority, hostEnd);
        }
      }
      // Split host and port.
      bool hasPort = false;
      for (; hostEnd < authority.length; hostEnd++) {
        if (authority.codeUnitAt(hostEnd) == _COLON) {
          var portString = authority.substring(hostEnd + 1);
          // We allow the empty port - falling back to initial value.
          if (portString.isNotEmpty) port = int.parse(portString);
          break;
        }
      }
      host = authority.substring(hostStart, hostEnd);
    }
    return new Uri(scheme: scheme,
                   userInfo: userInfo,
                   host: host,
                   port: port,
                   pathSegments: unencodedPath.split("/"),
                   queryParameters: queryParameters);
  }

  /// Implementation of [Uri.file].
  factory _Uri.file(String path, {bool windows}) {
    windows = (windows == null) ? _Uri._isWindows : windows;
    return windows ? _makeWindowsFileUrl(path, false)
                   : _makeFileUri(path, false);
  }

  /// Implementation of [Uri.directory].
  factory _Uri.directory(String path, {bool windows}) {
    windows = (windows == null) ? _Uri._isWindows : windows;
    return windows ? _makeWindowsFileUrl(path, true)
                   : _makeFileUri(path, true);
  }


  /// Used internally in path-related constructors.
  external static bool get _isWindows;

  static _checkNonWindowsPathReservedCharacters(List<String> segments,
                                                bool argumentError) {
    segments.forEach((segment) {
      if (segment.contains("/")) {
        if (argumentError) {
          throw new ArgumentError("Illegal path character $segment");
        } else {
          throw new UnsupportedError("Illegal path character $segment");
        }
      }
    });
  }

  static _checkWindowsPathReservedCharacters(List<String> segments,
                                             bool argumentError,
                                             [int firstSegment = 0]) {
    for (var segment in segments.skip(firstSegment)) {
      if (segment.contains(new RegExp(r'["*/:<>?\\|]'))) {
        if (argumentError) {
          throw new ArgumentError("Illegal character in path");
        } else {
          throw new UnsupportedError("Illegal character in path");
        }
      }
    }
  }

  static _checkWindowsDriveLetter(int charCode, bool argumentError) {
    if ((_UPPER_CASE_A <= charCode && charCode <= _UPPER_CASE_Z) ||
        (_LOWER_CASE_A <= charCode && charCode <= _LOWER_CASE_Z)) {
      return;
    }
    if (argumentError) {
      throw new ArgumentError("Illegal drive letter " +
                              new String.fromCharCode(charCode));
    } else {
      throw new UnsupportedError("Illegal drive letter " +
                              new String.fromCharCode(charCode));
    }
  }

  static _makeFileUri(String path, bool slashTerminated) {
    const String sep = "/";
    var segments = path.split(sep);
    if (slashTerminated &&
        segments.isNotEmpty &&
        segments.last.isNotEmpty) {
      segments.add("");  // Extra separator at end.
    }
    if (path.startsWith(sep)) {
      // Absolute file:// URI.
      return new Uri(scheme: "file", pathSegments: segments);
    } else {
      // Relative URI.
      return new Uri(pathSegments: segments);
    }
  }

  static _makeWindowsFileUrl(String path, bool slashTerminated) {
    if (path.startsWith(r"\\?\")) {
      if (path.startsWith(r"UNC\", 4)) {
        path = path.replaceRange(0, 7, r'\');
      } else {
        path = path.substring(4);
        if (path.length < 3 ||
            path.codeUnitAt(1) != _COLON ||
            path.codeUnitAt(2) != _BACKSLASH) {
          throw new ArgumentError(
              r"Windows paths with \\?\ prefix must be absolute");
        }
      }
    } else {
      path = path.replaceAll("/", r'\');
    }
    const String sep = r'\';
    if (path.length > 1 && path.codeUnitAt(1) == _COLON) {
      _checkWindowsDriveLetter(path.codeUnitAt(0), true);
      if (path.length == 2 || path.codeUnitAt(2) != _BACKSLASH) {
        throw new ArgumentError(
            "Windows paths with drive letter must be absolute");
      }
      // Absolute file://C:/ URI.
      var pathSegments = path.split(sep);
      if (slashTerminated &&
          pathSegments.last.isNotEmpty) {
        pathSegments.add("");  // Extra separator at end.
      }
      _checkWindowsPathReservedCharacters(pathSegments, true, 1);
      return new Uri(scheme: "file", pathSegments: pathSegments);
    }

    if (path.startsWith(sep)) {
      if (path.startsWith(sep, 1)) {
        // Absolute file:// URI with host.
        int pathStart = path.indexOf(r'\', 2);
        String hostPart =
            (pathStart < 0) ? path.substring(2) : path.substring(2, pathStart);
        String pathPart =
            (pathStart < 0) ? "" : path.substring(pathStart + 1);
        var pathSegments = pathPart.split(sep);
        _checkWindowsPathReservedCharacters(pathSegments, true);
        if (slashTerminated &&
            pathSegments.last.isNotEmpty) {
          pathSegments.add("");  // Extra separator at end.
        }
        return new Uri(
            scheme: "file", host: hostPart, pathSegments: pathSegments);
      } else {
        // Absolute file:// URI.
        var pathSegments = path.split(sep);
        if (slashTerminated &&
            pathSegments.last.isNotEmpty) {
          pathSegments.add("");  // Extra separator at end.
        }
        _checkWindowsPathReservedCharacters(pathSegments, true);
        return new Uri(scheme: "file", pathSegments: pathSegments);
      }
    } else {
      // Relative URI.
      var pathSegments = path.split(sep);
      _checkWindowsPathReservedCharacters(pathSegments, true);
      if (slashTerminated &&
          pathSegments.isNotEmpty &&
          pathSegments.last.isNotEmpty) {
        pathSegments.add("");  // Extra separator at end.
      }
      return new Uri(pathSegments: pathSegments);
    }
  }

  Uri replace({String scheme,
               String userInfo,
               String host,
               int port,
               String path,
               Iterable<String> pathSegments,
               String query,
               Map<String, dynamic/*String|Iterable<String>*/> queryParameters,
               String fragment}) {
    // Set to true if the scheme has (potentially) changed.
    // In that case, the default port may also have changed and we need
    // to check even the existing port.
    bool schemeChanged = false;
    if (scheme != null) {
      scheme = _makeScheme(scheme, 0, scheme.length);
      schemeChanged = (scheme != this.scheme);
    } else {
      scheme = this.scheme;
    }
    bool isFile = (scheme == "file");
    if (userInfo != null) {
      userInfo = _makeUserInfo(userInfo, 0, userInfo.length);
    } else {
      userInfo = this._userInfo;
    }
    if (port != null) {
      port = _makePort(port, scheme);
    } else {
      port = this._port;
      if (schemeChanged) {
        // The default port might have changed.
        port = _makePort(port, scheme);
      }
    }
    if (host != null) {
      host = _makeHost(host, 0, host.length, false);
    } else if (this.hasAuthority) {
      host = this._host;
    } else if (userInfo.isNotEmpty || port != null || isFile) {
      host = "";
    }

    bool hasAuthority = host != null;
    if (path != null || pathSegments != null) {
      path = _makePath(path, 0, _stringOrNullLength(path), pathSegments,
                       scheme, hasAuthority);
    } else {
      path = this._path;
      if ((isFile || (hasAuthority && !path.isEmpty)) &&
          !path.startsWith('/')) {
        path = "/" + path;
      }
    }

    if (query != null || queryParameters != null) {
      query = _makeQuery(query, 0, _stringOrNullLength(query), queryParameters);
    } else {
      query = this._query;
    }

    if (fragment != null) {
      fragment = _makeFragment(fragment, 0, fragment.length);
    } else {
      fragment = this._fragment;
    }

    return new _Uri._internal(
        scheme, userInfo, host, port, path, query, fragment);
  }

  Uri removeFragment() {
    if (!this.hasFragment) return this;
    return new _Uri._internal(scheme, _userInfo, _host, _port,
                             _path, _query, null);
  }

  List<String> get pathSegments {
    var result = _pathSegments;
    if (result != null) return result;

    var pathToSplit = path;
    if (pathToSplit.isNotEmpty && pathToSplit.codeUnitAt(0) == _SLASH) {
      pathToSplit = pathToSplit.substring(1);
    }
    result = (pathToSplit == "")
        ? const<String>[]
        : new List<String>.unmodifiable(
              pathToSplit.split("/").map(Uri.decodeComponent));
    _pathSegments = result;
    return result;
  }

  Map<String, String> get queryParameters {
    if (_queryParameters == null) {
      _queryParameters =
          new UnmodifiableMapView<String, String>(Uri.splitQueryString(query));
    }
    return _queryParameters;
  }

  Map<String, List<String>> get queryParametersAll {
    if (_queryParameterLists == null) {
      Map queryParameterLists = _splitQueryStringAll(query);
      for (var key in queryParameterLists.keys) {
        queryParameterLists[key] =
            new List<String>.unmodifiable(queryParameterLists[key]);
      }
      _queryParameterLists =
          new Map<String, List<String>>.unmodifiable(queryParameterLists);
    }
    return _queryParameterLists;
  }

  Uri normalizePath() {
    String path = _normalizePath(_path, scheme, hasAuthority);
    if (identical(path, _path)) return this;
    return this.replace(path: path);
  }

  static int _makePort(int port, String scheme) {
    // Perform scheme specific normalization.
    if (port != null && port == _defaultPort(scheme)) return null;
    return port;
  }

  /**
   * Check and normalize a host name.
   *
   * If the host name starts and ends with '[' and ']', it is considered an
   * IPv6 address. If [strictIPv6] is false, the address is also considered
   * an IPv6 address if it contains any ':' character.
   *
   * If it is not an IPv6 address, it is case- and escape-normalized.
   * This escapes all characters not valid in a reg-name,
   * and converts all non-escape upper-case letters to lower-case.
   */
  static String _makeHost(String host, int start, int end, bool strictIPv6) {
    // TODO(lrn): Should we normalize IPv6 addresses according to RFC 5952?
    if (host == null) return null;
    if (start == end) return "";
    // Host is an IPv6 address if it starts with '[' or contains a colon.
    if (host.codeUnitAt(start) == _LEFT_BRACKET) {
      if (host.codeUnitAt(end - 1) != _RIGHT_BRACKET) {
        _fail(host, start, 'Missing end `]` to match `[` in host');
      }
      Uri.parseIPv6Address(host, start + 1, end - 1);
      // RFC 5952 requires hex digits to be lower case.
      return host.substring(start, end).toLowerCase();
    }
    if (!strictIPv6) {
      // TODO(lrn): skip if too short to be a valid IPv6 address?
      for (int i = start; i < end; i++) {
        if (host.codeUnitAt(i) == _COLON) {
          Uri.parseIPv6Address(host, start, end);
          return '[$host]';
        }
      }
    }
    return _normalizeRegName(host, start, end);
  }

  static bool _isRegNameChar(int char) {
    return char < 127 && (_regNameTable[char >> 4] & (1 << (char & 0xf))) != 0;
  }

  /**
   * Validates and does case- and percent-encoding normalization.
   *
   * The [host] must be an RFC3986 "reg-name". It is converted
   * to lower case, and percent escapes are converted to either
   * lower case unreserved characters or upper case escapes.
   */
  static String _normalizeRegName(String host, int start, int end) {
    StringBuffer buffer;
    int sectionStart = start;
    int index = start;
    // Whether all characters between sectionStart and index are normalized,
    bool isNormalized = true;

    while (index < end) {
      int char = host.codeUnitAt(index);
      if (char == _PERCENT) {
        // The _regNameTable contains "%", so we check that first.
        String replacement = _normalizeEscape(host, index, true);
        if (replacement == null && isNormalized) {
          index += 3;
          continue;
        }
        if (buffer == null) buffer = new StringBuffer();
        String slice = host.substring(sectionStart, index);
        if (!isNormalized) slice = slice.toLowerCase();
        buffer.write(slice);
        int sourceLength = 3;
        if (replacement == null) {
          replacement = host.substring(index, index + 3);
        } else if (replacement == "%") {
          replacement = "%25";
          sourceLength = 1;
        }
        buffer.write(replacement);
        index += sourceLength;
        sectionStart = index;
        isNormalized = true;
      } else if (_isRegNameChar(char)) {
        if (isNormalized && _UPPER_CASE_A <= char && _UPPER_CASE_Z >= char) {
          // Put initial slice in buffer and continue in non-normalized mode
          if (buffer == null) buffer = new StringBuffer();
          if (sectionStart < index) {
            buffer.write(host.substring(sectionStart, index));
            sectionStart = index;
          }
          isNormalized = false;
        }
        index++;
      } else if (_isGeneralDelimiter(char)) {
        _fail(host, index, "Invalid character");
      } else {
        int sourceLength = 1;
        if ((char & 0xFC00) == 0xD800 && (index + 1) < end) {
          int tail = host.codeUnitAt(index + 1);
          if ((tail & 0xFC00) == 0xDC00) {
            char = 0x10000 | ((char & 0x3ff) << 10) | (tail & 0x3ff);
            sourceLength = 2;
          }
        }
        if (buffer == null) buffer = new StringBuffer();
        String slice = host.substring(sectionStart, index);
        if (!isNormalized) slice = slice.toLowerCase();
        buffer.write(slice);
        buffer.write(_escapeChar(char));
        index += sourceLength;
        sectionStart = index;
      }
    }
    if (buffer == null) return host.substring(start, end);
    if (sectionStart < end) {
      String slice = host.substring(sectionStart, end);
      if (!isNormalized) slice = slice.toLowerCase();
      buffer.write(slice);
    }
    return buffer.toString();
  }

  /**
   * Validates scheme characters and does case-normalization.
   *
   * Schemes are converted to lower case. They cannot contain escapes.
   */
  static String _makeScheme(String scheme, int start, int end) {
    if (start == end) return "";
    final int firstCodeUnit = scheme.codeUnitAt(start);
    if (!_isAlphabeticCharacter(firstCodeUnit)) {
      _fail(scheme, start, "Scheme not starting with alphabetic character");
    }
    bool containsUpperCase = false;
    for (int i = start; i < end; i++) {
      final int codeUnit = scheme.codeUnitAt(i);
      if (!_isSchemeCharacter(codeUnit)) {
        _fail(scheme, i, "Illegal scheme character");
      }
      if (_UPPER_CASE_A <= codeUnit && codeUnit <= _UPPER_CASE_Z) {
        containsUpperCase = true;
      }
    }
    scheme = scheme.substring(start, end);
    if (containsUpperCase) scheme = scheme.toLowerCase();
    return _canonicalizeScheme(scheme);
  }

  // Canonicalize a few often-used scheme strings.
  //
  // This improves memory usage and makes comparison faster.
  static String _canonicalizeScheme(String scheme) {
    if (scheme == "http") return "http";
    if (scheme == "file") return "file";
    if (scheme == "https") return "https";
    if (scheme == "package") return "package";
    return scheme;
  }

  static String _makeUserInfo(String userInfo, int start, int end) {
    if (userInfo == null) return "";
    return _normalize(userInfo, start, end, _userinfoTable);
  }

  static String _makePath(String path, int start, int end,
                          Iterable<String> pathSegments,
                          String scheme,
                          bool hasAuthority) {
    bool isFile = (scheme == "file");
    bool ensureLeadingSlash = isFile || hasAuthority;
    if (path == null && pathSegments == null) return isFile ? "/" : "";
    if (path != null && pathSegments != null) {
      throw new ArgumentError('Both path and pathSegments specified');
    }
    var result;
    if (path != null) {
      result = _normalize(path, start, end, _pathCharOrSlashTable);
    } else {
      result = pathSegments.map((s) =>
          _uriEncode(_pathCharTable, s, UTF8, false)).join("/");
    }
    if (result.isEmpty) {
      if (isFile) return "/";
    } else if (ensureLeadingSlash && !result.startsWith('/')) {
      result = "/" + result;
    }
    result = _normalizePath(result, scheme, hasAuthority);
    return result;
  }

  /// Performs path normalization (remove dot segments) on a path.
  ///
  /// If the URI has neither scheme nor authority, it's considered a
  /// "pure path" and normalization won't remove leading ".." segments.
  /// Otherwise it follows the RFC 3986 "remove dot segments" algorithm.
  static String _normalizePath(String path, String scheme, bool hasAuthority) {
    if (scheme.isEmpty && !hasAuthority && !path.startsWith('/')) {
      return _normalizeRelativePath(path, scheme.isNotEmpty || hasAuthority);
    }
    return _removeDotSegments(path);
  }

  static String _makeQuery(
      String query, int start, int end,
      Map<String, dynamic/*String|Iterable<String>*/> queryParameters) {
    if (query != null) {
      if (queryParameters != null) {
        throw new ArgumentError('Both query and queryParameters specified');
      }
      return _normalize(query, start, end, _queryCharTable);
    }
    if (queryParameters == null) return null;

    var result = new StringBuffer();
    var separator = "";

    void writeParameter(String key, String value) {
      result.write(separator);
      separator = "&";
      result.write(Uri.encodeQueryComponent(key));
      if (value != null && value.isNotEmpty) {
        result.write("=");
        result.write(Uri.encodeQueryComponent(value));
      }
    }

    queryParameters.forEach((key, value) {
      if (value == null || value is String) {
        writeParameter(key, value);
      } else {
        Iterable values = value;
        for (String value in values) {
          writeParameter(key, value);
        }
      }
    });
    return result.toString();
  }

  static String _makeFragment(String fragment, int start, int end) {
    if (fragment == null) return null;
    return _normalize(fragment, start, end, _queryCharTable);
  }

  /**
   * Performs RFC 3986 Percent-Encoding Normalization.
   *
   * Returns a replacement string that should be replace the original escape.
   * Returns null if no replacement is necessary because the escape is
   * not for an unreserved character and is already non-lower-case.
   *
   * Returns "%" if the escape is invalid (not two valid hex digits following
   * the percent sign). The calling code should replace the percent
   * sign with "%25", but leave the following two characters unmodified.
   *
   * If [lowerCase] is true, a single character returned is always lower case,
   */
  static String _normalizeEscape(String source, int index, bool lowerCase) {
    assert(source.codeUnitAt(index) == _PERCENT);
    if (index + 2 >= source.length) {
      return "%";  // Marks the escape as invalid.
    }
    int firstDigit = source.codeUnitAt(index + 1);
    int secondDigit = source.codeUnitAt(index + 2);
    int firstDigitValue = _parseHexDigit(firstDigit);
    int secondDigitValue = _parseHexDigit(secondDigit);
    if (firstDigitValue < 0 || secondDigitValue < 0) {
      return "%";  // Marks the escape as invalid.
    }
    int value = firstDigitValue * 16 + secondDigitValue;
    if (_isUnreservedChar(value)) {
      if (lowerCase && _UPPER_CASE_A <= value && _UPPER_CASE_Z >= value) {
        value |= 0x20;
      }
      return new String.fromCharCode(value);
    }
    if (firstDigit >= _LOWER_CASE_A || secondDigit >= _LOWER_CASE_A) {
      // Either digit is lower case.
      return source.substring(index, index + 3).toUpperCase();
    }
    // Escape is retained, and is already non-lower case, so return null to
    // represent "no replacement necessary".
    return null;
  }

  // Converts a UTF-16 code-unit to its value as a hex digit.
  // Returns -1 for non-hex digits.
  static int _parseHexDigit(int char) {
    const int zeroDigit = 0x30;
    int digit = char ^ zeroDigit;
    if (digit <= 9) return digit;
    int lowerCase = char | 0x20;
    if (_LOWER_CASE_A <= lowerCase && lowerCase <= _LOWER_CASE_F) {
      return lowerCase - (_LOWER_CASE_A - 10);
    }
    return -1;
  }

  static String _escapeChar(int char) {
    assert(char <= 0x10ffff);  // It's a valid unicode code point.
    List<int> codeUnits;
    if (char < 0x80) {
      // ASCII, a single percent encoded sequence.
      codeUnits = new List(3);
      codeUnits[0] = _PERCENT;
      codeUnits[1] = _hexDigits.codeUnitAt(char >> 4);
      codeUnits[2] = _hexDigits.codeUnitAt(char & 0xf);
    } else {
      // Do UTF-8 encoding of character, then percent encode bytes.
      int flag = 0xc0;  // The high-bit markers on the first byte of UTF-8.
      int encodedBytes = 2;
      if (char > 0x7ff) {
        flag = 0xe0;
        encodedBytes = 3;
        if (char > 0xffff) {
          encodedBytes = 4;
          flag = 0xf0;
        }
      }
      codeUnits = new List(3 * encodedBytes);
      int index = 0;
      while (--encodedBytes >= 0) {
        int byte = ((char >> (6 * encodedBytes)) & 0x3f) | flag;
        codeUnits[index] = _PERCENT;
        codeUnits[index + 1] = _hexDigits.codeUnitAt(byte >> 4);
        codeUnits[index + 2] = _hexDigits.codeUnitAt(byte & 0xf);
        index += 3;
        flag = 0x80;  // Following bytes have only high bit set.
      }
    }
    return new String.fromCharCodes(codeUnits);
  }

  /**
   * Runs through component checking that each character is valid and
   * normalize percent escapes.
   *
   * Uses [charTable] to check if a non-`%` character is allowed.
   * Each `%` character must be followed by two hex digits.
   * If the hex-digits are lower case letters, they are converted to
   * upper case.
   */
  static String _normalize(String component, int start, int end,
                           List<int> charTable) {
    StringBuffer buffer;
    int sectionStart = start;
    int index = start;
    // Loop while characters are valid and escapes correct and upper-case.
    while (index < end) {
      int char = component.codeUnitAt(index);
      if (char < 127 && (charTable[char >> 4] & (1 << (char & 0x0f))) != 0) {
        index++;
      } else {
        String replacement;
        int sourceLength;
        if (char == _PERCENT) {
          replacement = _normalizeEscape(component, index, false);
          // Returns null if we should keep the existing escape.
          if (replacement == null) {
            index += 3;
            continue;
          }
          // Returns "%" if we should escape the existing percent.
          if ("%" == replacement) {
            replacement = "%25";
            sourceLength = 1;
          } else {
            sourceLength = 3;
          }
        } else if (_isGeneralDelimiter(char)) {
          _fail(component, index, "Invalid character");
        } else {
          sourceLength = 1;
          if ((char & 0xFC00) == 0xD800) {
            // Possible lead surrogate.
            if (index + 1 < end) {
              int tail = component.codeUnitAt(index + 1);
              if ((tail & 0xFC00) == 0xDC00) {
                // Tail surrogate.
                sourceLength = 2;
                char = 0x10000 | ((char & 0x3ff) << 10) | (tail & 0x3ff);
              }
            }
          }
          replacement = _escapeChar(char);
        }
        if (buffer == null) buffer = new StringBuffer();
        buffer.write(component.substring(sectionStart, index));
        buffer.write(replacement);
        index += sourceLength;
        sectionStart = index;
      }
    }
    if (buffer == null) {
      // Makes no copy if start == 0 and end == component.length.
      return component.substring(start, end);
    }
    if (sectionStart < end) {
      buffer.write(component.substring(sectionStart, end));
    }
    return buffer.toString();
  }

  static bool _isSchemeCharacter(int ch) {
    return ch < 128 && ((_schemeTable[ch >> 4] & (1 << (ch & 0x0f))) != 0);
  }

  static bool _isGeneralDelimiter(int ch) {
    return ch <= _RIGHT_BRACKET &&
        ((_genDelimitersTable[ch >> 4] & (1 << (ch & 0x0f))) != 0);
  }

  /**
   * Returns whether the URI is absolute.
   */
  bool get isAbsolute => scheme != "" && fragment == "";

  String _mergePaths(String base, String reference) {
    // Optimize for the case: absolute base, reference beginning with "../".
    int backCount = 0;
    int refStart = 0;
    // Count number of "../" at beginning of reference.
    while (reference.startsWith("../", refStart)) {
      refStart += 3;
      backCount++;
    }

    // Drop last segment - everything after last '/' of base.
    int baseEnd = base.lastIndexOf('/');
    // Drop extra segments for each leading "../" of reference.
    while (baseEnd > 0 && backCount > 0) {
      int newEnd = base.lastIndexOf('/', baseEnd - 1);
      if (newEnd < 0) {
        break;
      }
      int delta = baseEnd - newEnd;
      // If we see a "." or ".." segment in base, stop here and let
      // _removeDotSegments handle it.
      if ((delta == 2 || delta == 3) &&
          base.codeUnitAt(newEnd + 1) == _DOT &&
          (delta == 2 || base.codeUnitAt(newEnd + 2) == _DOT)) {
        break;
      }
      baseEnd = newEnd;
      backCount--;
    }
    return base.replaceRange(baseEnd + 1, null,
                             reference.substring(refStart - 3 * backCount));
  }

  /// Make a guess at whether a path contains a `..` or `.` segment.
  ///
  /// This is a primitive test that can cause false positives.
  /// It's only used to avoid a more expensive operation in the case where
  /// it's not necessary.
  static bool _mayContainDotSegments(String path) {
    if (path.startsWith('.')) return true;
    int index = path.indexOf("/.");
    return index != -1;
  }

  /// Removes '.' and '..' segments from a path.
  ///
  /// Follows the RFC 2986 "remove dot segments" algorithm.
  /// This algorithm is only used on paths of URIs with a scheme,
  /// and it treats the path as if it is absolute (leading '..' are removed).
  static String _removeDotSegments(String path) {
    if (!_mayContainDotSegments(path)) return path;
    assert(path.isNotEmpty);  // An empty path would not have dot segments.
    List<String> output = [];
    bool appendSlash = false;
    for (String segment in path.split("/")) {
      appendSlash = false;
      if (segment == "..") {
        if (output.isNotEmpty) {
          output.removeLast();
          if (output.isEmpty) {
            output.add("");
          }
        }
        appendSlash = true;
      } else if ("." == segment) {
        appendSlash = true;
      } else {
        output.add(segment);
      }
    }
    if (appendSlash) output.add("");
    return output.join("/");
  }

  /// Removes all `.` segments and any non-leading `..` segments.
  ///
  /// If the path starts with something that looks like a scheme,
  /// and [allowScheme] is false, the colon is escaped.
  ///
  /// Removing the ".." from a "bar/foo/.." sequence results in "bar/"
  /// (trailing "/"). If the entire path is removed (because it contains as
  /// many ".." segments as real segments), the result is "./".
  /// This is different from an empty string, which represents "no path",
  /// when you resolve it against a base URI with a path with a non-empty
  /// final segment.
  static String _normalizeRelativePath(String path, bool allowScheme) {
    assert(!path.startsWith('/'));  // Only get called for relative paths.
    if (!_mayContainDotSegments(path)) {
      if (!allowScheme) path = _escapeScheme(path);
      return path;
    }
    assert(path.isNotEmpty);  // An empty path would not have dot segments.
    List<String> output = [];
    bool appendSlash = false;
    for (String segment in path.split("/")) {
      appendSlash = false;
      if (".." == segment) {
        if (!output.isEmpty && output.last != "..") {
          output.removeLast();
          appendSlash = true;
        } else {
          output.add("..");
        }
      } else if ("." == segment) {
        appendSlash = true;
      } else {
        output.add(segment);
      }
    }
    if (output.isEmpty || (output.length == 1 && output[0].isEmpty)) {
      return "./";
    }
    if (appendSlash || output.last == '..') output.add("");
    if (!allowScheme) output[0] = _escapeScheme(output[0]);
    return output.join("/");
  }

  /// If [path] starts with a valid scheme, escape the percent.
  static String _escapeScheme(String path) {
    if (path.length >= 2 && _isAlphabeticCharacter(path.codeUnitAt(0))) {
      for (int i = 1; i < path.length; i++) {
        int char = path.codeUnitAt(i);
        if (char == _COLON) {
          return "${path.substring(0, i)}%3A${path.substring(i + 1)}";
        }
        if (char > 127 ||
            ((_schemeTable[char >> 4] & (1 << (char & 0x0f))) == 0)) {
          break;
        }
      }
    }
    return path;
  }

  Uri resolve(String reference) {
    return resolveUri(Uri.parse(reference));
  }

  Uri resolveUri(Uri reference) {
    // From RFC 3986.
    String targetScheme;
    String targetUserInfo = "";
    String targetHost;
    int targetPort;
    String targetPath;
    String targetQuery;
    if (reference.scheme.isNotEmpty) {
      targetScheme = reference.scheme;
      if (reference.hasAuthority) {
        targetUserInfo = reference.userInfo;
        targetHost = reference.host;
        targetPort = reference.hasPort ? reference.port : null;
      }
      targetPath = _removeDotSegments(reference.path);
      if (reference.hasQuery) {
        targetQuery = reference.query;
      }
    } else {
      targetScheme = this.scheme;
      if (reference.hasAuthority) {
        targetUserInfo = reference.userInfo;
        targetHost = reference.host;
        targetPort = _makePort(reference.hasPort ? reference.port : null,
                               targetScheme);
        targetPath = _removeDotSegments(reference.path);
        if (reference.hasQuery) targetQuery = reference.query;
      } else {
        targetUserInfo = this._userInfo;
        targetHost = this._host;
        targetPort = this._port;
        if (reference.path == "") {
          targetPath = this._path;
          if (reference.hasQuery) {
            targetQuery = reference.query;
          } else {
            targetQuery = this._query;
          }
        } else {
          if (reference.hasAbsolutePath) {
            targetPath = _removeDotSegments(reference.path);
          } else {
            // This is the RFC 3986 behavior for merging.
            if (this.hasEmptyPath) {
              if (!this.hasAuthority) {
                if (!this.hasScheme) {
                  // Keep the path relative if no scheme or authority.
                  targetPath = reference.path;
                } else {
                  // Remove leading dot-segments if the path is put
                  // beneath a scheme.
                  targetPath = _removeDotSegments(reference.path);
                }
              } else {
                // RFC algorithm for base with authority and empty path.
                targetPath = _removeDotSegments("/" + reference.path);
              }
            } else {
              var mergedPath = _mergePaths(this._path, reference.path);
              if (this.hasScheme || this.hasAuthority || this.hasAbsolutePath) {
                targetPath = _removeDotSegments(mergedPath);
              } else {
                // Non-RFC 3986 behavior.
                // If both base and reference are relative paths,
                // allow the merged path to start with "..".
                // The RFC only specifies the case where the base has a scheme.
                targetPath = _normalizeRelativePath(mergedPath,
                  this.hasScheme || this.hasAuthority);
              }
            }
          }
          if (reference.hasQuery) targetQuery = reference.query;
        }
      }
    }
    String fragment = reference.hasFragment ? reference.fragment : null;
    return new _Uri._internal(targetScheme,
                              targetUserInfo,
                              targetHost,
                              targetPort,
                              targetPath,
                              targetQuery,
                              fragment);
  }

  bool get hasScheme => scheme.isNotEmpty;

  bool get hasAuthority => _host != null;

  bool get hasPort => _port != null;

  bool get hasQuery => _query != null;

  bool get hasFragment => _fragment != null;

  bool get hasEmptyPath => _path.isEmpty;

  bool get hasAbsolutePath => _path.startsWith('/');

  String get origin {
    if (scheme == "") {
      throw new StateError("Cannot use origin without a scheme: $this");
    }
    if (scheme != "http" && scheme != "https") {
      throw new StateError(
        "Origin is only applicable schemes http and https: $this");
    }
    if (_host == null || _host == "") {
      throw new StateError(
          "A $scheme: URI should have a non-empty host name: $this");
    }
    if (_port == null) return "$scheme://$_host";
    return "$scheme://$_host:$_port";
  }

  String toFilePath({bool windows}) {
    if (scheme != "" && scheme != "file") {
      throw new UnsupportedError(
          "Cannot extract a file path from a $scheme URI");
    }
    if (query != "") {
      throw new UnsupportedError(
          "Cannot extract a file path from a URI with a query component");
    }
    if (fragment != "") {
      throw new UnsupportedError(
          "Cannot extract a file path from a URI with a fragment component");
    }
    if (windows == null) windows = _isWindows;
    return windows ? _toWindowsFilePath(this) : _toFilePath();
  }

  String _toFilePath() {
    if (hasAuthority && host != "") {
      throw new UnsupportedError(
          "Cannot extract a non-Windows file path from a file URI "
          "with an authority");
    }
    // Use path segments to have any escapes unescaped.
    var pathSegments = this.pathSegments;
    _checkNonWindowsPathReservedCharacters(pathSegments, false);
    var result = new StringBuffer();
    if (hasAbsolutePath) result.write("/");
    result.writeAll(pathSegments, "/");
    return result.toString();
  }

  static String _toWindowsFilePath(Uri uri) {
    bool hasDriveLetter = false;
    var segments = uri.pathSegments;
    if (segments.length > 0 &&
        segments[0].length == 2 &&
        segments[0].codeUnitAt(1) == _COLON) {
      _checkWindowsDriveLetter(segments[0].codeUnitAt(0), false);
      _checkWindowsPathReservedCharacters(segments, false, 1);
      hasDriveLetter = true;
    } else {
      _checkWindowsPathReservedCharacters(segments, false, 0);
    }
    var result = new StringBuffer();
    if (uri.hasAbsolutePath && !hasDriveLetter) result.write(r"\");
    if (uri.hasAuthority) {
      var host = uri.host;
      if (host.isNotEmpty) {
        result.write(r"\");
        result.write(host);
        result.write(r"\");
      }
    }
    result.writeAll(segments, r"\");
    if (hasDriveLetter && segments.length == 1) result.write(r"\");
    return result.toString();
  }

  bool get _isPathAbsolute {
    return _path != null && _path.startsWith('/');
  }

  void _writeAuthority(StringSink ss) {
    if (_userInfo.isNotEmpty) {
      ss.write(_userInfo);
      ss.write("@");
    }
    if (_host != null) ss.write(_host);
    if (_port != null) {
      ss.write(":");
      ss.write(_port);
    }
  }

  /**
   * Access the structure of a `data:` URI.
   *
   * Returns a [UriData] object for `data:` URIs and `null` for all other
   * URIs.
   * The [UriData] object can be used to access the media type and data
   * of a `data:` URI.
   */
  UriData get data => (scheme == "data") ? new UriData.fromUri(this) : null;

  String toString() {
    return _text ??= _initializeText();
  }

  String _initializeText() {
    assert(_text == null);
    StringBuffer sb = new StringBuffer();
    if (scheme.isNotEmpty) sb..write(scheme)..write(":");
    if (hasAuthority || (scheme == "file")) {
      // File URIS always have the authority, even if it is empty.
      // The empty URI means "localhost".
      sb.write("//");
      _writeAuthority(sb);
    }
    sb.write(path);
    if (_query != null) sb..write("?")..write(_query);
    if (_fragment != null) sb..write("#")..write(_fragment);
    return sb.toString();
  }

  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is Uri) {
      Uri uri = other;
      return scheme       == uri.scheme       &&
             hasAuthority == uri.hasAuthority &&
             userInfo     == uri.userInfo     &&
             host         == uri.host         &&
             port         == uri.port         &&
             path         == uri.path         &&
             hasQuery     == uri.hasQuery     &&
             query        == uri.query        &&
             hasFragment  == uri.hasFragment  &&
             fragment     == uri.fragment;
    }
    return false;
  }

  int get hashCode {
    return _hashCodeCache ??= toString().hashCode;
  }

  static List _createList() => [];

  static Map _splitQueryStringAll(
      String query, {Encoding encoding: UTF8}) {
    Map result = {};
    int i = 0;
    int start = 0;
    int equalsIndex = -1;

    void parsePair(int start, int equalsIndex, int end) {
      String key;
      String value;
      if (start == end) return;
      if (equalsIndex < 0) {
        key =  _uriDecode(query, start, end, encoding, true);
        value = "";
      } else {
        key = _uriDecode(query, start, equalsIndex, encoding, true);
        value = _uriDecode(query, equalsIndex + 1, end, encoding, true);
      }
      result.putIfAbsent(key, _createList).add(value);
    }

    const int _equals = 0x3d;
    const int _ampersand = 0x26;
    while (i < query.length) {
      int char = query.codeUnitAt(i);
      if (char == _equals) {
        if (equalsIndex < 0) equalsIndex = i;
      } else if (char == _ampersand) {
        parsePair(start, equalsIndex, i);
        start = i + 1;
        equalsIndex = -1;
      }
      i++;
    }
    parsePair(start, equalsIndex, i);
    return result;
  }

  external static String _uriEncode(List<int> canonicalTable,
                                    String text,
                                    Encoding encoding,
                                    bool spaceToPlus);

  /**
   * Convert a byte (2 character hex sequence) in string [s] starting
   * at position [pos] to its ordinal value
   */
  static int _hexCharPairToByte(String s, int pos) {
    int byte = 0;
    for (int i = 0; i < 2; i++) {
      var charCode = s.codeUnitAt(pos + i);
      if (0x30 <= charCode && charCode <= 0x39) {
        byte = byte * 16 + charCode - 0x30;
      } else {
        // Check ranges A-F (0x41-0x46) and a-f (0x61-0x66).
        charCode |= 0x20;
        if (0x61 <= charCode && charCode <= 0x66) {
          byte = byte * 16 + charCode - 0x57;
        } else {
          throw new ArgumentError("Invalid URL encoding");
        }
      }
    }
    return byte;
  }

  /**
   * Uri-decode a percent-encoded string.
   *
   * It unescapes the string [text] and returns the unescaped string.
   *
   * This function is similar to the JavaScript-function `decodeURI`.
   *
   * If [plusToSpace] is `true`, plus characters will be converted to spaces.
   *
   * The decoder will create a byte-list of the percent-encoded parts, and then
   * decode the byte-list using [encoding]. The default encodings UTF-8.
   */
  static String _uriDecode(String text,
                           int start,
                           int end,
                           Encoding encoding,
                           bool plusToSpace) {
    assert(0 <= start);
    assert(start <= end);
    assert(end <= text.length);
    assert(encoding != null);
    // First check whether there is any characters which need special handling.
    bool simple = true;
    for (int i = start; i < end; i++) {
      var codeUnit = text.codeUnitAt(i);
      if (codeUnit > 127 ||
          codeUnit == _PERCENT ||
          (plusToSpace && codeUnit == _PLUS)) {
        simple = false;
        break;
      }
    }
    List<int> bytes;
    if (simple) {
      if (UTF8 == encoding || LATIN1 == encoding || ASCII == encoding) {
        return text.substring(start, end);
      } else {
        bytes = text.substring(start, end).codeUnits;
      }
    } else {
      bytes = new List();
      for (int i = start; i < end; i++) {
        var codeUnit = text.codeUnitAt(i);
        if (codeUnit > 127) {
          throw new ArgumentError("Illegal percent encoding in URI");
        }
        if (codeUnit == _PERCENT) {
          if (i + 3 > text.length) {
            throw new ArgumentError('Truncated URI');
          }
          bytes.add(_hexCharPairToByte(text, i + 1));
          i += 2;
        } else if (plusToSpace && codeUnit == _PLUS) {
          bytes.add(_SPACE);
        } else {
          bytes.add(codeUnit);
        }
      }
    }
    return encoding.decode(bytes);
  }

  static bool _isAlphabeticCharacter(int codeUnit) {
    var lowerCase = codeUnit | 0x20;
    return (_LOWER_CASE_A <= lowerCase && lowerCase <= _LOWER_CASE_Z);
  }

  static bool _isUnreservedChar(int char) {
    return char < 127 &&
           ((_unreservedTable[char >> 4] & (1 << (char & 0x0f))) != 0);
  }

  // Tables of char-codes organized as a bit vector of 128 bits where
  // each bit indicate whether a character code on the 0-127 needs to
  // be escaped or not.

  // The unreserved characters of RFC 3986.
  static const _unreservedTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //                           -.
      0x6000,   // 0x20 - 0x2f  0000000000000110
                //              0123456789
      0x03ff,   // 0x30 - 0x3f  1111111111000000
                //               ABCDEFGHIJKLMNO
      0xfffe,   // 0x40 - 0x4f  0111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // The unreserved characters of RFC 2396.
  static const _unreserved2396Table = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !     '()*  -.
      0x6782,   // 0x20 - 0x2f  0100000111100110
                //              0123456789
      0x03ff,   // 0x30 - 0x3f  1111111111000000
                //               ABCDEFGHIJKLMNO
      0xfffe,   // 0x40 - 0x4f  0111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Table of reserved characters specified by ECMAScript 5.
  static const _encodeFullTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               ! #$ &'()*+,-./
      0xffda,   // 0x20 - 0x2f  0101101111111111
                //              0123456789:; = ?
      0xafff,   // 0x30 - 0x3f  1111111111110101
                //              @ABCDEFGHIJKLMNO
      0xffff,   // 0x40 - 0x4f  1111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in the scheme.
  static const _schemeTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //                         + -.
      0x6800,   // 0x20 - 0x2f  0000000000010110
                //              0123456789
      0x03ff,   // 0x30 - 0x3f  1111111111000000
                //               ABCDEFGHIJKLMNO
      0xfffe,   // 0x40 - 0x4f  0111111111111111
                //              PQRSTUVWXYZ
      0x07ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz
      0x07ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in scheme except for upper case letters.
  static const _schemeLowerTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //                         + -.
      0x6800,   // 0x20 - 0x2f  0000000000010110
                //              0123456789
      0x03ff,   // 0x30 - 0x3f  1111111111000000
                //
      0x0000,   // 0x40 - 0x4f  0111111111111111
                //
      0x0000,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz
      0x07ff];  // 0x70 - 0x7f  1111111111100010

  // Sub delimiter characters combined with unreserved as of 3986.
  // sub-delims  = "!" / "$" / "&" / "'" / "(" / ")"
  //             / "*" / "+" / "," / ";" / "="
  // RFC 3986 section 2.3.
  // unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
  static const _subDelimitersTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-.
      0x7fd2,   // 0x20 - 0x2f  0100101111111110
                //              0123456789 ; =
      0x2bff,   // 0x30 - 0x3f  1111111111010100
                //               ABCDEFGHIJKLMNO
      0xfffe,   // 0x40 - 0x4f  0111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // General delimiter characters, RFC 3986 section 2.2.
  // gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
  //
  static const _genDelimitersTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //                 #           /
      0x8008,   // 0x20 - 0x2f  0001000000000001
                //                        :    ?
      0x8400,   // 0x30 - 0x3f  0000000000100001
                //              @
      0x0001,   // 0x40 - 0x4f  1000000000000000
                //                         [ ]
      0x2800,   // 0x50 - 0x5f  0000000000010100
                //
      0x0000,   // 0x60 - 0x6f  0000000000000000
                //
      0x0000];  // 0x70 - 0x7f  0000000000000000

  // Characters allowed in the userinfo as of RFC 3986.
  // RFC 3986 Apendix A
  // userinfo = *( unreserved / pct-encoded / sub-delims / ':')
  static const _userinfoTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-.
      0x7fd2,   // 0x20 - 0x2f  0100101111111110
                //              0123456789:; =
      0x2fff,   // 0x30 - 0x3f  1111111111110100
                //               ABCDEFGHIJKLMNO
      0xfffe,   // 0x40 - 0x4f  0111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in the reg-name as of RFC 3986.
  // RFC 3986 Apendix A
  // reg-name = *( unreserved / pct-encoded / sub-delims )
  static const _regNameTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $%&'()*+,-.
      0x7ff2,   // 0x20 - 0x2f  0100111111111110
                //              0123456789 ; =
      0x2bff,   // 0x30 - 0x3f  1111111111010100
                //               ABCDEFGHIJKLMNO
      0xfffe,   // 0x40 - 0x4f  0111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in the path as of RFC 3986.
  // RFC 3986 section 3.3.
  // pchar = unreserved / pct-encoded / sub-delims / ":" / "@"
  static const _pathCharTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-.
      0x7fd2,   // 0x20 - 0x2f  0100101111111110
                //              0123456789:; =
      0x2fff,   // 0x30 - 0x3f  1111111111110100
                //              @ABCDEFGHIJKLMNO
      0xffff,   // 0x40 - 0x4f  1111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in the path as of RFC 3986.
  // RFC 3986 section 3.3 *and* slash.
  static const _pathCharOrSlashTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-./
      0xffd2,   // 0x20 - 0x2f  0100101111111111
                //              0123456789:; =
      0x2fff,   // 0x30 - 0x3f  1111111111110100
                //              @ABCDEFGHIJKLMNO
      0xffff,   // 0x40 - 0x4f  1111111111111111

                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

  // Characters allowed in the query as of RFC 3986.
  // RFC 3986 section 3.4.
  // query = *( pchar / "/" / "?" )
  static const _queryCharTable = const [
                //             LSB            MSB
                //              |              |
      0x0000,   // 0x00 - 0x0f  0000000000000000
      0x0000,   // 0x10 - 0x1f  0000000000000000
                //               !  $ &'()*+,-./
      0xffd2,   // 0x20 - 0x2f  0100101111111111
                //              0123456789:; = ?
      0xafff,   // 0x30 - 0x3f  1111111111110101
                //              @ABCDEFGHIJKLMNO
      0xffff,   // 0x40 - 0x4f  1111111111111111
                //              PQRSTUVWXYZ    _
      0x87ff,   // 0x50 - 0x5f  1111111111100001
                //               abcdefghijklmno
      0xfffe,   // 0x60 - 0x6f  0111111111111111
                //              pqrstuvwxyz   ~
      0x47ff];  // 0x70 - 0x7f  1111111111100010

}

// --------------------------------------------------------------------
// Data URI
// --------------------------------------------------------------------

/**
 * A way to access the structure of a `data:` URI.
 *
 * Data URIs are non-hierarchical URIs that can contain any binary data.
 * They are defined by [RFC 2397](https://tools.ietf.org/html/rfc2397).
 *
 * This class allows parsing the URI text and extracting individual parts of the
 * URI, as well as building the URI text from structured parts.
 */
class UriData {
  static const int _noScheme = -1;
  /**
   * Contains the text content of a `data:` URI, with or without a
   * leading `data:`.
   *
   * If [_separatorIndices] starts with `4` (the index of the `:`), then
   * there is a leading `data:`, otherwise [_separatorIndices] starts with
   * `-1`.
   */
  final String _text;

  /**
   * List of the separators (';', '=' and ',') in the text.
   *
   * Starts with the index of the `:` in `data:` of the mimeType.
   * That is always either -1 or 4, depending on whether `_text` includes the
   * `data:` scheme or not.
   *
   * The first speparator ends the mime type. We don't bother with finding
   * the '/' inside the mime type.
   *
   * Each two separators after that marks a parameter key and value.
   *
   * If there is a single separator left, it ends the "base64" marker.
   *
   * So the following separators are found for a text:
   *
   *     data:text/plain;foo=bar;base64,ARGLEBARGLE=
   *         ^          ^   ^   ^      ^
   *
   */
  final List<int> _separatorIndices;

  /**
   * Cache of the result returned by [uri].
   */
  Uri _uriCache;

  UriData._(this._text, this._separatorIndices, this._uriCache);

  /**
   * Creates a `data:` URI containing the [content] string.
   *
   * Equivalent to `new Uri.dataFromString(...).data`, but may
   * be more efficient if the [uri] itself isn't used.
   */
  factory UriData.fromString(String content,
                             {String mimeType,
                              Encoding encoding,
                              Map<String, String> parameters,
                              bool base64: false}) {
    StringBuffer buffer = new StringBuffer();
    List<int> indices = [_noScheme];
    String charsetName;
    String encodingName;
    if (parameters != null) charsetName = parameters["charset"];
    if (encoding == null) {
      if (charsetName != null) {
        encoding = Encoding.getByName(charsetName);
      }
    } else if (charsetName == null) {
      // Non-null only if parameters does not contain "charset".
      encodingName = encoding.name;
    }
    encoding ??= ASCII;
    _writeUri(mimeType, encodingName, parameters, buffer, indices);
    indices.add(buffer.length);
    if (base64) {
      buffer.write(';base64,');
      indices.add(buffer.length - 1);
      buffer.write(encoding.fuse(BASE64).encode(content));
    } else {
      buffer.write(',');
      _uriEncodeBytes(_uricTable, encoding.encode(content), buffer);
    }
    return new UriData._(buffer.toString(), indices, null);
  }

  /**
   * Creates a `data:` URI containing an encoding of [bytes].
   *
   * Equivalent to `new Uri.dataFromBytes(...).data`, but may
   * be more efficient if the [uri] itself isn't used.
   */
  factory UriData.fromBytes(List<int> bytes,
                            {mimeType: "application/octet-stream",
                             Map<String, String> parameters,
                             percentEncoded: false}) {
    StringBuffer buffer = new StringBuffer();
    List<int> indices = [_noScheme];
    _writeUri(mimeType, null, parameters, buffer, indices);
    indices.add(buffer.length);
    if (percentEncoded) {
      buffer.write(',');
      _uriEncodeBytes(_uricTable, bytes, buffer);
    } else {
      buffer.write(';base64,');
      indices.add(buffer.length - 1);
      BASE64.encoder
            .startChunkedConversion(
                new StringConversionSink.fromStringSink(buffer))
            .addSlice(bytes, 0, bytes.length, true);
    }

    return new UriData._(buffer.toString(), indices, null);
  }

  /**
   * Creates a `DataUri` from a [Uri] which must have `data` as [Uri.scheme].
   *
   * The [uri] must have scheme `data` and no authority or fragment,
   * and the path (concatenated with the query, if there is one) must be valid
   * as data URI content with the same rules as [parse].
   */
  factory UriData.fromUri(Uri uri) {
    if (uri.scheme != "data") {
      throw new ArgumentError.value(uri, "uri",
                                    "Scheme must be 'data'");
    }
    if (uri.hasAuthority) {
      throw new ArgumentError.value(uri, "uri",
                                    "Data uri must not have authority");
    }
    if (uri.hasFragment) {
      throw new ArgumentError.value(uri, "uri",
                                    "Data uri must not have a fragment part");
    }
    if (!uri.hasQuery) {
      return _parse(uri.path, 0, uri);
    }
    // Includes path and query (and leading "data:").
    return _parse("$uri", 5, uri);
  }

  /**
   * Writes the initial part of a `data:` uri, from after the "data:"
   * until just before the ',' before the data, or before a `;base64,`
   * marker.
   *
   * Of an [indices] list is passed, separator indices are stored in that
   * list.
   */
  static void _writeUri(String mimeType,
                        String charsetName,
                        Map<String, String> parameters,
                        StringBuffer buffer, List indices) {
    if (mimeType == null || mimeType == "text/plain") {
      mimeType = "";
    }
    if (mimeType.isEmpty || identical(mimeType, "application/octet-stream")) {
      buffer.write(mimeType);  // Common cases need no escaping.
    } else {
      int slashIndex = _validateMimeType(mimeType);
      if (slashIndex < 0) {
        throw new ArgumentError.value(mimeType, "mimeType",
                                      "Invalid MIME type");
      }
      buffer.write(_Uri._uriEncode(_tokenCharTable,
                                   mimeType.substring(0, slashIndex),
                                   UTF8, false));
      buffer.write("/");
      buffer.write(_Uri._uriEncode(_tokenCharTable,
                                   mimeType.substring(slashIndex + 1),
                                   UTF8, false));
    }
    if (charsetName != null) {
      if (indices != null) {
        indices..add(buffer.length)
               ..add(buffer.length + 8);
      }
      buffer.write(";charset=");
      buffer.write(_Uri._uriEncode(_tokenCharTable, charsetName, UTF8, false));
    }
    parameters?.forEach((var key, var value) {
      if (key.isEmpty) {
        throw new ArgumentError.value("", "Parameter names must not be empty");
      }
      if (value.isEmpty) {
        throw new ArgumentError.value("", "Parameter values must not be empty",
                                      'parameters["$key"]');
      }
      if (indices != null) indices.add(buffer.length);
      buffer.write(';');
      // Encode any non-RFC2045-token character and both '%' and '#'.
      buffer.write(_Uri._uriEncode(_tokenCharTable, key, UTF8, false));
      if (indices != null) indices.add(buffer.length);
      buffer.write('=');
      buffer.write(_Uri._uriEncode(_tokenCharTable, value, UTF8, false));
    });
  }

  /**
   * Checks mimeType is valid-ish (`token '/' token`).
   *
   * Returns the index of the slash, or -1 if the mime type is not
   * considered valid.
   *
   * Currently only looks for slashes, all other characters will be
   * percent-encoded as UTF-8 if necessary.
   */
  static int _validateMimeType(String mimeType) {
    int slashIndex = -1;
    for (int i = 0; i < mimeType.length; i++) {
      var char = mimeType.codeUnitAt(i);
      if (char != _SLASH) continue;
      if (slashIndex < 0) {
        slashIndex = i;
        continue;
      }
      return -1;
    }
    return slashIndex;
  }

  /**
   * Parses a string as a `data` URI.
   *
   * The string must have the format:
   *
   * ```
   * 'data:' (type '/' subtype)? (';' attribute '=' value)* (';base64')? ',' data
   * ````
   *
   * where `type`, `subtype`, `attribute` and `value` are specified in RFC-2045,
   * and `data` is a sequence of URI-characters (RFC-2396 `uric`).
   *
   * This means that all the characters must be ASCII, but the URI may contain
   * percent-escapes for non-ASCII byte values that need an interpretation
   * to be converted to the corresponding string.
   *
   * Parsing doesn't check the validity of any part, it just checks that the
   * input has the correct structure with the correct sequence of `/`, `;`, `=`
   * and `,` delimiters.
   *
   * Accessing the individual parts may fail later if they turn out to have
   * content that can't be decoded successfully as a string.
   */
  static UriData parse(String uri) {
    if (uri.length >= 5) {
      int dataDelta = _startsWithData(uri, 0);
      if (dataDelta == 0) {
        // Exact match on "data:".
        return _parse(uri, 5, null);
      }
      if (dataDelta == 0x20) {
        // Starts with a non-normalized "data" scheme containing upper-case
        // letters. Parse anyway, but throw away the scheme.
        return _parse(uri.substring(5), 0, null);
      }
    }
    throw new FormatException("Does not start with 'data:'", uri, 0);
  }

  /**
   * The [Uri] that this `UriData` is giving access to.
   *
   * Returns a `Uri` with scheme `data` and the remainder of the data URI
   * as path.
   */
  Uri get uri {
    if (_uriCache != null) return _uriCache;
    String path = _text;
    String query = null;
    int colonIndex = _separatorIndices[0];
    int queryIndex = _text.indexOf('?', colonIndex + 1);
    int end = null;
    if (queryIndex >= 0) {
      query = _text.substring(queryIndex + 1);
      end = queryIndex;
    }
    path = _text.substring(colonIndex + 1, end);
    // TODO(lrn): This can generate a URI that isn't path normalized.
    // That's perfectly reasonable - data URIs are not hierarchical,
    // but it may make some consumers stumble.
    // Should we at least do escape normalization?
    _uriCache = new _Uri._internal("data", "", null, null, path, query, null);
    return _uriCache;
  }

  /**
   * The MIME type of the data URI.
   *
   * A data URI consists of a "media type" followed by data.
   * The media type starts with a MIME type and can be followed by
   * extra parameters.
   *
   * Example:
   *
   *     data:text/plain;charset=utf-8,Hello%20World!
   *
   * This data URI has the media type `text/plain;charset=utf-8`, which is the
   * MIME type `text/plain` with the parameter `charset` with value `utf-8`.
   * See [RFC 2045](https://tools.ietf.org/html/rfc2045) for more detail.
   *
   * If the first part of the data URI is empty, it defaults to `text/plain`.
   */
  String get mimeType {
    int start = _separatorIndices[0] + 1;
    int end = _separatorIndices[1];
    if (start == end) return "text/plain";
    return _Uri._uriDecode(_text, start, end, UTF8, false);
  }

  /**
   * The charset parameter of the media type.
   *
   * If the parameters of the media type contains a `charset` parameter
   * then this returns its value, otherwise it returns `US-ASCII`,
   * which is the default charset for data URIs.
   */
  String get charset {
    int parameterStart = 1;
    int parameterEnd = _separatorIndices.length - 1;  // The ',' before data.
    if (isBase64) {
      // There is a ";base64" separator, so subtract one for that as well.
      parameterEnd -= 1;
    }
    for (int i = parameterStart; i < parameterEnd; i += 2) {
      var keyStart = _separatorIndices[i] + 1;
      var keyEnd = _separatorIndices[i + 1];
      if (keyEnd == keyStart + 7 && _text.startsWith("charset", keyStart)) {
        return _Uri._uriDecode(_text, keyEnd + 1, _separatorIndices[i + 2],
                               UTF8, false);
      }
    }
    return "US-ASCII";
  }

  /**
   * Whether the data is Base64 encoded or not.
   */
  bool get isBase64 => _separatorIndices.length.isOdd;

  /**
   * The content part of the data URI, as its actual representation.
   *
   * This string may contain percent escapes.
   */
  String get contentText => _text.substring(_separatorIndices.last + 1);

  /**
   * The content part of the data URI as bytes.
   *
   * If the data is Base64 encoded, it will be decoded to bytes.
   *
   * If the data is not Base64 encoded, it will be decoded by unescaping
   * percent-escaped characters and returning byte values of each unescaped
   * character. The bytes will not be, e.g., UTF-8 decoded.
   */
  List<int> contentAsBytes() {
    String text = _text;
    int start = _separatorIndices.last + 1;
    if (isBase64) {
      return BASE64.decoder.convert(text, start);
    }

    // Not base64, do percent-decoding and return the remaining bytes.
    // Compute result size.
    const int percent = 0x25;
    int length = text.length - start;
    for (int i = start; i < text.length; i++) {
      var codeUnit = text.codeUnitAt(i);
      if (codeUnit == percent) {
        i += 2;
        length -= 2;
      }
    }
    // Fill result array.
    Uint8List result = new Uint8List(length);
    if (length == text.length) {
      result.setRange(0, length, text.codeUnits, start);
      return result;
    }
    int index = 0;
    for (int i = start; i < text.length; i++) {
      var codeUnit = text.codeUnitAt(i);
      if (codeUnit != percent) {
        result[index++] = codeUnit;
      } else {
        if (i + 2 < text.length) {
          var digit1 = _Uri._parseHexDigit(text.codeUnitAt(i + 1));
          var digit2 = _Uri._parseHexDigit(text.codeUnitAt(i + 2));
          if (digit1 >= 0 && digit2 >= 0) {
            int byte = digit1 * 16 + digit2;
            result[index++] = byte;
            i += 2;
            continue;
          }
        }
        throw new FormatException("Invalid percent escape", text, i);
      }
    }
    assert(index == result.length);
    return result;
  }

  /**
   * Returns a string created from the content of the data URI.
   *
   * If the content is Base64 encoded, it will be decoded to bytes and then
   * decoded to a string using [encoding].
   * If encoding is omitted, the value of a `charset` parameter is used
   * if it is recognized by [Encoding.getByName], otherwise it defaults to
   * the [ASCII] encoding, which is the default encoding for data URIs
   * that do not specify an encoding.
   *
   * If the content is not Base64 encoded, it will first have percent-escapes
   * converted to bytes and then the character codes and byte values are
   * decoded using [encoding].
   */
  String contentAsString({Encoding encoding}) {
    if (encoding == null) {
      var charset = this.charset;  // Returns "US-ASCII" if not present.
      encoding = Encoding.getByName(charset);
      if (encoding == null) {
        throw new UnsupportedError("Unknown charset: $charset");
      }
    }
    String text = _text;
    int start = _separatorIndices.last + 1;
    if (isBase64) {
      var converter = BASE64.decoder.fuse(encoding.decoder);
      return converter.convert(text.substring(start));
    }
    return _Uri._uriDecode(text, start, text.length, encoding, false);
  }

  /**
   * A map representing the parameters of the media type.
   *
   * A data URI may contain parameters between the MIME type and the
   * data. This converts these parameters to a map from parameter name
   * to parameter value.
   * The map only contains parameters that actually occur in the URI.
   * The `charset` parameter has a default value even if it doesn't occur
   * in the URI, which is reflected by the [charset] getter. This means that
   * [charset] may return a value even if `parameters["charset"]` is `null`.
   *
   * If the values contain non-ASCII values or percent escapes, they default
   * to being decoded as UTF-8.
   */
  Map<String, String> get parameters {
    var result = <String, String>{};
    for (int i = 3; i < _separatorIndices.length; i += 2) {
      var start = _separatorIndices[i - 2] + 1;
      var equals = _separatorIndices[i - 1];
      var end = _separatorIndices[i];
      String key = _Uri._uriDecode(_text, start, equals, UTF8, false);
      String value = _Uri._uriDecode(_text,equals + 1, end, UTF8, false);
      result[key] = value;
    }
    return result;
  }

  static UriData _parse(String text, int start, Uri sourceUri) {
    assert(start == 0 || start == 5);
    assert((start == 5) == text.startsWith("data:"));

    /// Character codes.
    const int comma     = 0x2c;
    const int slash     = 0x2f;
    const int semicolon = 0x3b;
    const int equals    = 0x3d;
    List<int> indices = [start - 1];
    int slashIndex = -1;
    var char;
    int i = start;
    for (; i < text.length; i++) {
      char = text.codeUnitAt(i);
      if (char == comma || char == semicolon) break;
      if (char == slash) {
        if (slashIndex < 0) {
          slashIndex = i;
          continue;
        }
        throw new FormatException("Invalid MIME type", text, i);
      }
    }
    if (slashIndex < 0 && i > start) {
      // An empty MIME type is allowed, but if non-empty it must contain
      // exactly one slash.
      throw new FormatException("Invalid MIME type", text, i);
    }
    while (char != comma) {
      // Parse parameters and/or "base64".
      indices.add(i);
      i++;
      int equalsIndex = -1;
      for (; i < text.length; i++) {
        char = text.codeUnitAt(i);
        if (char == equals) {
          if (equalsIndex < 0) equalsIndex = i;
        } else if (char == semicolon || char == comma) {
          break;
        }
      }
      if (equalsIndex >= 0) {
        indices.add(equalsIndex);
      } else {
        // Have to be final "base64".
        var lastSeparator = indices.last;
        if (char != comma ||
            i != lastSeparator + 7 /* "base64,".length */ ||
            !text.startsWith("base64", lastSeparator + 1)) {
          throw new FormatException("Expecting '='", text, i);
        }
        break;
      }
    }
    indices.add(i);
    return new UriData._(text, indices, sourceUri);
  }

  /**
   * Like [Uri._uriEncode] but takes the input as bytes, not a string.
   *
   * Encodes into [buffer] instead of creating its own buffer.
   */
  static void _uriEncodeBytes(List<int> canonicalTable,
                              List<int> bytes,
                              StringSink buffer) {
    // Encode the string into bytes then generate an ASCII only string
    // by percent encoding selected bytes.
    int byteOr = 0;
    for (int i = 0; i < bytes.length; i++) {
      int byte = bytes[i];
      byteOr |= byte;
      if (byte < 128 &&
          ((canonicalTable[byte >> 4] & (1 << (byte & 0x0f))) != 0)) {
        buffer.writeCharCode(byte);
      } else {
        buffer.writeCharCode(_PERCENT);
        buffer.writeCharCode(_hexDigits.codeUnitAt(byte >> 4));
        buffer.writeCharCode(_hexDigits.codeUnitAt(byte & 0x0f));
      }
    }
    if ((byteOr & ~0xFF) != 0) {
      for (int i = 0; i < bytes.length; i++) {
        var byte = bytes[i];
        if (byte < 0 || byte > 255) {
          throw new ArgumentError.value(byte, "non-byte value");
        }
      }
    }
  }

  String toString() =>
      (_separatorIndices[0] == _noScheme) ? "data:$_text" : _text;

  // Table of the `token` characters of RFC 2045 in a URI.
  //
  // A token is any US-ASCII character except SPACE, control characters and
  // `tspecial` characters. The `tspecial` category is:
  // '(', ')', '<', '>', '@', ',', ';', ':', '\', '"', '/', '[, ']', '?', '='.
  //
  // In a data URI, we also need to escape '%' and '#' characters.
  static const _tokenCharTable = const [
                //             LSB             MSB
                //              |               |
      0x0000,   // 0x00 - 0x0f  00000000 00000000
      0x0000,   // 0x10 - 0x1f  00000000 00000000
                //               !  $ &'   *+ -.
      0x6cd2,   // 0x20 - 0x2f  01001011 00110110
                //              01234567 89
      0x03ff,   // 0x30 - 0x3f  11111111 11000000
                //               ABCDEFG HIJKLMNO
      0xfffe,   // 0x40 - 0x4f  01111111 11111111
                //              PQRSTUVW XYZ   ^_
      0xc7ff,   // 0x50 - 0x5f  11111111 11100011
                //              `abcdefg hijklmno
      0xffff,   // 0x60 - 0x6f  11111111 11111111
                //              pqrstuvw xyz{|}~
      0x7fff];  // 0x70 - 0x7f  11111111 11111110

  // All non-escape RFC-2396 uric characters.
  //
  //  uric        =  reserved | unreserved | escaped
  //  reserved    =  ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" | "$" | ","
  //  unreserved  =  alphanum | mark
  //  mark        =  "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"
  //
  // This is the same characters as in a URI query (which is URI pchar plus '?')
  static const _uricTable = _Uri._queryCharTable;
}

// --------------------------------------------------------------------
// Constants used to read the scanner result.
// The indices points into the table filled by [_scan] which contains
// recognized positions in the scanned URI.
// The `0` index is only used internally.

/// Index of the position of that `:` after a scheme.
const int _schemeEndIndex     = 1;
/// Index of the position of the character just before the host name.
const int _hostStartIndex     = 2;
/// Index of the position of the `:` before a port value.
const int _portStartIndex     = 3;
/// Index of the position of the first character of a path.
const int _pathStartIndex     = 4;
/// Index of the position of the `?` before a query.
const int _queryStartIndex    = 5;
/// Index of the position of the `#` before a fragment.
const int _fragmentStartIndex = 6;
/// Index of a position where the URI was determined to be "non-simple".
const int _notSimpleIndex     = 7;

// Initial state for scanner.
const int _uriStart           = 00;

// If scanning of a URI terminates in this state or above,
// consider the URI non-simple
const int _nonSimpleEndStates = 14;

// Initial state for scheme validation.
const int _schemeStart        = 20;

/// Transition tables used to scan a URI to determine its structure.
///
/// The tables represent a state machine with output.
///
/// To scan the URI, start in the [_uriStart] state, then read each character
/// of the URI in order, from start to end, and for each character perform a
/// transition to a new state while writing the current position into the output
/// buffer at a designated index.
///
/// Each state, represented by an integer which is an index into
/// [_scannerTables], has a set of transitions, one for each character.
/// The transitions are encoded as a 5-bit integer representing the next state
/// and a 3-bit index into the output table.
///
/// For URI scanning, only characters in the range U+0020 through U+007E are
/// interesting, all characters outside that range are treated the same.
/// The tables only contain 96 entries, representing that characters in the
/// interesting range, plus one more to represent all values outside the range.
/// The character entries are stored in one `Uint8List` per state, with the
/// transition for a character at position `character ^ 0x60`,
/// which maps the range U+0020 .. U+007F into positions 0 .. 95.
/// All remaining characters are mapped to position 31 (`0x7f ^ 0x60`) which
/// represents the transition for all remaining characters.
final List<Uint8List> _scannerTables = _createTables();

// ----------------------------------------------------------------------
// Code to create the URI scanner table.

/// Creates the tables for [_scannerTables] used by [Uri.parse].
///
/// See [_scannerTables] for the generated format.
///
/// The concrete tables are chosen as a trade-off between the number of states
/// needed and the precision of the result.
/// This allows definitely recognizing the general structure of the URI
/// (presence and location of scheme, user-info, host, port, path, query and
/// fragment) while at the same time detecting that some components are not
/// in canonical form (anything containing a `%`, a host-name containing a
/// capital letter). Since the scanner doesn't know whether something is a
/// scheme or a path until it sees `:`, or user-info or host until it sees
/// a `@`, a second pass is needed to validate the scheme and any user-info
/// is considered non-canonical by default.
///
/// The states (starting from [_uriStart]) write positions while scanning
/// a string from `start` to `end` as follows:
///
/// - [_schemeEndIndex]: Should be initialized to `start-1`.
///   If the URI has a scheme, it is set to the position of the `:` after
///   the scheme.
/// - [_hostStartIndex]: Should be initialized to `start - 1`.
///   If the URI has an authority, it is set to the character before the
///   host name - either the second `/` in the `//` leading the authority,
///   or the `@` after a user-info. Comparing this value to the scheme end
///   position can be used to detect that there is a user-info component.
/// - [_portStartIndex]: Should be initialized to `start`.
///   Set to the position of the last `:` in an authority, and unchanged
///   if there is no authority or no `:` in an authority.
///   If this position is after the host start, there is a port, otherwise it
///   is just marking a colon in the user-info component.
/// - [_pathStartIndex]: Should be initialized to `start`.
///   Is set to the first path character unless the path is empty.
///   If the path is empty, the position is either unchanged (`start`) or
///   the first slash of an authority. So, if the path start is before a
///   host start or scheme end, the path is empty.
/// - [_queryStartIndex]: Should be initialized to `end`.
///   The position of the `?` leading a query if the URI contains a query.
/// - [_fragmentStartIndex]: Should be initialized to `end`.
///   The position of the `#` leading a fragment if the URI contains a fragment.
/// - [_notSimpleIndex]: Should be initialized to `start - 1`.
///   Set to another value if the URI is considered "not simple".
///   This is elaborated below.
///
/// # Simple URIs
/// A URI is considered "simple" if it is in a normalized form containing no
/// escapes. This allows us to skip normalization and checking whether escapes
/// are valid, and to extract components without worrying about unescaping.
///
/// The scanner computes a conservative approximation of being "simple".
/// It rejects any URI with an escape, with a user-info component (mainly
/// because they are rare and would increase the number of states in the
/// scanner significantly), with an IPV6 host or with a capital letter in
/// the scheme or host name (the scheme is handled in a second scan using
/// a separate two-state table).
/// Further, paths containing `..` or `.` path segments are considered
/// non-simple except for pure relative paths (no scheme or authority) starting
/// with a sequence of "../" segments.
///
/// The transition tables cannot detect a trailing ".." in the path,
/// followed by a query or fragment, because the segment is not known to be
/// complete until we are past it, and we then need to store the query/fragment
/// start instead. This cast is checked manually post-scanning (such a path
/// needs to be normalized to end in "../", so the URI shouldn't be considered
/// simple).
List<Uint8List> _createTables() {
  // TODO(lrn): Use a precomputed table.

  // Total number of states for the scanner.
  const int stateCount         = 22;

  // States used to scan a URI from scratch.
  const int schemeOrPath       = 01;
  const int authOrPath         = 02;
  const int authOrPathSlash    = 03;
  const int uinfoOrHost0       = 04;
  const int uinfoOrHost        = 05;
  const int uinfoOrPort0       = 06;
  const int uinfoOrPort        = 07;
  const int ipv6Host           = 08;
  const int relPathSeg         = 09;
  const int pathSeg            = 10;
  const int path               = 11;
  const int query              = 12;
  const int fragment           = 13;
  const int schemeOrPathDot    = 14;
  const int schemeOrPathDot2   = 15;
  const int relPathSegDot      = 16;
  const int relPathSegDot2     = 17;
  const int pathSegDot         = 18;
  const int pathSegDot2        = 19;

  // States used to validate a scheme after its end position has been found.
  const int scheme0            = _schemeStart;
  const int scheme             = 21;

  // Constants encoding the write-index for the state transition into the top 5
  // bits of a byte.
  const int schemeEnd          = _schemeEndIndex     << 5;
  const int hostStart          = _hostStartIndex     << 5;
  const int portStart          = _portStartIndex     << 5;
  const int pathStart          = _pathStartIndex     << 5;
  const int queryStart         = _queryStartIndex    << 5;
  const int fragmentStart      = _fragmentStartIndex << 5;
  const int notSimple          = _notSimpleIndex     << 5;

  /// The `unreserved` characters of RFC 3986.
  const unreserved =
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._~"  ;
  /// The `sub-delim` characters of RFC 3986.
  const subDelims = r"!$&'()*+,;=";
  // The `pchar` characters of RFC 3986: characters that may occur in a path,
  // excluding escapes.
  const pchar = "$unreserved$subDelims";

  var tables = new List<Uint8List>.generate(stateCount,
      (_) => new Uint8List(96));

  // Helper function which initialize the table for [state] with a default
  // transition and returns the table.
  Uint8List build(state, defaultTransition) =>
      tables[state]..fillRange(0, 96, defaultTransition);

  // Helper function which sets the transition for each character in [chars]
  // to [transition] in the [target] table.
  // The [chars] string must contain only characters in the U+0020 .. U+007E
  // range.
  void setChars(Uint8List target, String chars, int transition) {
    for (int i = 0; i < chars.length; i++) {
      var char = chars.codeUnitAt(i);
      target[char ^ 0x60] = transition;
    }
  }

  /// Helper function which sets the transition for all characters in the
  /// range from `range[0]` to `range[1]` to [transition] in the [target] table.
  ///
  /// The [range] must be a two-character string where both characters are in
  /// the U+0020 .. U+007E range and the former character must have a lower
  /// code point than the latter.
  void setRange(Uint8List target, String range, int transition) {
    for (int i = range.codeUnitAt(0), n = range.codeUnitAt(1); i <= n; i++) {
      target[i ^ 0x60] = transition;
    }
  }

  // Create the transitions for each state.
  var b;

  // Validate as path, if it is a scheme, we handle it later.
  b = build(_uriStart, schemeOrPath | notSimple);
  setChars(b, pchar, schemeOrPath);
  setChars(b, ".", schemeOrPathDot);
  setChars(b, ":", authOrPath | schemeEnd);  // Handle later.
  setChars(b, "/", authOrPathSlash);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(schemeOrPathDot, schemeOrPath | notSimple);
  setChars(b, pchar, schemeOrPath);
  setChars(b, ".", schemeOrPathDot2);
  setChars(b, ':', authOrPath | schemeEnd);
  setChars(b, "/", pathSeg | notSimple);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(schemeOrPathDot2, schemeOrPath | notSimple);
  setChars(b, pchar, schemeOrPath);
  setChars(b, "%", schemeOrPath | notSimple);
  setChars(b, ':', authOrPath | schemeEnd);
  setChars(b, "/", relPathSeg);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(schemeOrPath, schemeOrPath | notSimple);
  setChars(b, pchar, schemeOrPath);
  setChars(b, ':', authOrPath | schemeEnd);
  setChars(b, "/", pathSeg);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(authOrPath, path | notSimple);
  setChars(b, pchar, path | pathStart);
  setChars(b, "/", authOrPathSlash | pathStart);
  setChars(b, ".", pathSegDot | pathStart);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(authOrPathSlash, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, "/", uinfoOrHost0 | hostStart);
  setChars(b, ".", pathSegDot);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(uinfoOrHost0, uinfoOrHost | notSimple);
  setChars(b, pchar, uinfoOrHost);
  setRange(b, "AZ", uinfoOrHost | notSimple);
  setChars(b, ":", uinfoOrPort0 | portStart);
  setChars(b, "@", uinfoOrHost0 | hostStart);
  setChars(b, "[", ipv6Host | notSimple);
  setChars(b, "/", pathSeg | pathStart);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(uinfoOrHost, uinfoOrHost | notSimple);
  setChars(b, pchar, uinfoOrHost);
  setRange(b, "AZ", uinfoOrHost | notSimple);
  setChars(b, ":", uinfoOrPort0 | portStart);
  setChars(b, "@", uinfoOrHost0 | hostStart);
  setChars(b, "/", pathSeg | pathStart);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(uinfoOrPort0, uinfoOrPort | notSimple);
  setRange(b, "19", uinfoOrPort);
  setChars(b, "@", uinfoOrHost0 | hostStart);
  setChars(b, "/", pathSeg | pathStart);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(uinfoOrPort, uinfoOrPort | notSimple);
  setRange(b, "09", uinfoOrPort);
  setChars(b, "@", uinfoOrHost0 | hostStart);
  setChars(b, "/", pathSeg | pathStart);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(ipv6Host, ipv6Host);
  setChars(b, "]", uinfoOrHost);

  b = build(relPathSeg, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, ".", relPathSegDot);
  setChars(b, "/", pathSeg | notSimple);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(relPathSegDot, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, ".", relPathSegDot2);
  setChars(b, "/", pathSeg | notSimple);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(relPathSegDot2, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, "/", relPathSeg);
  setChars(b, "?", query | queryStart);  // This should be non-simple.
  setChars(b, "#", fragment | fragmentStart);  // This should be non-simple.

  b = build(pathSeg, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, ".", pathSegDot);
  setChars(b, "/", pathSeg | notSimple);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(pathSegDot, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, ".", pathSegDot2);
  setChars(b, "/", pathSeg | notSimple);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(pathSegDot2, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, "/", pathSeg | notSimple);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(path, path | notSimple);
  setChars(b, pchar, path);
  setChars(b, "/", pathSeg);
  setChars(b, "?", query | queryStart);
  setChars(b, "#", fragment | fragmentStart);

  b = build(query, query | notSimple);
  setChars(b, pchar, query);
  setChars(b, "?", query);
  setChars(b, "#", fragment | fragmentStart);

  b = build(fragment, fragment | notSimple);
  setChars(b, pchar, fragment);
  setChars(b, "?", fragment);

  // A separate two-state validator for lower-case scheme names.
  // Any non-scheme character or upper-case letter is marked as non-simple.
  b = build(scheme0, scheme | notSimple);
  setRange(b, "az", scheme);

  b = build(scheme, scheme | notSimple);
  setRange(b, "az", scheme);
  setRange(b, "09", scheme);
  setChars(b, "+-.", scheme);

  return tables;
}

// --------------------------------------------------------------------
// Code that uses the URI scanner table.

/// Scan a string using the [_scannerTables] state machine.
///
/// Scans [uri] from [start] to [end], startig in state [state] and
/// writing output into [indices].
///
/// Returns the final state.
int _scan(String uri, int start, int end, int state, List<int> indices) {
  var tables = _scannerTables;
  assert(end <= uri.length);
  for (int i = start; i < end; i++) {
    var table = tables[state];
    // Xor with 0x60 to move range 0x20-0x7f into 0x00-0x5f
    int char = uri.codeUnitAt(i) ^ 0x60;
    // Use 0x1f (nee 0x7f) to represent all unhandled characters.
    if (char > 0x5f) char = 0x1f;
    int transition = table[char];
    state = transition & 0x1f;
    indices[transition >> 5] = i;
  }
  return state;
}

class _SimpleUri implements Uri {
  final String _uri;
  final int _schemeEnd;
  final int _hostStart;
  final int _portStart;
  final int _pathStart;
  final int _queryStart;
  final int _fragmentStart;
  /// The scheme is often used to distinguish URIs.
  /// To make comparisons more efficient, we cache the value, and
  /// canonicalize a few known types.
  String _schemeCache;
  int _hashCodeCache;

  _SimpleUri(
      this._uri,
      this._schemeEnd,
      this._hostStart,
      this._portStart,
      this._pathStart,
      this._queryStart,
      this._fragmentStart,
      this._schemeCache);

  bool get hasScheme => _schemeEnd > 0;
  bool get hasAuthority => _hostStart > 0;
  bool get hasUserInfo => _hostStart > _schemeEnd + 4;
  bool get hasPort => _hostStart > 0 && _portStart + 1 < _pathStart;
  bool get hasQuery => _queryStart < _fragmentStart;
  bool get hasFragment => _fragmentStart < _uri.length;

  bool get _isFile => _schemeEnd == 4 && _uri.startsWith("file");
  bool get _isHttp => _schemeEnd == 4 && _uri.startsWith("http");
  bool get _isHttps => _schemeEnd == 5 && _uri.startsWith("https");
  bool get _isPackage => _schemeEnd == 7 && _uri.startsWith("package");
  /// Like [isScheme] but expects argument to be case normalized.
  bool _isScheme(String scheme) =>
    _schemeEnd == scheme.length && _uri.startsWith(scheme);

  bool get hasAbsolutePath => _uri.startsWith("/", _pathStart);
  bool get hasEmptyPath => _pathStart == _queryStart;

  bool get isAbsolute => hasScheme && !hasFragment;

  bool isScheme(String scheme) {
    if (scheme == null || scheme.isEmpty) return _schemeEnd < 0;
    if (scheme.length != _schemeEnd) return false;
    return _Uri._compareScheme(scheme, _uri);
  }

  String get scheme {
    if (_schemeEnd <= 0) return "";
    if (_schemeCache != null) return _schemeCache;
    if (_isHttp) {
      _schemeCache = "http";
    } else if (_isHttps) {
      _schemeCache = "https";
    } else if (_isFile) {
      _schemeCache = "file";
    } else if (_isPackage) {
      _schemeCache = "package";
    } else {
      _schemeCache = _uri.substring(0, _schemeEnd);
    }
    return _schemeCache;
  }
  String get authority => _hostStart > 0 ?
      _uri.substring(_schemeEnd + 3, _pathStart) : "";
  String get userInfo => (_hostStart > _schemeEnd + 3) ?
      _uri.substring(_schemeEnd + 3, _hostStart - 1) : "";
  String get host =>
      _hostStart > 0 ? _uri.substring(_hostStart, _portStart) : "";
  int get port {
    if (hasPort) return int.parse(_uri.substring(_portStart + 1, _pathStart));
    if (_isHttp) return 80;
    if (_isHttps) return 443;
    return 0;
  }
  String get path =>_uri.substring(_pathStart, _queryStart);
  String get query => (_queryStart < _fragmentStart) ?
     _uri.substring(_queryStart + 1, _fragmentStart) : "";
  String get fragment => (_fragmentStart < _uri.length) ?
     _uri.substring(_fragmentStart + 1) : "";

  String get origin {
    // Check original behavior - W3C spec is wonky!
    bool isHttp = _isHttp;
    if (_schemeEnd < 0) {
      throw new StateError("Cannot use origin without a scheme: $this");
    }
    if (!isHttp && !_isHttps) {
      throw new StateError(
        "Origin is only applicable schemes http and https: $this");
    }
    if (_hostStart == _portStart) {
      throw new StateError(
          "A $scheme: URI should have a non-empty host name: $this");
    }
    if (_hostStart == _schemeEnd + 3) {
      return _uri.substring(0, _pathStart);
    }
    // Need to drop anon-empty userInfo.
    return _uri.substring(0, _schemeEnd + 3) +
           _uri.substring(_hostStart, _pathStart);
  }

  List<String> get pathSegments {
    int start = _pathStart;
    int end = _queryStart;
    if (_uri.startsWith("/", start)) start++;
    if (start == end) return const <String>[];
    List<String> parts = [];
    for (int i = start; i < end; i++) {
      var char = _uri.codeUnitAt(i);
      if (char == _SLASH) {
        parts.add(_uri.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(_uri.substring(start, end));
    return new List<String>.unmodifiable(parts);
  }

  Map<String, String> get queryParameters {
    if (!hasQuery) return const <String, String>{};
    return new UnmodifiableMapView<String, String>(
        Uri.splitQueryString(query));
  }

  Map<String, List<String>> get queryParametersAll {
    if (!hasQuery) return const <String, List<String>>{};
    Map queryParameterLists = _Uri._splitQueryStringAll(query);
    for (var key in queryParameterLists.keys) {
      queryParameterLists[key] =
          new List<String>.unmodifiable(queryParameterLists[key]);
    }
    return new Map<String, List<String>>.unmodifiable(queryParameterLists);
  }

  bool _isPort(String port) {
    int portDigitStart = _portStart + 1;
    return portDigitStart + port.length == _pathStart &&
           _uri.startsWith(port, portDigitStart);
  }

  Uri normalizePath() => this;

  Uri removeFragment() {
    if (!hasFragment) return this;
    return new _SimpleUri(
      _uri.substring(0, _fragmentStart),
      _schemeEnd, _hostStart, _portStart,
      _pathStart, _queryStart, _fragmentStart, _schemeCache);
  }

  Uri replace({String scheme,
               String userInfo,
               String host,
               int port,
               String path,
               Iterable<String> pathSegments,
               String query,
               Map<String, dynamic/*String|Iterable<String>*/> queryParameters,
               String fragment}) {
    bool schemeChanged = false;
    if (scheme != null) {
      scheme = _Uri._makeScheme(scheme, 0, scheme.length);
      schemeChanged = !_isScheme(scheme);
    } else {
      scheme = this.scheme;
    }
    bool isFile = (scheme == "file");
    if (userInfo != null) {
      userInfo = _Uri._makeUserInfo(userInfo, 0, userInfo.length);
    } else if (_hostStart > 0) {
      userInfo = _uri.substring(_schemeEnd + 3, _hostStart);
    } else {
      userInfo = "";
    }
    if (port != null) {
      port = _Uri._makePort(port, scheme);
    } else {
      port = this.hasPort ? this.port : null;
      if (schemeChanged) {
        // The default port might have changed.
        port = _Uri._makePort(port, scheme);
      }
    }
    if (host != null) {
      host = _Uri._makeHost(host, 0, host.length, false);
    } else if (_hostStart > 0) {
      host = _uri.substring(_hostStart, _portStart);
    } else if (userInfo.isNotEmpty || port != null || isFile) {
      host = "";
    }

    bool hasAuthority = host != null;
    if (path != null || pathSegments != null) {
      path = _Uri._makePath(path, 0, _stringOrNullLength(path), pathSegments,
                           scheme, hasAuthority);
    } else {
      path = _uri.substring(_pathStart, _queryStart);
      if ((isFile || (hasAuthority && !path.isEmpty)) &&
          !path.startsWith('/')) {
        path = "/" + path;
      }
    }

    if (query != null || queryParameters != null) {
      query = _Uri._makeQuery(
          query, 0, _stringOrNullLength(query), queryParameters);
    } else if (_queryStart < _fragmentStart) {
      query = _uri.substring(_queryStart + 1, _fragmentStart);
    }

    if (fragment != null) {
      fragment = _Uri._makeFragment(fragment, 0, fragment.length);
    } else if (_fragmentStart < _uri.length) {
      fragment = _uri.substring(_fragmentStart + 1);
    }

    return new _Uri._internal(
        scheme, userInfo, host, port, path, query, fragment);
  }

  Uri resolve(String reference) {
    return resolveUri(Uri.parse(reference));
  }

  Uri resolveUri(Uri reference) {
    if (reference is _SimpleUri) {
      return _simpleMerge(this, reference);
    }
    return _toNonSimple().resolveUri(reference);
  }

  // Merge two simple URIs. This should always result in a prefix of
  // one concatentated with a suffix of the other, possibly with a `/` in
  // the middle of two merged paths, which is again simple.
  // In a few cases, there might be a need for extra normalization, when
  // resolving on top of a known scheme.
  Uri _simpleMerge(_SimpleUri base, _SimpleUri ref) {
    if (ref.hasScheme) return ref;
    if (ref.hasAuthority) {
      if (!base.hasScheme) return ref;
      bool isSimple = true;
      if (base._isFile) {
        isSimple = !ref.hasEmptyPath;
      } else if (base._isHttp) {
        isSimple = !ref._isPort("80");
      } else if (base._isHttps) {
        isSimple = !ref._isPort("443");
      }
      if (isSimple) {
        var delta = base._schemeEnd + 1;
        var newUri = base._uri.substring(0, base._schemeEnd + 1) +
                     ref._uri.substring(ref._schemeEnd + 1);
        return new _SimpleUri(newUri,
           base._schemeEnd,
           ref._hostStart + delta,
           ref._portStart + delta,
           ref._pathStart + delta,
           ref._queryStart + delta,
           ref._fragmentStart + delta,
           base._schemeCache);
      } else {
        // This will require normalization, so use the _Uri implementation.
        return _toNonSimple().resolveUri(ref);
      }
    }
    if (ref.hasEmptyPath) {
      if (ref.hasQuery) {
        int delta = base._queryStart - ref._queryStart;
        var newUri = base._uri.substring(0, base._queryStart) +
                     ref._uri.substring(ref._queryStart);
        return new _SimpleUri(newUri,
           base._schemeEnd,
           base._hostStart,
           base._portStart,
           base._pathStart,
           ref._queryStart + delta,
           ref._fragmentStart + delta,
           base._schemeCache);
      }
      if (ref.hasFragment) {
        int delta = base._fragmentStart - ref._fragmentStart;
        var newUri = base._uri.substring(0, base._fragmentStart) +
                     ref._uri.substring(ref._fragmentStart);
        return new _SimpleUri(newUri,
           base._schemeEnd,
           base._hostStart,
           base._portStart,
           base._pathStart,
           base._queryStart,
           ref._fragmentStart + delta,
           base._schemeCache);
      }
      return base.removeFragment();
    }
    if (ref.hasAbsolutePath) {
      var delta = base._pathStart - ref._pathStart;
      var newUri = base._uri.substring(0, base._pathStart) +
                   ref._uri.substring(ref._pathStart);
      return new _SimpleUri(newUri,
        base._schemeEnd,
        base._hostStart,
        base._portStart,
        base._pathStart,
        ref._queryStart + delta,
        ref._fragmentStart + delta,
        base._schemeCache);
    }
    if (base.hasEmptyPath && base.hasAuthority) {
      // ref has relative non-empty path.
      // Add a "/" in front, then leading "/../" segments are folded to "/".
      int refStart = ref._pathStart;
      while (ref._uri.startsWith("../", refStart)) {
        refStart += 3;
      }
      var delta = base._pathStart - refStart + 1;
      var newUri = "${base._uri.substring(0, base._pathStart)}/"
                   "${ref._uri.substring(refStart)}";
      return new _SimpleUri(newUri,
        base._schemeEnd,
        base._hostStart,
        base._portStart,
        base._pathStart,
        ref._queryStart + delta,
        ref._fragmentStart + delta,
        base._schemeCache);
    }
    // Merge paths.

    // The RFC 3986 algorithm merges the base path without its final segment
    // (anything after the final "/", or everything if the base path doesn't
    // contain any "/"), and the reference path.
    // Then it removes "." and ".." segments using the remove-dot-segment
    // algorithm.
    // This code combines the two steps. It is simplified by knowing that
    // the base path contains no "." or ".." segments, and the reference
    // path can only contain leading ".." segments.

    String baseUri = base._uri;
    String refUri = ref._uri;
    int baseStart = base._pathStart;
    int baseEnd = base._queryStart;
    while (baseUri.startsWith("../", baseStart)) baseStart += 3;
    int refStart = ref._pathStart;
    int refEnd = ref._queryStart;

    /// Count of leading ".." segments in reference path.
    /// The count is decremented when the segment is matched with a
    /// segment of the base path, and both are then omitted from the result.
    int backCount = 0;
    /// Count "../" segments and advance `refStart` to after the segments.
    while (refStart + 3 <= refEnd && refUri.startsWith("../", refStart)) {
      refStart += 3;
      backCount += 1;
    }

    // Extra slash inserted between base and reference path parts if
    // the base path contains any slashes, or empty string if none.
    // (We could use a slash from the base path in most cases, but not if
    // we remove the entire base path).
    String insert = "";

    /// Remove segments from the base path.
    /// Start with the segment trailing the last slash,
    /// then remove segments for each leading "../" segment
    /// from the reference path, or as many of them as are available.
    while (baseEnd > baseStart) {
      baseEnd--;
      int char = baseUri.codeUnitAt(baseEnd);
      if (char == _SLASH) {
        insert = "/";
        if (backCount == 0) break;
        backCount--;
      }
    }

    if (baseEnd == baseStart && !base.hasScheme && !base.hasAbsolutePath) {
      // If the base is *just* a relative path (no scheme or authority),
      // then merging with another relative path doesn't follow the
      // RFC-3986 behavior.
      // Don't need to check `base.hasAuthority` since the base path is
      // non-empty - if there is an authority, a non-empty path is absolute.

      // We reached the start of the base path, and want to stay relative,
      // so don't insert a slash.
      insert = "";
      // If we reached the start of the base path with more "../" left over
      // in the reference path, include those segments in the result.
      refStart -= backCount * 3;
    }

    var delta = baseEnd - refStart + insert.length;
    var newUri = "${base._uri.substring(0, baseEnd)}$insert"
               "${ref._uri.substring(refStart)}";

    return new _SimpleUri(newUri,
      base._schemeEnd,
      base._hostStart,
      base._portStart,
      base._pathStart,
      ref._queryStart + delta,
      ref._fragmentStart + delta,
      base._schemeCache);
  }

  String toFilePath({bool windows}) {
    if (_schemeEnd >= 0 && !_isFile) {
      throw new UnsupportedError(
          "Cannot extract a file path from a $scheme URI");
    }
    if (_queryStart < _uri.length) {
      if (_queryStart < _fragmentStart) {
        throw new UnsupportedError(
            "Cannot extract a file path from a URI with a query component");
      }
      throw new UnsupportedError(
          "Cannot extract a file path from a URI with a fragment component");
    }
    if (windows == null) windows = _Uri._isWindows;
    return windows ? _Uri._toWindowsFilePath(this) : _toFilePath();
  }

  String _toFilePath() {
    if (_hostStart < _portStart) {
      // Has authority and non-empty host.
      throw new UnsupportedError(
        "Cannot extract a non-Windows file path from a file URI "
        "with an authority");
    }
    return this.path;
  }

  UriData get data {
    assert(scheme != "data");
    return null;
  }

  int get hashCode => _hashCodeCache ??= _uri.hashCode;

  bool operator==(Object other) {
    if (identical(this, other)) return true;
    if (other is Uri) return _uri == other.toString();
    return false;
  }

  Uri _toNonSimple() {
    return new _Uri._internal(
      this.scheme,
      this.userInfo,
      this.hasAuthority ? this.host: null,
      this.hasPort ? this.port : null,
      this.path,
      this.hasQuery ? this.query : null,
      this.hasFragment ? this.fragment : null
    );
  }

  String toString() => _uri;
}

/// Checks whether [text] starts with "data:" at position [start].
///
/// The text must be long enough to allow reading five characters
/// from the [start] position.
///
/// Returns an integer value which is zero if text starts with all-lowercase
/// "data:" and 0x20 if the text starts with "data:" that isn't all lower-case.
/// All other values means the text starts with some other character.
int _startsWithData(String text, int start) {
  // Multiply by 3 to avoid a non-colon character making delta be 0x20.
  int delta = (text.codeUnitAt(start + 4) ^ _COLON) * 3;
  delta |= text.codeUnitAt(start)     ^ 0x64 /*d*/;
  delta |= text.codeUnitAt(start + 1) ^ 0x61 /*a*/;
  delta |= text.codeUnitAt(start + 2) ^ 0x74 /*t*/;
  delta |= text.codeUnitAt(start + 3) ^ 0x61 /*a*/;
  return delta;
}

/// Helper function returning the length of a string, or `0` for `null`.
int _stringOrNullLength(String s) => (s == null) ? 0 : s.length;
