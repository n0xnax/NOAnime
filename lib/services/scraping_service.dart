import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:noanime_app/model/model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

class Scraper {
  final platform = const MethodChannel('com.noanime_app/scrape');
  final baseUrl = 'https://www.arabanime.net';

  Future<Map<String, dynamic>?> executeMethod(String methodName, Map<String, dynamic> arguments) async {
    try {
      final result = await platform.invokeMethod(
        methodName,
        arguments, // Just pass the arguments directly
      );

      if (result != null) {
        return jsonDecode(result);
      }
    } catch (e) {
      print('error in methodInvoke $e');
      return null;
    }
    return null;
  }

  // Get popular anime by page
  Future<List<AnimeItem>> getPopularAnime(String page) async {
    final result = await executeMethod('getPopularAnime', {'page': page});

    // Check if the result is valid and contains the expected field, e.g., 'Shows'
    if (result != null && result['Shows'] is List) {
      // Map the result['Shows'] list (Base64 encoded strings) to a list of AnimeItem objects
      List<AnimeItem> animeList = List<AnimeItem>.from(
        result['Shows'].map((base64String) {
          // Decode each Base64 encoded string into a JSON map
          String decodedString = utf8.decode(base64.decode(base64String));

          // Parse the decoded string into a Map
          Map<String, dynamic> animeJson = jsonDecode(decodedString);

          // Return AnimeItem using the parsed data
          return AnimeItem(
            coverUrl: animeJson['anime_cover_image_url'], // Mapping to coverUrl
            id: animeJson['anime_id'], // Mapping to id
            name: animeJson['anime_name'], // Mapping to name
            score: animeJson['anime_score'], // Mapping to score
            slug: animeJson['anime_slug'], // Mapping to slug
            type: animeJson['anime_type'], // Mapping to type
            infoSrc: animeJson['info_src'], // Mapping to infoSrc
          );
        }),
      );

      return animeList;
    }

    // Return an empty list if no valid data is found
    return [];
  }

  Future<ShowResponse> getAnime(String infoSrc) async {
    // Step 1: Fetch HTML content
    final response = await http.get(Uri.parse(infoSrc));

    if (response.statusCode == 200) {
      // Step 2: Parse HTML and extract the content of div#data
      var document = html.parse(response.body);
      var dataDiv = document.querySelector('div#data');

      if (dataDiv != null) {
        // Step 3: Get the inner HTML, trim whitespace, and decode from base64
        String base64String = dataDiv.innerHtml.trim();

        String jsonString = utf8.decode(base64.decode(base64String));

        // Step 4: Parse the JSON string
        var jsonData = jsonDecode(jsonString);

        // Return the ShowResponse object (assuming you have a method to convert jsonData to ShowResponse)
        return ShowResponse.fromJson(jsonData);
      } else {
        throw Exception('Data div not found');
      }
    } else {
      throw Exception('Failed to load HTML content');
    }
  }

  Future<List<AnimeItem>> getAnimeByQuery(String query) async {
    try {
      final response = await http.get(Uri.parse('https://www.arabanime.net/api/search?q=$query'));

      if (response.statusCode == 200) {
        // Decode the response body
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if 'Shows' key exists and is a list
        if (jsonResponse.containsKey('SearchResaults') && jsonResponse['SearchResaults'] is List) {
          final List<String> base64Shows = List<String>.from(jsonResponse['SearchResaults']);

          // Decode each base64 string and parse the JSON
          List<AnimeItem> animeList = [];

          for (String base64Show in base64Shows) {
            if (base64Show.isNotEmpty) {
              print('Base64 show: $base64Show'); // Log the base64 string

              // Decode the base64 string
              String decodedJson = utf8.decode(base64.decode(base64Show));

              // Convert the decoded JSON string to a Map
              Map<String, dynamic> animeData = json.decode(decodedJson);

              print('so far works ');

              AnimeItem animeItem = AnimeItem(
                coverUrl: animeData['anime_cover_image_url'],
                id: animeData['anime_id'].toString(),
                name: animeData['anime_name'],
                infoSrc: animeData['info_url'],
                slug: animeData['anime_slug'],
                score: animeData['anime_release_date'],
                type: animeData['anime_type'],
              );
              print('so far doesnt ');
              print(animeItem);
              // Create an AnimeItem from the Map and add it to the list
              animeList.add(animeItem);
            } else {
              print('Base64 show is null or empty.');
            }
          }
          print(animeList.length);
          return animeList; // Return the list of AnimeItems
        } else {
          print('No shows found in the response or invalid structure: $jsonResponse');
          return []; // Return an empty list if no shows are found
        }
      } else {
        throw Exception('Failed to load anime: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching anime by query: $e');
      return []; // Return an empty list on error
    }
  }

  Future<List<Video>> getVideos(String episodeSrc) async {
    try {
      // Step 1: Fetch the HTML from the episode source URL
      final response = await http.get(Uri.parse(episodeSrc));

      if (response.statusCode == 200) {
        // Step 2: Parse the HTML response and extract div#datawatch
        var document = html.parse(response.body);
        var watchDataDiv = document.querySelector('#datawatch');

        if (watchDataDiv != null) {
          // Decode the Base64 content
          String watchData = watchDataDiv.text;
          String decodedWatchData = utf8.decode(base64.decode(watchData));

          var serversJson = json.decode(decodedWatchData);
          var base64streamServers = serversJson['ep_info'][0]['stream_servers'];

          List<Video> videos = [];

          // Iterate through each base64 stream server
          for (var base64Server in base64streamServers) {
            String streamServersLink = utf8.decode(base64.decode(base64Server.replaceAll('[', '').replaceAll(']', '')));

            final serversResponse = await http.get(Uri.parse(streamServersLink));
            if (serversResponse.statusCode == 200) {
              var serverDocument = html.parse(serversResponse.body);
              var serverElement = serverDocument.querySelector('#server');

              if (serverElement != null) {
                // Iterate through each option
                var options = serverElement.querySelectorAll('option');

                // Map options to (name, decoded data-src)
                var serverUrls = options
                    .map((option) {
                      var name = option.text;
                      var dataSrc = option.attributes['data-src'];

                      if (dataSrc != null) {
                        var decodedDataSrc = utf8.decode(base64.decode(dataSrc));
                        return MapEntry(name, decodedDataSrc);
                      }
                      return null;
                    })
                    .where((entry) => entry != null)
                    .toList();

                // For each server URL, make an HTTP request
                for (var entry in serverUrls) {
                  var name = entry!.key;
                  var url = entry.value;

                  // Make the HTTP request
                  var response = await http.get(Uri.parse(url));
                  print('started');
                  if (response.statusCode == 200) {
                    if (response.contentLength == 0) {
                      break;
                    }
                    print(response.contentLength);
                    var sourceDocument = html.parse(response.body);
                    if (response.body == '') {}
                    var sources = sourceDocument.querySelectorAll('source');

                    // Map sources to Video objects
                    for (var source in sources) {
                      var videoUrl = source.attributes['src'];
                      if (videoUrl != null && !videoUrl.contains('static')) {
                        var quality = source.attributes['label'] ?? '';
                        if (!quality.contains('p')) {
                          quality += 'p';
                        }
                        videos.add(Video(videoUrl, '$name: $quality'));
                      }
                    }
                  }
                }
              } else {
                print('No server element found for stream server: $streamServersLink');
              }
            } else {
              print('Failed to load server link: $streamServersLink');
            }
          }
          return videos;
        } else {
          throw Exception('div#datawatch not found');
        }
      } else {
        throw Exception('Failed to load episode page');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
