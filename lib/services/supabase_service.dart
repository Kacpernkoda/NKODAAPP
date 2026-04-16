import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Pobieranie wszystkich produktów (folii)
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _client.from('products').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania produktów: $e');
      return [];
    }
  }

  // Pobieranie wszystkich instalatorów
  Future<List<Map<String, dynamic>>> getInstallers() async {
    try {
      final response = await _client.from('installers').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania instalatorów: $e');
      return [];
    }
  }

  // Pobieranie realizacji
  Future<List<Map<String, dynamic>>> getRealizations() async {
    try {
      final response = await _client.from('realizations').select('''
        *,
        products ( nazwa, seria ),
        installers ( nazwa_studia )
      ''');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Błąd pobierania realizacji: $e');
      return [];
    }
  }

  // Pobieranie realizacji bezpośrednio z plików Storage
  Future<List<Map<String, dynamic>>> getRealizationsFromStorage() async {
    try {
      final List<Map<String, dynamic>> allImages = [];
      const String bucketUrl = 'https://wljdozodcnzslcqbrpwu.supabase.co/storage/v1/object/list/Realizacje';
      const String anonKey = 'sb_publishable_cc861E3tVRXPdvqKSoCLRg_cQNOru_t';
      
      final headers = {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json'
      };

      final responseFolders = await http.post(
        Uri.parse(bucketUrl),
        headers: headers,
        body: jsonEncode({"prefix": "", "limit": 100, "offset": 0, "sortBy": {"column": "name", "order": "asc"}})
      );
      
      if (responseFolders.statusCode == 200) {
        final List<dynamic> folders = jsonDecode(responseFolders.body);
        
        for (var folderData in folders) {
          final String folderName = folderData['name'];
          
          if (folderName.isNotEmpty && folderName != '.emptyFolderPlaceholder') {
            final responseFiles = await http.post(
              Uri.parse(bucketUrl),
              headers: headers,
              body: jsonEncode({"prefix": folderName, "limit": 100, "offset": 0, "sortBy": {"column": "name", "order": "asc"}})
            );

            if (responseFiles.statusCode == 200) {
               final List<dynamic> files = jsonDecode(responseFiles.body);
               
               for (var fileData in files) {
                 final String fileName = fileData['name'];
                 final String lowerName = fileName.toLowerCase();
                 
                 if (lowerName.endsWith('.webp') || lowerName.endsWith('.jpg') || lowerName.endsWith('.png') || lowerName.endsWith('.jpeg')) {
                    final exactFileName = fileName.replaceFirst('$folderName/', '');
                    final String encodedFolder = Uri.encodeComponent(folderName);
                    final String encodedFile = Uri.encodeComponent(exactFileName);
                    
                    final String publicUrl = 'https://wljdozodcnzslcqbrpwu.supabase.co/storage/v1/object/public/Realizacje/$encodedFolder/$encodedFile';
                    
                    allImages.add({
                      'folderName': folderName,
                      'fileName': exactFileName,
                      'url': publicUrl,
                    });
                 }
               }
            }
          }
        }
      }
      
      allImages.shuffle();
      return allImages;
    } catch (e) {
      print('Błąd pobierania realizacji z HTTP: $e');
      return [];
    }
  }

  // Przesyłanie wizualizacji do Storage
  Future<String?> uploadVisualization(Uint8List bytes) async {
    try {
      final String fileName = 'viz_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'inquiries/$fileName';
      
      await _client.storage.from('visualizations').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      
      return _client.storage.from('visualizations').getPublicUrl(path);
    } catch (e) {
      print('BŁĄD SUPABASE STORAGE (uploadVisualization): $e');
      print('Wskazówka: Upewnij się, że bucket "visualizations" istnieje i jest publiczny.');
      return null;
    }
  }

  // Zapisywanie nowego leada
  Future<bool> createLead(Map<String, dynamic> leadData) async {
    try {
      // 1. Zapisz w bazie danych
      await _client.from('leads').insert(leadData);

      // 2. Wyślij powiadomienie e-mail przez Edge Function
      try {
        await _client.functions.invoke(
          'send-lead-email',
          body: {
            'name': leadData['imie_firma'],
            'email': leadData['email'],
            'phone': leadData['telefon'],
            'message': leadData['source'] == 'product_catalog' 
                ? (leadData['notes']?.toString().isNotEmpty == true ? leadData['notes'] : 'Brak dodatkowych uwag.') 
                : 'Samochód: ${leadData['marka_model'] ?? 'Brak'}\nRok: ${leadData['rok_produkcji'] ?? 'Brak'}\nIlość: ${leadData['ilosc'] ?? 'Brak'}\nWizualizacja: ${leadData['link_do_wizualizacji'] ?? 'Brak'}\nUwagi: ${leadData['notes'] ?? 'Brak'}',
            'productName': leadData['source'] == 'product_catalog' 
                ? (leadData['product_name'] ?? 'Ogólne zapytanie') 
                : (leadData['kolor_symbol'] ?? 'Wizualizacja AI'),
          },
        );
      } catch (e) {
        // Nawet jeśli e-mail się nie wyśle, zwracamy true, bo lead jest w bazie
        print('Błąd wysyłki e-mail: $e');
      }

      return true;
    } catch (e) {
      print('Błąd zapisu leada: $e');
      return false;
    }
  }

  // Sprawdzanie limitu generacji AI (ostatnie 24h)
  Future<int> getAIUsageCount(String deviceId) async {
    try {
      final String yesterday = DateTime.now()
          .subtract(const Duration(hours: 24))
          .toUtc()
          .toIso8601String();

      final List<dynamic> response = await _client
          .from('ai_generations')
          .select('id')
          .eq('device_id', deviceId)
          .gt('created_at', yesterday);

      return response.length;
    } catch (e) {
      print('Błąd sprawdzania limitu AI: $e');
      return 0; // W razie błędu pozwalamy spróbować, by nie blokować użytkownika bez powodu
    }
  }

  // Logowanie nowej generacji AI
  Future<void> logAIVisualization(String deviceId) async {
    try {
      await _client.from('ai_generations').insert({
        'device_id': deviceId,
      });
    } catch (e) {
      print('Błąd logowania generacji AI: $e');
    }
  }
}
