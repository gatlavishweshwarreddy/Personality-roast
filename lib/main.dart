import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!kIsWeb) {
      await Purchases.configure(
        PurchasesConfiguration('test_OxllDKILQOlnyimetdBcOmBNmyp'),
      );
    }
  } catch (e) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personality Roast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

const String apiKey = 'GEMINI_API_KEY';
const String apiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=$apiKey';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text(
              'Personality Roast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Chat with our AI and get brutally roasted',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(mode: 'roast'),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text(
    'Roast My Personality 🔥',
    style: TextStyle(color: Colors.white, fontSize: 18),
  ),
),
const SizedBox(height: 16),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(mode: 'vent'),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange.shade800,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text(
    'Roast My Problems 😤',
    style: TextStyle(color: Colors.white, fontSize: 18),
  ),
),
const SizedBox(height: 16),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red.shade900,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text(
    '💀 Savage Mode (Pro)',
    style: TextStyle(color: Colors.white, fontSize: 18),
  ),
),

const SizedBox(height: 16),
ElevatedButton(
  onPressed: () async {
    final customerInfo = await Purchases.getCustomerInfo();
    final isPro = customerInfo.entitlements.active.containsKey('savage_mode');
    if (isPro) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DailyRoastScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PaywallScreen(),
        ),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade800,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text(
    'Daily Roast 🎯 (Pro)',
    style: TextStyle(color: Colors.white, fontSize: 18),
  ),
),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final String mode;
  const ChatScreen({super.key, required this.mode});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final List<Map<String, dynamic>> history = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;

  @override
void initState() {
  super.initState();
  setState(() {
    if (widget.mode == 'roast') {
      messages.add(ChatMessage(
        text: 'Hey! 👋 I\'m your Roast Master 🔥\n\nI\'m going to ask you a few fun questions and then absolutely destroy your personality. Ready?\n\nFirst question: What\'s your go-to excuse to cancel plans?',
        isUser: false,
      ));
    } else {
      messages.add(ChatMessage(
        text: 'Hey! 😤 Rough day? Tell me what\'s going on and I\'ll roast your problems into oblivion.\n\nWhat\'s bothering you right now?',
        isUser: false,
      ));
    }
  });
}


  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    controller.clear();

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      isLoading = true;
    });
    scrollToBottom();

    history.add({
      'role': 'user',
      'parts': [{'text': text}]
    });

    final systemPrompt = widget.mode == 'roast' ? '''
You are a savage but friendly AI roast master. Ask fun casual questions one at a time about the user's personality and habits. After 6-8 questions, deliver a hilarious savage but friendly roast based on their answers. End with a funny nickname. Keep responses short and conversational.
''' : widget.mode == 'savage' ? '''
You are the most brutal, savage, no-mercy AI roast master. Ask questions then absolutely destroy the user with the most savage, brutal, hilarious roast possible. No filter. No mercy. End with the most savage nickname ever. This is SAVAGE MODE.
''' : '''
You are a funny, savage but supportive AI therapist. When the user vents about their problems, roast the situation with humor to make them laugh and feel better. Be witty, savage but always end with something uplifting. Keep responses short and punchy.
''';

    final body = jsonEncode({
      'system_instruction': {
        'parts': [{'text': systemPrompt}]
      },
      'contents': history,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];

      history.add({
        'role': 'model',
        'parts': [{'text': reply}]
      });

      setState(() {
  messages.add(ChatMessage(text: reply, isUser: false));
  isLoading = false;
});

// Detect if roast is delivered
if (reply.contains('dub thee') || reply.contains('nickname') || 
    reply.contains('I dub') || reply.contains('**')) {
  // Extract nickname between ** **
  final nickRegex = RegExp(r'\*\*(.*?)\*\*');
  final match = nickRegex.firstMatch(reply);
  final nickname = match?.group(1) ?? 'Roast Victim';
  
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoastCardScreen(
          roastText: reply,
          nickname: nickname,
        ),
      ),
    );
  });
}
    } catch (e) {
      
      setState(() {
        messages.add(ChatMessage(
            text: 'Something went wrong. Try again!', isUser: false));
        isLoading = false;
      });
    }
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Text('🔥', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Roast Master', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        CircularProgressIndicator(
                          color: Colors.deepPurple,
                          strokeWidth: 2,
                        ),
                      ],
                    ),
                  );
                }
                final message = messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Colors.deepPurple
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade900,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your answer...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => sendMessage(controller.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoastCardScreen extends StatelessWidget {
  final String roastText;
  final String nickname;
  final ScreenshotController screenshotController = ScreenshotController();

  RoastCardScreen({super.key, required this.roastText, required this.nickname});

  Future<void> shareCard() async {
    final image = await screenshotController.capture();
    if (image != null) {
      await Share.shareXFiles(
        [XFile.fromData(image, mimeType: 'image/png', name: 'roast.png')],
        text: 'I got roasted by AI 🔥 Get yours at PersonalityRoast app!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Your Roast Card 🔥',
            style: TextStyle(color: Colors.white)),
      ),
    body: SingleChildScrollView(
  child: Column(
    children: [
      Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1a0033), Color(0xFF4a0080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            const Text(
              'PERSONALITY ROAST',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              roastText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                nickname,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'personalityroast.app',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: shareCard,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text('Share Your Roast 🔥',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
      ),
      const SizedBox(height: 20),
    ],
  ),
),
    );
  }
}

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool isLoading = false;

  Future<void> purchase() async {
    setState(() => isLoading = true);
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering != null && offering.monthly != null) {
        await Purchases.purchasePackage(offering.monthly!);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(mode: 'savage'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Savage Mode 💀',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💀', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              const Text(
                'Savage Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No mercy. No filter. Pure destruction.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade900),
                ),
                child: const Column(
                  children: [
                    FeatureRow(text: '💀 Absolutely brutal roasts'),
                    FeatureRow(text: '🔥 No mercy mode activated'),
                    FeatureRow(text: '😈 Savage personality destruction'),
                    FeatureRow(text: '♾️ Unlimited roast sessions'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : purchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Get Savage Mode - \$0.99/month',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  final String text;
  const FeatureRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class DailyRoastScreen extends StatefulWidget {
  const DailyRoastScreen({super.key});

  @override
  State<DailyRoastScreen> createState() => _DailyRoastScreenState();
}

class _DailyRoastScreenState extends State<DailyRoastScreen> {
  String roast = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    generateDailyRoast();
  }

  Future<void> generateDailyRoast() async {
    final today = DateTime.now();
    final dayOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][today.weekday - 1];

    final body = jsonEncode({
      'contents': [{
        'role': 'user',
        'parts': [{'text': 'Generate a savage, funny daily roast for someone on a $dayOfWeek. Make it about typical $dayOfWeek behavior and mood. Keep it under 4 sentences. End with a funny nickname.'}]
      }],
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];
      setState(() {
        roast = reply;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        roast = 'Even the AI is tired today. Come back tomorrow! 😴';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Daily Roast 🎯',
            style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              const Text(
                'Your Daily Roast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Come back every day for a fresh roast 🔥',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade800),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : Text(
                        roast,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => generateDailyRoast(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Roast Me Again 🎯',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
