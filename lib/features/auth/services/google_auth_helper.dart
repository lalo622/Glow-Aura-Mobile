import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthHelper {
  static bool _initialized = false;
  static final GoogleSignIn _instance = GoogleSignIn.instance;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _instance.initialize(
      serverClientId: '759554172471-gncg6c36gc3c93enk5k5ska2obivugc7.apps.googleusercontent.com',
    );
    _initialized = true;
  }

  static Future<String?> signInAndGetIdToken() async {
    await _ensureInitialized();
    try {
      final account = await _instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  static Future<void> signOut() => _instance.signOut();
}