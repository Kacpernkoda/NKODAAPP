import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../services/ai_visualization_service.dart';
import 'inquiry_form.dart';
import '../../services/device_id_service.dart';
import '../../services/supabase_service.dart';

class VisualizationScreen extends StatefulWidget {
  final Map<String, String?> colorData;
  final Color parsedColor;

  const VisualizationScreen({
    Key? key,
    required this.colorData,
    required this.parsedColor,
  }) : super(key: key);

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  Uint8List? _resultImageBytes;
  bool _isProcessing = false;
  String? _errorMessage;

  late AnimationController _animController;
  int _remainingAttempts = 3;
  String? _deviceId;
  bool _isLoadingLimit = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initDeviceAndCheckLimit();
  }

  Future<void> _initDeviceAndCheckLimit() async {
    try {
      final id = await DeviceIdService.getDeviceId();
      final count = await SupabaseService().getAIUsageCount(id);
      
      if (mounted) {
        setState(() {
          _deviceId = id;
          _remainingAttempts = (3 - count).clamp(0, 3);
          _isLoadingLimit = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLimit = false);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() {
            _selectedImageBytes = bytes;
          });
          _processImage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Błąd podczas wyboru zdjęcia: $e';
        });
      }
    }
  }

  Future<void> _processImage() async {
    if (!mounted) return;

    if (_remainingAttempts <= 0) {
      _showLimitReachedDialog();
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _resultImageBytes = null;
    });

    try {
      final resultBytes = await AiVisualizationService().generateVehicleWrap(
        imageBytes: _selectedImageBytes!,
        colorHex: widget.colorData['hex'] ?? '000000',
        colorName: widget.colorData['name'] ?? 'Brak nazwy',
      );

      if (mounted) {
        // Logowanie udanej generacji w Supabase
        await SupabaseService().logAIVisualization(_deviceId!);
        
        setState(() {
          _isProcessing = false;
          _resultImageBytes = resultBytes;
          _remainingAttempts = (_remainingAttempts - 1).clamp(0, 3);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wizualizacja AI ✨', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppPadding.large),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: widget.parsedColor.withOpacity(0.5), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.parsedColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wybrany kolor foli', style: TextStyle(color: AppColors.textSilver.withOpacity(0.8), fontSize: 12)),
                          Text(
                            widget.colorData['name'] ?? '',
                            style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildLimitBadge(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isProcessing && _selectedImageBytes != null) {
      return _buildProcessingState();
    } else if (_resultImageBytes != null) {
      return _buildResultState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.drive_eta, size: 64, color: AppColors.accentRed),
          ),
          const SizedBox(height: 32),
          const Text(
            'Wgraj zdjęcie swojego auta',
            style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nasze algorytmy AI przeanalizują obraz i nałożą wybrany kolor na karoserię pojazdu w ułamku sekundy.',
            style: TextStyle(color: AppColors.textSilver, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Zrób zdjęcie teraz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Wybierz z galerii'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: MemoryImage(_selectedImageBytes!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Positioned(
                  top: _animController.value * 250,
                  width: 250,
                  height: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      boxShadow: [
                        BoxShadow(color: AppColors.accentRed.withOpacity(0.8), blurRadius: 10, spreadRadius: 3),
                      ],
                    ),
                  ),
                );
              },
            ),
            const CircularProgressIndicator(color: AppColors.accentRed),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Silnik Generatywny w trakcie pracy...',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rozpoznawanie maski i nakładanie koloru\nProszę czekać.',
          style: TextStyle(color: AppColors.textSilver, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.large),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _resultImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppPadding.large),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Sukces! Wizualizacja gotowa.',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Zapisz do galerii', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zapisano w galerii!')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('WYŚLIJ ZAPYTANIE OFERTOWE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.accentRed, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showInquiryForm(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _resultImageBytes = null;
                      _selectedImageBytes = null;
                    });
                  },
                  child: const Text('Zrób kolejne zdjęcie', style: TextStyle(color: AppColors.textSilver)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.large),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.accentRed, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Błąd sztucznej inteligencji',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Wystąpił nieznany błąd podczas łączenia z silnikiem AI.',
            style: const TextStyle(color: AppColors.textSilver, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _selectedImageBytes = null;
              });
            },
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  void _showInquiryForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InquiryFormDialog(
        imageBytes: _resultImageBytes!,
        colorName: widget.colorData['name'] ?? 'Brak nazwy',
        colorSymbol: widget.colorData['symbol'] ?? 'Brak symbolu',
      ),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zapytanie zostało wysłane pomyślnie!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Widget _buildLimitBadge() {
    if (_isLoadingLimit) {
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _remainingAttempts > 0 ? Colors.green.withOpacity(0.2) : AppColors.accentRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _remainingAttempts > 0 ? Colors.green.withOpacity(0.5) : AppColors.accentRed.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Limit',
            style: TextStyle(
              color: AppColors.textSilver.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$_remainingAttempts/3',
            style: TextStyle(
              color: _remainingAttempts > 0 ? Colors.greenAccent : AppColors.accentRed,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: AppColors.accentRed),
            SizedBox(width: 12),
            Text('Limit wyczerpany', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Wykorzystałeś już swój dzienny limit 3 wizualizacji AI. Zapraszamy ponownie za 24 godziny!',
          style: TextStyle(color: AppColors.textSilver),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ROZUMIEM', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
