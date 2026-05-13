import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FunctionsException implements Exception {
  FunctionsException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => 'FunctionsException($statusCode): $message';
}

abstract class FunctionCaller {
  Future<Map<String, dynamic>> call(
    String functionName, [
    Map<String, dynamic>? data,
  ]);
}

class CloudFunctionClient implements FunctionCaller {
  CloudFunctionClient({http.Client? httpClient, FirebaseAuth? auth})
    : _http = httpClient ?? http.Client(),
      _auth = auth ?? FirebaseAuth.instance;

  final http.Client _http;
  final FirebaseAuth _auth;

  String _baseUrl() {
    if (kDebugMode) {
      final host = defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2'
          : '127.0.0.1';
      return 'http://$host:5001/smartnutri-dev-2e67b/us-central1';
    }
    return 'https://us-central1-smartnutri-dev-2e67b.cloudfunctions.net';
  }

  @override
  Future<Map<String, dynamic>> call(
    String functionName, [
    Map<String, dynamic>? data,
  ]) async {
    final url = Uri.parse('${_baseUrl()}/$functionName');

    final headers = <String, String>{'Content-Type': 'application/json'};

    // Attach auth token if user is signed in
    final user = _auth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      headers['Authorization'] = 'Bearer $token';
    }

    final http.Response response;
    try {
      response = await _http
          .post(
            url,
            headers: headers,
            body: data != null ? jsonEncode(data) : '{}',
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw FunctionsException('network_error');
    } catch (e) {
      throw FunctionsException('network_error');
    }

    final Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Response is not a JSON object');
      }
      body = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw FunctionsException('invalid_response', response.statusCode);
    }

    if (response.statusCode >= 400) {
      throw FunctionsException(
        body['error'] as String? ?? 'unknown_error',
        response.statusCode,
      );
    }

    return body;
  }

  void dispose() => _http.close();
}
