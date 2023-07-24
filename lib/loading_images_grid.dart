import 'package:flutter/material.dart';

class GridViewPage extends StatelessWidget {
  final String userId;

  const GridViewPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [];
    Future<void> loadImages() async {
      // Code to fetch the image URLs for the current user from Firebase Firestore.
      // You should retrieve the URLs saved in the 'photos' collection under the user's document.
      // Here, I assume you have already stored the image URLs in the _imageUrls list.
    }
    return FutureBuilder(
      future: loadImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(imageUrls[index], fit: BoxFit.cover);
            },
          );
        }
      },
    );
  }
}
