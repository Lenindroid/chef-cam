class Recipe {
  final String? id; // ID de la fila en Supabase (historial)
  final String title;
  final String description;
  final List<String> ingredients;
  final List<CookingStep> steps;
  final int prepTimeMinutes;
  final String difficulty;
  final String emoji;
  final DateTime? cookedAt; // Fecha en que se cocinó (historial)
  bool isFavorite; // Estado local de favorito

  Recipe({
    this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.emoji,
    this.cookedAt,
    this.isFavorite = false,
  });

  /// Para guardar en Supabase
  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'nombre': title,
      'descripcion': description,
      'ingredientes': ingredients,
      'dificultad': difficulty,
      'tiempo': '$prepTimeMinutes minutos',
      'emoji': emoji,
      'pasos': steps
          .map((s) => {
                'instruccion': s.instruction,
                'imageUrl': s.imageUrl,
              })
          .toList(),
    };
  }

  /// Desde Supabase (historial / favoritos)
  factory Recipe.fromSupabase(Map<String, dynamic> json) {
    final pasos = (json['pasos'] as List<dynamic>? ?? []);
    final steps = pasos.asMap().entries.map((e) {
      final paso = e.value;
      if (paso is Map<String, dynamic>) {
        return CookingStep(
          stepNumber: e.key + 1,
          instruction:
              paso['instruccion']?.toString() ?? paso['instruction']?.toString() ?? '',
          imageUrl: paso['imageUrl']?.toString(),
        );
      }
      return CookingStep(stepNumber: e.key + 1, instruction: paso.toString());
    }).toList();

    int minutes = 20;
    final tiempoStr = json['tiempo']?.toString() ?? '';
    final match = RegExp(r'\d+').firstMatch(tiempoStr);
    if (match != null) minutes = int.tryParse(match.group(0)!) ?? 20;

    final nombre = json['nombre']?.toString() ?? '';

    return Recipe(
      id: json['id']?.toString(),
      title: nombre,
      description: json['descripcion']?.toString() ??
          'Tiempo: ${json['tiempo'] ?? ''} · ${json['dificultad'] ?? ''}',
      ingredients: List<String>.from(json['ingredientes'] ?? []),
      steps: steps,
      prepTimeMinutes: minutes,
      difficulty: _normalizeDiff(json['dificultad']?.toString() ?? ''),
      emoji: json['emoji']?.toString() ?? _pickEmoji(nombre),
      cookedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      isFavorite: json['is_favorite'] == true,
    );
  }

  /// Desde Gemini (legado)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] ?? 'Receta Especial',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((s) => CookingStep.fromJson(s))
          .toList(),
      prepTimeMinutes: json['prepTimeMinutes'] ?? 30,
      difficulty: json['difficulty'] ?? 'Fácil',
      emoji: json['emoji'] ?? '🍽️',
    );
  }

  static String _normalizeDiff(String d) {
    switch (d.toLowerCase().trim()) {
      case 'facil':
      case 'fácil':
        return 'Fácil';
      case 'media':
      case 'medio':
        return 'Medio';
      case 'dificil':
      case 'difícil':
        return 'Difícil';
      default:
        return d.isEmpty ? 'Fácil' : d;
    }
  }

  static String _pickEmoji(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('ensalada')) return '🥗';
    if (n.contains('huevo')) return '🍳';
    if (n.contains('brocheta') || n.contains('plancha')) return '🍢';
    if (n.contains('sopa') || n.contains('caldo')) return '🍲';
    if (n.contains('arroz')) return '🍚';
    if (n.contains('pasta')) return '🍝';
    if (n.contains('pollo')) return '🍗';
    if (n.contains('carne') || n.contains('res')) return '🥩';
    if (n.contains('sandwich') || n.contains('torta')) return '🥪';
    if (n.contains('tacos') || n.contains('taco')) return '🌮';
    if (n.contains('fruta') || n.contains('mango')) return '🍓';
    if (n.contains('jugo') || n.contains('batido')) return '🥤';
    if (n.contains('pastel') || n.contains('cake')) return '🎂';
    return '🍽️';
  }
}

class CookingStep {
  final int stepNumber;
  final String instruction;
  final int? durationSeconds;
  final String? imageUrl;

  CookingStep({
    required this.stepNumber,
    required this.instruction,
    this.durationSeconds,
    this.imageUrl,
  });

  factory CookingStep.fromJson(Map<String, dynamic> json) {
    return CookingStep(
      stepNumber: json['stepNumber'] ?? 0,
      instruction: json['instruction'] ?? '',
      durationSeconds: json['durationSeconds'],
      imageUrl: json['imageUrl'],
    );
  }
}