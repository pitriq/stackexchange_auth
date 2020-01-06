import 'package:flutter/material.dart';
import 'package:stackexchange_auth/models/models.dart';
import 'package:stackexchange_auth/service/stackexchange_service.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

/// Renders a [WebView] without a scaffold. One must provide a base view to render
/// the view. You can use a full page route and render it or use an Dialog. This view
/// will not render without a scaffold parent.
class StackExchangeLoginView extends StatefulWidget {
  /// Redirect Url provided to linkedIn developer console
  final String redirectUrl;

  /// Client ID from developer dashboard
  final String clientId;

  /// Custom callback for onError method, please provide one to get errors and do actions on them.
  final Function(String) onError;

  /// Success callback when token is captured, from this method, normally you would close the
  /// scaffold by calling [Navigation.pop] and use [AccessToken] to store in secure storage.
  final Function(AccessToken) onTokenCapture;

  /// Any calls to redirect URI will be bypassed from the [WebView] and called directly and the
  /// [http.Response] will be given to the user to fetch token and expiry from it.
  final AccessToken Function(http.Response) onServerResponse;

  /// Scopes to get access for, default scope would be empty, which would only allow to access /me method.
  /// Optional field, can be ignored for default behaviour.
  final List<StackExchangeScope> scopes;

  /// Applications that have the client side flow enabled can use https://stackexchange.com/oauth/login_success 
  /// as their redirect_uri by default. This way, upon a successful authentication, access_token will be placed 
  /// in the url hash as with a standard implicit authentication.
  /// 
  /// This is provided so non-web clients can participate in OAuth 2.0 without requiring a full fledged web server.
  /// 
  /// Defaults to false.
  final bool clientSideFlow;

  StackExchangeLoginView(
      {@required this.redirectUrl,
      @required this.clientId,
      @required this.onError,
      this.onTokenCapture,
      this.onServerResponse,
      this.scopes,
      this.clientSideFlow = false});

  _StackExchangeLoginViewState createState() => _StackExchangeLoginViewState();
}

class _StackExchangeLoginViewState extends State<StackExchangeLoginView> {
  // Redirect 
  
  // Response values
  static const STATE = 'state';
  static const ACCESS_TOKEN = 'access_token';
  static const EXPIRES = 'expires';
  static const ERROR = 'error';
  static const ERROR_DESC = 'error_description';
  
  StackExchangeRequest _request;

  @override
  void initState() {
    super.initState();
    _request = StackExchangeService.getStackExchangeRequest(
      clientId: widget.clientId,
      redirectUri: widget.redirectUrl,
      scopes: widget.scopes != null
          ? widget.scopes
          : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: _request.url,
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: _navDelegate,
    );
  }

  /// Handles the navigation delegation for the [WebView]. If redirectUrl is found
  /// in the URL, then a call is made separately to the server and parsed
  /// by the custom [widget.onServerResponse] method.
  ///
  /// On any error, navigation is prevented and error is returned in [widget.onError]
  ///
  /// On successful token capture, [widget.onTokenCapture] gets the data, from where,
  /// one must close the WebView.
  NavigationDecision _navDelegate(NavigationRequest req) {
    if (req.url.contains(widget.redirectUrl)) {
      Uri uri = Uri.parse(req.url);
      Map<String, String> queryParams = uri.queryParameters;
      String error = _parseError(queryParams);
      if (error.isNotEmpty) {
        widget.onError(error);
        return NavigationDecision.prevent;
      }
      if (queryParams.containsKey(STATE) &&
          !_request.verifyState(queryParams[STATE])) {
        widget.onError('State match failed, possible CSRF issue');
        return NavigationDecision.prevent;
      }
      
      _getServerData(req.url);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _getServerData(String url) async {
    AccessToken token;
    if (widget.clientSideFlow) {
      Uri uri = Uri.parse(url);
      Map<String, String> hashParams = _getHashParams(uri);
      token = AccessToken(hashParams[ACCESS_TOKEN], int.parse(hashParams[EXPIRES]));
    } else {
      var res = await http.get(url);
      token = widget.onServerResponse(res);
    }
    if (widget.onTokenCapture != null) {
      widget.onTokenCapture(token);
    } else {
      Navigator.pop(context, token);
    }
  }

  Map<String, String> _getHashParams(Uri uri) {
    List<String> fragments = uri.fragment.split('&');
    Map<String, String> hashParams = {};
  
    fragments.forEach((f) {
      List<String> fragment = f.split('=');
      hashParams[fragment[0]] = fragment[1];
    });
  
    return hashParams;
  }

  String _parseError(Map<String, String> params) {
    if (params.containsKey(ERROR)) {
      return params[ERROR_DESC];
    }
    return '';
  }

}