import 'dart:convert';

import 'package:nostr/nostr.dart';

class Auth extends Event {
  Auth(
    super.id,
    super.pubkey,
    super.createdAt,
    super.kind,
    super.tags,
    super.content,
    super.sig,
  );

  @override
  String serialize() {
    if (subscriptionId != null) {
      return jsonEncode(["AUTH", subscriptionId, toJson()]);
    } else {
      return jsonEncode(["AUTH", toJson()]);
    }
  }
}
