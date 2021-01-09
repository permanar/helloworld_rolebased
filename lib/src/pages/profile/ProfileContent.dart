import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helloworld_rolebased/src/widgets.dart';

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

  final Future<bool> Function(
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
  bool _success = false;
  Map<String, dynamic> _user = {'role': '', 'name': ''};

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
      setState(() {
        _user = event.data();
      });
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
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Manage Profile',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Hi, ${_user['name']}',
                      ),
                      TextSpan(
                        text: "\nYour current role: ${_user['role']}.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                    _success
                        ? Row(
                            children: [
                              SizedBox(width: 25),
                              Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Successfully changed!",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    Expanded(
                      child: Container(),
                    ),
                    SizedBox(width: 16),
                    StyledButton(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });

                        if (_formKey.currentState.validate()) {
                          widget
                              .modifyAccount(
                            _displayNameController.text,
                            _selectedRole.value,
                            (e) => _showErrorDialog(
                                context, 'Failed to save the changes', e),
                          )
                              .then((val) async {
                            setState(() {
                              _loading = false;
                            });

                            if (val) {
                              setState(() {
                                _success = true;
                              });

                              await Future.delayed(
                                  Duration(milliseconds: 4000));
                              setState(() {
                                _success = false;
                              });
                            }
                          });
                        }
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
