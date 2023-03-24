import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSendPage extends StatefulWidget {
  const MessageSendPage({super.key});

  @override
  _MessageSendPageState createState() => _MessageSendPageState();
}

class _MessageSendPageState extends State<MessageSendPage> {
  String _text = ''; // メッセージ
  String _privKey = ''; // 秘密鍵
  final _textEditingController = TextEditingController();
  WebSocketChannel channel =
      WebSocketChannel.connect(Uri.parse('wss://relay.damus.io'));

  _MessageSendPageState();

  // テキストフィールドと _text を合わせる
  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  // テキストフィールドと _privKey を合わせる
  void _handleKey(String e) {
    setState(() {
      _privKey = e;
    });
  }

  // メッセージを送信する
  void _sendMessage() {
    if (_privKey == '' && _text == '') return;
    Event event = Event.from(
      kind: 1,
      content: _text,
      privkey: _privKey,
      tags: [],
    );
    channel.sink.add(event.serialize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージ送信'),
        actions: [
          // メッセージの送信ボタン
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _sendMessage();
                _handleText('');
                _textEditingController.clear();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '秘密鍵',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  enabled: true,
                  onChanged: _handleKey,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メッセージ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _textEditingController,
                  enabled: true,
                  onChanged: _handleText,
                  minLines: 3,
                  maxLines: 10,
                ),
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                  child: const Icon(Icons.login),
                  onTap: () {
                    print('pressed!');
                    var p = Keychain.generate();
                    print(p.public);
                    print(p.private);
                  }))
        ],
      ),
    );
  }
}
