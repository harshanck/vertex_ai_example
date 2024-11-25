import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

import 'message.dart';
import 'weather_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController(
      text:
          'Provide current weather and next hour forecast for Matugama, Sri Lanka');
  late final GenerativeModel _generativeModel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  _initModel() {
    _generativeModel = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
      tools: [
        Tool.functionDeclarations([currentWeatherTool, weatherForecastTool]),
      ],
    );
  }

  final currentWeatherTool = FunctionDeclaration(
    'currentWeather',
    'Get the weather conditions for a specific city',
    parameters: {
      'city': Schema.string(
        description: 'The city name to get weather',
      ),
    },
  );

  final weatherForecastTool = FunctionDeclaration(
    'weatherForecast',
    'Get the weather forecast for a specific city',
    parameters: {
      'city': Schema.string(
        description: 'The city name to get weather forecast',
      ),
    },
  );

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _messages.insert(
        0,
        Message(text: _controller.text.trim(), isSender: true),
      );
    });
    ChatSession chat = _generativeModel.startChat();

    var response = await chat.sendMessage(
      Content.text(_controller.text.trim()),
    );

    while (response.functionCalls.isNotEmpty) {
      List<FunctionResponse> functionResponses = [];
      for (var call in response.functionCalls) {
        if (call.name == 'currentWeather') {
          var city = call.args['city']! as String;
          print("Executing function: ${call.name} with city: $city");
          final apiResult = await WeatherService().getWeather(city);
          functionResponses.add(FunctionResponse(call.name, apiResult));
        } else if (call.name == 'weatherForecast') {
          var city = call.args['city']! as String;
          print("Executing function: ${call.name} with city: $city");
          final apiResult = await WeatherService().getForecast(city);
          functionResponses.add(FunctionResponse(call.name, apiResult));
        } else {
          throw UnimplementedError(
            'Unknown function: ${call.name}',
          );
        }
      }
      response = await chat.sendMessage(
        Content.functionResponses(functionResponses),
      );
    }

    if (response.text case final text?) {
      _messages.insert(0, Message(text: text, isSender: false));
      _controller.clear();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vertex AI Example')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isSender
                            ? Colors.green[200]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
