import '../models/ssl_models.dart';
import 'ssl_issue_mixin.dart';
import 'ssl_persistence_mixin.dart';
import 'ssl_provider_base.dart';
import 'ssl_revocation_mixin.dart';

export '../services/openssl_command_service.dart';
export 'ssl_cnf_code_controller.dart';
export 'ssl_provider_base.dart' show SslProviderBase;

/// The single provider that composes all SSL certificate management concerns.
///
/// State lives in [SslProviderBase]. Logical groups of behaviour are split into:
/// - [SslIssueMixin]       – issuance, renewal, CSR, templates, CNF rendering
/// - [SslRevocationMixin]  – revocation, CRL, batch ops, deletion
/// - [SslPersistenceMixin] – persistence, snapshots, storage setup, validation
class SslCertificateManagerProvider extends SslProviderBase
    with SslIssueMixin, SslRevocationMixin, SslPersistenceMixin {
  // ────────────────── backward-compatible getters ──────────────────

  /// Unmodifiable view of all certificate records.
  List<SslCertificateRecord> get certificates => certificatesList;

  /// Current manager configuration snapshot.
  SslManagerConfig get config => configSnapshot;

  // ────────────────── static re-exports ──────────────────
  // Consumers reference these via `SslCertificateManagerProvider.xxx`.

  static const List<String> availableKeyUsageTypes =
      SslProviderBase.availableKeyUsageTypes;
  static const List<String> availableExtendedKeyUsageTypes =
      SslProviderBase.availableExtendedKeyUsageTypes;
  static const String moduleName = SslProviderBase.moduleName;
}
