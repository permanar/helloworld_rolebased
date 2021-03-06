import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:helloworld_rolebased/src/pages/chats/ChatRoom.dart';
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
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('created_at', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: record.name),
                TextSpan(
                  text: "\n<${record.email}>",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          trailing: Text(record.votes.toString()),
          onTap: () =>
              record.reference.update({'votes': FieldValue.increment(1)}),
        ),
      ),
    );
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      homeContent(context),
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

  Widget homeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          SizedBox(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Let's Vote someone up!"),
                ),
                _buildBody(context)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: StyledButton(
              child: Text('LOGOUT'),
              onPressed: () {
                widget.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem {
  String value;
  String name;

  ListItem(this.value, this.name);
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({
    Key key,
    @required this.modifyAccount,
  }) : super(key: key);

  final void Function(
    String displayName,
    String role,
    void Function(Exception e) error,
  ) modifyAccount;

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  List<ListItem> _dropdownItems = [
    ListItem("counselor", "Counselor"),
    ListItem("guest", "Guest"),
    ListItem("super-admin", "Super Admin"),
  ];
  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedRole;
  bool _loading = false;

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
      _emailController.text = event.get('email');
      _displayNameController.text = event.get('name');
    });
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Manage Profile',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Change your email',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter your email address to continue';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    hintText: 'Change your name',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter your account name';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: DropdownButtonFormField<ListItem>(
                  hint: Text('Select Role'),
                  value: _selectedRole,
                  items: _dropdownMenuItems,
                  validator: (value) {
                    if (value == null) {
                      return 'Please choose one role';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 16),
                    StyledButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                        });
                        if (_formKey.currentState.validate()) {
                          widget.modifyAccount(
                            _displayNameController.text,
                            _selectedRole.value,
                            (e) => _showErrorDialog(
                                context, 'Failed to save the changes', e),
                          );
                        }
                        setState(() {
                          _loading = false;
                        });
                      },
                      child: _loading
                          ? Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : Text("Save Changes"),
                    ),
                    SizedBox(width: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatContent extends StatelessWidget {
  const ChatContent({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

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
        onPressed: null,
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
                    'Please choose your conselor',
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
          _ChatItem(
            'Bushra Martinez',
            'https://cdn-images-1.medium.com/max/1200/1*3X2tLj85Jfq3dlGxWqQ4TA.png',
            7,
            true,
            'On my way to the gym but I need to go to the supplement store to buy some BCAAs. On my way to the gym but I needed to stop at the supplement store to buy some BCAAs On my way to the gym but I needed to stop by the supplement store to buy some BCAAs.',
          ),
          _ChatItem(
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
}

class _ChatItem extends StatelessWidget {
  final String imgURL, name, message;
  final int unread;
  final bool active;

  _ChatItem(this.name, this.imgURL, this.unread, this.active, this.message);

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

class Record {
  final String name;
  final int votes;
  final String email;
  final String role;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        assert(map['email'] != null),
        assert(map['role'] != null),
        name = map['name'],
        votes = map['votes'],
        email = map['email'],
        role = map['role'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
