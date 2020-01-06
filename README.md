# Stack Exchange Authentication

Authentication for Stack Exchange in Flutter, using OAuth2.0 and V2.2 API.

This is pretty much a carbon copy of [this wonderful package](https://pub.dev/packages/linkedin_auth) with a few adaptations, so props to @ishaanbahal.

## So what do I do to use this?

- First, register on Stack Exchange [here](https://stackoverflow.com/users/signup).
- After that, head to [this link](http://stackapps.com/apps/oauth/register) to register a new application.
- You can then get your `client_id` from your application's overview page.
- If you wish to set up client side flow, enable both _Client Side Flow_ and _Desktop OAuth Redirect Uri_ options in your application's overview page. You can read more about that on the _Desktop Aplications_ section [here](https://api.stackexchange.com/docs/authentication).

## Cool, how do I use it?

Here's a piece of code showing how you would implement the client side flow, taken from the [example](https://github.com/franpitri/stackexchange_auth/tree/master/example) app.

```dart
MaterialButton(
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
    child: Text('Signup/Login', style: TextStyle(color:Colors.white),),
)
```

For server side token collection, you would have to implement a web server capable of returning the access token.