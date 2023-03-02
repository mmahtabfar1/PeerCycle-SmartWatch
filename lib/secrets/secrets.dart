import 'dart:convert';

import 'package:flutter/services.dart';

class Secrets {
  static const String _secretPath = "lib/secrets/secrets.json";

  static Future<Map<String, dynamic>> getSecrets() async {
    String json = await rootBundle.loadString(_secretPath, cache: true);
    return jsonDecode(json);
  }
}
