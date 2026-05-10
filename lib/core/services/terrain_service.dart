import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TerrainService {
  final String _base = dotenv.env['API_URL'] ?? 'http://localhost:3000/api/v1';

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await _token()}',
  };

  // ── GET /terrains/mine ─────────────────────────────────────────────────────
  Future<List<dynamic>> getMesTerrains() async {
    final response = await http.get(
      Uri.parse('$_base/terrains/mine'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['data'] as List<dynamic>)
          .map((item) => _normalizeTerrain(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur chargement terrains: ${response.body}');
  }

  Map<String, dynamic> _normalizeTerrain(Map<String, dynamic> terrain) {
    final normalized = Map<String, dynamic>.from(terrain);
    normalized['imageUrl'] = _normalizeStorageUrl(normalized['imageUrl']);
    normalized['imageUrls'] = (normalized['imageUrls'] as List<dynamic>? ?? [])
        .map(_normalizeStorageUrl)
        .whereType<String>()
        .toList();
    return normalized;
  }

  String? _normalizeStorageUrl(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || uri.pathSegments.length < 2) return value;

    final isLocalMinio =
        (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
        uri.port == 9000;
    final bucket = uri.pathSegments.first;
    if (!isLocalMinio || bucket != 'minifoot-terrains') return value;

    final key = uri.pathSegments.skip(1).join('/');
    return '$_base/storage/terrains/$key';
  }

  // ── POST /terrains ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> creerTerrain(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_base/terrains'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Erreur création terrain: ${response.body}');
  }

  // ── PATCH /terrains/:id ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> modifierTerrain(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$_base/terrains/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Erreur modification terrain: ${response.body}');
  }

  // ── DELETE /terrains/:id ───────────────────────────────────────────────────
  Future<void> supprimerTerrain(String id) async {
    final response = await http.delete(
      Uri.parse('$_base/terrains/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression terrain: ${response.body}');
    }
  }

  // ── GET /terrains/:id/slots?date=YYYY-MM-DD ────────────────────────────────
  Future<List<dynamic>> getCreneaux(
    String terrainId,
    String date, {
    String? subTerrainId,
  }) async {
    final uri = Uri.parse('$_base/terrains/$terrainId/slots').replace(
      queryParameters: {
        'date': date,
        if (subTerrainId != null && subTerrainId.isNotEmpty)
          'subTerrainId': subTerrainId,
      },
    );
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Erreur chargement créneaux: ${response.body}');
  }

  // ── POST /terrains/:id/slots/block ─────────────────────────────────────────
  Future<void> bloquerCreneau(
    String terrainId,
    String date,
    String slot, {
    String? subTerrainId,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/terrains/$terrainId/slots/block'),
      headers: await _headers(),
      body: jsonEncode({
        'date': date,
        'slot': slot,
        if (subTerrainId != null && subTerrainId.isNotEmpty)
          'subTerrainId': subTerrainId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur blocage créneau: ${response.body}');
    }
  }

  // ── DELETE /terrains/:id/slots/block ───────────────────────────────────────
  Future<void> debloquerCreneau(
    String terrainId,
    String date,
    String slot, {
    String? subTerrainId,
  }) async {
    final request = http.Request(
      'DELETE',
      Uri.parse('$_base/terrains/$terrainId/slots/block'),
    );
    request.headers.addAll(await _headers());
    request.body = jsonEncode({
      'date': date,
      'slot': slot,
      if (subTerrainId != null && subTerrainId.isNotEmpty)
        'subTerrainId': subTerrainId,
    });
    final streamed = await request.send();
    if (streamed.statusCode != 200 && streamed.statusCode != 204) {
      throw Exception('Erreur déblocage créneau');
    }
  }

  // ── POST /terrains/:id/images ──────────────────────────────────────────────
  Future<void> uploadImages(String terrainId, List<File> images) async {
    final token = await _token();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base/terrains/$terrainId/images'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    for (final image in images) {
      request.files.add(await http.MultipartFile.fromPath('files', image.path));
    }
    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur upload images');
    }
  }
}
