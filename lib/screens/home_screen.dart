import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chef_provider.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'recipes_screen.dart';
import 'cooking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChefProvider>().init();
    });
  }

  void _onTap(int i) {
    // Tab 1 = Escanear: navega a cámara como página completa
    if (i == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const _FullCameraPage()),
      );
      return;
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        if (provider.state == ChefState.recipesReady) return const RecipesScreen();
        if (provider.state == ChefState.cooking) return const CookingScreen();

        final screens = [
          const DashboardScreen(),
          const SizedBox.shrink(), // placeholder, nunca se muestra
          const HistoryScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex,
            onTap: _onTap,
          ),
        );
      },
    );
  }
}

// Página completa de cámara con botón atrás
class _FullCameraPage extends StatelessWidget {
  const _FullCameraPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        if (provider.state == ChefState.recipesReady) {
          return RecipesScreen(onBack: () {
            provider.resetToCamera();
            Navigator.of(context).pop();
          });
        }
        if (provider.state == ChefState.cooking) {
          return const CookingScreen();
        }
        return const CameraScreen();
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.home_rounded, 'Inicio'),
      _Item(Icons.camera_alt_rounded, 'Escanear'),
      _Item(Icons.history_rounded, 'Historial'),
      _Item(Icons.favorite_rounded, 'Favoritos'),
      _Item(Icons.person_rounded, 'Perfil'),
    ];

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = currentIndex == i;
              final isCenter = i == 1;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: isCenter
                      ? Center(
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(items[i].icon, color: Colors.black, size: 22),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(items[i].icon,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                              size: 22),
                            const SizedBox(height: 3),
                            Text(items[i].label, style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                            )),
                          ],
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  _Item(this.icon, this.label);
}