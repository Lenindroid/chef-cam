// services/recetas_db_service.dart
//
// SQL necesario en Supabase (ejecutar en SQL Editor una sola vez):
// ─────────────────────────────────────────────────────────────────
// create table if not exists recetas_historial (
//   id uuid primary key default gen_random_uuid(),
//   user_id uuid references auth.users(id) on delete cascade not null,
//   nombre text not null,
//   descripcion text,
//   ingredientes jsonb default '[]',
//   dificultad text,
//   tiempo text,
//   emoji text,
//   pasos jsonb default '[]',
//   created_at timestamptz default now()
// );
// alter table recetas_historial enable row level security;
// create policy "usuario ve su historial" on recetas_historial
//   for all using (auth.uid() = user_id);
//
// create table if not exists recetas_favoritos (
//   id uuid primary key default gen_random_uuid(),
//   user_id uuid references auth.users(id) on delete cascade not null,
//   nombre text not null,
//   descripcion text,
//   ingredientes jsonb default '[]',
//   dificultad text,
//   tiempo text,
//   emoji text,
//   pasos jsonb default '[]',
//   created_at timestamptz default now(),
//   unique(user_id, nombre)
// );
// alter table recetas_favoritos enable row level security;
// create policy "usuario ve sus favoritos" on recetas_favoritos
//   for all using (auth.uid() = user_id);
// ─────────────────────────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';

class RecetasDbService {
  static SupabaseClient get _db => Supabase.instance.client;

  // ── HISTORIAL ──────────────────────────────────────────────────────────────

  /// Inserta una receta cocinada en el historial.
  static Future<void> guardarEnHistorial(Recipe recipe, String userId) async {
    await _db.from('recetas_historial').insert(recipe.toMap(userId));
  }

  /// Devuelve las últimas [limit] recetas del usuario, ordenadas por fecha.
  static Future<List<Recipe>> obtenerHistorial({int limit = 50}) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _db
        .from('recetas_historial')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).map((r) => Recipe.fromSupabase(r)).toList();
  }

  /// Actualiza nombre, dificultad y tiempo de una entrada del historial.
  static Future<void> actualizarHistorial({
    required String id,
    required String nombre,
    required String dificultad,
    required int prepTimeMinutes,
  }) async {
    await _db.from('recetas_historial').update({
      'nombre': nombre,
      'dificultad': dificultad,
      'tiempo': '$prepTimeMinutes minutos',
    }).eq('id', id);
  }

  /// Elimina una entrada del historial por su id.
  static Future<void> eliminarDeHistorial(String id) async {
    await _db.from('recetas_historial').delete().eq('id', id);
  }

  // ── FAVORITOS ──────────────────────────────────────────────────────────────

  /// Guarda una receta como favorito (upsert para evitar duplicados).
  static Future<void> agregarFavorito(Recipe recipe, String userId) async {
    await _db.from('recetas_favoritos').upsert(
      recipe.toMap(userId),
      onConflict: 'user_id,nombre',
    );
  }

  /// Elimina un favorito por nombre de receta.
  static Future<void> eliminarFavoritoPorNombre(
      String nombre, String userId) async {
    await _db
        .from('recetas_favoritos')
        .delete()
        .eq('user_id', userId)
        .eq('nombre', nombre);
  }

  /// Elimina un favorito por id de fila.
  static Future<void> eliminarFavoritoPorId(String id) async {
    await _db.from('recetas_favoritos').delete().eq('id', id);
  }

  /// Devuelve todos los favoritos del usuario.
  static Future<List<Recipe>> obtenerFavoritos() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _db
        .from('recetas_favoritos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((r) => Recipe.fromSupabase(r)..isFavorite = true)
        .toList();
  }
}