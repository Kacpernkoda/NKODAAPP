import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'product_inquiry_dialog.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  void _showInquiryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductInquiryDialog(productName: product['name']),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dziękujemy! Zapytanie zostało wysłane pomyślnie.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSpecsGrid(),
                  const SizedBox(height: 32),
                  _buildFeaturesList(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'prod_${product['name']}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                product['thumbUrl'],
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withOpacity(0.8),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withOpacity(0.1),
                border: Border.all(color: AppColors.accentRed.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SERIA PREMIUM',
                style: TextStyle(color: AppColors.accentRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              product['material'] ?? 'TPU',
              style: TextStyle(color: AppColors.textSilver.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product['name'],
          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 12),
        Text(
          product['desc'],
          style: const TextStyle(color: AppColors.textSilver, fontSize: 16, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PARAMETRY TECHNICZNE',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _specItem('Lączna grubość', product['thickness'], Icons.layers_outlined),
            _specItem('Gwarancja', product['warranty'], Icons.verified_user_outlined),
            _specItem('Wykończenie', product['finish'], Icons.auto_awesome_outlined),
            _specItem('Poziom połysku', '${product['gloss']} / 100', Icons.light_mode_outlined),
          ],
        ),
      ],
    );
  }

  Widget _specItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSilver.withOpacity(0.5), fontSize: 10)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final List<dynamic> features = product['features'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KLUCZOWE CECHY',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
              const SizedBox(width: 12),
              Text(f, style: const TextStyle(color: AppColors.textSilver, fontSize: 15)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () => _showInquiryDialog(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
          ),
          child: const Text('ZAPYTAJ O PRODUKT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }
}
