import 'dart:convert';
import 'package:eduprime/models/Quiz.dart';
import 'package:eduprime/models/User.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _baseUrl = "localhost:9090";

  static Future<List<User>> login(
      {int page = 0, int limit = 5, String query = ''}) async {
    var url = Uri.parse('$_baseUrl/login?page=$page&limit=$limit&query=$query');
    try {
      final response =
          await http.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.map((quizJson) => User.fromJson(quizJson)).toList();
      } else {
        throw Exception(
            'Failed to load quiz results. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Quiz> fetchQuizQuestion(String category, String level) async {
  final url = Uri.parse('http://localhost:5001/api/quiz');
  final response =
      await http.post(url, body: {'category': category, 'level': level});

  if (response.statusCode == 201) {
    final data = json.decode(response.body) as Map<String, dynamic>?;

    if (data != null) {
      return Quiz.fromJson(data);
    } else {
      throw Exception('Received null response');
    }
  } else {
    throw Exception('Failed to load question');
  }
}

static Future<String> fetchProblem(String category, String level) async {
    final url = Uri.parse('http://localhost:5001/api/prob');
    final response = await http.post(url, body: {'category': category, 'level': level});

    if (response.statusCode == 201) {
      final data = json.decode(response.body);

      if (data != null) {
        return data.toString(); // Convert data to string
      } else {
        throw Exception('Received null response');
      }
    } else {
      throw Exception('Failed to load question');
    }
  }

  static Future<String> solveProblem(String category, String level,String prob,String answer) async {
    final url = Uri.parse('http://localhost:5001/api/solve');
    print(answer);
    final response = await http.post(url, body: {'category': category, 'level': level, 'problem':prob,'myAnswer':answer});

    if (response.statusCode == 201) {
      final data = json.decode(response.body);

      if (data != null) {
        return data.toString(); // Convert data to string
      } else {
        throw Exception('Received null response');
      }
    } else {
      throw Exception('Failed to load question');
    }
  }

}
