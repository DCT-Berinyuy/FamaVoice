import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AiService {
  final String _apiKey = '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';
  final String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> getResponse(String query, {required String localeId}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return _getOfflineResponse(query, localeId: localeId);
    } else {
      try {
        return await _getOnlineResponse(query, localeId: localeId);
      } catch (e) {
        // Fallback to offline if online fails
        return _getOfflineResponse(query, localeId: localeId);
      }
    }
  }

  Future<String> _getOnlineResponse(String query, {required String localeId}) async {
    String systemPrompt;
    if (localeId == 'en_NG') {
      systemPrompt = 'You are an agriculture expert assistant for rural farmers in Cameroon and Nigeria. Respond in simple Pidgin English. Refer to yourself as FamaVoice.';
    } else if (localeId == 'fr_CM') {
      systemPrompt = 'You are an agriculture expert assistant for rural farmers in Cameroon. Respond in simple French. Refer to yourself as FamaVoice.';
    } else {
      systemPrompt = 'You are an agriculture expert assistant for rural farmers in Cameroon. Respond in simple English. Refer to yourself as FamaVoice.';
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-r1:free',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt
            },
            {'role': 'user', 'content': query}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: ${response.statusCode}\n${response.body}';
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      return "I'm sorry, something went wrong with the online service. Please try again later.";
    }
  }

  Future<String> _getOfflineResponse(String query, {required String localeId}) async {
    try {
      final String response = await rootBundle.loadString('assets/data/offline_answers.json');
      final data = await json.decode(response);
      final List<dynamic> categories = data['categories'] as List;
      final lowerCaseQuery = query.toLowerCase();

      for (var category in categories) {
        final List<dynamic> categoryKeywords = category['keywords'] as List;
        final List<dynamic> questions = category['questions'] as List;

        // Check if the query contains any of the category keywords
        bool categoryMatch = categoryKeywords.any((keyword) => lowerCaseQuery.contains(keyword.toLowerCase()));

        if (categoryMatch) {
          for (var questionData in questions) {
            final keyword = questionData['keyword'].toLowerCase();
            if (lowerCaseQuery.contains(keyword)) {
              // For offline, we'll just return the answer as is, as we don't have Pidgin translation logic here.
              // The TTS will attempt to read it in the selected voice.
              return "FamaVoice says: ${questionData['answer']}";
            }
          }
        }
      }

      return "I'm sorry, I don't have an answer for that right now. Please try asking your question in a different way or check your internet connection.";
    } catch (e) {
      return "I'm sorry, I couldn't load the offline answers. The data file might be missing or corrupted.";
    }
  }
}