import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GlobalWidget extends StatefulWidget {
  const GlobalWidget({super.key});

  @override
  State<GlobalWidget> createState() => _GlobalWidgetState();
}

class _GlobalWidgetState extends State<GlobalWidget> {
  _GlobalWidgetState();
  final List<Map<String, dynamic>> messages = [];
  final Image profileImage = const Image(
    width: 50, // いい感じに大きさ調節しています。
    height: 50,
    image: NetworkImage(
        'https://1.bp.blogspot.com/-BnPjHnaxR8Q/YEGP_e4vImI/AAAAAAABdco/2i7s2jl14xUhqtxlR2P3JIsFz76EDZv3gCNcBGAsYHQ/s180-c/buranko_boy_smile.png'),
  );

  final channel = WebSocketChannel.connect(Uri.parse('wss://relay.damus.io'));

  @override
  void initState() {
    Request myRequestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [1],
        limit: 50,
      )
    ]);
    channel.sink.add(myRequestWithFilter.serialize());
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
        print(_msg.message.id);
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
    return Center(
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return messageWidget(messages, index);
        },
      ),
    );
  }
}
