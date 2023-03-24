import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import './messageSendPage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
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
  final List<Map<String, dynamic>> messages = [
    {'createdAt': 0, "content": "これが最初のメッセージ"},
    {'createdAt': 1, "content": "2つ目のメッセージ"},
    {'createdAt': 2, "content": "これが3つ目だ!"},
  ];
  final Image profileImage = const Image(
    width: 50, // いい感じに大きさ調節しています。
    height: 50,
    image: NetworkImage(
        'https://1.bp.blogspot.com/-BnPjHnaxR8Q/YEGP_e4vImI/AAAAAAABdco/2i7s2jl14xUhqtxlR2P3JIsFz76EDZv3gCNcBGAsYHQ/s180-c/buranko_boy_smile.png'),
  );

  final channel = WebSocketChannel.connect(Uri.parse('wss://relay.damus.io'));

  final myChannel = WebSocketChannel.connect(Uri.parse('wss://relay.damus.io'));
  final List<Map<String, dynamic>> myMessages = [];

  @override
  void initState() {
    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [1],
        limit: 50,
      )
    ]);
    channel.sink.add(requestWithFilter.serialize());
    channel.stream.listen((payload) {
      try {
        final _msg = Message.deserialize(payload);
        if (_msg.type == 'EVENT') {
          setState(() {
            messages.add({
              "createdAt": _msg.message.createdAt,
              "content": _msg.message.content
            });
            messages.sort((a, b) {
              return b['createdAt'].compareTo(a['createdAt']);
            });
          });
        }
      } catch (err) {}
    });
    const privKey = "<your private key>";
    final keys = Keychain(privKey);
    Request myRequestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [1],
        limit: 50,
        authors: [keys.public],
      )
    ]);
    myChannel.sink.add(myRequestWithFilter.serialize());
    myChannel.stream.listen((payload) {
      try {
        final _msg = Message.deserialize(payload);
        if (_msg.type == 'EVENT') {
          setState(() {
            myMessages.add({
              "createdAt": _msg.message.createdAt,
              "content": _msg.message.content
            });
            myMessages.sort((a, b) {
              return b['createdAt'].compareTo(a['createdAt']);
            });
          });
        }
      } catch (err) {}
    });
    super.initState();
  }

  Widget messageWidget(List<Map<String, dynamic>> messages, int index) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0), // 下線の左右に余白を作りたかった
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10), // いい感じに上下の余白を作ります。
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 上詰めにする
        children: [
          ClipRRect(
            // プロフィール画像を丸くします。
            borderRadius: BorderRadius.circular(25),
            child: profileImage,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('吾輩は猫である', // 名前です。
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    messages[index]["content"],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('これからすごくなる SNS アプリ'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.search)),
              ],
            )),
        body: TabBarView(children: [
          Center(
            child: ListView.builder(
              itemCount: myMessages.length,
              itemBuilder: (context, index) {
                return messageWidget(myMessages, index);
              },
            ),
          ),
          Center(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return messageWidget(messages, index);
              },
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessageSendPage(channel),
                fullscreenDialog: true,
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
