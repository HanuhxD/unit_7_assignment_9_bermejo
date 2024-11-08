import 'package:flutter/material.dart';
import 'dart:convert'; // for decoding JSON
import 'package:http/http.dart' as http;
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Setup the future variable for fetching data
  late Future<List<dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = fetchCharacters(); // calling fetchCharacters to get data
  }

  // Fetching data from the API
  Future<List<dynamic>> fetchCharacters() async {
    final url = Uri.parse("https://api.disneyapi.dev/character");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // successful request
      final data = json.decode(response.body);
      return data['data']; // assuming 'data' key holds character list
    } else {
      // error occurred
      throw Exception("Failed to load characters");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
        backgroundColor: Colors.deepPurple, // Set app bar color to purple
      ),
      body: FutureBuilder(
        // Setup the URL for your API here
        future: future,
        builder: (context, snapshot) {
          // when the process is ongoing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // when the process is completed:
          else if (snapshot.hasData) {
            // successful
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final character = snapshot.data![index];
                final tileController = ExpandedTileController(); // Add controller for each tile

                return ExpandedTile(
                  controller: tileController, // Required controller

                  leading: character['imageUrl'] != null
                      ? Image.network(character['imageUrl'], width: 50, height: 50)
                      : const Icon(Icons.image_not_supported), // Fallback if image is missing
                      title: Text(character['name']),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(character['description'] ?? "No description available"),
                      const SizedBox(height: 8),

                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            // error
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
    );
  }
}
