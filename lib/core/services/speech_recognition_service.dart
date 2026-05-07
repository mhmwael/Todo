import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

// Singleton service managing speech-to-text voice recognition functionality
class SpeechRecognitionService {
  // Singleton instance initialization
  static final SpeechRecognitionService
  _instance = SpeechRecognitionService._internal();

  factory SpeechRecognitionService() => _instance;
  SpeechRecognitionService._internal();

  // Speech-to-text plugin instance
  final stt.SpeechToText
  _speechToText = stt.SpeechToText();

  // Tracks whether speech recognition is actively listening
  bool
  _isListening = false;

  // Stores the recognized speech text
  String
  _recognizedText = '';

  // Completer to handle async speech recognition result
  Completer<
    String
  >?
  _listeningCompleter;

  // Check if currently listening to speech
  bool
  get isListening => _isListening;

  // Get last recognized text from speech
  String
  get recognizedText => _recognizedText;

  // Request microphone permission from user
  Future<
    bool
  >
  _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      print(
        'Microphone permission: $status',
      );
      return status.isGranted;
    } catch (
      e
    ) {
      print(
        'Permission request error: $e',
      );
      return false;
    }
  }

  // Initialize speech recognition and request microphone permission
  Future<
    bool
  >
  initialize() async {
    try {
      // Request microphone permission first
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        print(
          'Microphone permission not granted',
        );
        return false;
      }

      // If already initialized successfully, return true
      if (_speechToText.isAvailable) {
        print(
          'Speech to text is already available',
        );
        return true;
      }

      // Try to initialize
      print(
        'Attempting to initialize speech to text...',
      );
      final initialized = await _speechToText.initialize(
        onError:
            (
              error,
            ) {
              print(
                'Speech error callback - error: ${error.errorMsg}',
              );
              _isListening = false;
              // Complete completer on error
              if (_listeningCompleter !=
                      null &&
                  !_listeningCompleter!.isCompleted) {
                print(
                  'Completing completer with error',
                );
                _listeningCompleter!.complete(
                  '',
                );
              }
            },
        onStatus:
            (
              status,
            ) {
              print(
                'Speech status: $status',
              );
            },
      );

      print(
        'Speech initialized: $initialized, Available: ${_speechToText.isAvailable}',
      );
      return initialized;
    } catch (
      e
    ) {
      print(
        'Init error: $e',
      );
      return false;
    }
  }

  // Start listening to user's speech and return recognized text
  Future<
    String?
  >
  startListening() async {
    try {
      // Check if available
      if (!_speechToText.isAvailable) {
        print(
          'Speech not available, attempting init...',
        );
        final initialized = await initialize();
        if (!initialized) {
          throw Exception(
            'Speech recognition not available on this device',
          );
        }
      }

      if (_isListening) {
        print(
          'Already listening',
        );
        return null;
      }

      _recognizedText = '';
      _isListening = true;
      _listeningCompleter =
          Completer<
            String
          >();
      print(
        'Starting to listen...',
      );

      await _speechToText.listen(
        onResult:
            (
              result,
            ) {
              _recognizedText = result.recognizedWords;
              print(
                'Recognized: "$_recognizedText", isFinal: ${result.finalResult}',
              );

              // If this is the final result, complete the future
              if (result.finalResult) {
                print(
                  'Final result received. Stopping listening.',
                );
                if (!_listeningCompleter!.isCompleted) {
                  _listeningCompleter!.complete(
                    _recognizedText,
                  );
                }
                // Stop listening to prevent further callbacks
                _speechToText.stop();
              }
            },
        listenFor: const Duration(
          seconds: 30,
        ),
        pauseFor: const Duration(
          seconds: 3,
        ),
        partialResults: true,
      );

      print(
        'Listening started, waiting for result...',
      );

      // Wait for the recognized text or timeout after 35 seconds
      final result = await _listeningCompleter!.future.timeout(
        const Duration(
          seconds: 35,
        ),
        onTimeout: () {
          print(
            'Listening timeout, recognized: "$_recognizedText"',
          );
          _isListening = false;
          return _recognizedText;
        },
      );

      _isListening = false;
      print(
        'Returning result: "$result"',
      );
      return result.isNotEmpty
          ? result
          : null;
    } catch (
      e
    ) {
      _isListening = false;
      print(
        'Listen error: $e',
      );
      await _speechToText.stop();
      return null;
    }
  }

  // Stop listening to speech
  Future<
    void
  >
  stopListening() async {
    try {
      if (_isListening) {
        await _speechToText.stop();
        _isListening = false;
      }
    } catch (
      e
    ) {
      print(
        'Stop error: $e',
      );
    }
  }

  // Cancel speech recognition and reset state
  Future<
    void
  >
  cancel() async {
    try {
      if (_listeningCompleter !=
              null &&
          !_listeningCompleter!.isCompleted) {
        _listeningCompleter!.complete(
          _recognizedText,
        );
      }
      await _speechToText.cancel();
      _isListening = false;
      _recognizedText = '';
    } catch (
      e
    ) {
      print(
        'Cancel error: $e',
      );
    }
  }
}
