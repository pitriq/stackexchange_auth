import 'package:flutter/foundation.dart';
import 'package:stackexchange_auth/models/models.dart';
import 'package:uuid/uuid.dart';


class StackExchangeService {

  // API Endpoints and Base url
  static const BASE_AUTH_URL = 'www.stackoverflow.com';
  static const LOGIN_PATH = 'oauth/dialog';

  // URL parameters
  static const CLIENT_ID = 'client_id';
  static const REDIRECT_URI = 'redirect_uri';
  static const STATE = 'state';
  static const SCOPE = 'scope';

  // Scope values
  static const SCOPE_READ_INBOX = 'read_inbox';
  static const SCOPE_NO_EXPIRY = 'no_expiry';
  static const SCOPE_WRITE_ACCESS = 'write_access';
  static const SCOPE_PRIVATE_INFO = 'private_info';

  /// Returns [StackExchangeRequest] object containing URL and state
  ///
  /// Throws a [StackExchangeException] if either of the fields are empty or missing.
  /// For more info, please read https://api.stackexchange.com/docs/authentication
  ///
  /// Example:
  /// ```dart
  /// StackExchangeService.getStackExchangeRequest(
  ///      clientId: "foobar",
  ///      redirectUri: "https://www.example.com/stackexchange/auth",
  ///     scopes: [StackExchangeScope.WRITE_ACCESS, StackExchangeScope.PRIVATE_INFO],
  /// );
  /// ```
  static StackExchangeRequest getStackExchangeRequest(
      {@required String clientId,
      @required String redirectUri,
      @required List<StackExchangeScope> scopes}) {
    if (clientId.isEmpty) {
      throw StackExchangeException('Missing client ID, cannot be left blank');
    }
    if (redirectUri.isEmpty) {
      throw StackExchangeException(
          'Redirect URI is required and cannot be left blank');
    }
    String state = Uuid().v4();
    Uri promptUrl = Uri.https(BASE_AUTH_URL, LOGIN_PATH, {
      // Please read: https://api.stackexchange.com/docs/authentication
      CLIENT_ID: clientId,
      REDIRECT_URI: redirectUri,
      STATE: state,
      SCOPE: _getRequestScope(scopes),
    });

    return StackExchangeRequest(state, promptUrl.toString());
  }

  /// Multiple request scopes merged to form a single comma separated string
  static String _getRequestScope(List<StackExchangeScope> scopes) {
    List<String> scopeConvert = [];
    scopes.forEach((StackExchangeScope scope) {
      switch (scope) {
        case StackExchangeScope.NO_EXPIRY:
          return scopeConvert.add(SCOPE_NO_EXPIRY);
        case StackExchangeScope.PRIVATE_INFO:
          return scopeConvert.add(SCOPE_PRIVATE_INFO);
        case StackExchangeScope.READ_INBOX:
          return scopeConvert.add(SCOPE_READ_INBOX);
        case StackExchangeScope.WRITE_ACCESS:
          return scopeConvert.add(SCOPE_WRITE_ACCESS);
      }
    });
    return scopeConvert.join(',');
  }

}