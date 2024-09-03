import 'package:flutter/material.dart';
import 'package:ft_staj_app/classes/question_class.dart';
import 'package:ft_staj_app/components/bottom_navigation.dart';
import 'package:ft_staj_app/main.dart';

class QuizPage extends StatefulWidget {
  final String testName;
  final String examName;
  final String topicId;

  const QuizPage({
    Key? key,
    required this.testName,
    required this.examName,
    required this.topicId,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late PageController _pageController;
  List<Question> questions = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;
  bool showExplanationButton = false;
  Set<int> selectedIndices = {};
  bool answeredCorrectly = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final records = await pb.collection('questions').getFullList(
            sort: '-created',
            filter: 'topic.id = "${widget.topicId}"',
          );

      setState(() {
        questions = records
            .map((record) => Question(
                  id: record.id,
                  questionText: record.data['question'],
                  options: [
                    record.data['answer1'],
                    record.data['answer2'],
                    record.data['answer3'],
                    record.data['answer4'],
                    record.data['answer5'],
                  ],
                  correctAnswerIndex: int.parse(record.data['correct_answer']),
                  explanation: record.data['hint'],
                ))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void quizCompleted() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Soruları Bitirdin"),
          content: const Text("Tebrikler! Tüm soruları tamamladınız."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Return to the previous page
              },
            ),
          ],
        );
      },
    );
  }

  void checkAnswer(int index) {
    setState(() {
      if (!answeredCorrectly) {
        selectedIndices.add(index);

        if (index == questions[currentQuestionIndex].correctAnswerIndex) {
          // Correct answer
          answeredCorrectly = true;
        } else {
          // Incorrect answer
          showExplanationButton = true;
        }
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedIndices.clear();
        showExplanationButton = false;
        answeredCorrectly = false;
      } else {
        quizCompleted();
      }
    });
  }

  void showExplanationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("İpucu"),
          content: Text(questions[currentQuestionIndex].explanation),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.testName} Quiz'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : questions.isEmpty
                ? const Center(child: Text('Bu testte soru yok'))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          questions[currentQuestionIndex].questionText,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ...questions[currentQuestionIndex]
                            .options
                            .asMap()
                            .entries
                            .map((entry) {
                          int idx = entry.key;
                          String option = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () => checkAnswer(idx),
                              child: Text(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedIndices.contains(idx)
                                    ? (idx ==
                                            questions[currentQuestionIndex]
                                                .correctAnswerIndex
                                        ? Colors.greenAccent
                                        : Colors.redAccent)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                        if (showExplanationButton)
                          ElevatedButton.icon(
                            onPressed: showExplanationModal,
                            icon: const Icon(Icons.lightbulb_outline),
                            label: const Text("İpucu"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                            ),
                          ),
                        if (answeredCorrectly)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ElevatedButton.icon(
                              onPressed: nextQuestion,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text(
                                "Next Question",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 245, 190, 254),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
