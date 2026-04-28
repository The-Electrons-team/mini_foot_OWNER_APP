import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl =
      dotenv.env['API_URL'] ?? 'http://localhost:3000/api/v1';

  Future<String?> savedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('COMPTE_NON_TROUVE');
    } else if (response.statusCode == 401) {
      throw Exception('ID_INVALIDES');
    } else {
      throw Exception('Erreur de connexion: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> startSignup(String phone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur d\'inscription: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Code invalide: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    String? birthDate,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'birthDate': birthDate,
        }..removeWhere((key, value) => value == null),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'enregistrement: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String phone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('COMPTE_NON_TROUVE');
    } else {
      throw Exception('Erreur réinitialisation: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String code,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('CODE_INVALIDE');
    } else {
      throw Exception('Erreur réinitialisation: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return _normalizeUser(jsonDecode(response.body));
    } else {
      throw Exception('Erreur profil: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return _normalizeUser(jsonDecode(response.body));
    } else {
      throw Exception('Erreur mise à jour profil: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> uploadAvatar({
    required String token,
    required File image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/users/me/avatar'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode == 200 || streamed.statusCode == 201) {
      return _normalizeUser(jsonDecode(body));
    }
    throw Exception('Erreur upload avatar: $body');
  }

  Future<Map<String, dynamic>> getPayoutInfo(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/payout-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur coordonnées paiement: ${response.body}');
  }

  Future<Map<String, dynamic>> updatePayoutInfo(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me/payout-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur coordonnées paiement: ${response.body}');
  }

  Future<void> requestPhoneChange({
    required String token,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/me/phone/request'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return;
    if (response.statusCode == 409) throw Exception('PHONE_ALREADY_USED');
    throw Exception('Erreur changement téléphone: ${response.body}');
  }

  Future<Map<String, dynamic>> confirmPhoneChange({
    required String token,
    required String phone,
    required String code,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me/phone/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'phone': phone, 'code': code}),
    );

    if (response.statusCode == 200) {
      return _normalizeUser(jsonDecode(response.body));
    }
    if (response.statusCode == 401) throw Exception('CODE_INVALIDE');
    if (response.statusCode == 409) throw Exception('PHONE_ALREADY_USED');
    throw Exception('Erreur changement téléphone: ${response.body}');
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/me/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('MOT_DE_PASSE_ACTUEL_INCORRECT');
    } else {
      throw Exception('Erreur mot de passe: ${response.body}');
    }
  }

  Map<String, dynamic> _normalizeUser(dynamic value) {
    final user = Map<String, dynamic>.from(value as Map);
    user['avatarUrl'] = _normalizeStorageUrl(user['avatarUrl']);
    return user;
  }

  String? _normalizeStorageUrl(dynamic value) {
    if (value is! String || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || uri.pathSegments.length < 2) return value;

    final isLocalMinio =
        (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
        uri.port == 9000;
    final bucket = uri.pathSegments.first;
    if (!isLocalMinio || bucket != 'minifoot-avatars') return value;

    final key = uri.pathSegments.skip(1).join('/');
    return '$_baseUrl/storage/avatars/$key';
  }
}
