import 'package:eduprime/pages/QuizPage.dart';
import 'package:flutter/material.dart';
import '../Service/ApiService.dart';

class ChatbotPage extends StatefulWidget {
  final String? level;
  final String? category;
  final int? score;
  final int? totalQuestions;
  ChatbotPage(
      {required this.level,
      required this.category,
      required this.score,
      required this.totalQuestions});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatMessage {
  final String text;
  final bool isUserMessage;

  _ChatMessage({required this.text, required this.isUserMessage});
}

class _ChatbotPageState extends State<ChatbotPage> {
  TextEditingController _messageController = TextEditingController();
  List<_ChatMessage> _chatMessages = [];
  String problem = '';
  String? correctAnswer; // Store the correct answer
  int? rating;
  int tries = 0;
  String? again;
  int? maxRating = 0;

  @override
  void initState() {
    super.initState();
    fetchProblem(); // Call fetchProblem when the page initializes
  }

  Future<void> fetchProblem() async {
    try {
      final problemText =
          await ApiService.fetchProblem(widget.category!, widget.level!);
      setState(() {
        problem = problemText;
      });
    } catch (error) {
      print('Error fetching problem: $error');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Problem'),
      ),
      body: Center(
        child: problem.isEmpty
            ? CircularProgressIndicator() // Show loading indicator while fetching problem
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(problem), // Display the fetched problem
                      SizedBox(height: 16),
                      TextField(
                        controller: _messageController,
                        maxLines: null, // Allow multiple lines
                        keyboardType: TextInputType
                            .multiline, // Enable multiline keyboard
                        decoration: InputDecoration(
                          hintText: 'Enter your answer',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (correctAnswer != null) Text('result: $again'),
                      SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () {
                          solveProblem();
                          
                        },
                        child: Text('Submit'),
                      ),
                      // Display correct answer if available
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  int extractRating(String? resultString) {
    // Split the string by ":"
    List<String> parts = resultString!.split(":");
    // Check if there are at least two parts
    if (parts.length >= 2) {
      // Get the second part which contains the rating
      String ratingPart = parts[1];
      // Split the rating part by "/"
      List<String> ratingParts = ratingPart.split("/");
      // Check if there are at least two parts
      if (ratingParts.length >= 2) {
        // Extract the rating value before the "/"
        String ratingValue = ratingParts[0].trim();
        // Convert the rating value to an integer
        int? rating = int.tryParse(ratingValue);
        return rating ?? 0; // Return 0 if parsing fails
      }
    }
    return 0; // Return 0 if parsing fails
  }

  void navToResult() {
   
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizResultsScreen(
                score: widget.score! + maxRating!,
                totalQuestions: widget.totalQuestions! + 10)));
  }

  Future<void> solveProblem() async {
    try {
      final userAnswer = _messageController.text.trim();
      print(userAnswer);
      final String answerText = await ApiService.solveProblem(
          widget.category!, widget.level!, problem, userAnswer);
      setState(() {
        correctAnswer =
            answerText; // Update correct answer returned from the backend
        rating = extractRating(correctAnswer);
        
      });
      rate();
      tries++;
      if (rating! < 7 && tries < 3) {
        setState(() {
          again = "your rating is ${rating}. you can try again";
        });
      } else {
        navToResult();
      }
    } catch (error) {
      print('Error fetching answer: $error');
      // Handle error as needed
    }
  }

  void rate() {
    if (rating! > maxRating!) {
      setState(() {
        maxRating = rating;
      });
    }
  }

  void _submitAnswer() {
    // Do something with the user's answer
    //print('User answer: $answer');

    // Optionally, you can clear the TextField after submitting
    _messageController.clear();
  }
}
