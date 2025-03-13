import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center( // Center the text in the body
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              Text(
                'Content Creators',
                style: TextStyle(
                  fontSize: 24.0, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Center text
              ),
              SizedBox(height: 16.0), // Increased space between title and description
              Text(
                'V. Vidyasagar\nRoll No : 22VD1A6609\n\nB. Meghana\nRoll No : 22VD1A6620\n\nR. Jahnavi\nRoll No : 22VD1A6614',
                style: TextStyle(
                  fontSize: 20.0, // Increased font size
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center, // Center text
              ),
            ],
          ),
        ),
      ),
    );
  }
}