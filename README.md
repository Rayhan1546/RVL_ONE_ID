# RVL OneID

A comprehensive Flutter package engineered specifically for seamless authentication integration with the OneID OAuth2 system, powered by enterprise-grade Keycloak infrastructure. This sophisticated package was meticulously developed to serve as the unified authentication solution for the RVL ecosystem.

The RVL OneID package provides a robust, secure, and developer-friendly approach to handling complex authentication workflows, including user authentication, automated token management, session handling, and streamlined user registration processes. Built on top of the industry-standard flutter_appauth library and integrated with Keycloak's powerful identity management capabilities, this package ensures enterprise-level security while maintaining simplicity in implementation.

As the cornerstone authentication system for RVL Systems, this package standardizes the authentication experience across all RVL applications, providing consistent user experience, centralized identity management, and seamless single sign-on (SSO) capabilities. Whether you're building mobile applications within the RVL ecosystem, this package serves as your gateway to secure, scalable, and maintainable authentication infrastructure.

## Features

- 🔐 **OAuth2 Authentication** - Secure login with OneID powered by Keycloak
- 🔄 **Token Management** - Automatic token refresh and secure storage
- 📱 **User Registration** - In-app registration via WebView
- 🔒 **Secure Storage** - Encrypted token storage using flutter_secure_storage
- 🎯 **Singleton Pattern** - Easy-to-use singleton instance
- ⚡ **Auto-initialization** - Automatic token refresh on app start
- 🛡️ **Keycloak Integration** - Built on top of flutter_appauth for enterprise-grade security

## Technology Stack

This package is built on top of:
- **[flutter_appauth](https://pub.dev/packages/flutter_appauth)** - For OAuth2/OpenID Connect authentication
- **[Keycloak](https://www.keycloak.org/)** - Open-source identity and access management
- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)** - For secure token storage

### Why Keycloak?

Keycloak is an enterprise-grade identity and access management solution that provides:
- **Single Sign-On (SSO)** - One login for multiple applications
- **Identity Federation** - Connect with LDAP, Active Directory, and social providers
- **Fine-grained Authorization** - Role-based and attribute-based access control
- **Standard Protocols** - OAuth2, OpenID Connect, and SAML support
- **Admin Console** - Web-based administration interface
- **Scalability** - Clustered and cloud-ready architecture

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  rvl_one_id:
    path: rvl_one_id
```

Then run:

```bash
flutter pub get
```

## Configuration

### OneIdConfig

Before using the package, you need to configure it with your OneID/Keycloak settings:

```dart
import 'package:rvl_one_id/rvl_one_id.dart';

const config = OneIdConfig(
  issuer: 'https://your-keycloak-server.com/realms/your-realm',
  clientId: 'your-client-id',
  clientSecret: 'your-client-secret',
  redirectUri: 'com.yourapp.package://oauth2redirect',
);
```

### Parameters

- **issuer**: Your Keycloak server URL with realm (e.g., `https://keycloak.example.com/realms/my-realm`)
- **clientId**: Your registered client ID in Keycloak
- **clientSecret**: Your registered client secret in Keycloak
- **redirectUri**: OAuth2 redirect URI (must match your app's deep link configuration)

### Keycloak Client Configuration

In your Keycloak admin console, ensure your client is configured with:

1. **Client Protocol**: `openid-connect`
2. **Access Type**: `confidential` (for client secret) or `public`
3. **Valid Redirect URIs**: Include your app's redirect URI
4. **Web Origins**: Configure appropriate CORS settings
5. **Standard Flow Enabled**: `ON`
6. **Direct Access Grants Enabled**: `ON` (if needed)

## Usage

### 1. Initialize the Package

Initialize the OneID package in your app's startup (recommended in a splash screen):

```dart
import 'package:flutter/material.dart';
import 'package:your_app/homepage.dart';
import 'package:your_app/login_screen.dart';
import 'package:rvl_one_id/rvl_one_id.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final RvlOneId oneId = RvlOneId();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    const config = OneIdConfig(
      issuer: 'https://oneid.ticket-bangla.com/realms/flutter-realm',
      clientId: 'flutter-app',
      clientSecret: 'your-client-secret',
      redirectUri: 'com.example.oneiddemo.app://oauth2redirect',
    );

    try {
      await oneId.initialize(config: config);
      final isLoggedIn = await oneId.isUserLoggedIn();

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isLoggedIn ? const Homepage() : const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      // Handle initialization errors
      print('Initialization error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
```

### 2. User Authentication

#### Login

```dart
Future<void> login() async {
  try {
    final bool success = await oneId.login();
    
    if (success) {
      print('Login successful!');
      // Navigate to home screen or update UI
      final token = await oneId.getAccessToken();
      print('Access token: $token');
    } else {
      print('Login failed');
      // Show error message to user
    }
  } catch (e) {
    print('Login error: $e');
    // Handle login errors appropriately
  }
}
```

#### Registration

```dart
Future<void> registration(BuildContext context) async {
  try {
    await oneId.registration(context: context);
    
    // Check login status after registration
    final isLoggedIn = await oneId.isUserLoggedIn();
    if (isLoggedIn) {
      print('Registration and login successful!');
      // Navigate to home screen
    }
  } catch (e) {
    print('Registration error: $e');
    // Handle registration errors
  }
}
```

#### Logout

```dart
Future<void> logout() async {
  try {
    final bool success = await oneId.logout();
    
    if (success) {
      print('Logout successful!');
      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      print('Logout failed');
    }
  } catch (e) {
    print('Logout error: $e');
  }
}
```

### 3. Token Management

#### Get Access Token

```dart
Future<String?> getAccessToken() async {
  try {
    final token = await oneId.getAccessToken();
    return token;
  } catch (e) {
    print('Error getting access token: $e');
    return null;
  }
}
```

#### Refresh Access Token

```dart
Future<void> refreshToken() async {
  try {
    final bool success = await oneId.refreshAccessToken();
    
    if (success) {
      print('Token refreshed successfully!');
    } else {
      print('Token refresh failed - user may need to re-login');
      // Redirect to login screen
    }
  } catch (e) {
    print('Token refresh error: $e');
  }
}
```

#### Check Login Status

```dart
Future<bool> checkLoginStatus() async {
  try {
    return await oneId.isUserLoggedIn();
  } catch (e) {
    print('Error checking login status: $e');
    return false;
  }
}
```
## Flow Chart
<img height="689" alt="Image" src="https://github.com/user-attachments/assets/b67e7c53-1ad3-4b0b-a6e9-b49063ce43f7" />

## API Reference

### RvlOneId Class

#### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `initialize({required OneIdConfig config})` | `Future<void>` | Initialize the OneID package with Keycloak configuration |
| `login()` | `Future<bool>` | Start the OAuth2 login process with Keycloak |
| `registration({required BuildContext context})` | `Future<void>` | Open registration WebView |
| `refreshAccessToken()` | `Future<bool>` | Refresh the access token using refresh token |
| `logout()` | `Future<bool>` | Logout the current user and clear tokens |
| `getAccessToken()` | `Future<String?>` | Get the current access token |
| `isUserLoggedIn()` | `Future<bool>` | Check if user is logged in with valid tokens |

### OneIdConfig Class

#### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `issuer` | `String` | Yes | Keycloak server URL with realm |
| `clientId` | `String` | Yes | OAuth2 client ID registered in Keycloak |
| `clientSecret` | `String` | Yes | OAuth2 client secret from Keycloak |
| `redirectUri` | `String` | Yes | OAuth2 redirect URI for deep linking |

## Error Handling

The package provides comprehensive error handling:

```dart
try {
  await oneId.login();
} catch (e) {
  if (e is StateError) {
    print('OneID not initialized: ${e.message}');
    // Initialize the package first
  } else if (e is PlatformException) {
    print('Platform error: ${e.message}');
    // Handle platform-specific errors
  } else {
    print('Unknown error: $e');
    // Handle other errors
  }
}
```


## Add Permission

### Android

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for registration purposes</string>
```

## Deep Link Configuration

### Android

Add the following to your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        manifestPlaceholders += [
            'appAuthRedirectScheme': 'com.example.oneiddemo.app'
        ]
    }
}
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.oneiddemo.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.oneiddemo.app</string>
        </array>
    </dict>
</array>
```

## Security Considerations

- **Token Storage**: All tokens are stored securely using `flutter_secure_storage` with encryption
- **Automatic Refresh**: Tokens are automatically refreshed when expired
- **Secure Communication**: All communication with Keycloak uses HTTPS
- **Client Secret**: Store client secrets securely and never expose them in client-side code for production apps

### Best Practices

1. **Use HTTPS**: Always use HTTPS URLs for your Keycloak server
2. **Validate Tokens**: Always validate tokens server-side for critical operations
3. **Handle Expiration**: Implement proper token refresh logic
4. **Secure Storage**: Never store sensitive data in plain text
5. **Error Handling**: Implement comprehensive error handling for all authentication flows

## Troubleshooting

### Common Issues

1. **StateError: OneId must be initialized before use**
   - **Solution**: Make sure to call `initialize()` before using any other methods
   - **Example**: Initialize in your app's startup or splash screen

2. **Login fails with network error**
   - **Solution**: Check your Keycloak server configuration and network connectivity
   - **Verify**: Ensure the issuer URL is correct and accessible

3. **Redirect URI mismatch**
   - **Solution**: Ensure the redirect URI in your app matches the one configured in Keycloak
   - **Check**: Both deep link configuration and Keycloak client settings

4. **Token refresh fails**
   - **Solution**: Check if the refresh token is valid and not expired
   - **Action**: Redirect user to login screen if refresh fails

5. **Registration WebView not loading**
   - **Solution**: Check internet connectivity and registration URL accessibility
   - **Verify**: Ensure the registration URL is correct and the server is running

6. **iOS build issues**
   - **Solution**: Ensure you have configured URL schemes correctly in Info.plist
   - **Check**: Verify the bundle identifier matches your redirect URI scheme

### Debug Tips

- Enable verbose logging in development builds
- Test with a local Keycloak instance first
- Use network monitoring tools to debug OAuth2 flows
- Check Keycloak server logs for authentication issues

## Dependencies

This package depends on:
- `flutter_appauth: 9.0.1`
- `flutter_secure_storage: 9.2.4`
- `flutter/material.dart`
- `permission_handler: 12.0.1`
- `webview_flutter: 4.7.0`

## 📱 Example / Demo APK

You can download and try the demo version of the app using the link below:

🔗 [**Download APK**](https://drive.google.com/file/d/1256v7qM-dRVNJ6H0QffgsqR5bNYd0uxB/view?usp=sharing)

> ⚠️ **Installation Tips:**
> - Open the link on your Android device.
> - Tap the download icon at the top.
> - Allow installation from unknown sources when prompted.
> - Minimum supported Android version: **8.0 (API 26)**

## License

This project is licensed under a proprietary license. All rights reserved by RVL Systems.

**Important**: This package is proprietary software developed by RVL Systems. Unauthorized copying, distribution, or use is strictly prohibited.

### Usage Rights

- ✅ **Permitted**: Use within your organization's projects
- ✅ **Permitted**: Modify for internal use
- ❌ **Prohibited**: Redistribution without permission
- ❌ **Prohibited**: Commercial use without license
- ❌ **Prohibited**: Reverse engineering

### Contact

For licensing inquiries, support, or to request permission to use this package, please contact:

© 2025 RVL Systems. All rights reserved.
