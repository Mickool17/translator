import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, String> languageCodes = {
    'English': 'en',
    'Yoruba': 'yo', 
    'Ibo': 'ig',
    'Hausa': 'ha',
  };

  Future<String> translate(String text, String to) async {
    var url = Uri.parse(
        'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=$to');
    var response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': 'ece7cf4d4a78483289c547039707b434',
        'Ocp-Apim-Subscription-Region': 'global', 
        'Content-Type': 'application/json',
      },
      body: jsonEncode([
        {'Text': text},
      ]),
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse[0]['translations'][0]['text'];
    } else {
      throw Exception('Failed to translate text');
    }
  }

  SpeechToText speechToText = SpeechToText();
  var textresult = "hold the button and start speaking";
  var microphonepressed = false;

  String dropdownValue1 = 'Yoruba';
  String dropdownValue2 = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
          endRadius: 100,
          animate: microphonepressed,
          duration: const Duration(
            milliseconds: 2000,
          ),
          glowColor: Colors.red,
          repeatPauseDuration: const Duration(milliseconds: 100),
          showTwoGlows: true,
          child: GestureDetector(
              onTapDown: (details) async {
                if (!microphonepressed) {
                  bool available = await speechToText.initialize();
                  if (available) {
                    setState(() {
                      microphonepressed = true;
                    });
                    speechToText.listen(
                      onResult: (result) async {
                        setState(() {
                          textresult = result.recognizedWords;
                        });
                        var translatedText = await translate(
                            textresult, languageCodes[dropdownValue2]!);
                        setState(() {
                          textresult = translatedText;
                        });
                      },
                    );
                  }
                }
              },
              onTapUp: (details) {
                setState(() {
                  microphonepressed = false;
                });
                speechToText.stop();
              },
              child: CircleAvatar(
                radius: 50,
                child: Icon(microphonepressed ? Icons.mic : Icons.mic_off),
              ))),
      body: SingleChildScrollView(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                textresult,
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: microphonepressed ? Colors.black87 : Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: null, // This disables the button
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'English',
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const Spacer(),
                  Container(
                    // ignore: prefer_const_constructors
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue2,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 0,
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue2 = newValue ?? dropdownValue2;
                          });
                          // Only translate if the text is not the initial instruction
                          if (textresult !=
                              "hold the button and start speaking") {
                            translate(
                                    textresult, languageCodes[dropdownValue2]!)
                                .then((translatedText) {
                              setState(() {
                                textresult = translatedText;
                              });
                            });
                          }
                        },
                        style: GoogleFonts.poppins(color: Colors.white),
                        dropdownColor: Colors.black,
                        items: <String>['English', 'Yoruba', 'Ibo', 'Hausa']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.poppins(fontSize: 12,fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
