import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:famavoice/models/message_model.dart';
import 'package:famavoice/services/ai_service.dart';
import 'package:famavoice/services/voice_input_service.dart';
import 'package:famavoice/services/connectivity_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:famavoice/widgets/animated_chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _voiceInputService = VoiceInputService();
  final FlutterTts _flutterTts = FlutterTts();
  final AiService _aiService = AiService();

  final List<Message> _messages = <Message>[];
  bool _isListening = false;
  bool _isAiTyping = false;
  bool _isInitializing = true;
  String _currentLocaleId = 'en_US';
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _textEditingController;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  List<dynamic> _availableVoices = []; // To store available voices
  String? _selectedVoiceName;

  // Example prompts to guide the user
  final List<String> _examplePrompts = [
    'How to plant beans during the dry season?',
    'What are the best fertilizers for maize?',
    'Show me the current price of cocoa.',
  ];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _initializeServices();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _colorAnimation = ColorTween(
      begin: Colors.red.shade700,
      end: Colors.red.shade400,
    ).animate(_animationController);
  }

  Future<void> _initializeServices() async {
    await _voiceInputService.init();
    await _initTts();
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _initTts() async {
    _availableVoices = await _flutterTts.getVoices;
    print('Available TTS Voices: $_availableVoices');

    String? voiceToSet;
    // Prioritize en-NG and fr-CM
    if (_currentLocaleId == 'en_NG') {
      voiceToSet = _availableVoices.firstWhere(
        (voice) => voice['locale'] == 'en-ng', // Check for en-ng locale
        orElse: () => null,
      )?['name'];
    } else if (_currentLocaleId == 'fr_CM') {
      voiceToSet = _availableVoices.firstWhere(
        (voice) => voice['locale'] == 'fr-cm', // Check for fr-cm locale
        orElse: () => null,
      )?['name'];
    } else if (_currentLocaleId == 'en_US') {
      voiceToSet = _availableVoices.firstWhere(
        (voice) => voice['locale'] == 'en-us', // Fallback to en-us
        orElse: () => null,
      )?['name'];
    }

    if (voiceToSet != null) {
      await _flutterTts.setVoice({'name': voiceToSet, 'locale': _currentLocaleId});
      _selectedVoiceName = voiceToSet;
      print('No specific voice found for $_currentLocaleId. Setting language only.');
    } else {
      // Fallback to setting just the language if no specific voice is found
      await _flutterTts.setLanguage(_currentLocaleId);
      _selectedVoiceName = null; // Clear selected voice name if not found
      print('No specific voice found for $_currentLocaleId. Setting language only.');
    }

    // Set speech rate and pitch
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/famavoice_logo.png',
              height: 30, // Adjust size as needed
            ),
            const SizedBox(width: 10),
            const Text('Ask FamaVoice', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Consumer<ConnectivityService>(
            builder: (context, connectivityService, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  connectivityService.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: connectivityService.isOnline ? Colors.green : Colors.red,
                ),
              );
            },
          ),
          _buildLanguageSwitcher(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceVariant.withAlpha((255 * 0.3).round()),
              Theme.of(context).colorScheme.surfaceVariant.withAlpha((255 * 0.1).round()),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildChatHistory()),
            _buildMicButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    return PopupMenuButton<String>(
      onSelected: (String value) async {
        setState(() {
          _currentLocaleId = value;
        });
        await _initTts();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'en_US', child: Text('English')),
        const PopupMenuItem<String>(value: 'en_NG', child: Text('Pidgin')),
        const PopupMenuItem<String>(value: 'fr_CM', child: Text('French')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.3).round())),
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 4),
            Text(
              _currentLocaleId == 'en_US' ? 'English' : (_currentLocaleId == 'en_NG' ? 'Nigerian English' : 'Cameroonian French'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHistory() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUserMessage = message.sender == 'user';
        return AnimatedChatMessage(
          isUserMessage: isUserMessage,
          child: Align(
            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUserMessage ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUserMessage ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text.replaceAll('*', ''), // Remove asterisks from display
                style: TextStyle(
                  color: isUserMessage
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicButton() {
    if (_isInitializing) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (!_voiceInputService.isInitialized) return;
            if (_isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return CircleAvatar(
                radius: _isListening ? 50 : 40, // Larger when listening
                backgroundColor: _isListening
                    ? _colorAnimation.value
                    : Theme.of(context).primaryColor,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: _isListening ? 50 : 40,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isListening ? 'Listening...' : 'Tap to Speak',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.8).round()),
              ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onSubmitted: (text) {
              if (text.isNotEmpty) {
                _handleSpeechResult(text, isFinal: true);
                _textEditingController.clear();
              }
            },
          ),
        ),
      ],
    );
  }

  void _startListening() {
    _animationController.repeat(reverse: true);
    _voiceInputService.startListening(
      localeId: _currentLocaleId,
      onResult: (text) {
        if (text.isNotEmpty) {
          _handleSpeechResult(text, isFinal: true);
        }
      },
      onPartialResult: (text) {
        if (text.isNotEmpty) {
          _textEditingController.text = text; // Update text field with partial results
          _textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textEditingController.text.length));
          _handleSpeechResult(text, isFinal: false);
        }
      },
      onListening: (isListening) {
        if (mounted) {
          setState(() {
            _isListening = isListening;
          });
          if (!isListening) {
            _animationController.stop();
            _animationController.reset();
          }
        }
      },
    );
  }

  void _stopListening() {
    _voiceInputService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _handleSpeechResult(String text, {required bool isFinal}) async {
    if (text.isEmpty) return;

    if (isFinal) {
      // Stop listening before getting AI response
      _stopListening();

      // Add user message to chat
      _addMessage(Message(
          id: DateTime.now().toString(),
          text: text,
          sender: 'user',
          timestamp: DateTime.now()));

      setState(() {
        _isAiTyping = true;
      });

      // Get response from AI service
      final responseText = await _aiService.getResponse(text, localeId: _currentLocaleId);

      // Add AI response to chat
      _addMessage(Message(
          id: DateTime.now().toString(),
          text: responseText,
          sender: 'ai',
          timestamp: DateTime.now()));

      setState(() {
        _isAiTyping = false;
      });

      // Speak the response
      await _speak(responseText);

      // Re-enable listening after TTS finishes
      if (mounted) {
        // _startListening(); // Only re-enable if user explicitly taps mic again
      }
    } else {
      // Update the last message with partial results
      if (_messages.isNotEmpty && _messages.last.sender == 'user') {
        setState(() {
          _messages.last = _messages.last.copyWith(text: text);
        });
      } else {
        // If there's no user message yet, add a new one for partial results
        _addMessage(Message(
            id: DateTime.now().toString(),
            text: text,
            sender: 'user',
            timestamp: DateTime.now()));
      }
    }
  }

  void _addMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
    // Scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    final cleanText = text.replaceAll('*', ''); // Remove asterisks
    await _flutterTts.speak(cleanText);
    // Re-enable listening after TTS finishes
    if (mounted) {
      // _startListening(); // Only re-enable if user explicitly taps mic again
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceInputService.cancelListening();
    _flutterTts.stop();
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}