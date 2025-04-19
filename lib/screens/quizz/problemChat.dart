import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_frontend/screens/quizz/quiz_results_screen.dart';
import '../../Service/ApiService.dart';

class ChatbotPage extends StatefulWidget {
  final String level;
  final String category;
  final int score;
  final int totalQuestions;

  ChatbotPage({
    required this.level,
    required this.category,
    required this.score,
    required this.totalQuestions,
  });

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
  ApiService apiService = ApiService();
  String problem = '';
  String? correctAnswer;
  int? rating;
  int tries = 0;
  String? again;
  int? maxRating = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProblem();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProblem() async {
    setState(() => _isLoading = true);
    try {
      final problemText = await apiService.fetchProblem(widget.category, widget.level);
      setState(() {
        problem = problemText;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading problem: ${error.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          "${widget.category} Problem",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D0EB5), Color(0xFF4059F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading || problem.isEmpty
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                problem,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _messageController,
                                maxLines: 5,
                                minLines: 3,
                                style: GoogleFonts.poppins(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter your solution...',
                                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                              if (correctAnswer != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    again ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                child: SizedBox(
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
                    onPressed: solveProblem,
                    child: Text("Submit Solution"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int extractRating(String? resultString) {
    List<String> parts = resultString!.split(":");
    if (parts.length >= 2) {
      String ratingPart = parts[1];
      List<String> ratingParts = ratingPart.split("/");
      if (ratingParts.length >= 2) {
        String ratingValue = ratingParts[0].trim();
        int? rating = int.tryParse(ratingValue);
        return rating ?? 0;
      }
    }
    return 0;
  }

  void navToResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          score: widget.score + maxRating!,
          totalQuestions: widget.totalQuestions + 10,
        ),
      ),
    );
  }

  Future<void> solveProblem() async {
    setState(() => _isLoading = true);
    try {
      final userAnswer = _messageController.text.trim();
      final String answerText = await apiService.solveProblem(
          widget.category,
          widget.level,
          problem,
          userAnswer
      );

      setState(() {
        correctAnswer = answerText;
        rating = extractRating(correctAnswer);
      });

      rate();
      tries++;

      if (rating! < 7 && tries < 3) {
        setState(() {
          again = "Your rating is $rating. You can try again";
        });
      } else {
        navToResult();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting solution: ${error.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void rate() {
    if (rating! > maxRating!) {
      setState(() {
        maxRating = rating;
      });
    }
  }
}