import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Quiz.dart';
import '../models/User.dart';
import '../models/category.dart';
import '../models/problem.dart';
import 'package:http_parser/http_parser.dart';

import 'SharedPrefService.dart';

class ApiService {
  final String baseUrl = "http://localhost:5001";
final SharedPrefService sharedPrefService = SharedPrefService();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data["accessToken"];
      final prefs = await SharedPreferences.getInstance();
      if (data['accessToken'] != null) {
        await prefs.setString('accessToken', data['accessToken']);
      }
      if (data['refreshToken'] != null) {
        await prefs.setString('refreshToken', data['refreshToken']); // Store refresh token too
      }
      if (data['user'] != null ) { // Check if user exists and is a Map
        try {
          print(data['user']);
          // Encode the Map into a JSON String
          final User user = User.fromJson(data['user']);
          print(user.image);
          await sharedPrefService.saveUser(user); // Now passing a User object
        } catch (e) {
          print("Error encoding user data: $e"); // Debug log error
        }
      } else {
        print("User data not found or not a Map in response."); // Debug log
        // Optionally remove existing invalid user data if needed
        // await prefs.remove('user');
      }
      return token;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/signup');
    var request = http.MultipartRequest('POST', uri);
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['name'] = username;
    request.fields['password_confirmation'] = password;

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      if (data['accessToken'] != null) {
        await prefs.setString('accessToken', data['accessToken']);
      }
      if (data['refreshToken'] != null) {
        await prefs.setString('refreshToken', data['refreshToken']); // Store refresh token too
      }
      if (data['user'] != null) {
        print(data['user']);
        // Encode the Map into a JSON String
        final User user = User.fromJson(data['user']);
        await sharedPrefService.saveUser(user); // Now passing a User object
      }
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': response.body};
    }
  }


  Future<Quiz> fetchQuizQuestion(String category, String level) async {
    final url = Uri.parse('$baseUrl/api/quiz');
    final response =
    await http.post(url, body: {'category': category, 'level': level});

    if (response.statusCode == 200) {
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

  Future<Quiz> fetchQuizQuestionn(
      String category,
      String level,
      List<String> excludeIds,
      ) async {
    print("-----------------------------------------------");
    print("Category: $category");
    print("Level: $level");
    print("Exclude IDs: $excludeIds");

    try {
      final url = Uri.parse('$baseUrl/api/quizz');

      // Properly encode the entire request body as JSON
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // Important header
        body: json.encode({
          'category': category,
          'level': level,
          'excludeIds': excludeIds,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return Quiz.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load quiz question. Status: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching quiz question: $e");
      throw Exception('Failed to load quiz question: ${e.toString()}');
    }
  }


   Future<String> fetchProblem(String category, String level) async {
    final url = Uri.parse('$baseUrl/api/prob');
    final response = await http.post(
        url, body: {'category': category, 'level': level});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Problem prob = Problem.fromJson(data);

      if (data != null) {
        return prob.problem; // Convert data to string
      } else {
        throw Exception('Received null response');
      }
    } else {
      throw Exception('Failed to load question');
    }
  }

   Future<String> solveProblem(String category, String level, String prob,
      String answer) async {
    final url = Uri.parse('$baseUrl/api/solve');
    print(answer);
    final response = await http.post(url, body: {
      'category': category,
      'level': level,
      'problem': prob,
      'myAnswer': answer
    });

    if (response.statusCode == 200) {
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


  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/category');

    try {
      final response = await http.get(
          url, headers: {"Content-Type": "application/json"});

      // Check if the server returned a 200 OK response
      if (response.statusCode == 200) {
        // Decode response to a list of category objects
        final List<dynamic> data = json.decode(response.body);

        // Map each category from JSON to the Dart object
        return data.map((categoryJson) => Category.fromJson(categoryJson))
            .toList();
      } else {
        // If the server did not return a 200 OK response, throw an error
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any network or JSON parsing errors
      print("Error: $e");
      throw Exception('Error fetching categories: $e');
    }
  }
}




