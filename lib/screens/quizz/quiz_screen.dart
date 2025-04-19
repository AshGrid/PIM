import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_frontend/screens/quizz/problemChat.dart';
import '../../Service/ApiService.dart';
import '../../models/Quiz.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String level;

  const QuizScreen({
    required this.category,
    required this.level,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _apiService = ApiService();
  final List<String> _seenQuestionIds = [];
  Quiz? _currentQuiz;
  String? _selectedAnswer;
  int _score = 0;
  int _questionCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNewQuestion();
  }

  Future<void> _fetchNewQuestion() async {
    if (_questionCount >= 3) {
      _navigateToChatPage();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newQuiz = await _apiService.fetchQuizQuestionn(
        widget.category,
        widget.level,
        _seenQuestionIds,
      );

      if (newQuiz != null) {
        setState(() {
          _currentQuiz = newQuiz;
          _seenQuestionIds.add(newQuiz.id);
          _questionCount++;
          _selectedAnswer = null;
        });
      } else {
        if (_questionCount >= 3) {
          _navigateToChatPage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Not enough questions available")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading quiz: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToChatPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotPage(
          score: _score,
          totalQuestions: _questionCount,
          category: widget.category,
          level: widget.level,
        ),
      ),
    );
  }

  void _handleNextQuestion() {
    if (_selectedAnswer == _currentQuiz?.correctAnswer) {
      setState(() => _score++);
    }
    _fetchNewQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${widget.category} Quiz",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "Question ${_questionCount}/3",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D0EB5), Color(0xFF4059F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading || _currentQuiz == null
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          _currentQuiz!.question,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ..._currentQuiz!.choices.map((choice) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedAnswer == choice
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.2),
                                foregroundColor: _selectedAnswer == choice
                                    ? Colors.deepPurple
                                    : Colors.white,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() => _selectedAnswer = choice);
                              },
                              child: Text(
                                choice,
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _selectedAnswer != null
                        ? _handleNextQuestion
                        : null,
                    child: Text(_questionCount < 3
                        ? "Next Question"
                        : "Finish Quiz"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}