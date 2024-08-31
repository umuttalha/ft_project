import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

final pb = PocketBase('http://172.81.178.244:8090');

class UserProvider with ChangeNotifier {
  String? _email;
  String? _token;
  bool _skippedSignIn = false;

  String? get email => _email;
  String? get token => _token;
  bool get skippedSignIn => _skippedSignIn;

  bool get isLoggedIn => _token != null && !_skippedSignIn;

  void setUser(String email, String token) {
    _email = email;
    _token = token;
    _skippedSignIn = false;
    notifyListeners();
  }

  void setSkippedSignIn(bool skipped) {
    _skippedSignIn = skipped;
    notifyListeners();
  }

  void clearUser() {
    _email = null;
    _token = null;
    _skippedSignIn = false;
    notifyListeners();
  }

  void signOut() {
    clearUser();
  }
}

void main() {
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
      title: 'Exam Preparation App',
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoggedIn || userProvider.skippedSignIn) {
            return ExamSelectionPage();
          } else {
            return SignInPage();
          }
        },
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _skipSignIn() {
    Provider.of<UserProvider>(context, listen: false).setSkippedSignIn(true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ExamSelectionPage()),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final authData = await pb.collection('users').authWithPassword(
              _email,
              _password,
            );

        Provider.of<UserProvider>(context, listen: false)
            .setUser(_email, authData.token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ExamSelectionPage()),
        );
      } catch (e) {
        print(e.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          TextButton(
            onPressed: _skipSignIn,
            child: const Text('Skip', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : const Text('Sign In'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await pb.collection('users').create(body: {
          'email': _email,
          'password': _passwordController.text,
          'passwordConfirm': _confirmPasswordController.text,
        });

        // Sign in the user after successful sign up
        final authData = await pb.collection('users').authWithPassword(
              _email,
              _passwordController.text, // Use the password from the controller
            );

        Provider.of<UserProvider>(context, listen: false)
            .setUser(_email, authData.token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ExamSelectionPage()),
        );
      } catch (e) {
        print(e.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamSelectionPage extends StatelessWidget {
  const ExamSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sınav Seçin'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExamButton(
                examName: 'YKS',
                onTap: () => _navigateToFirstRoute(context, 'YKS'),
              ),
              ExamButton(
                examName: 'TEOG',
                onTap: () => _navigateToFirstRoute(context, 'TEOG'),
              ),
              ExamButton(
                examName: 'KPSS',
                onTap: () => _navigateToFirstRoute(context, 'KPSS'),
              ),
              ExamButton(
                examName: 'ALES',
                onTap: () => _navigateToFirstRoute(context, 'ALES'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFirstRoute(BuildContext context, String examName) {
    print("Ders Seç page for $examName"); //
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FirstRoute(examName: examName)),
    );
  }
}

class ExamButton extends StatelessWidget {
  final String examName;
  final VoidCallback onTap;

  const ExamButton({Key? key, required this.examName, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(examName, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      ),
    );
  }
}

class BottomNavWrapper extends StatefulWidget {
  final Widget child;

  const BottomNavWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _BottomNavWrapperState createState() => _BottomNavWrapperState();
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userProvider.email ?? 'No email',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (userProvider.isLoggedIn) {
                  userProvider.signOut();
                }
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SignInPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(userProvider.isLoggedIn ? 'Sign Out' : 'Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          widget.child,
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.purple,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class FirstRoute extends StatelessWidget {
  final String examName;

  const FirstRoute({Key? key, required this.examName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ders Seç'),
        ),
        body: Center(
          child: CardExample(examName: examName),
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class CardExample extends StatelessWidget {
  final String examName;
  static const List<Map<String, dynamic>> cardData = [
    {'title': 'İngilizce', 'icon': Icons.language},
    {'title': 'Türkçe', 'icon': Icons.book},
    {'title': 'Matematik', 'icon': Icons.calculate},
  ];

  const CardExample({super.key, required this.examName});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cardData.length,
      itemBuilder: (context, index) {
        return TestCard(
          title: cardData[index]['title'],
          icon: cardData[index]['icon'],
          onTap: () => _navigateToTestPage(context, cardData[index]['title']),
        );
      },
    );
  }

  void _navigateToTestPage(BuildContext context, String testName) {
    print("Test page for $testName - $examName sınavı");
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TestPage(testName: testName, examName: examName)),
    );
  }
}

class TestCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: onTap,
          child: SizedBox(
            width: 300,
            height: 100,
            child: Center(
              child: ListTile(
                leading: Icon(icon),
                title: Text(title),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TestPage extends StatelessWidget {
  final String testName;
  final String examName;

  const TestPage({super.key, required this.testName, required this.examName});

  @override
  Widget build(BuildContext context) {
    return BottomNavWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(testName),
        ),
        body: ListView(
          children: [
            TestCard(
              title: 'Random $testName Quiz',
              icon: Icons.shuffle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      testName: testName,
                      quizNumber: 0, // 0 can indicate a random quiz
                      examName: examName,
                    ),
                  ),
                );
              },
            ),
            ...List.generate(
              3,
              (index) => TestCard(
                title: '$testName ${index + 1} Konu',
                icon: Icons.quiz,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                          testName: testName,
                          quizNumber: index + 1,
                          examName: examName),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String testName;
  final int quizNumber;
  final String examName;

  const QuizPage({
    Key? key,
    required this.testName,
    required this.quizNumber,
    required this.examName,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late PageController _pageController;

  int currentQuestionIndex = 0;
  List<Question> questions = [];
  bool showExplanationButton = false;
  Set<int> selectedIndices = {};
  bool answeredCorrectly = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    print(
        "Test Name: ${widget.testName}, Quiz Number: ${widget.quizNumber}, Exam Name: ${widget.examName}");
    questions = [
      Question(
        questionText: "What is the capital of France?",
        options: ["London", "Berlin", "Paris", "Madrid"],
        correctAnswerIndex: 2,
        explanation:
            "Paris is the capital and largest city of France. It is located on the Seine River in northern France and is known for its iconic landmarks like the Eiffel Tower and the Louvre Museum.",
      ),
      Question(
        questionText: "Which planet is known as the Red Planet?",
        options: ["Venus", "Mars", "Jupiter", "Saturn"],
        correctAnswerIndex: 1,
        explanation:
            "Mars is often called the Red Planet due to its reddish appearance in the night sky. This color is caused by the presence of iron oxide (rust) on its surface.",
      ),
      Question(
        questionText: "What is the largest ocean on Earth?",
        options: [
          "Atlantic Ocean",
          "Indian Ocean",
          "Arctic Ocean",
          "Pacific Ocean"
        ],
        correctAnswerIndex: 3,
        explanation:
            "The Pacific Ocean is the largest and deepest ocean on Earth, covering an area of about 63 million square miles (165 million square kilometers).",
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        // Quiz finished
        // You can navigate to a results page or show a dialog here
      }
    });
  }

  void showExplanationModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Explanation"),
          content: Text(questions[currentQuestionIndex].explanation),
          actions: [
            TextButton(
              child: Text("Close"),
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
          title: Text('${widget.testName} Quiz ${widget.quizNumber}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                questions[currentQuestionIndex].questionText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
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
                  icon: Icon(Icons.lightbulb_outline),
                  label: Text("İpucu"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              if (answeredCorrectly)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      nextQuestion();
                    },
                    icon: Icon(Icons.arrow_forward),
                    label: Text(
                      "Next Question",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 190, 254),
                      padding: EdgeInsets.symmetric(
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
