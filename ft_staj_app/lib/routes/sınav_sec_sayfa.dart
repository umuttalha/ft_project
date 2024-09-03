import 'package:flutter/material.dart';
import 'package:ft_staj_app/components/bottom_navigation.dart';
import 'package:ft_staj_app/components/test_card.dart';
import 'package:ft_staj_app/main.dart';
import 'package:ft_staj_app/routes/test_page.dart';
import 'package:pocketbase/pocketbase.dart';

class FirstRoute extends StatefulWidget {
  final String examName;

  const FirstRoute({Key? key, required this.examName}) : super(key: key);

  @override
  _FirstRouteState createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  List<RecordModel> lectures = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLectures();
  }

  Future<void> fetchLectures() async {
    try {
      final records = await pb.collection('exam_type_lecture').getFullList(
            sort: '-created',
            filter: 'exam.name="${widget.examName}"',
          );

      setState(() {
        lectures = records;
        isLoading = false;
      });
    } catch (e) {
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
          title: const Text('Ders Seç'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: lectures.length,
                itemBuilder: (context, index) {
                  final lecture = lectures[index];
                  return TestCard(
                    title: lecture.data['name'] ?? 'Unknown',
                    icon: Icons.book, // You might want to customize this
                    onTap: () => _navigateToTestPage(
                        context, lecture.data['name'] ?? 'Unknown'),
                  );
                },
              ),
      ),
    );
  }

  void _navigateToTestPage(BuildContext context, String testName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TestPage(testName: testName, examName: widget.examName),
      ),
    );
  }
}
