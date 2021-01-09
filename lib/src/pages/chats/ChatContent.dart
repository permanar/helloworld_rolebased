import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helloworld_rolebased/src/models/record.dart';
import 'package:helloworld_rolebased/src/pages/chats/ChatItem.dart';

class ChatContent extends StatefulWidget {
  const ChatContent({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _ChatContentState createState() => _ChatContentState();
}

class _ChatContentState extends State<ChatContent> {
  String currentRole;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser.uid;

    FirebaseFirestore.instance.collection("users").doc(uid).get().then((value) {
      if (value.get("role") == 'guest') {
        setState(() {
          currentRole = 'counselor';
        });
      }
      if (value.get("role") == 'counselor') {
        setState(() {
          currentRole = 'guest';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List avatars = [
      "https://cdn-images-1.medium.com/max/1200/1*3X2tLj85Jfq3dlGxWqQ4TA.png'",
      "https://www.thenational.ae/image/policy:1.696524:1516870898/DTrCaEnXUAAIGi2.jpg?f=16x9&w=1200'",
      "https://pbs.twimg.com/profile_images/1114924576679424000/budLZeGp_400x400.jpg'",
      "https://modelstudents.co.uk/assets/models/176/176-profile-image-1525428232-thumb.jpg'",
      "https://akns-images.eonline.com/eol_images/Entire_Site/2017618/rs_765x1024-170718174545-765.Kim-Kardashian-Mascara.jl.071817.jpg?fit=inside|900:auto&output-quality=90"
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    child: Text(
                      'Please choose your $currentRole',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where("role", isEqualTo: currentRole)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        );

                      return _buildChatList(context, snapshot.data.docs);
                    },
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_downward,
                        size: 30,
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
        tooltip: "Search for conselor",
        child: Icon(Icons.search),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Chats',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(Icons.search),
                  ),
                )
              ],
            ),
          ),
          ChatItem(
            'Bushra Martinez',
            'https://cdn-images-1.medium.com/max/1200/1*3X2tLj85Jfq3dlGxWqQ4TA.png',
            7,
            true,
            'On my way to the gym but I need to go to the supplement store to buy some BCAAs. On my way to the gym but I needed to stop at the supplement store to buy some BCAAs On my way to the gym but I needed to stop by the supplement store to buy some BCAAs.',
          ),
          ChatItem(
            'Zainab Khan',
            'https://www.thenational.ae/image/policy:1.696524:1516870898/DTrCaEnXUAAIGi2.jpg?f=16x9&w=1200',
            0,
            false,
            'Rahhhh... I saw u with bushra',
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children:
          snapshot.map((data) => _buildChatListItem(context, data)).toList(),
    );
  }

  Widget _buildChatListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return ChatItem(
      record.name,
      'https://www.thenational.ae/image/policy:1.696524:1516870898/DTrCaEnXUAAIGi2.jpg?f=16x9&w=1200',
      0,
      false,
      'Rahhhh... I saw u with bushra',
    );
  }
}
