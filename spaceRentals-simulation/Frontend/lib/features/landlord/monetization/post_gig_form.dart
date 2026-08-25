import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/ui_helpers.dart';

// Mock property options
const _mockProperties = ['Apt. Bastos A', 'Villa Bonamoussadi', 'Studio Makepe'];

class PostPropertyGigForm extends StatefulWidget {
  const PostPropertyGigForm({super.key});

  @override
  State<PostPropertyGigForm> createState() => _PostPropertyGigFormState();
}

class _PostPropertyGigFormState extends State<PostPropertyGigForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _selectedProperty;
  DateTime? _targetDate;

  static const double _minBudget = 2000;
  static const double _maxBudget = 150000;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  double get _clampedBudget {
    final v = double.tryParse(_budgetController.text) ?? 0;
    return v.clamp(_minBudget, _maxBudget);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.showSuccessToast('Tâche "${_titleController.text}" publiée pour ${CurrencyFormatter.formatCFA(_clampedBudget)} !');
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Publier une Tâche'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF5D3F6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header hint ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Publiez des petites tâches (entretien, nettoyage, réparations) pour votre propriété. Les locataires acceptent et soumettent des photos.',
                        style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────
              _buildLabel('Titre de la tâche'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _fieldDecoration('Ex: Tonte de gazon, Nettoyage couloir...', Icons.title),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.isEmpty) ? 'Veuillez saisir un titre' : null,
              ),
              const SizedBox(height: 20),

              // ── Description ──────────────────────────────
              _buildLabel('Description de la tâche'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: _fieldDecoration('Décrivez ce qui doit être fait en détail...', Icons.description),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // ── Budget ───────────────────────────────────
              _buildLabel('Budget (F CFA)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Entre 2 000 et 150 000 F CFA', Icons.attach_money),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null) return 'Montant invalide';
                  if (n < _minBudget) return 'Minimum ${CurrencyFormatter.formatCFA(_minBudget)}';
                  if (n > _maxBudget) return 'Maximum ${CurrencyFormatter.formatCFA(_maxBudget)}';
                  return null;
                },
              ),
              if (_budgetController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget ajusté :', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text(
                      CurrencyFormatter.formatCFA(_clampedBudget),
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // ── Property Dropdown ────────────────────────
              _buildLabel('Propriété concernée'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProperty,
                decoration: _fieldDecoration('Sélectionnez une propriété', Icons.home),
                items: _mockProperties
                    .map((p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProperty = v),
                validator: (v) => v == null ? 'Veuillez sélectionner une propriété' : null,
              ),
              const SizedBox(height: 20),

              // ── Target Date ──────────────────────────────
              _buildLabel('Date cible'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: _fieldDecoration(
                      _targetDate == null
                          ? 'Choisir une date...'
                          : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                      Icons.calendar_today,
                    ),
                    validator: (_) => _targetDate == null ? 'Veuillez choisir une date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Submit ───────────────────────────────────
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Publier la tâche', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));

  InputDecoration _fieldDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2)),
      );
}
