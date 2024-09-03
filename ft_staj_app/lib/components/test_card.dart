import 'package:flutter/material.dart';

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
