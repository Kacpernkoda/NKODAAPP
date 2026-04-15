import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://wljdozodcnzslcqbrpwu.supabase.co', 'sb_publishable_cc861E3tVRXPdvqKSoCLRg_cQNOru_t');
  
  try {
    final buckets = await supabase.storage.listBuckets();
    print("BUCKETS FOUND: ${buckets.length}");
    for (var b in buckets) {
      print("BUCKET ID: '${b.id}', NAME: '${b.name}'");
    }
  } catch (e) {
    print("ERROR LISTING BUCKETS: $e");
  }
}
