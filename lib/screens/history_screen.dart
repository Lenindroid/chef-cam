import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/chef_provider.dart';
import '../models/recipe.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChefProvider>().cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChefProvider>(
      builder: (context, provider, _) {
        final historial = provider.historial;
        final loading = provider.loadingHistorial;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // ── Header ───────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Historial',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            loading
                                ? 'Cargando...'
                                : '${historial.length} receta${historial.length == 1 ? '' : 's'} cocinada${historial.length == 1 ? '' : 's'}',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: provider.cargarHistorial,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Lista ────────────────────────────────────────────────
                  Expanded(
                    child: loading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2))
                        : historial.isEmpty
                            ? const _EmptyState()
                            : RefreshIndicator(
                                color: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                onRefresh: provider.cargarHistorial,
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: historial.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) => _HistoryCard(
                                    recipe: historial[i],
                                    onTap: () => provider
                                        .selectRecipeFromHistory(historial[i]),
                                    onDelete: () => _confirmDelete(
                                        ctx, provider, historial[i]),
                                    onEdit: () => _showEditSheet(
                                        ctx, provider, historial[i]),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, ChefProvider provider, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('${recipe.emoji} ${recipe.title}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('¿Eliminar del historial?',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SheetBtn(
                    label: 'Cancelar',
                    color: AppColors.surface2,
                    textColor: Colors.white,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetBtn(
                    label: 'Eliminar',
                    color: AppColors.error.withOpacity(0.15),
                    textColor: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      provider.eliminarDeHistorial(recipe);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, ChefProvider provider, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditSheet(recipe: recipe, provider: provider),
    );
  }
}

// ── Tarjeta ────────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _HistoryCard({
    required this.recipe,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext ctx) {
    return Dismissible(
      key: Key(recipe.id ?? recipe.title),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // La eliminación real ocurre tras confirmación
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_rounded, color: AppColors.error, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(recipe.emoji,
                        style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _Badge(
                            icon: Icons.timer_outlined,
                            label: '${recipe.prepTimeMinutes} min'),
                        const SizedBox(width: 8),
                        _Badge(
                            icon: Icons.bar_chart_rounded,
                            label: recipe.difficulty),
                        const SizedBox(width: 8),
                        // Indicador de pasos guardados
                        if (recipe.steps.isNotEmpty)
                          _Badge(
                              icon: Icons.list_alt_rounded,
                              label: '${recipe.steps.length} pasos'),
                      ],
                    ),
                    if (recipe.cookedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(recipe.cookedAt!),
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Botones de acción
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón cocinar (play)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9)),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.black, size: 18),
                  ),
                  const SizedBox(height: 6),
                  // Botón favorito
                  GestureDetector(
                    onTap: () {
                      ctx.read<ChefProvider>().toggleFavorito(recipe);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: recipe.isFavorite
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.surface2,
                          borderRadius: BorderRadius.circular(9)),
                      child: Icon(
                        recipe.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: recipe.isFavorite
                            ? AppColors.primary
                            : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Botón editar
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.edit_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Edit sheet ─────────────────────────────────────────────────────────────
class _EditSheet extends StatefulWidget {
  final Recipe recipe;
  final ChefProvider provider;
  const _EditSheet({required this.recipe, required this.provider});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _timeCtrl;
  late String _difficulty;
  bool _saving = false;

  static const _difficulties = ['Fácil', 'Medio', 'Difícil'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.recipe.title);
    _timeCtrl =
        TextEditingController(text: '${widget.recipe.prepTimeMinutes}');
    _difficulty = widget.recipe.difficulty;
    // Asegura que el valor inicial sea uno válido
    if (!_difficulties.contains(_difficulty)) _difficulty = 'Fácil';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final minutes =
        int.tryParse(_timeCtrl.text.trim()) ?? widget.recipe.prepTimeMinutes;
    if (name.isEmpty) return;

    setState(() => _saving = true);
    await widget.provider.editarHistorial(
      recipe: widget.recipe,
      nombre: name,
      dificultad: _difficulty,
      prepTimeMinutes: minutes,
    );
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 32 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),

          // Título
          Row(
            children: [
              Text(widget.recipe.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Text('Editar receta',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 24),

          // Nombre
          _Label('Nombre'),
          const SizedBox(height: 8),
          _Field(controller: _nameCtrl, hint: 'Nombre de la receta'),
          const SizedBox(height: 16),

          // Tiempo
          _Label('Tiempo (minutos)'),
          const SizedBox(height: 8),
          _Field(
              controller: _timeCtrl,
              hint: '20',
              keyboard: TextInputType.number),
          const SizedBox(height: 16),

          // Dificultad
          _Label('Dificultad'),
          const SizedBox(height: 10),
          Row(
            children: _difficulties.asMap().entries.map((entry) {
              final d = entry.value;
              final isLast = entry.key == _difficulties.length - 1;
              final selected = d == _difficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: isLast ? 0 : 8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(d,
                          style: TextStyle(
                              color:
                                  selected ? Colors.black : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Guardar
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  color:
                      _saving ? AppColors.surface2 : AppColors.primary,
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2))
                    : const Text('Guardar cambios',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18)),
            child: const Center(
                child: Icon(Icons.history_rounded,
                    color: Colors.white, size: 32)),
          ),
          const SizedBox(height: 16),
          const Text('Sin historial aún',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Cocina tu primera receta\npara verla aquí',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  const _Field(
      {required this.controller,
      required this.hint,
      this.keyboard = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _SheetBtn(
      {required this.label,
      required this.color,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.w700))),
      ),
    );
  }
}