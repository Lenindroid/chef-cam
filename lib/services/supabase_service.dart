import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class SupabaseService {
  static const String _url = '';
  static const String _token = ''; // removed hardcoded secret

  Future<Map<String, dynamic>> analizarRefri(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Content-Type': 'application/json',
              if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
            },
            body: jsonEncode({'imagenBase64': base64Image}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  List<String> parseIngredientes(Map<String, dynamic> data) {
    return List<String>.from(data['ingredientes'] ?? []);
  }

  List<Recipe> parseRecetas(Map<String, dynamic> data) {
    final recetasJson = data['recetas'] as List<dynamic>? ?? [];
    return recetasJson.map((r) => Recipe.fromSupabase(r)).toList();
  }
}
