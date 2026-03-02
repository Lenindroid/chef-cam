import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/chef_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await AuthService.initialize();
  runApp(const ChefCamApp());
}

class ChefCamApp extends StatelessWidget {
  const ChefCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChefProvider(),
      child: MaterialApp(
        title: 'ChefCam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF9B800),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF111111),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        ),
        // Si ya hay sesión activa, ir directo al home
        home: AuthService.currentUser != null
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }
}