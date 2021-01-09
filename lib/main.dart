import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld_rolebased/src/authentication.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() async {
  // await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Vote App!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: _buildBody(context),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => Authentication(
          email: appState.email,
          loginState: appState.loginState,
          startLoginFlow: appState.startLoginFlow,
          signIn: appState.signIn,
          signOut: appState.signOut,
          verifyEmail: appState.verifyEmail,
          cancelRegistration: appState.cancelRegistration,
          registerAccount: appState.registerAccount,
          modifyAccount: appState.modifyAccount,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: _signIn,
      //     tooltip: 'Login!',
      //     child: Icon(Icons
      //         .login),),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
      } else {
        _loginState = ApplicationLoginState.loggedOut;
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState;
  ApplicationLoginState get loginState => _loginState;

  String _email;
  String get email => _email;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void verifyEmail(String email,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }

      _email = email;
      notifyListeners();

      print(_email);
      print(_loginState);
      print(methods);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signIn(String email, String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('info user login =>> $user');

      var doc =
          FirebaseFirestore.instance.collection('users').doc(user.user.uid);

      await doc.set({"created_at": user.user.metadata.creationTime},
          SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void registerAccount(String email, String displayName, String password,
      String role, void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user.updateProfile(displayName: displayName);

      var doc = FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user.uid);

      await doc.set({
        "email": email,
        "name": displayName,
        "role": role,
        "votes": Random().nextInt(500) + 150,
        "created_at": credential.user.metadata.creationTime
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  Future<void> modifyAccount(String displayName, String role,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = FirebaseAuth.instance.currentUser;
      await credential.updateProfile(displayName: displayName);

      var doc =
          FirebaseFirestore.instance.collection('users').doc(credential.uid);

      await doc.set({
        "name": displayName,
        "role": role,
        "updated_at": FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      errorCallback(FirebaseAuthException(message: 'Hehe'));
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
