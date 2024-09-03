import 'package:flutter/material.dart';
import 'package:ft_staj_app/providers/user_provider.dart';
import 'package:ft_staj_app/routes/sign_pages.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userProvider.email ?? 'Giriş Yapılmadı',
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
              child: Text(userProvider.isLoggedIn ? 'Çıkış Yap' : 'Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
