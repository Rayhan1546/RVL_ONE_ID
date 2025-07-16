class OneIdConfig {
  final String issuer;
  final String clientId;
  final String redirectUri;
  final String clientSecret;
  final List<String> scopes;

  const OneIdConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    required this.clientSecret,
    this.scopes = const ['openid', 'profile', 'email'],
  });

  void validate() {
    if (issuer.isEmpty) {
      throw ArgumentError('Issuer cannot be empty');
    }
    if (clientId.isEmpty) {
      throw ArgumentError('Client ID cannot be empty');
    }
    if (clientSecret.isEmpty) {
      throw ArgumentError('Client secret cannot be empty');
    }
    if (redirectUri.isEmpty) {
      throw ArgumentError('Redirect URI cannot be empty');
    }
  }
}
