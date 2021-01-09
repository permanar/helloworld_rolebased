import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helloworld_rolebased/src/pages/chats/ChatRoom.dart';

class ChatItem extends StatelessWidget {
  final String imgURL, name, message;
  final int unread;
  final bool active;

  ChatItem(this.name, this.imgURL, this.unread, this.active, this.message);

  Widget _activeIcon(isActive) {
    if (isActive) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3),
          width: 16,
          height: 16,
          color: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Color(0xff43ce7d), // flat green
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ChatRoom(),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      var user = FirebaseAuth.instance;
                      var doc = FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.currentUser.uid)
                          .snapshots()
                          .listen((snapshot) {
                        print('yeaayyy => ${snapshot.get('role')}');
                      });

                      print('You want to see the display pictute.');
                      print('ngeheeee =>> ${user.currentUser}');
                      print('yuhuuu =>> ${user.currentUser.uid}');
                      print('doc nya oyy =>> ${doc}');

                      // we need to cancel subsscription when no longer needed
                      // doc.cancel();
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(this.imgURL),
                      radius: 30.0,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _activeIcon(active),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 6.0, right: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.name,
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4.0),
                      child: Text(
                        this.message,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Text(
                  '15 min',
                  style: TextStyle(
                    color: Colors.grey[350],
                  ),
                ),
                _UnreadIndicator(this.unread),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  final int unread;

  _UnreadIndicator(this.unread);

  bool isUnread() {
    return unread == 0;
  }

  @override
  Widget build(BuildContext context) {
    return isUnread()
        ? Container()
        : Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 30,
                color: Color(0xff3e5aeb),
                width: 30,
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: Text(
                  unread.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          );
  }
}
