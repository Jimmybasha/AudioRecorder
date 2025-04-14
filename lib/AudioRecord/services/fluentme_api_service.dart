import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart' show StorageOptions;

class FluentMeApiService {
  static const String baseUrl = 'https://thefluentme.p.rapidapi.com';
  static const String rapidApiHost = 'thefluentme.p.rapidapi.com';
  static const String rapidApiKey = '35cc1bb038msh1226e4475277319p167f05jsnfda26ce69601';
  static const String supabaseBucket = 'recordings';

  final Dio _dio;

  FluentMeApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'x-rapidapi-host': rapidApiHost,
      'x-rapidapi-key': rapidApiKey,
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<String?> uploadAudioFileToSupabase(File file, String fileName) async {
    final supabase = Supabase.instance.client;
    const bucket = supabaseBucket;

    // Use timestamp-based filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = 'audio/demo_$timestamp.wav';

    try {
      final fileBytes = await file.readAsBytes();
      final contentType = lookupMimeType(file.path) ?? 'audio/wav';

      print('Uploading to Supabase path: $filePath');

      // Upload with RLS bypass
      await supabase.storage
          .from(bucket)
          .uploadBinary(
        filePath,
        fileBytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

      // Get public URL
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(filePath);
      print('Upload successful. Public URL: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('Supabase Storage Error: ${e.message}');
      return null;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }

  Future<List<dynamic>> submitRecording({
    required String audioFilePath,
    required String postId,
    required int scale,
  }) async {
    try {
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        throw Exception("Audio file not found");
      }

      final publicUrl = await uploadAudioFileToSupabase(audioFile, 'recording');

      if (publicUrl == null) {
        throw Exception("Failed to get Supabase URL");
      }

      final response = await _dio.post(
        '/score/$postId?scale=$scale',
        data: {'audio_provided': publicUrl},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Since the response is a List, you can return it as is
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      print('API Error: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      print('Submission Error: $e');
      rethrow;
    }
  }


}