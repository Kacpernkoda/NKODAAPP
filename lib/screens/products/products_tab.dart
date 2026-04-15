import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/local_colors.dart';
import '../visualization/visualization_screen.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({Key? key}) : super(key: key);

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  String _searchQuery = '';
  late List<Map<String, String?>> _filteredColors;

  @override
  void initState() {
    super.initState();
    _filteredColors = LocalColors.rawList;
  }

  void _filterColors(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredColors = LocalColors.rawList;
      } else {
        _filteredColors = LocalColors.rawList.where((color) {
          final symbol = color['symbol']?.toLowerCase() ?? '';
          final name = color['name']?.toLowerCase() ?? '';
          final q = query.toLowerCase();
          return symbol.contains(q) || name.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(
            child: _filteredColors.isEmpty
                ? const Center(
                    child: Text('Brak wyników', style: TextStyle(color: AppColors.textSilver)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium, vertical: AppPadding.medium),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredColors.length,
                    itemBuilder: (context, index) {
                      return _buildColorSquare(context, _filteredColors[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppPadding.medium, AppPadding.large, AppPadding.medium, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Katalog Kolorów',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
              ),
              const Icon(Icons.style, color: AppColors.accentRed),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Poznaj naszą flagową serię kolorowych folii.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSilver.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium, vertical: 8),
      child: TextField(
        onChanged: _filterColors,
        decoration: InputDecoration(
          hintText: 'Szukaj po nazwie lub symbolu...',
          hintStyle: const TextStyle(color: AppColors.textSilver),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSilver),
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: AppColors.textWhite),
      ),
    );
  }

  Widget _buildColorSquare(BuildContext context, Map<String, String?> colorData) {
    final hexString = colorData['hex'];
    final bool hasColor = hexString != null && hexString.isNotEmpty;
    final Color parsedColor = _parseColor(hexString ?? '#2a2a2a');

    return GestureDetector(
      onTap: () => _showColorModal(context, colorData, parsedColor, hasColor),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: parsedColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.medium)),
                ),
                child: !hasColor 
                  ? const Center(child: Icon(Icons.pattern, color: Colors.white24, size: 40)) 
                  : null,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.medium)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    colorData['symbol'] ?? '',
                    style: const TextStyle(
                      color: AppColors.accentRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    colorData['name'] ?? '',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorModal(BuildContext context, Map<String, String?> colorData, Color bgColor, bool hasColor) {
    final symbol = colorData['symbol'] ?? '';
    // Używamy oryginalnego symbolu z bazy (myślniki zostają myślnikami)
    final imageName = Uri.encodeComponent(symbol);
    final imageUrl = '${LocalColors.supabaseBucketBaseUrl}$imageName.webp';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppPadding.medium),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accentRed),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported, color: Colors.white24, size: 64),
                        const SizedBox(height: 16),
                        Text('Brak zdjęcia dla $symbol', style: const TextStyle(color: AppColors.textSilver)),
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppPadding.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: !hasColor ? const Icon(Icons.pattern, color: Colors.white24) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                colorData['name'] ?? '',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                symbol,
                                style: const TextStyle(
                                  color: AppColors.accentRed, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    _buildInfoRow('Kod HEX', hasColor ? (colorData['hex'] ?? '') : 'Brak danych'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Format', 'Pełna rolka'),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('✨ Zrób wizualizację auta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.accentRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                          shadowColor: AppColors.accentRed.withOpacity(0.5),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VisualizationScreen(
                                colorData: colorData,
                                parsedColor: bgColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSilver, fontSize: 16)),
        Text(value, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontFamily: 'monospace', fontSize: 16)),
      ],
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.tryParse(hex, radix: 16) ?? 0xFF2A2A2A);
  }
}
