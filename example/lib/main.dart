import 'package:flutter/material.dart';
import 'package:stackexchange_auth/stackexchange_auth.dart';

void main() => runApp(MyApp());

/// This is a client side token collection example, for server side, you need
/// to implement a web server capable of returning the access token.
/// For more info, please visit:
/// https://api.stackexchange.com/docs/authentication
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack Exchange Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _HomeWidget(),
    );
  }
}

class _HomeWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StackExchange Login Example'),
      ),
      body: Center(
        child: MaterialButton(
          color: Colors.blue,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        leading: CloseButton(),
                      ),
                      body: StackExchangeLoginView(
                        clientId: 'your_client_id',
                        redirectUrl: 'https://stackoverflow.com/oauth/login_success',
                        onError: (String error) {
                          print(error);
                        },
                        onTokenCapture: (token) {
                          print('${token.token} ${token.expiry}');
                          Navigator.pop(context, token);
                        },
                        clientSideFlow: true,
                      ))),
            );
          },
          child: Text("Signup/Login", style: TextStyle(color:Colors.white),),
        ),
      ),
    );
  }

}