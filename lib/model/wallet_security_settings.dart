class WalletSecuritySettings {
  bool isPassphraseSaved;
  bool logOutOnExit;
  bool activatePinProtection;
  bool isPinCreated;
  String createdPin;
  bool activateBioProtection;
  bool enableCamo;
  bool isCamoPinCreated;
  String camoPin;
  bool isCamoActive;
  int camoFraction;
  String camoBalance;
  int camoSessionStartedAt;

  WalletSecuritySettings({
    this.isPassphraseSaved = false,
    this.logOutOnExit = false,
    this.activatePinProtection = false,
    this.isPinCreated = false,
    this.createdPin,
    this.activateBioProtection = false,
    this.enableCamo = false,
    this.isCamoPinCreated = false,
    this.camoPin,
    this.isCamoActive,
    this.camoFraction,
    this.camoBalance,
    this.camoSessionStartedAt,
  });
}
