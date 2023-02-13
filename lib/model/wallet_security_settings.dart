class WalletSecuritySettings {
  bool activatePinProtection;
  bool activateBioProtection;
  bool enableCamo;
  bool isCamoActive;
  int? camoFraction;
  String? camoBalance;
  int? camoSessionStartedAt;
  bool logOutOnExit;

  WalletSecuritySettings({
    this.activatePinProtection = true,
    this.activateBioProtection = false,
    this.enableCamo = false,
    this.isCamoActive = false,
    this.camoFraction,
    this.camoBalance,
    this.camoSessionStartedAt,
    this.logOutOnExit = false,
  });
}
