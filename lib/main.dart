import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necessário para o MethodChannel
import 'package:watch_connectivity/watch_connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Apple Watch Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Send Text to Apple Watch'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WatchConnectivityBase _watchConnectivity = WatchConnectivity();
  String _receivedText = "";
  final TextEditingController _textController = TextEditingController();

  // Método de canal para se comunicar com o código nativo
  static const platform = MethodChannel('com.example.watch');

  @override
  void initState() {
    super.initState();

    // Escutar mensagens vindas do iOS (via canal nativo)
    platform.setMethodCallHandler((call) async {
      if (call.method == "receivedMessage") {
        setState(() {
          _receivedText = call.arguments as String;
        });
      }
    });

    // Listen for messages from the Apple Watch
    _watchConnectivity.messageStream.listen((message) {
      print('Mensagem recebida no Flutter: $message');
      if (message.containsKey('response')) {
        setState(() {
          _receivedText = message['response'];
        });
      }
    });
  }

  Future<void> _sendTextToAppDelegate(String message) async {
    try {
      await platform.invokeMethod('sendMessageToAppDelegate', message);
      print('Mensagem enviada para o AppDelegate: $message');
    } on PlatformException catch (e) {
      print('Erro ao enviar mensagem para o AppDelegate: ${e.message}');
    }
  }

  Future<void> _sendTextToWatch() async {
    final textToSend = _textController.text;
    final isPaired = await _watchConnectivity.isPaired;
    final isReachable = await _watchConnectivity.isReachable;

    if (isPaired && isReachable) {
      // Enviar texto ao Apple Watch
      _watchConnectivity.sendMessage({'text': textToSend});
      print('Mensagem enviada para o Apple Watch: $textToSend');
      
      // Também enviar texto ao AppDelegate
      await _sendTextToAppDelegate(textToSend);
    } else {
      print('Apple Watch não está conectado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Digite o texto para enviar ao Apple Watch',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendTextToWatch,
              child: const Text('Enviar para Apple Watch'),
            ),
            const SizedBox(height: 20),
            Text(
              'Recebido do Apple Watch: $_receivedText',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}