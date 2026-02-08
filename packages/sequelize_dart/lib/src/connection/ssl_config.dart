/// SSL/TLS configuration for database connections.
///
/// This class provides type-safe SSL configuration options based on Node.js TLS
/// and database driver documentation.
///
/// Example usage:
/// ```dart
/// // Simple: enable SSL with default settings
/// SequelizeConnection.postgres(
///   host: 'localhost',
///   ssl: SslConfig(),
/// )
///
/// // With CA certificate
/// SequelizeConnection.postgres(
///   host: 'localhost',
///   ssl: SslConfig(
///     ca: File('ca.pem').readAsStringSync(),
///     rejectUnauthorized: true,
///   ),
/// )
///
/// // Self-signed certificates (development only)
/// SequelizeConnection.postgres(
///   host: 'localhost',
///   ssl: SslConfig.selfSigned(),
/// )
/// ```
class SslConfig {
  /// CA certificates in PEM format.
  ///
  /// Optionally override the trusted CA certificates. Default is to trust
  /// the well-known CAs curated by Mozilla. For self-signed certificates,
  /// the certificate is its own CA and must be provided.
  final String? ca;

  /// Client certificate chain in PEM format.
  ///
  /// One cert chain should be provided per private key.
  final String? cert;

  /// Client private key in PEM format.
  ///
  /// Encrypted keys are decrypted with [passphrase] if provided.
  final String? key;

  /// Shared passphrase used for a single private key and/or a PFX.
  final String? passphrase;

  /// PFX or PKCS12 encoded private key and certificate chain.
  ///
  /// Alternative to providing [key] and [cert] separately.
  /// Encrypted PFX will be decrypted with [passphrase] if provided.
  final String? pfx;

  /// Reject connections with unverifiable certificates.
  ///
  /// Defaults to `true`. Set to `false` only for development/testing
  /// with self-signed certificates. **Never use `false` in production.**
  final bool rejectUnauthorized;

  /// Cipher suite specification, replacing the default.
  ///
  /// Example: `'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384'`
  final String? ciphers;

  /// Use the server's cipher suite preferences instead of the client's.
  final bool? honorCipherOrder;

  /// Minimum size of the DH parameter in bits to accept a TLS connection.
  ///
  /// Default is 1024.
  final int? minDHSize;

  /// Custom function to verify server identity.
  ///
  /// Not serializable - for advanced use only.
  final Function? checkServerIdentity;

  /// SSL method to use.
  ///
  /// Example: `'TLSv1_2_method'`
  final String? secureProtocol;

  /// Named curve or colon-separated list of curve NIDs/names for ECDH.
  ///
  /// Example: `'P-521:P-384:P-256'`
  final String? ecdhCurve;

  /// PEM formatted CRLs (Certificate Revocation Lists).
  final String? crl;

  /// Diffie Hellman parameters for Perfect Forward Secrecy.
  final String? dhparam;

  /// Creates an SSL configuration.
  ///
  /// All parameters are optional. Without any parameters, SSL is enabled
  /// with default certificate validation.
  const SslConfig({
    this.ca,
    this.cert,
    this.key,
    this.passphrase,
    this.pfx,
    this.rejectUnauthorized = true,
    this.ciphers,
    this.honorCipherOrder,
    this.minDHSize,
    this.checkServerIdentity,
    this.secureProtocol,
    this.ecdhCurve,
    this.crl,
    this.dhparam,
  });

  /// Creates an SSL configuration for self-signed certificates.
  ///
  /// **Warning:** This disables certificate validation and should only
  /// be used in development/testing environments. Never use in production.
  const SslConfig.selfSigned()
    : ca = null,
      cert = null,
      key = null,
      passphrase = null,
      pfx = null,
      rejectUnauthorized = false,
      ciphers = null,
      honorCipherOrder = null,
      minDHSize = null,
      checkServerIdentity = null,
      secureProtocol = null,
      ecdhCurve = null,
      crl = null,
      dhparam = null;

  /// Converts this SSL configuration to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      if (ca != null) 'ca': ca,
      if (cert != null) 'cert': cert,
      if (key != null) 'key': key,
      if (passphrase != null) 'passphrase': passphrase,
      if (pfx != null) 'pfx': pfx,
      'rejectUnauthorized': rejectUnauthorized,
      if (ciphers != null) 'ciphers': ciphers,
      if (honorCipherOrder != null) 'honorCipherOrder': honorCipherOrder,
      if (minDHSize != null) 'minDHSize': minDHSize,
      if (secureProtocol != null) 'secureProtocol': secureProtocol,
      if (ecdhCurve != null) 'ecdhCurve': ecdhCurve,
      if (crl != null) 'crl': crl,
      if (dhparam != null) 'dhparam': dhparam,
    };
  }
}

/// Helper to serialize SSL configuration.
///
/// Handles both simple boolean values and SslConfig objects.
dynamic serializeSsl(Object? ssl) {
  if (ssl == null) return null;
  if (ssl is bool) return ssl;
  if (ssl is SslConfig) return ssl.toJson();
  if (ssl is Map) return ssl;
  return ssl;
}
