import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../api/api_endpoints.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  String? _token;

  Future<void> _getToken() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }
  }

  // الحصول على قائمة المحافظات
  Future<GovernorateResponse> getGovernorates() async {
    try {
      await _getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoints.getgovernoratesUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GovernorateResponse.fromJson(data);
      } else {
        throw Exception('Failed to load governorates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting governorates: $e');
      rethrow;
    }
  }

  // الحصول على قائمة المدن حسب المحافظة
  Future<CityResponse> getCitiesByGovernorate(int governorateId) async {
    try {
      await _getToken();
      final response = await http.get(
        Uri.parse('${ApiEndpoints.getcitiesbygovernorateUrl}$governorateId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CityResponse.fromJson(data);
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting cities: $e');
      rethrow;
    }
  }
}