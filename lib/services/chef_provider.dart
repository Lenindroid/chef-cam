import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'supabase_service.dart';
import 'recetas_db_service.dart';
import 'tts_service.dart';
import 'auth_service.dart';

export 'recetas_db_service.dart';

enum ChefState { idle, scanning, analyzing, recipesReady, cooking }

class ChefProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final TtsService _ttsService = TtsService();

  ChefState _state = ChefState.idle;
  List<String> _detectedIngredients = [];
  List<Recipe> _recipes = [];
  Recipe? _selectedRecipe;
  int _currentStep = 0;
  String _statusMessage = '';
  bool _isSpeaking = false;
  String? _error;
  bool _errorEsNoComida = false;
  bool _errorEsYaPreparada = false;
  String? _nombreYaPreparada;

  // Flag: indica si la receta actual viene del historial (no re-guardar al terminar)
  bool _cookingFromHistory = false;

  // Historial & Favoritos
  List<Recipe> _historial = [];
  List<Recipe> _favoritos = [];
  bool _loadingHistorial = false;
  bool _loadingFavoritos = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  ChefState get state => _state;
  List<String> get detectedIngredients => _detectedIngredients;
  List<Recipe> get recipes => _recipes;
  Recipe? get selectedRecipe => _selectedRecipe;
  int get currentStep => _currentStep;
  String get statusMessage => _statusMessage;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;
  bool get errorEsNoComida => _errorEsNoComida;
  bool get errorEsYaPreparada => _errorEsYaPreparada;
  String? get nombreYaPreparada => _nombreYaPreparada;
  bool get cookingFromHistory => _cookingFromHistory;

  List<Recipe> get historial => _historial;
  List<Recipe> get favoritos => _favoritos;
  bool get loadingHistorial => _loadingHistorial;
  bool get loadingFavoritos => _loadingFavoritos;

  CookingStep? get currentStepData {
    if (_selectedRecipe == null) return null;
    if (_currentStep >= _selectedRecipe!.steps.length) return null;
    return _selectedRecipe!.steps[_currentStep];
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await _ttsService.init();
    await Future.wait([cargarHistorial(), cargarFavoritos()]);
  }

  // ── ANÁLISIS ───────────────────────────────────────────────────────────────
  Future<void> analyzeImage(Uint8List imageBytes) async {
    try {
      _error = null;
      _errorEsNoComida = false;
      _errorEsYaPreparada = false;
      _nombreYaPreparada = null;
      _state = ChefState.analyzing;
      _statusMessage = 'Analizando ingredientes...';
      notifyListeners();

      await _ttsService.speak('Analizando los ingredientes...');

      final data = await _supabaseService.analizarRefri(imageBytes);

      _detectedIngredients = _supabaseService.parseIngredientes(data);
      _recipes = _supabaseService.parseRecetas(data);

      await _marcarFavoritos(_recipes);

      if (_detectedIngredients.isEmpty && _recipes.isEmpty) {
        _statusMessage = 'No encontré ingredientes. Intenta de nuevo.';
        await _ttsService
            .speak('No pude detectar ingredientes. Apunta la cámara a los alimentos.');
        _state = ChefState.idle;
        notifyListeners();
        return;
      }

      _state = ChefState.recipesReady;
      _statusMessage = '¡${_recipes.length} recetas encontradas!';
      await _ttsService.speak(
          '¡Listo! Encontré ${_recipes.length} recetas. Elige la que quieras preparar.');
      notifyListeners();
    } on NoEsComidaException catch (e) {
      _errorEsNoComida = true;
      _error = e.mensaje;
      _state = ChefState.idle;
      _statusMessage = '';
      await _ttsService.speak(
          'Eso no parece comida. Apunta al refrigerador o despensa e intenta de nuevo.');
      notifyListeners();
    } catch (e) {
      _errorEsNoComida = false;
      _errorEsYaPreparada = false;
      _state = ChefState.idle;
      _statusMessage = '';

      final raw = e.toString();
      final jsonStart = raw.indexOf('{');
      if (jsonStart != -1) {
        try {
          final parsed = jsonDecode(raw.substring(jsonStart));
          if (parsed['error'] == 'no_es_comida') {
            _errorEsNoComida = true;
            _error = parsed['mensaje'] ??
                'No se detectó comida. Apunta al refrigerador e intenta de nuevo.';
            await _ttsService.speak(
                'Eso no parece comida. Apunta al refrigerador o despensa e intenta de nuevo.');
            notifyListeners();
            return;
          }
          if (parsed['error'] == 'ya_preparada') {
            _errorEsYaPreparada = true;
            _nombreYaPreparada = parsed['nombre'];
            _error = parsed['mensaje'] ??
                'Eso ya está listo para comer. Apunta al refrigerador para generar recetas.';
            await _ttsService.speak(
                '¡Eso ya está listo para comer! Apunta al refrigerador o despensa para encontrar ingredientes.');
            notifyListeners();
            return;
          }
          _error =
              parsed['mensaje'] ?? parsed['error'] ?? 'Error al analizar la imagen.';
        } catch (_) {
          _error = 'Error al analizar la imagen. Intenta de nuevo.';
        }
      } else {
        _error = raw.replaceFirst('Exception: ', '');
      }

      notifyListeners();
    }
  }

  // ── COCINAR ────────────────────────────────────────────────────────────────

  /// Flujo normal: escaneo → selección → cocinar (guarda al terminar).
  Future<void> selectRecipe(Recipe recipe) async {
    _cookingFromHistory = false;
    _selectedRecipe = recipe;
    _currentStep = 0;
    _state = ChefState.cooking;
    notifyListeners();

    await _ttsService
        .speak('Vamos a preparar ${recipe.title}. ${recipe.description}.');
    await Future.delayed(const Duration(seconds: 1));
    await speakCurrentStep();
  }

  /// Desde historial: carga los pasos ya guardados sin llamar a la IA
  /// y sin volver a guardar en historial al terminar.
  Future<void> selectRecipeFromHistory(Recipe recipe) async {
    _cookingFromHistory = true;
    _selectedRecipe = recipe;
    _currentStep = 0;
    _state = ChefState.cooking;
    notifyListeners();

    await _ttsService.speak('Vamos a preparar ${recipe.title}.');
    await Future.delayed(const Duration(milliseconds: 800));
    await speakCurrentStep();
  }

  Future<void> speakCurrentStep() async {
    if (_selectedRecipe == null) return;
    final step = currentStepData;
    if (step == null) return;
    _isSpeaking = true;
    notifyListeners();
    await _ttsService.speakStep(step.stepNumber, step.instruction);
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> nextStep() async {
    if (_selectedRecipe == null) return;
    if (_currentStep < _selectedRecipe!.steps.length - 1) {
      _currentStep++;
      notifyListeners();
      await speakCurrentStep();
    } else {
      // Solo guardar en historial si NO viene del historial
      if (!_cookingFromHistory) {
        await _guardarRecetaCompletada();
      }
      await _ttsService.speak(
          '¡Felicidades! Has terminado de preparar ${_selectedRecipe!.title}. ¡Buen provecho!');
      _statusMessage = '¡Receta completada!';
      notifyListeners();
    }
  }

  Future<void> previousStep() async {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
      await speakCurrentStep();
    }
  }

  Future<void> repeatStep() async => await speakCurrentStep();

  // ── HISTORIAL ──────────────────────────────────────────────────────────────

  /// Carga el historial desde Supabase.
  Future<void> cargarHistorial() async {
    _loadingHistorial = true;
    notifyListeners();
    try {
      _historial = await RecetasDbService.obtenerHistorial();
    } catch (_) {
      // Sin conexión o tabla aún no existe → lista vacía, sin crash
    } finally {
      _loadingHistorial = false;
      notifyListeners();
    }
  }

  /// Edita nombre, dificultad y tiempo de una entrada del historial.
  Future<void> editarHistorial({
    required Recipe recipe,
    required String nombre,
    required String dificultad,
    required int prepTimeMinutes,
  }) async {
    if (recipe.id == null) return;
    try {
      await RecetasDbService.actualizarHistorial(
        id: recipe.id!,
        nombre: nombre,
        dificultad: dificultad,
        prepTimeMinutes: prepTimeMinutes,
      );
      // Actualizar localmente sin recargar toda la lista
      final idx = _historial.indexWhere((r) => r.id == recipe.id);
      if (idx != -1) {
        final updated = Recipe(
          id: recipe.id,
          title: nombre,
          description: recipe.description,
          ingredients: recipe.ingredients,
          steps: recipe.steps,
          prepTimeMinutes: prepTimeMinutes,
          difficulty: dificultad,
          emoji: recipe.emoji,
          cookedAt: recipe.cookedAt,
          isFavorite: recipe.isFavorite,
        );
        _historial[idx] = updated;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Elimina una entrada del historial.
  Future<void> eliminarDeHistorial(Recipe recipe) async {
    if (recipe.id == null) return;
    try {
      await RecetasDbService.eliminarDeHistorial(recipe.id!);
      _historial.removeWhere((r) => r.id == recipe.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _guardarRecetaCompletada() async {
    final recipe = _selectedRecipe;
    if (recipe == null) return;
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      await RecetasDbService.guardarEnHistorial(recipe, userId);
      cargarHistorial(); // refresh en background
    } catch (_) {}
  }

  // ── FAVORITOS ──────────────────────────────────────────────────────────────

  /// Carga los favoritos desde Supabase.
  Future<void> cargarFavoritos() async {
    _loadingFavoritos = true;
    notifyListeners();
    try {
      _favoritos = await RecetasDbService.obtenerFavoritos();
    } catch (_) {}
    finally {
      _loadingFavoritos = false;
      notifyListeners();
    }
  }

  /// Agrega o quita un favorito, actualizando listas locales al instante.
  Future<void> toggleFavorito(Recipe recipe) async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;

    final eraFavorito = recipe.isFavorite;
    recipe.isFavorite = !eraFavorito;
    notifyListeners();

    try {
      if (!eraFavorito) {
        await RecetasDbService.agregarFavorito(recipe, userId);
        if (!_favoritos.any((f) => f.title == recipe.title)) {
          _favoritos.insert(0, recipe);
        }
      } else {
        await RecetasDbService.eliminarFavoritoPorNombre(recipe.title, userId);
        _favoritos.removeWhere((f) => f.title == recipe.title);
        for (final h in _historial) {
          if (h.title == recipe.title) h.isFavorite = false;
        }
      }
      notifyListeners();
    } catch (_) {
      recipe.isFavorite = eraFavorito; // revertir si falla
      notifyListeners();
    }
  }

  /// Elimina un favorito desde la pantalla de favoritos.
  Future<void> eliminarFavorito(Recipe recipe) async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    try {
      if (recipe.id != null) {
        await RecetasDbService.eliminarFavoritoPorId(recipe.id!);
      } else {
        await RecetasDbService.eliminarFavoritoPorNombre(recipe.title, userId);
      }
      recipe.isFavorite = false;
      _favoritos.removeWhere((f) => f.title == recipe.title);
      for (final h in _historial) {
        if (h.title == recipe.title) h.isFavorite = false;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _marcarFavoritos(List<Recipe> recipes) async {
    final favTitles = _favoritos.map((f) => f.title).toSet();
    for (final r in recipes) {
      r.isFavorite = favTitles.contains(r.title);
    }
  }

  // ── NAVEGACIÓN ─────────────────────────────────────────────────────────────
  void clearError() {
    _error = null;
    _errorEsNoComida = false;
    _errorEsYaPreparada = false;
    _nombreYaPreparada = null;
    notifyListeners();
  }

  void resetToCamera() {
    _state = ChefState.idle;
    _detectedIngredients = [];
    _recipes = [];
    _selectedRecipe = null;
    _currentStep = 0;
    _statusMessage = '';
    _error = null;
    _errorEsNoComida = false;
    _errorEsYaPreparada = false;
    _nombreYaPreparada = null;
    _cookingFromHistory = false;
    _ttsService.stop();
    notifyListeners();
  }

  void backToRecipes() {
    if (_cookingFromHistory) {
      // Vinimos del historial, no hay lista de recetas → volver al estado normal
      _state = ChefState.idle;
      _selectedRecipe = null;
      _currentStep = 0;
      _cookingFromHistory = false;
      _ttsService.stop();
      notifyListeners();
      return;
    }
    _state = ChefState.recipesReady;
    _selectedRecipe = null;
    _currentStep = 0;
    _ttsService.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}

class NoEsComidaException implements Exception {
  final String mensaje;
  const NoEsComidaException(this.mensaje);

  @override
  String toString() => mensaje;
}