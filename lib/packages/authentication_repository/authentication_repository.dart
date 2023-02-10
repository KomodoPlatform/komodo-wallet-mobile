class AuthenticationRepository {
  AuthenticationRepository();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized)
      throw Exception('AuthenticationRepository is already initialized');

    // do any necessary initialization here:

    //

    // Set initialized
    _isInitialized = true;
  }

  Future<void> setPin(String pin) async {
    //
    print('isInitialized: ${_isInitialized}');
  }

  Future<void> setCamoPin(String pin) async {
    //
  }

  Future<void> setCamoPinEnabled(bool value) async {
    //
  }

  Future<void> setBioProtection(bool value) async {
    //
  }

  Future<bool> getBioProtection() async {
    //
  }

  Future<void> setLogOutOnExit(bool value) async {
    //
  }

  Future<bool> getLogOutOnExit(bool value) async {
    //
  }

  Future<bool> validatePin(String pin) async {
    //
  }

  Future<void> loginWithPin(String pin) async {
    //
  }

  Future<bool> validateCamoPin(String pin) async {
    //
  }

  Future<void> loginWithCamoPin(String pin) async {
    //
  }
}
