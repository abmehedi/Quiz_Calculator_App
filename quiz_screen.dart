import 'package:flutter/material.dart';
import 'package:flutter_simple_quiz_app/question_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_screen.dart';

void main() {
  runApp(MaterialApp(
    home: QuizScreen(),
  ));
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questionList = getQuestions();
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswerIndex;
  int remainingMinutes = 9;
  int remainingSeconds = 60;
  bool showingCorrectAnswer = false;

  late Timer quizTimer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    quizTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingMinutes == 0 && remainingSeconds == 0) {
        timer.cancel();
        showScoreDialog();
      } else if (remainingSeconds == 0) {
        setState(() {
          remainingMinutes--;
          remainingSeconds = 59;
        });
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    quizTimer.cancel();
    super.dispose();
  }

  void showScoreDialog() {
    quizTimer.cancel();
    bool isPassed = score >= questionList.length * 0.6;
    String title = isPassed ? "Passed" : "Failed";

    saveScore(score); // Save the user's score when the quiz ends.

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            "$title | Score is $score",
            style: TextStyle(
              color: isPassed ? Color.fromARGB(255, 196, 8, 171) : Color.fromARGB(255, 218, 4, 168),
              fontSize: 24,
            ),
          ),
          content: ElevatedButton(
            child: Text("Restart"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentQuestionIndex = 0;
                score = 0;
                selectedAnswerIndex = null;
                remainingMinutes = 9;
                remainingSeconds = 60;
                showingCorrectAnswer = false;
                startTimer();
              });
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("High Score"),
              onPressed: () {
                showHighScore();
              },
            ),
          ],
        );
      },
    );
  }

  void answerQuestion(int answerIndex) {
    if (!showingCorrectAnswer) {
      setState(() {
        selectedAnswerIndex = answerIndex;
        if (questionList[currentQuestionIndex].answersList[answerIndex].isCorrect) {
          score++;
        }
        showingCorrectAnswer = true;
      });
    }
  }

  void showHighScore() {
    getHighScore().then((highScore) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "High Score",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            content: Text(
              "Your high score is $highScore",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> saveScore(int userScore) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScore', userScore);
  }

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 225),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  color: const Color.fromARGB(255, 255, 64, 201),
                  child: Text(
                    "Quiz App",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Question ${currentQuestionIndex + 1}/${questionList.length}",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 249, 26, 26),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.black,
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Time: $remainingMinutes:$remainingSeconds",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 186, 157, 13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      questionList[currentQuestionIndex].questionText,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 82, 42, 42),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                _answerList(),
                _nextButton(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalculatorScreen()),
                    );
                  },
                  child: Text('Open Calculator'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerList() {
    return Column(
      children: List.generate(
        questionList[currentQuestionIndex].answersList.length,
            (index) => _answerButton(
          questionList[currentQuestionIndex].answersList[index],
          index,
        ),
      ),
    );
  }

  Widget _answerButton(Answer answer, int answerIndex) {
    bool isSelected = selectedAnswerIndex == answerIndex;
    bool isCorrect = isSelected && answer.isCorrect;
    bool showCorrectIndicator = showingCorrectAnswer && answer.isCorrect;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(answer.answerText),
              if (showCorrectIndicator)
                Icon(
                  isCorrect ? Icons.check : Icons.check_box,
                  color: isCorrect ? const Color.fromARGB(255, 170, 76, 175) : const Color.fromARGB(255, 240, 105, 229),
                ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: isSelected
                ? (isCorrect ? const Color.fromARGB(255, 175, 76, 158) : Colors.red)
                : Colors.white,
            onPrimary: isSelected ? Color.fromARGB(255, 241, 5, 5) : Colors.black,
          ),
          onPressed: () {
            answerQuestion(answerIndex);
          },
        ),
      ),
    );
  }

  Widget _nextButton() {
    bool isLastQuestion = currentQuestionIndex == questionList.length - 1;
    String buttonText = showingCorrectAnswer
        ? (isLastQuestion ? "Submit" : "Next")
        : "Submit";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        child: Text(buttonText),
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          primary: Color.fromARGB(255, 186, 150, 6),
          onPrimary: Color.fromARGB(255, 229, 37, 37)     ),
        onPressed: () {
          if (isLastQuestion && showingCorrectAnswer) {
            showScoreDialog();
          } else {
            setState(() {
              if (showingCorrectAnswer) {
                selectedAnswerIndex = null;
                currentQuestionIndex++;
                showingCorrectAnswer = false;
              } else {
                answerQuestion(0);
              }
            });
          }
        },
      ),
    );
  }
}
