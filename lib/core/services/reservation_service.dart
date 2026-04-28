import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  final String _base = dotenv.env['API_URL'] ?? 'http://localhost:3000/api/v1';

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await _token()}',
  };

  Future<List<dynamic>> getOwnerReservations({String? status}) async {
    final uri = Uri.parse('$_base/reservations/owner/mine').replace(
      queryParameters: status == null || status.isEmpty
          ? null
          : {'status': status},
    );

    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) return body;
      if (body is Map<String, dynamic>) {
        return body['data'] as List<dynamic>? ?? [];
      }
      return [];
    }
    throw Exception('Erreur chargement réservations: ${response.body}');
  }

  Future<void> cancelOwnerReservation(String id) async {
    final response = await http.patch(
      Uri.parse('$_base/reservations/owner/$id/cancel'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur annulation réservation: ${response.body}');
    }
  }
}
