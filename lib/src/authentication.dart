import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:helloworld_rolebased/src/pages/DashboardPage.dart';

import 'widgets.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  password,
  register,
  loggedIn,
}

class Authentication extends StatelessWidget {
  const Authentication({
    @required this.loginState,
    @required this.email,
    @required this.startLoginFlow,
    @required this.verifyEmail,
    @required this.signIn,
    @required this.signOut,
    @required this.cancelRegistration,
    @required this.registerAccount,
    @required this.modifyAccount,
  });

  final ApplicationLoginState loginState;
  final String email;
  final void Function() startLoginFlow;
  final void Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;
  final void Function(
    String email,
    String password,
    void Function(Exception e) error,
  ) signIn;
  final void Function() cancelRegistration;
  final void Function(
    String email,
    String displayName,
    String password,
    String role,
    void Function(Exception e) error,
  ) registerAccount;
  final void Function(
    String displayName,
    String role,
    void Function(Exception e) error,
  ) modifyAccount;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 100,
              ),
              child: StyledButton(
                child: Text('Login'),
                onPressed: () {
                  startLoginFlow();
                },
              ),
            ),
          ],
        );
      case ApplicationLoginState.emailAddress:
        return EmailForm(
            callback: (email) => verifyEmail(
                email, (e) => _showErrorDialog(context, 'Invalid email', e)));
      case ApplicationLoginState.password:
        return PasswordForm(
          email: email,
          cancel: () {
            cancelRegistration();
          },
          login: (email, password) {
            signIn(email, password,
                (e) => _showErrorDialog(context, 'Failed to sign in', e));
          },
        );
      case ApplicationLoginState.register:
        return RegisterForm(
          email: email,
          cancel: () {
            cancelRegistration();
          },
          registerAccount: (
            email,
            displayName,
            password,
            role,
          ) {
            registerAccount(
              email,
              displayName,
              password,
              role,
              (e) => _showErrorDialog(context, 'Failed to create account', e),
            );
          },
        );
      case ApplicationLoginState.loggedIn:
        return DashboardPage(
          signOut: signOut,
          modifyAccount: modifyAccount,
        );
      default:
        return Row(
          children: [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
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
}

class EmailForm extends StatefulWidget {
  EmailForm({@required this.callback});
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header('Sign in with email'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: StyledButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            widget.callback(_controller.text);
                            log('clicked?');
                          }
                        },
                        child: Text('NEXT'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ListItem {
  String value;
  String name;

  ListItem(this.value, this.name);
}

class RegisterForm extends StatefulWidget {
  RegisterForm({
    @required this.registerAccount,
    @required this.cancel,
    @required this.email,
  });
  final String email;
  final void Function(
          String email, String displayName, String password, String role)
      registerAccount;
  final void Function() cancel;
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  List<ListItem> _dropdownItems = [
    ListItem("counselor", "Counselor"),
    ListItem("guest", "Guest"),
    ListItem("super-admin", "Super Admin"),
  ];
  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedRole;

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

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedRole = _dropdownMenuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header('Create account'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
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
                      hintText: 'First & last name',
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
                  child: DropdownButton<ListItem>(
                    hint: Text('Select Role'),
                    value: _selectedRole,
                    items: _dropdownMenuItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.cancel,
                        child: Text('CANCEL'),
                      ),
                      SizedBox(width: 16),
                      StyledButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            widget.registerAccount(
                              _emailController.text,
                              _displayNameController.text,
                              _passwordController.text,
                              _selectedRole.value,
                            );
                          }
                        },
                        child: Text('SAVE'),
                      ),
                      SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordForm extends StatefulWidget {
  PasswordForm({
    @required this.login,
    @required this.email,
    @required this.cancel,
  });
  final String email;
  final void Function(String email, String password) login;
  final void Function() cancel;
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header('Sign in'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
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
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.cancel,
                        child: Text('CANCEL'),
                      ),
                      SizedBox(width: 16),
                      StyledButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            widget.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                        child: Text('SIGN IN'),
                      ),
                      SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
