class StackExchangeRequest {
  /// Random string generated, must be verified once returned from server
  final String state;

  /// Request URL to hit for Stack Exchange login workflow
  final String url;

  StackExchangeRequest(this.state, this.url);

  bool verifyState(String state) {
    if (this.state == state) {
      return true;
    }
    return false;
  }
}

class AccessToken {
  final String token;
  DateTime expiry;

  AccessToken(this.token, int expiry) {
    this.expiry = DateTime.now().add(Duration(seconds: expiry));
  }
}

// Scope enum for accessing user info. Will be shown on the login prompt.
///
/// Read more here: https://api.stackexchange.com/docs/authentication#scope
enum StackExchangeScope {
  /// Requests the read_inbox scope
  READ_INBOX,

  /// Requests the no_expiry scope
  NO_EXPIRY,

  /// Requests the write_access scope
  WRITE_ACCESS,

  /// Requests the private_info scope
  PRIVATE_INFO,
}

class StackExchangeException implements Exception {
  String cause;

  StackExchangeException(this.cause);
}