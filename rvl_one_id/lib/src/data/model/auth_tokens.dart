class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String appIdToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.appIdToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'appIdToken': appIdToken,
    };
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      appIdToken: json['appIdToken'],
    );
  }
}
