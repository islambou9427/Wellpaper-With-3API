import 'package:WellpaperUsing3Api/screenss/Home.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorScreen extends StatefulWidget {
  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  var networkSubscription;

  @override
  void initState() {
    super.initState();

    networkSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      print("Connection Status has Changed\n\n$result");
      if ((result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi)) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Home()));

        Fluttertoast.showToast(
          msg: 'INTERNET IS BACK',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Error Screen');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'All wallpaper',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Carrington',
              fontSize: 42.0,
            ),
          ),
        ),
        body: Container(
          color: Colors.black87,
          child: Column(
            children: [
              Center(
                child: Container(
                  child: Image.asset(
                    'assets/1.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Please Connect to internet or wifi",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
