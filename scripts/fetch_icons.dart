// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Fetching icon metadata from Google...');
  
  try {
    // This is the official metadata URL used by fonts.google.com/icons
    final response = await http.get(Uri.parse('https://fonts.google.com/metadata/icons'));
    
    if (response.statusCode == 200) {
      // The response starts with )]}' which is a JSON-hijacking protection string
      final body = response.body.substring(response.body.indexOf('{'));
      final data = jsonDecode(body);
      
      final List icons = data['icons'];
      final Map<String, dynamic> result = {
        'host': data['host'],
        'icons': icons.map((icon) => {
          'name': icon['name'],
          'version': icon['version'],
          'categories': icon['categories'],
          'tags': icon['tags'],
        }).toList(),
      };
      
      final file = File('assets/metadata/icons.json');
      await file.writeAsString(JsonEncoder.withIndent('  ').convert(result));
      
      print('Successfully saved ${icons.length} icons to assets/metadata/icons.json');
    } else {
      print('Failed to fetch metadata: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
