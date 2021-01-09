import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:helloworld_rolebased/src/models/record.dart';
import 'package:helloworld_rolebased/src/pages/chats/ChatContent.dart';
import 'package:helloworld_rolebased/src/pages/home/HomeContent.dart';
import 'package:helloworld_rolebased/src/pages/profile/ProfileContent.dart';
import 'package:helloworld_rolebased/src/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    Key key,
    @required this.signOut,
    @required this.modifyAccount,
  }) : super(key: key);

  final void Function() signOut;
  final void Function(
          String displayName, String role, void Function(Exception e) error)
      modifyAccount;

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomeContent(signOut: widget.signOut),
      ChatContent(context: context),
      ProfileContent(
        modifyAccount: widget.modifyAccount,
      ),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
