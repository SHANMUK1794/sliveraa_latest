import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Check if biometric authentication is supported on the device
  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  // Get a list of available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  // Perform the actual biometric authentication
  Future<bool> authenticate({String reason = 'Please authenticate to access Silvra'}) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Set to false to allow device credential fallback if needed
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}
