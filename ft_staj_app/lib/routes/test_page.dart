import 'package:flutter/material.dart';
import 'package:ft_staj_app/components/bottom_navigation.dart';
import 'package:ft_staj_app/components/test_card.dart';
import 'package:ft_staj_app/main.dart';
import 'package:ft_staj_app/routes/quiz_page.dart';
import 'package:pocketbase/pocketbase.dart';

class TestPage extends StatefulWidget {
  final String testName;
  final String examName;

  const TestPage({super.key, required this.testName, required this.examName});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<RecordModel> topics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    try {
      final records =
          await pb.collection('exam_type_lecture_topic').getFullList(
                sort: '-created',
                expand: "lecture",
                filter: 'lecture.name="${widget.testName}"',
              );

      setState(() {
        topics = records;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching topics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.testName),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  ...topics.map((topic) => TestCard(
                        title: topic.data['topic'] ?? 'Unknown Topic',
                        icon: Icons.quiz,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                                testName: widget.testName,
                                examName: widget.examName,
                                topicId: topic.id,
                              ),
                            ),
                          );
                        },
                      )),
                ],
              ),
      ),
    );
  }
}
