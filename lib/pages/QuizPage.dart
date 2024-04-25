import 'package:eduprime/models/category.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';

import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

import '../models/Quiz.dart';
import '../Service/ApiService.dart';
import 'dart:convert';
import 'problemChat.dart';

class QuizCategoryCard extends StatefulWidget {
  final String title;
  final String level;
  final VoidCallback onTap;

  const QuizCategoryCard({
    required this.title,
    required this.level,
    required this.onTap,
  });

  @override
  _QuizCategoryCardState createState() => _QuizCategoryCardState();
  
}
  String? questCategory;
  String? questLevel;
class _QuizCategoryCardState extends State<QuizCategoryCard> {
  final ApiService _apiService = ApiService();
  Quiz? _quizData; // Change to List<Quiz>
  Quiz? quizQuestion;
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          questCategory=widget.title;
          questLevel=widget.level;
        });
          try {
            final quizData = await _apiService.fetchQuizQuestion(
              widget.title, // Access instance variables from widget
              widget.level, // Access instance variables from widget
            );
            print('API Response: $quizData');
            setState(() {
              _quizData = quizData;
              quizQuestion = quizData;
              
              print('Stored Data:');
              quizQuestion!;
            });
          } catch (error) {
            print('Error fetching quiz questions: $error');
            // Handle error appropriately, e.g., show a snackbar
          }
        
        if (_quizData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UIUXDesignQuizScreen(
                quizQuestions:
                    quizQuestion,
                    category: widget.title,
                    level: widget.level,
                     // Pass quizList to UIUXDesignQuizScreen
              ),
            ),
          );
        }
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: ListTile(
          leading: Icon(Icons.question_mark),
          title: Text(widget.title),
          subtitle: Text('${widget.level}'), // Display level
          // Adjust the trailing widget as needed
          trailing: _quizData != null
              ? Text('${_quizData!} questions')
              : null, // Show number of questions if available
        ),
      ),
    );
  }
}

class QuizHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void navigateToUIUXDesignQuiz() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UIUXDesignQuizScreen(
                    quizQuestions: null,
                    level: null,
                    category: null,
                     
                  )));
    }

    void navigateToGraphicDesignQuiz() {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => GraphicDesignQuizScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, James",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text("Let's test your knowledge"),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryButton(text: "Popular", onTap: () {}),
                      CategoryButton(text: "Science", onTap: () {}),
                      CategoryButton(text: "Mathematics", onTap: () {}),
                      CategoryButton(text: "Computer", onTap: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                QuizCategoryCard(
                  title: 'java',
                  level: 'advanced',

                  onTap: navigateToUIUXDesignQuiz, // Navigates to UI/UX Quiz
                ),
                QuizCategoryCard(
                  title: 'Graphic Design',
                  level: 'beginner',

                  onTap:
                      navigateToGraphicDesignQuiz, // Navigates to Graphic Design Quiz
                ),
              ],
            ),
          ),
          FloatingActionButton.extended(
            onPressed: () {},
            label: Text('Start Quiz'),
            icon: Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  CategoryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Text(text),
      onPressed: onTap,
    );
  }
}

class UIUXDesignQuizScreen extends StatefulWidget {
   Quiz? quizQuestions;
   String? level;
   String? category;

   UIUXDesignQuizScreen({required this.quizQuestions, required this.level, required this.category});

  @override
  _UIUXDesignQuizScreenState createState() => _UIUXDesignQuizScreenState();
}

class _UIUXDesignQuizScreenState extends State<UIUXDesignQuizScreen> {
  String? selectedValue;
  final ApiService _apiService = ApiService();
  int score = 0; // Track the score
  int totalQuestions = 0;
  int endTime = DateTime.now().millisecondsSinceEpoch +
      1000 * 60 * 75; // 1 hour 15 min timer

  void _checkAnswer() {
    if (selectedValue == widget.quizQuestions?.correctAnswer) {
      setState(() {
        score++; // Increment score if answer is correct
      });
      print(score);
    }
  }

  Future<void> _fetchNewQuestion() async {
    try {
      // Retrieve category and level from another class or global variable
      String? category = questCategory;
      String? level = questLevel;

      final quizData = await _apiService.fetchQuizQuestion(category!, level!);
      setState(() {
        widget.quizQuestions = quizData;
        selectedValue = null; // Reset selected answer
      });
    } catch (error) {
      print('Error fetching quiz questions: $error');
      // Handle error appropriately, e.g., show a snackbar
    }
  }

  void _submitQuiz() {
    // Calculate final score
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                QuizResultsScreen(score: score, totalQuestions: totalQuestions)));

    // Display final score (You can navigate to a new screen to display the score)
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UI UX Design Quiz'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          CountdownTimer(
            endTime: endTime,
            widgetBuilder: (_, CurrentRemainingTime? time) {
              if (time == null) {
                return Text('Time\'s up!');
              }
              return Text(
                '${time.min ?? '00'}:${time.sec ?? '00'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.quizQuestions?.question ?? '',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
          ),
          // Use the fetched choices dynamically
          ...(widget.quizQuestions?.choices ?? []).map((choice) {
            return RadioListTile<String>(
              value: choice,
              groupValue: selectedValue,
              title: Text(choice),
              onChanged: (String? value) {
                setState(() {
                  selectedValue = value;
                });
              },
              activeColor: Colors.blue,
            );
          }).toList(),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              _checkAnswer(); // Check answer before fetching new question
               totalQuestions++;
              if (totalQuestions == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatbotPage(level: widget.level,
      category: widget.category,score:score,totalQuestions: totalQuestions,), // Redirect to the chatbot page
        ),
      );
    }else
             { _fetchNewQuestion(); // Fetch new question
             }
              
            },
            child: Text('Next Question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _checkAnswer(); // Check last answer before submitting quiz
               totalQuestions++;
              _submitQuiz(); // Submit the quiz
            },
            child: Text('Submit Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }
}


class GraphicDesignQuizScreen extends StatefulWidget {
  @override
  _GraphicDesignQuizScreenState createState() =>
      _GraphicDesignQuizScreenState();
}

class _GraphicDesignQuizScreenState extends State<GraphicDesignQuizScreen> {
  int score = 0;
  int? selectedValue;

  void _submitQuiz() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                QuizResultsScreen(score: score, totalQuestions: 10)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Graphic Design Quiz')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('What is the meaning of Graphic Design?',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
          ),
          ElevatedButton(onPressed: _submitQuiz, child: Text('Submit Quiz')),
        ],
      ),
    );
  }
}

class QuizResultsScreen extends StatelessWidget {
  final int score; // Nombre de réponses correctes
  final int totalQuestions; // Nombre total de questions

  QuizResultsScreen({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    double percentage = score / totalQuestions * 100;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share results logic
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
  Text(
    percentage >= 80
        ? 'Congratulations! You Passed!'
        : 'Sorry, You Failed!',
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
       color: percentage >= 80 ? Colors.green : Colors.red,
    ),
  ),
          SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0, // Pas d'espace entre les sections
                centerSpaceRadius: 40, // Rayon de l'espace central
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: percentage,
                    title: '${percentage.toStringAsFixed(1)}%',
                    showTitle: true,
                    radius: 100,
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: 100 - percentage,
                    title: '${(100 - percentage).toStringAsFixed(1)}%',
                    showTitle: true,
                    radius: 100,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('${score} Correct Answers'),
          Text('${totalQuestions-score} Wrong Answers'),
          Text('${percentage}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logic to try again
            },
            child: Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              // Logic to view details
            },
            child: Text('View Details'),
          ),
        ],
      ),
    );
  }
}
