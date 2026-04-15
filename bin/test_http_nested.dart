import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = Uri.parse('https://wljdozodcnzslcqbrpwu.supabase.co/storage/v1/object/list/Realizacje');
  final headers = {
    'apikey': 'sb_publishable_cc861E3tVRXPdvqKSoCLRg_cQNOru_t',
    'Authorization': 'Bearer sb_publishable_cc861E3tVRXPdvqKSoCLRg_cQNOru_t',
    'Content-Type': 'application/json'
  };
  
  final response = await http.post(url, headers: headers,
    body: jsonEncode({
      "prefix": "Amazon jungle", // To list inside the folder
      "limit": 100,
      "offset": 0,
      "sortBy": {"column": "name", "order": "asc"}
    })
  );

  print("STATUS CODE: ${response.statusCode}");
  print("BODY: ${response.body}");
}
