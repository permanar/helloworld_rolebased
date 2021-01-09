import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
      ),
      body: DashChat(
        messages: [
          ChatMessage(
            text: "Hello",
            user: ChatUser(
              name: "Fayeed",
              uid: "123456789",
              avatar:
                  "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
            ),
            createdAt: DateTime.now(),
            image:
                "https://modelstudents.co.uk/assets/models/176/176-profile-image-1525428232-thumb.jpg",
          ),
        ],
        user: ChatUser(
          name: "Fayeed",
          firstName: "Fayeed",
          lastName: "Pawaskar",
          uid: "12345678",
          avatar:
              "https://www.wrappixel.com/ampleadmin/assets/images/users/4.jpg",
        ),
        onSend: null,
      ),
    );
  }
}
