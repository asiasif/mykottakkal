import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> with SingleTickerProviderStateMixin {
  String _status = "Tap a mic to speak";
  String _englishText = "";
  String _malayalamText = "";
  bool _isListening = false;
  late AnimationController _pulseController;



  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  final GoogleTranslator _translator = GoogleTranslator();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))..repeat(reverse: true);
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _listenAndTranslate(bool isEnglishInput) async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Microphone not available")));
      return;
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
       _isListening = true;
       _status = "Listening to ${isEnglishInput ? 'English' : 'Malayalam'}...";
       if (isEnglishInput) _englishText = ""; else _malayalamText = "";
    });

    await _speechToText.listen(
      onResult: (result) async {
        if (result.finalResult) {
            String spokenText = result.recognizedWords;
            setState(() {
               _isListening = false;
               if (isEnglishInput) _englishText = spokenText; else _malayalamText = spokenText;
               _status = "Translating...";
            });

            // Translate
            String targetLang = isEnglishInput ? 'ml' : 'en';
            var translation = await _translator.translate(spokenText, to: targetLang);
            
            setState(() {
               _status = "Translated Result";
               if (isEnglishInput) {
                  _malayalamText = translation.text;
                  _speak(translation.text, 'ml-IN');
               } else {
                  _englishText = translation.text;
                  _speak(translation.text, 'en-US');
               }
            });
        }
      },
      localeId: isEnglishInput ? 'en_US' : 'ml_IN', // Check locale support on device
    );
  }

  void _speak(String text, String lang) async {
    await _flutterTts.setLanguage(lang);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Ayur-Translator", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Translation Display Area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("English", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    _englishText.isEmpty && !_isListening ? "..." : _englishText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 24, color: Colors.black87),
                  ),
                  SizedBox(height: 24),
                  Icon(Icons.swap_vert, color: Colors.teal[200], size: 30),
                  SizedBox(height: 24),
                  Text("Malayalam", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    _malayalamText.isEmpty && !_isListening ? "..." : _malayalamText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansMalayalam(fontSize: 24, color: Colors.teal[900], fontWeight: FontWeight.bold),
                  ),
                  
                  if (_isListening) ...[
                     SizedBox(height: 40),
                     FadeTransition(
                       opacity: _pulseController,
                       child: Icon(Icons.graphic_eq, color: Colors.redAccent, size: 40),
                     ),
                     Text("Processing...", style: TextStyle(color: Colors.redAccent)) 
                  ]
                ],
              ),
            ),
          ),

          // Controls
          Container(
            padding: EdgeInsets.only(bottom: 40, top: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMicButton("English", Colors.blue, true),
                _buildMicButton("Malayalam", Colors.green, false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMicButton(String label, Color color, bool isEnglish) {
    return GestureDetector(
      onTap: _isListening ? null : () => _listenAndTranslate(isEnglish),
      child: Column(
        children: [
          Container(
            width: 80, 
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2)
            ),
            child: Icon(Icons.mic, color: color, size: 36),
          ),
          SizedBox(height: 12),
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: color))
        ],
      ),
    );
  }
}
