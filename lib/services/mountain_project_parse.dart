import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'dart:convert';

/// Entry point of the application.
Future<void> main() async {
  const url = 'https://www.mountainproject.com/area/105739280/big-cottonwood-canyon';
  // const url = 'https://www.mountainproject.com/area/105716763/indian-creek';
  String areaName = extractAreaName(url);

  try {
    final areaLinks = await findCragLinks(url, areaName);
    if (areaLinks.isNotEmpty) {
      String cragJSON = await getCragInfo(areaLinks, areaName);
      await writeToFile(cragJSON, 'crag_data.json');
    } else {
      print('No area links found.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

/// Fetches and processes information for a list of crag URLs.
Future<String> getCragInfo(List<String> urls, String areaName) async {
  final List<Map<String, dynamic>> dataList = [];

  for (final url in urls) {
    try {
      final response = await get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = parse(response.body);

        final titleElement = document.querySelector('title');
        final title = titleElement?.text ?? 'Unknown Title';

        final gpsMatch = RegExp(r'(\d+\.\d+),\s*(-?\d+\.\d+)').firstMatch(response.body);
        final longitude = gpsMatch?.group(1);
        final latitude = gpsMatch?.group(2);

        final urlData = {
          'name': title,
          'area': areaName,
          'coordinates': (latitude != null && longitude != null)
              ? {
            'latitude': double.tryParse(latitude),
            'longitude': double.tryParse(longitude),
          }
              : null,
        };

        dataList.add(urlData);
      } else {
        print('Failed to load $url. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error processing URL $url: $e');
    }
  }

  final jsonData = {'crags': dataList};
  final jsonString = jsonEncode(jsonData);

  print('JSON Data:\n$jsonString');
  return jsonString;

}

/// Finds all area links from the specified web page.
Future<List<String>> findCragLinks(String url, String areaName) async {

  try {
    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parse(response.body);

      // Find all <h3> elements
      final headings = document.querySelectorAll('h3');
      final heading = headings.firstWhere(
            (element) => element.text.trim() == "Areas in $areaName",
        orElse: () => throw Exception('Heading not found.'),
      );

      final List<String> links = [];
      Element? current = heading.nextElementSibling;

      // Traverse siblings and find all <a href="..."> links
      while (current != null) {
        for (final element in current.querySelectorAll('a[href]')) {
          final href = element.attributes['href'];
          if (href != null) {
            links.add(href);
          }
        }
        current = current.nextElementSibling;
      }

      print('Extracted links: $links');
      return links;
    } else {
      throw Exception('Failed to load the page. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching area links: $e');
    return [];
  }
}

String extractAreaName(String url) {
  // Split the URL by slashes
  List<String> segments = url.split('/');

  // Get the last non-empty segment
  String lastSegment = segments.lastWhere((segment) => segment.isNotEmpty);

  // Replace dashes with spaces and capitalize each word
  String areaName = lastSegment
      .split('-') // Split by dashes
      .map((word) => word[0].toUpperCase() + word.substring(1)) // Capitalize each word
      .join(' '); // Join with spaces

  print ('Area Name = $areaName');
  return areaName;
}


/// Writes the JSON data to a file.
Future<void> writeToFile(String data, String fileName) async {
  try {
    final String filePath = 'C:\\Users\\cawoo\\code\\v_crag\\assets';
    final file = File('$filePath\\$fileName');
    await file.writeAsString(data);
    print('Data written to $fileName');
  } catch (e) {
    print('Error writing to file: $e');
  }
}



// final urls = [
//   'https://www.mountainproject.com/area/105716763/indian-creek',
//   'https://www.mountainproject.com/area/105716784/castle-valley',
//   'https://www.mountainproject.com/area/105716826/saint-george',
//   'https://www.mountainproject.com/area/105717086/kolob-canyon',
//   'https://www.mountainproject.com/area/105744243/clear-creek-canyon',
//   'https://www.mountainproject.com/area/105744246/eldorado-canyon-state-park',
//   'https://www.mountainproject.com/area/105744319/castlewood-canyon-sp',
//   'https://www.mountainproject.com/area/105744373/poudre-canyon',
//   'https://www.mountainproject.com/area/105837312/reimers-ranch',
//   'https://www.mountainproject.com/area/105868955/taos-area',
//   'https://www.mountainproject.com/area/105739280/big-cottonwood-canyon',
// ];


