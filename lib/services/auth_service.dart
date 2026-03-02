import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _supabaseUrl = 'ñe';
  static const String _supabaseAnonKey = 'nop';

  // Android Client ID (el que va en la app)
  static const String _googleClientId = 'nop';

  static final _googleSignIn = GoogleSignIn(
    clientId: _googleClientId,
    scopes: ['email', 'profile'],
  );

  static SupabaseClient get client => Supabase.instance.client;

  /// Inicializar Supabase — llamar en main()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  /// Login con email y contraseña
  static Future<AuthResponse> signInWithEmail(
      String email, String password) async {
    return await client.auth
        .signInWithPassword(email: email, password: password);
  }

  /// Registro con email y contraseña
  static Future<AuthResponse> signUpWithEmail(
      String email, String password, String name) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  /// Login / Registro con Google
  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw Exception('No se obtuvo ID token de Google');

      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Error con Google Sign-In: $e');
    }
  }

  /// Cerrar sesión
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await client.auth.signOut();
  }

  /// Usuario actual
  static User? get currentUser => client.auth.currentUser;

  /// Stream de cambios de sesión
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Nombre del usuario actual
  static String get userName {
    final user = currentUser;
    if (user == null) return 'Chef';
    return user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        user.email?.split('@').first ??
        'Chef';
  }

  /// Avatar del usuario
  static String? get userAvatar {
    return currentUser?.userMetadata?['avatar_url'];
  }
}
