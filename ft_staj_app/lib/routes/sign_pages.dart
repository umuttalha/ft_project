import 'package:flutter/material.dart';
import 'package:ft_staj_app/main.dart';
import 'package:ft_staj_app/providers/user_provider.dart';
import 'package:ft_staj_app/routes/exam_selection_page.dart';
import 'package:provider/provider.dart';

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
      MaterialPageRoute(builder: (context) => const ExamSelectionPage()),
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

        // auth save
        Provider.of<UserProvider>(context, listen: false)
            .setUser(_email, authData.token);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExamSelectionPage()),
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
        title: const Text('Giriş Yap'),
        actions: [
          TextButton(
            onPressed: _skipSignIn,
            child: const Text('Geç', style: TextStyle(color: Colors.black)),
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
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen Şifrenizi girin';
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
                    ? const CircularProgressIndicator()
                    : const Text('Giriş Yap'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                child: const Text('Hesabınız yok mu? Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
