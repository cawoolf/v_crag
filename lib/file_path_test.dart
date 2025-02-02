import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

class FileDataWidget extends StatelessWidget {
  final String filePath;

  FileDataWidget({required this.filePath});

  Future<String> _loadDataFromAsset() async {
    try {
      // Load the file from the assets folder using rootBundle
      final data = await rootBundle.loadString(filePath);
      return data;
    } catch (e) {
      return "Error loading asset: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Load Data from Asset")),
      body: Center(
        child: FutureBuilder<String>(
          future: _loadDataFromAsset(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text(snapshot.data ?? 'No data');
            } else {
              return Text("No data available");
            }
          },
        ),
      ),
    );
  }
}
