import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';

class ProductInquiryDialog extends StatefulWidget {
  final String productName;

  const ProductInquiryDialog({Key? key, required this.productName}) : super(key: key);

  @override
  State<ProductInquiryDialog> createState() => _ProductInquiryDialogState();
}

class _ProductInquiryDialogState extends State<ProductInquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final supabase = SupabaseService();
      final leadData = {
        'imie_firma': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'telefon': _phoneController.text.trim(),
        'notes': _messageController.text.trim(),
        'product_name': widget.productName,
        'source': 'product_catalog',
      };

      final success = await supabase.createLead(leadData);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Błąd podczas wysyłania. Spróbuj ponownie.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wystąpił błąd: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Zapytaj o ${widget.productName}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Zostaw swoje dane, a nasz doradca skontaktuje się z Tobą wkrótce.',
                style: TextStyle(color: AppColors.textSilver, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Imię lub Nazwa Firmy',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Podaj swoje imię lub nazwę firmy' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Adres E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'Podaj poprawny e-mail' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Numer Telefonu',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Podaj numer telefonu' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _messageController,
                label: 'Uwagi / Pytania',
                icon: Icons.chat_bubble_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitInquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('WYŚLIJ ZAPYTANIE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSilver, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.accentRed, size: 20),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accentRed, width: 1)),
        errorStyle: const TextStyle(color: AppColors.accentRed),
      ),
    );
  }
}
