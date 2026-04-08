class LocalizationKeys {
  static const String navSslManager = 'nav_ssl_certificate_manager';
  static const String sslManager = 'ssl_certificate_manager';
  static const String initGuide = 'ssl_init_guide';
  static const String setupStoragePath = 'ssl_setup_storage_path';
  static const String setupRootCA = 'ssl_setup_root_ca';
  static const String setupComplete = 'ssl_setup_complete';
  static const String importRootCA = 'ssl_import_root_ca';
  static const String generateRootCA = 'ssl_generate_root_ca';
  static const String rootCaName = 'ssl_root_ca_name';
  static const String rootCaPassword = 'ssl_root_ca_password';
  static const String rootCaCertPath = 'ssl_root_ca_cert_path';
  static const String rootCaKeyPath = 'ssl_root_ca_key_path';
  static const String completeInit = 'ssl_complete_init';
  static const String certList = 'ssl_cert_list';
  static const String certIssue = 'ssl_cert_issue';
  static const String storageConfig = 'ssl_storage_config';
  static const String opensslTemplate = 'ssl_openssl_template';
  static const String issueNow = 'ssl_issue_now';
  static const String revoke = 'ssl_revoke';
  static const String delete = 'ssl_delete';
  static const String detail = 'ssl_detail';
  static const String statusIssued = 'ssl_status_issued';
  static const String statusRevoked = 'ssl_status_revoked';
  static const String validDays = 'ssl_valid_days';
  static const String pinField = 'ssl_pin_field';
  static const String unpinField = 'ssl_unpin_field';
  static const String saveCnf = 'ssl_save_cnf';
  static const String regenerateCnf = 'ssl_regenerate_cnf';
  static const String addAltName = 'ssl_add_alt_name';
  static const String close = 'ssl_close';
  static const String confirm = 'ssl_confirm';
  static const String cancel = 'ssl_cancel';
  static const String previousStep = 'ssl_previous_step';
  static const String nextStep = 'ssl_next_step';
  static const String confirmIssue = 'ssl_confirm_issue';
  static const String issueGuideBanner = 'ssl_issue_guide_banner';
  static const String stepBasicIdentity = 'ssl_step_basic_identity';
  static const String stepBasicIdentitySubtitle =
      'ssl_step_basic_identity_subtitle';
  static const String stepSubjectInfo = 'ssl_step_subject_info';
  static const String stepSubjectInfoSubtitle =
      'ssl_step_subject_info_subtitle';
  static const String stepUsageType = 'ssl_step_usage_type';
  static const String stepUsageTypeSubtitle = 'ssl_step_usage_type_subtitle';
  static const String stepEndpoint = 'ssl_step_endpoint';
  static const String stepEndpointSubtitle = 'ssl_step_endpoint_subtitle';
  static const String stepSecurity = 'ssl_step_security';
  static const String stepSecuritySubtitle = 'ssl_step_security_subtitle';
  static const String stepFinalConfirm = 'ssl_step_final_confirm';
  static const String stepFinalConfirmSubtitle =
      'ssl_step_final_confirm_subtitle';
  static const String issueSummary = 'ssl_issue_summary';
  static const String draftOpenSslConfig = 'ssl_draft_openssl_config';
  static const String confirmBeforeIssue = 'ssl_confirm_before_issue';
  static const String issuingWait = 'ssl_issuing_wait';
  static const String keyUsageLabel = 'ssl_key_usage_label';
  static const String extendedKeyUsageLabel = 'ssl_extended_key_usage_label';
  static const String crlDistributionUrl = 'ssl_crl_distribution_url';
  static const String ocspCaIssuersUrl = 'ssl_ocsp_ca_issuers_url';
  static const String ocspResponderUrl = 'ssl_ocsp_responder_url';
  static const String summaryDomain = 'ssl_summary_domain';
  static const String summaryCommonName = 'ssl_summary_common_name';
  static const String summaryLocation = 'ssl_summary_location';
  static const String summaryOrganization = 'ssl_summary_organization';
  static const String summaryEmail = 'ssl_summary_email';
  static const String summaryValidDays = 'ssl_summary_valid_days';
  static const String summaryPassword = 'ssl_summary_password';
  static const String summaryPasswordSet = 'ssl_summary_password_set';
  static const String summaryPasswordNotSet = 'ssl_summary_password_not_set';
  static const String summaryAltNames = 'ssl_summary_alt_names';
  static const String summaryNone = 'ssl_summary_none';
  static const String summaryKeyUsage = 'ssl_summary_key_usage';
  static const String summaryExtendedKeyUsage =
      'ssl_summary_extended_key_usage';
  static const String summaryCrlUrl = 'ssl_summary_crl_url';
  static const String summaryOcspCaIssuersUrl =
      'ssl_summary_ocsp_ca_issuers_url';
  static const String summaryOcspResponderUrl =
      'ssl_summary_ocsp_responder_url';
  static const String validationFillDomainAndCn =
      'ssl_validation_fill_domain_and_cn';
  static const String validationSelectUsage = 'ssl_validation_select_usage';
  static const String validationValidDays = 'ssl_validation_valid_days';
  static const String validationRequiredFields =
      'ssl_validation_required_fields';
  static const String validationInvalidDomain = 'ssl_validation_invalid_domain';
  static const String validationInvalidDomainOrIp =
      'ssl_validation_invalid_domain_or_ip';
  static const String validationInvalidIp = 'ssl_validation_invalid_ip';
  static const String validationInvalidUrl = 'ssl_validation_invalid_url';
  static const String validationInvalidEmail = 'ssl_validation_invalid_email';
  static const String validationInvalidCountryCode =
      'ssl_validation_invalid_country_code';
  static const String dialogIssueConfirmTitle =
      'ssl_dialog_issue_confirm_title';
  static const String dialogIssueConfirmContent =
      'ssl_dialog_issue_confirm_content';
  static const String dialogIssueNow = 'ssl_dialog_issue_now';
  static const String dialogIssuingTitle = 'ssl_dialog_issuing_title';
  static const String dialogIssuingContent = 'ssl_dialog_issuing_content';
  static const String dialogIssueSuccessTitle =
      'ssl_dialog_issue_success_title';
  static const String dialogIssueFailedTitle = 'ssl_dialog_issue_failed_title';
  static const String dialogAcknowledge = 'ssl_dialog_acknowledge';
  static const String summaryCn = 'ssl_summary_cn';
  static const String summaryCertPath = 'ssl_summary_cert_path';
  static const String summaryKeyPath = 'ssl_summary_key_path';
  static const String summaryConfigPath = 'ssl_summary_config_path';
  static const String altNameTypeDns = 'ssl_alt_name_type_dns';
  static const String altNameTypeIp = 'ssl_alt_name_type_ip';
  static const String fileTypeNotAllowed = 'ssl_file_type_not_allowed';
  static const String rootCertFileAllowedOnly = 'ssl_root_cert_file_allowed';
  static const String rootKeyFileAllowedOnly = 'ssl_root_key_file_allowed';
  static const String importRootCaFailed = 'ssl_import_root_ca_failed';
  static const String initFailed = 'ssl_init_failed';
  static const String importRootCaConfirmTitle = 'ssl_import_root_ca_confirm';
  static const String confirmAndContinue = 'ssl_confirm_and_continue';
  static const String emptyPasswordRiskTitle = 'ssl_empty_password_risk_title';
  static const String emptyPasswordRiskContent =
      'ssl_empty_password_risk_content';
  static const String backToFillPassword = 'ssl_back_to_fill_password';
  static const String continueWithRisk = 'ssl_continue_with_risk';
  static const String keyUsageDescDigitalSignature =
      'ssl_key_usage_desc_digital_signature';
  static const String keyUsageDescNonRepudiation =
      'ssl_key_usage_desc_non_repudiation';
  static const String keyUsageDescKeyEncipherment =
      'ssl_key_usage_desc_key_encipherment';
  static const String keyUsageDescDataEncipherment =
      'ssl_key_usage_desc_data_encipherment';
  static const String keyUsageDescKeyAgreement =
      'ssl_key_usage_desc_key_agreement';
  static const String keyUsageDescKeyCertSign =
      'ssl_key_usage_desc_key_cert_sign';
  static const String keyUsageDescCrlSign = 'ssl_key_usage_desc_crl_sign';
  static const String keyUsageDescEncipherOnly =
      'ssl_key_usage_desc_encipher_only';
  static const String keyUsageDescDecipherOnly =
      'ssl_key_usage_desc_decipher_only';
  static const String extKeyUsageDescServerAuth =
      'ssl_ext_key_usage_desc_server_auth';
  static const String extKeyUsageDescClientAuth =
      'ssl_ext_key_usage_desc_client_auth';
  static const String extKeyUsageDescCodeSigning =
      'ssl_ext_key_usage_desc_code_signing';
  static const String extKeyUsageDescEmailProtection =
      'ssl_ext_key_usage_desc_email_protection';
  static const String extKeyUsageDescTimeStamping =
      'ssl_ext_key_usage_desc_time_stamping';
  static const String extKeyUsageDescOcspSigning =
      'ssl_ext_key_usage_desc_ocsp_signing';
  static const String extKeyUsageDescIpsecIke =
      'ssl_ext_key_usage_desc_ipsec_ike';
  static const String extKeyUsageDescMsCodeInd =
      'ssl_ext_key_usage_desc_ms_code_ind';
  static const String extKeyUsageDescMsCodeCom =
      'ssl_ext_key_usage_desc_ms_code_com';
  static const String extKeyUsageDescMsCtlSign =
      'ssl_ext_key_usage_desc_ms_ctl_sign';
  static const String extKeyUsageDescMsEfs = 'ssl_ext_key_usage_desc_ms_efs';
  static const String extKeyUsageDescNsSgc = 'ssl_ext_key_usage_desc_ns_sgc';
  static const String domain = 'ssl_domain';
  static const String commonName = 'ssl_common_name';
  static const String countryName = 'ssl_country_name';
  static const String stateName = 'ssl_state_name';
  static const String localityName = 'ssl_locality_name';
  static const String organizationName = 'ssl_organization_name';
  static const String orgUnitName = 'ssl_org_unit_name';
  static const String emailAddress = 'ssl_email_address';
  static const String explicitText = 'ssl_explicit_text';
  static const String challengePassword = 'ssl_challenge_password';
  static const String unstructuredName = 'ssl_unstructured_name';
  static const String ocspDomain = 'ssl_ocsp_domain';
  static const String revokeReason = 'ssl_revoke_reason';
  static const String defaultOpenSslCnf = 'ssl_default_openssl_cnf';
  static const String compareChanges = 'ssl_compare_changes';
  static const String noChangesDetected = 'ssl_no_changes_detected';
  static const String altNames = 'ssl_alt_names';
  static const String issuer = 'ssl_issuer';
  static const String issuedAt = 'ssl_issued_at';
  static const String expiresAt = 'ssl_expires_at';
  static const String serialNumber = 'ssl_serial_number';
  static const String noData = 'ssl_no_data';
}
