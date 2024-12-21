import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://thondanapp.com/api/';
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'poster_check': 'HTRF35Poster90io@#Xcv100RF',
    'locale': 'en',
  };

  //Common method to handle POST request
  static Future<Map<String, dynamic>> _postRequest({
    required String endPoint,
    Map<String, String>? headers,
    Map<String, String>? body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endPoint'),
        headers: {..._defaultHeaders, if (headers != null) ...headers},
        body: body,
      );
      return _headerResponse(response);
    } catch (e) {
      return {'error': 'Exception caught: $e'};
    }
  }

  //Common method to handle GET request
  static Future<Map<String, dynamic>> _getRequest({
    required String endPoint,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endPoint'),
        headers: {..._defaultHeaders, if (headers != null) ...headers},
      );
      return _headerResponse(response);
    } catch (e) {
      return {'error': 'Exception caught: $e'};
    }
  }

  //method to handle header
  static Map<String, dynamic> _headerResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return {
        'error':
            'Failed with status code: ${response.statusCode}, reason: ${response.reasonPhrase}',
      };
    }
  }

  //method to handle login
  static Future<Map<String, dynamic>> loginUser({
    required String mobileNo,
    required String password,
    required String endPoint,
  }) {
    return _postRequest(
        endPoint: endPoint,
        body: {'p1_mobile': mobileNo, 'p1_password': password});
  }

  //method to handle Post
  static Future<Map<String, dynamic>> commonPostDataMethod({
    required String accesstoken,
    required String endPoint,
  }) {
    return _postRequest(
      endPoint: endPoint,
      headers: {'Authorization': 'Bearer $accesstoken'},
      body: {'locale': 'en'},
    );
  }
  // common method to handle Get
  static Future<Map<String, dynamic>> commonGetDataMethod({
    String? accesstoken,
    required String endPoint,
  }) {
    return _getRequest(endPoint: endPoint);
  }

  //method to handle Register
  
}
