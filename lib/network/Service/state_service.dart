import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Model/GlobalModels/state_model.dart';

class StateService {
  static const String _baseUrl = 'https://seekhelp.in/bhulex/get_all_state';

  Future<List<StateModel>> fetchStates() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'true') {
          final List<dynamic> stateList = data['data'];
          return stateList.map((json) => StateModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load states: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to load states. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching states: $e');
    }
  }
}
