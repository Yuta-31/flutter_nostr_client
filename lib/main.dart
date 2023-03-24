import 'package:flutter/material.dart';
import 'package:nostr_client/global.dart';
import 'package:nostr_client/messageSendPage.dart';
import 'package:nostr_client/profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: NostrWidget(),
      ),
    );
  }
}

class NostrWidget extends StatefulWidget {
  const NostrWidget({super.key});

  @override
  State<NostrWidget> createState() => _NostrWidgetState();
}

class _NostrWidgetState extends State<NostrWidget> {
  _NostrWidgetState();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgets = [const ProfileWidget(), const GlobalWidget()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('これからすごくなる SNS アプリ'),
      ),
      body: _widgets.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessageSendPage(),
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Global'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
