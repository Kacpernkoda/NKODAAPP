import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';

class InquiryFormDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String colorName;
  final String colorSymbol;

  const InquiryFormDialog({
    Key? key,
    required this.imageBytes,
    required this.colorName,
    required this.colorSymbol,
  }) : super(key: key);

  @override
  State<InquiryFormDialog> createState() => _InquiryFormDialogState();
}

class _InquiryFormDialogState extends State<InquiryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedQuantity = 'Full body';
  bool _isSending = false;

  final List<String> _quantityOptions = ['Full body', 'Full front', 'Inne'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final supabase = SupabaseService();
      
      // 1. Upload zdjęcia do Storage (z zabezpieczeniem)
      String? imageUrl;
      try {
        imageUrl = await supabase.uploadVisualization(widget.imageBytes);
        if (imageUrl == null) {
          // Błahy błąd (np. brak bucketu) - informujemy w konsoli, ale nie rzucamy błędu do SnackBar
          print('OSTRZEŻENIE: Zdjęcie nie zostało przesłane. Próba wysłania samego formularza.');
        }
      } catch (e) {
        print('KRYTYCZNY BŁĄD UPLOADU: $e');
      }
      
      // 2. Zapisz leada w bazie (zawsze, nawet bez zdjęcia)
      final leadData = {
        'imie_firma': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'telefon': _phoneController.text.trim(),
        'marka_model': '${_brandController.text.trim()} ${_modelController.text.trim()}',
        'rok_produkcji': _yearController.text.trim(),
        'ilosc': _selectedQuantity,
        'kolor_symbol': '${widget.colorSymbol} (${widget.colorName})',
        'link_do_wizualizacji': imageUrl, // Może być null, jeśli upload zawiódł
        'notes': _notesController.text.trim(),
        'source': 'ai_visualization',
      };

      final success = await supabase.createLead(leadData);

      if (mounted) {
        if (success) {
          if (imageUrl == null) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Wysłano zapytanie (bez zdjęcia podglądowego)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          Navigator.pop(context, true); // Sukces - modal się zamyka
        } else {
          throw Exception('Błąd zapisu danych w bazie.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Zapytanie ofertowe',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Imię / Nazwa firmy', Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Adres E-mail', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Numer telefonu', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              const Text('Dane samochodu', style: TextStyle(color: AppColors.accentRed, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_brandController, 'Marka', Icons.directions_car_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_modelController, 'Model', Icons.model_training_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_yearController, 'Rok produkcji', Icons.calendar_today_outlined, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedQuantity,
                          dropdownColor: AppColors.cardBackground,
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: _quantityOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedQuantity = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_notesController, 'Uwagi / Pytania (opcjonalnie)', Icons.chat_bubble_outline, maxLines: 3, isRequired: false),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSending ? null : _submitInquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('WYŚLIJ ZAPYTANIE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.accentRed.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: AppColors.cardBackground,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentRed)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
      validator: isRequired ? (value) => value == null || value.isEmpty ? 'To pole jest wymagane' : null : null,
    );
  }
}
