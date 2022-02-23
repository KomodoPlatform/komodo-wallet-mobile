class WalletSecuritySettings {
  bool activatePinProtection;
  bool activateBioProtection;
  bool enableCamo;
  bool isCamoActive;
  int camoFraction;
  String camoBalance;
  int camoSessionStartedAt;

  WalletSecuritySettings({
    this.activatePinProtection = false,
    this.activateBioProtection = false,
    this.enableCamo = false,
    this.isCamoActive = false,
    this.camoFraction,
    this.camoBalance,
    this.camoSessionStartedAt,
  });
}
