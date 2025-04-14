import '../model/fluent_me_model.dart';
import '../services/fluentme_api_service.dart';

class FluentMeRepository {
  final FluentMeApiService _apiService;

  FluentMeRepository({FluentMeApiService? apiService})
      : _apiService = apiService ?? FluentMeApiService();

  Future<FluentMeResponse> scoreRecording({
    required String audioFilePath,
    required String postId,
    required int scale,
  }) async {
    try {
      final response = await _apiService.submitRecording(
        audioFilePath: audioFilePath,
        postId: postId,
        scale: scale,
      );

      // Debug the response structure
      print('Repository received response: $response');

      // Convert the API response to your model
      // Note: This might need adjustment based on the exact API response format
      try {
        if (response is List) {
          // If the response is a List, convert it directly to the model
          return FluentMeResponse.fromJson(response);
        } else if (response is Map<String, dynamic>) {
          // If the response is a Map, process it
          return FluentMeResponse.fromJson([response]); // wrap it in a List to be compatible
        } else {
          throw FormatException("Unexpected response type: ${response.runtimeType}");
        }
      } catch (e) {
        print('Error parsing response: $e');
        print('Response type: ${response.runtimeType}');
        print('Response data: $response');

        // If the response format is different than expected, fall back to mock response
        if (response is Map<String, dynamic>) {
          return _parsePostDetails(response);
        }
        rethrow;
      }
    } catch (e) {
      print('Repository error: $e');
      rethrow;
    }
  }

  FluentMeResponse _parsePostDetails(List<dynamic> response) {
    // Extract provided data, overall result data, and word result data
    final providedData = response[0]['provided_data'][0];
    final overallResultData = response[1]['overall_result_data'][0];
    final wordResultData = response[2]['word_result_data'];

    return FluentMeResponse(
      providedData: ProvidedData(
        audioProvided: providedData['audio_provided'] ?? '',
        postProvided: providedData['post_provided'] ?? '',
      ),
      overallResultData: OverallResultData(
        aiReading: overallResultData['ai_reading'] ?? '',
        lengthOfRecordingInSec: overallResultData['length_of_recording_in_sec'] ?? 0.0,
        numberOfRecognizedWords: overallResultData['number_of_recognized_words'] ?? 0,
        numberOfWordsInPost: overallResultData['number_of_words_in_post'] ?? 0,
        overallPoints: overallResultData['overall_points'] ?? 0.0,
        postLanguageId: overallResultData['post_language_id'] ?? 0,
        postLanguageName: overallResultData['post_language_name'] ?? '',
        scoreId: overallResultData['score_id'] ?? '',
        userRecordingTranscript: overallResultData['user_recording_transcript'] ?? '',
      ),
      wordResultData: wordResultData.map((wordData) {
        return WordResultData(
          points: wordData['points'] ?? 0.0,
          speed: wordData['speed'] ?? '',
          word: wordData['word'] ?? '',
        );
      }).toList(),
    );
  }
}
