import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';
import '../../core/local_colors.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({Key? key}) : super(key: key);

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allImages = [];
  List<Map<String, dynamic>> _filteredImages = [];
  
  List<String> _filters = ['Wszystkie'];
  String _selectedFilter = 'Wszystkie';

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    setState(() => _isLoading = true);
    
    final images = await _supabaseService.getRealizationsFromStorage();
    
    // Zbieramy unikalne filtry (foldery)
    Set<String> uniqueFolders = {};
    for (var img in images) {
      uniqueFolders.add(img['folderName']);
    }
    
    setState(() {
      _allImages = images;
      _filteredImages = images;
      _filters = ['Wszystkie', ...uniqueFolders.toList()..sort()];
      _isLoading = false;
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Wszystkie') {
        _filteredImages = _allImages;
      } else {
        _filteredImages = _allImages.where((img) => img['folderName'] == filter).toList();
      }
    });
  }
  
  // Wyszukuje pasującego koloru z zaimplementowanej biblioteki po tytule folderu
  Color _getFolderColor(String folderName) {
    final lowerName = folderName.toLowerCase();
    
    var match = LocalColors.rawList.firstWhere(
      (c) {
        final sym = (c['symbol'] ?? '').toLowerCase();
        return sym.isNotEmpty && lowerName.contains(sym);
      }, 
      orElse: () => <String, String?>{}
    );
    
    if (match.isEmpty) {
      match = LocalColors.rawList.firstWhere(
        (c) {
          final n = (c['name'] ?? '').toLowerCase();
          return n.isNotEmpty && lowerName.contains(n);
        }, 
        orElse: () => <String, String?>{}
      );
    }
    
    if (match.isNotEmpty && match['hex'] != null) {
      return _parseColor(match['hex']!);
    }
    return AppColors.accentRed;
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.tryParse(hex, radix: 16) ?? 0xFFD32F2F);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildFilters(),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentRed))
              : _filteredImages.isEmpty
                  ? Center(
                      child: Text(
                        'Brak realizacji w tej kategorii.',
                        style: TextStyle(color: AppColors.textSilver.withOpacity(0.7)),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.accentRed,
                      backgroundColor: AppColors.cardBackground,
                      onRefresh: _fetchGallery,
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium, vertical: 8),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70, 
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredImages.length,
                        itemBuilder: (context, index) {
                          final item = _filteredImages[index];
                          return _buildGalleryCard(context, item);
                        },
                      ),
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
                'Realizacje',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
              ),
              const Icon(Icons.auto_awesome, color: AppColors.accentRed),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Inspiracje od najlepszych studiów partnerskich z użyciem naszych folii NKODA.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSilver.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    if (_isLoading) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium, vertical: AppPadding.medium),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = filter == _selectedFilter;
            
            Widget filterWidget = Text(
              filter,
              style: TextStyle(
                color: isSelected ? AppColors.accentRed : AppColors.textSilver,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            );

            // Jeśli to konkretny kolor, renderujemy malutki kwadracik HEX
            if (filter != 'Wszystkie') {
              filterWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getFolderColor(filter),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  filterWidget,
                ],
              );
            }

            return GestureDetector(
              onTap: () => _onFilterSelected(filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentRed.withOpacity(0.1) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.accentRed.withOpacity(0.5) : AppColors.textSilver.withOpacity(0.1),
                    width: 1.5
                  ),
                ),
                child: filterWidget,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, Map<String, dynamic> item) {
    final String folderName = item['folderName'];
    final matchedColor = _getFolderColor(folderName);
    
    return GestureDetector(
      onTap: () {
        // Implementacja pożądanego efektu Full Screen np. w kolejnym kroku
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.network(
                item['url'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: AppColors.accentRed, strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1A1A1A), 
                  child: const Center(child: Icon(Icons.car_crash, color: Colors.white24, size: 40))
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.medium)),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.95), Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: matchedColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white38, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            folderName,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}
