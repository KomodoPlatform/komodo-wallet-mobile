class WalletSecuritySettings {
  bool isPassphraseSaved;
  bool activatePinProtection;
  bool activateBioProtection;
  bool enableCamo;
  bool isCamoActive;
  int camoFraction;
  String camoBalance;
  int camoSessionStartedAt;

  WalletSecuritySettings({
    this.isPassphraseSaved = false,
    this.activatePinProtection = false,
    this.activateBioProtection = false,
    this.enableCamo = false,
    this.isCamoActive = false,
    this.camoFraction,
    this.camoBalance,
    this.camoSessionStartedAt,
  });
}
