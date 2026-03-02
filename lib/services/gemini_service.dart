import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe.dart';

class GeminiService {
  static final String _apiKey =
      const String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');

  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Analiza imagen y detecta ingredientes
  Future<List<String>> detectIngredients(Uint8List imageBytes) async {
    try {
      final prompt = TextPart(
        '''Analiza esta imagen de comida/nevera/despensa y lista TODOS los ingredientes visibles.
Responde ÚNICAMENTE con un JSON válido en este formato exacto:
{
  "ingredients": ["ingrediente1", "ingrediente2", "ingrediente3"]
}
Sé específico (ej: "pollo crudo", "tomate maduro", "queso manchego").
Si no ves ingredientes, devuelve {"ingredients": []}.''',
      );

      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await _visionModel.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(0)!);
        return List<String>.from(jsonData['ingredients'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Error detectando ingredientes: $e');
    }
  }

  /// Genera recetas basadas en ingredientes disponibles
  Future<List<Recipe>> generateRecipes(List<String> ingredients) async {
    try {
      final ingredientsList = ingredients.join(', ');
      final prompt = '''
Eres un chef profesional. Tengo estos ingredientes: $ingredientsList

Genera 3 recetas diferentes que pueda hacer con ESTOS ingredientes (pueden usarse ingredientes básicos como sal, aceite, agua que se asumen disponibles).

Responde ÚNICAMENTE con JSON válido:
{
  "recipes": [
    {
      "title": "Nombre del plato",
      "emoji": "🍳",
      "description": "Descripción breve y apetitosa",
      "difficulty": "Fácil|Medio|Difícil",
      "prepTimeMinutes": 20,
      "ingredients": ["ingrediente con cantidad", "..."],
      "steps": [
        {
          "stepNumber": 1,
          "instruction": "Instrucción detallada y clara",
          "durationSeconds": 120
        }
      ]
    }
  ]
}

Cada receta debe tener entre 4-7 pasos. Las instrucciones deben ser claras para narrar por voz.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);

      if (jsonMatch != null) {
        final jsonData = json.decode(jsonMatch.group(0)!);
        final recipesJson = jsonData['recipes'] as List<dynamic>;
        return recipesJson.map((r) => Recipe.fromJson(r)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error generando recetas: $e');
    }
  }
}
