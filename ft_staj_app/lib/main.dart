import 'package:flutter/material.dart';
import 'package:ft_staj_app/pocetbase_servis.dart';
import 'package:ft_staj_app/providers/user_provider.dart';
import 'package:ft_staj_app/routes/exam_selection_page.dart';
import 'package:ft_staj_app/routes/sign_pages.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

PocetbaseServis pbServis = PocetbaseServis();
final pb = pbServis.pb;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sınav Hazırlık Uygulaması',
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoggedIn || userProvider.skippedSignIn) {
            return const ExamSelectionPage();
          } else {
            return const SignInPage();
          }
        },
      ),
    );
  }
}
