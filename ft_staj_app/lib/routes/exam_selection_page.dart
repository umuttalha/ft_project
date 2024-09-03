import 'package:flutter/material.dart';
import 'package:ft_staj_app/components/bottom_navigation.dart';
import 'package:ft_staj_app/components/exam_buttom.dart';
import 'package:ft_staj_app/main.dart';
import 'package:ft_staj_app/routes/s%C4%B1nav_sec_sayfa.dart';
import 'package:pocketbase/pocketbase.dart';

class ExamSelectionPage extends StatefulWidget {
  const ExamSelectionPage({Key? key}) : super(key: key);

  @override
  _ExamSelectionPageState createState() => _ExamSelectionPageState();
}

class _ExamSelectionPageState extends State<ExamSelectionPage> {
  List<RecordModel> examTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExamTypes();
  }

  Future<void> fetchExamTypes() async {
    try {
      final records = await pb.collection('exam_type').getFullList(
            sort: '-created',
            expand: "Lectures",
          );

      setState(() {
        examTypes = records;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching exam types: $e');
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
          title: const Text('Sınav Seçin'),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: examTypes.length,
                  itemBuilder: (context, index) {
                    final examType = examTypes[index];
                    return ExamButton(
                      examName: examType.data['name'] ?? 'Unknown',
                      onTap: () => _navigateToFirstRoute(
                          context, examType.data['name'] ?? 'Unknown'),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _navigateToFirstRoute(BuildContext context, String examName) {
    print("Ders Seç page for $examName");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FirstRoute(examName: examName)),
    );
  }
}
