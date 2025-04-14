// Models for API response parsing

class FluentMeResponse {
  final ProvidedData providedData;
  final OverallResultData overallResultData;
  final List<WordResultData> wordResultData;

  FluentMeResponse({
    required this.providedData,
    required this.overallResultData,
    required this.wordResultData,
  });

  factory FluentMeResponse.fromJson(List<dynamic> json) {
    return FluentMeResponse(
      providedData: ProvidedData.fromJson(json[0]['provided_data'][0]),
      overallResultData: OverallResultData.fromJson(json[1]['overall_result_data'][0]),
      wordResultData: (json[2]['word_result_data'] as List)
          .map((word) => WordResultData.fromJson(word))
          .toList(),
    );
  }
}

class ProvidedData {
  final String audioProvided;
  final String? postProvided;

  ProvidedData({required this.audioProvided, this.postProvided});

  factory ProvidedData.fromJson(Map<String, dynamic> json) {
    return ProvidedData(
      audioProvided: json['audio_provided'],
      postProvided: json['post_provided'],
    );
  }
}

class OverallResultData {
  final String aiReading;
  final double lengthOfRecordingInSec;
  final int numberOfRecognizedWords;
  final int numberOfWordsInPost;
  final double overallPoints;
  final int postLanguageId;
  final String postLanguageName;
  final String scoreId;
  final String userRecordingTranscript;

  OverallResultData({
    required this.aiReading,
    required this.lengthOfRecordingInSec,
    required this.numberOfRecognizedWords,
    required this.numberOfWordsInPost,
    required this.overallPoints,
    required this.postLanguageId,
    required this.postLanguageName,
    required this.scoreId,
    required this.userRecordingTranscript,
  });

  factory OverallResultData.fromJson(Map<String, dynamic> json) {
    return OverallResultData(
      aiReading: json['ai_reading'],
      lengthOfRecordingInSec: double.parse(json['length_of_recording_in_sec'].toString()),
      numberOfRecognizedWords: json['number_of_recognized_words'],
      numberOfWordsInPost: json['number_of_words_in_post'],
      overallPoints: double.parse(json['overall_points'].toString()),
      postLanguageId: json['post_language_id'],
      postLanguageName: json['post_language_name'],
      scoreId: json['score_id'],
      userRecordingTranscript: json['user_recording_transcript'],
    );
  }
}

class WordResultData {
  final double points;
  final String speed;
  final String word;

  WordResultData({
    required this.points,
    required this.speed,
    required this.word,
  });

  factory WordResultData.fromJson(Map<String, dynamic> json) {
    return WordResultData(
      points: double.parse(json['points'].toString()),
      speed: json['speed'],
      word: json['word'],
    );
  }
}