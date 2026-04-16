import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  // Ciemny styl mapy (JSON)
  final String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{"color": "#121212"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#121212"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#3c3c3c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _loadInstallers();
  }

  Future<void> _loadInstallers() async {
    try {
      final data = await Supabase.instance.client
          .from('installers')
          .select()
          .not('latitude', 'is', null);

      if (mounted) {
        setState(() {
          _markers.clear();
          for (var installer in data) {
            final lat = (installer['latitude'] as num).toDouble();
            final lng = (installer['longitude'] as num).toDouble();
            
            final List<String> snippetParts = [];
            if (installer['miasto']?.toString().isNotEmpty == true) snippetParts.add(installer['miasto']);
            if (installer['adres']?.toString().isNotEmpty == true) snippetParts.add(installer['adres']);
            if (installer['email']?.toString().isNotEmpty == true) snippetParts.add(installer['email']);
            
            _markers.add(
              Marker(
                markerId: MarkerId(installer['id'].toString()),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: installer['nazwa_studia'],
                  snippet: snippetParts.join('\n'),
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Błąd ładowania markerów: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mapa Studiów', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(52.237049, 21.017532), // Centrum Polski (Warszawa)
              zoom: 6,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController?.setMapStyle(_mapStyle);
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.accentRed)),
          
          // Przyciski kontrolne (zoom)
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              children: [
                _buildMapControl(Icons.add, () => _mapController?.animateCamera(CameraUpdate.zoomIn())),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () => _mapController?.animateCamera(CameraUpdate.zoomOut())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onTap,
      backgroundColor: AppColors.cardBackground,
      child: Icon(icon, color: Colors.white),
    );
  }
}
