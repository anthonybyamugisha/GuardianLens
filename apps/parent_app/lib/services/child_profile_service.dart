import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/child_profile.dart';

class ChildProfileServiceException implements Exception {
  final String message;
  ChildProfileServiceException(this.message);
  @override
  String toString() => message;
}

class ChildProfileService {
  ChildProfileService({http.Client? client, this._token})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String? _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null && _token.isNotEmpty)
          'Authorization': 'Bearer $_token',
      };

  Uri _uri([String path = '']) =>
      Uri.parse('${ApiConfig.baseUrl}/api/children/$path');

  Future<List<ChildProfile>> listChildren() async {
    final response = await _client.get(_uri(), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => ChildProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ChildProfileServiceException(
      'Failed to load children (${response.statusCode})',
    );
  }

  Future<ChildProfile> createChild(ChildProfile child) async {
    final response = await _client.post(
      _uri(),
      headers: _headers,
      body: jsonEncode(child.toJson()),
    );
    if (response.statusCode == 201) {
      return ChildProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw ChildProfileServiceException(
      'Failed to create child (${response.statusCode}): ${response.body}',
    );
  }

  Future<ChildProfile> updateChild(ChildProfile child) async {
    if (child.id == null) {
      throw ChildProfileServiceException('Cannot update child without an id');
    }
    final response = await _client.put(
      _uri('${child.id}/'),
      headers: _headers,
      body: jsonEncode(child.toJson()),
    );
    if (response.statusCode == 200) {
      return ChildProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw ChildProfileServiceException(
      'Failed to update child (${response.statusCode})',
    );
  }

  Future<void> deleteChild(int id) async {
    final response = await _client.delete(_uri('$id/'), headers: _headers);
    if (response.statusCode != 204) {
      throw ChildProfileServiceException(
        'Failed to delete child (${response.statusCode})',
      );
    }
  }
}