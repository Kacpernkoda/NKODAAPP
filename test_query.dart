import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://wljdozodcnzslcqbrpwu.supabase.co', 'sb_publishable_cc861E3tVRXPdvqKSoCLRg_cQNOru_t');
  
  try {
    final response = await supabase.from('installers').select();
    print("ZNALEZIONO REKORDÓW: ${response.length}");
    for (var r in response) {
      print("${r['id']} - ${r['nazwa_studia']}");
    }
  } catch (e) {
    print("BŁĄD POBIERANIA STUDIÓW: $e");
  }
}
