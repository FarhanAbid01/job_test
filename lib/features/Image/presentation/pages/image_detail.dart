import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen image
          Center(
            child: Hero(
              tag: imageUrl, // Unique tag for Hero animation
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain, // Make the image fit inside the screen
              ),
            ),
          ),


          Positioned(
            top: 40.0, // Adjust the top position based on status bar
            right: 20.0, // Adjust the right position for padding
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30.0, // Size of the close button
              ),
              onPressed: () {
                Navigator.pop(context); // Return to the original state
              },
            ),
          ),
        ],
      ),
    );
  }
}
