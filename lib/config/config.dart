import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  final String apiEndpoint;
  AppConfig({required this.apiEndpoint});

  static Future<AppConfig> load() async {
    final String jsonString =
        await rootBundle.loadString('assets/config/config.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return AppConfig(apiEndpoint: jsonMap['apiEndpoint']);
  }
}
