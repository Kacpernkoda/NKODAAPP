import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import 'map_view_screen.dart';

class MapTab extends StatefulWidget {
  const MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Wszystkie';

  final List<Map<String, dynamic>> _allStudios = [];
  List<Map<String, dynamic>> _filteredStudios = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudios();
    _searchController.addListener(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  Future<void> _fetchStudios() async {
    try {
      final data = await Supabase.instance.client
          .from('installers')
          .select()
          .order('nazwa_studia', ascending: true);

      if (mounted) {
        setState(() {
          _allStudios.clear();
          for (var row in data) {
            _allStudios.add({
              'name': row['nazwa_studia'] ?? '',
              'city': row['miasto'] ?? '',
              'province': row['wojewodztwo'] ?? '',
              'address': row['adres'] ?? '',
              'authorized': row['status_autoryzacji'] == true,
              'phone': row['telefon'] ?? '',
              'email': row['email'] ?? '',
            });
          }
          _filteredStudios = List.from(_allStudios);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Błąd pobierania danych: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = List.from(_allStudios);

    // Wyszukiwanie tylko po nazwie i mieście instalatora
    if (_searchQuery.isNotEmpty) {
      results = results.where((s) {
        final text = '${s['name']} ${s['city']} ${s['province']}'.toLowerCase();
        return text.contains(_searchQuery);
      }).toList();
    }

    // Filtracja tagów (Chip)
    if (_selectedFilter == 'Autoryzowane NKODA') {
      results = results.where((s) => s['authorized'] == true).toList();
    }

    setState(() {
      _filteredStudios = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentRed))
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.accentRed)))
                      : _filteredStudios.isEmpty
                          ? const Center(
                              child: Text('Brak wyników', style: TextStyle(color: AppColors.textSilver)),
                            )
                          : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredStudios.length,
                      itemBuilder: (context, index) {
                        return _buildStudioCard(_filteredStudios[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapViewScreen()),
          );
        },
        backgroundColor: AppColors.accentRed,
        icon: const Icon(Icons.map, color: Colors.white),
        label: const Text('WIDOK MAPY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppPadding.medium, AppPadding.large, AppPadding.medium, AppPadding.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sieć Partnerska',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Znajdź certyfikowane studio na mapie aplikatorów.',
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
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.textSilver.withOpacity(0.1)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: const InputDecoration(
            hintText: 'Wpisz miasto, województwo lub nazwę...',
            hintStyle: TextStyle(color: Colors.white30),
            prefixIcon: Icon(Icons.search, color: AppColors.textSilver),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium, vertical: AppPadding.medium),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildChip('Wszystkie'),
            const SizedBox(width: 8),
            _buildChip('Autoryzowane NKODA'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilters();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentRed.withOpacity(0.15) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentRed.withOpacity(0.5) : AppColors.textSilver.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.accentRed : AppColors.textSilver,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStudioCard(Map<String, dynamic> studio) {
    final bool isAuth = studio['authorized'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppPadding.medium),
      padding: const EdgeInsets.all(AppPadding.medium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isAuth ? AppColors.accentRed.withOpacity(0.4) : Colors.white12,
          width: isAuth ? 1.5 : 1,
        ),
        boxShadow: isAuth
            ? [
                BoxShadow(
                  color: AppColors.accentRed.withOpacity(0.08),
                  blurRadius: 15,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studio['name'],
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${studio['address']} (${studio['city']}, ${studio['province']})',
                      style: const TextStyle(
                        color: AppColors.textSilver,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAuth)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.verified,
                    color: AppColors.accentRed,
                    size: 26,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppPadding.medium),
          Row(
            children: [
              Icon(Icons.phone_outlined, color: AppColors.textSilver.withOpacity(0.5), size: 16),
              const SizedBox(width: 4),
              Text(
                studio['phone']?.isNotEmpty == true ? studio['phone'] : 'Brak telefonu',
                style: TextStyle(
                  color: AppColors.textSilver.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              _buildActionButton(Icons.phone_outlined, 'Zadzwoń'),
              const SizedBox(width: 8),
              _buildActionButton(Icons.directions_outlined, 'Trasa', isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isPrimary = false}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.accentRed : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isPrimary ? Colors.transparent : AppColors.textSilver.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isPrimary ? AppColors.textWhite : AppColors.textSilver,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? AppColors.textWhite : AppColors.textSilver,
                fontSize: 12,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
