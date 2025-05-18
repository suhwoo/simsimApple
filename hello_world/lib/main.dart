import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  // Function to get the server URL based on the platform
  String _getServerUrl() {
    if (kIsWeb) {
      // Running on web
      return 'http://127.0.0.1:5001';
    } else if (Platform.isAndroid) {
      // Running on Android emulator
      return 'http://10.0.2.2:5001';
    } else if (Platform.isIOS) {
      // Running on iOS simulator
      // For physical iOS device, replace with your machine's local IP
      return 'http://127.0.0.1:5001';
    } else {
      // Fallback or other platforms (e.g. desktop)
      // Replace with your machine's local IP if running on a physical device connected to the same network
      // You might need to make this configurable or discoverable
      return 'http://127.0.0.1:5001'; // Default, adjust as needed
    }
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Username and password cannot be empty';
      });
      return;
    }

    setState(() {
      _message = 'Logging in...';
    });

    final String serverUrl = _getServerUrl();
    final Uri loginUrl = Uri.parse('$serverUrl/login');

    try {
      final response = await http.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _message = responseBody['message'] ?? 'Login successful!';
        });
        // Navigate to another screen or show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_message)),
          );
        }
      } else if (response.statusCode == 401) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _message = responseBody['error'] ?? 'Invalid credentials';
        });
      } else {
        setState(() {
          _message = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        // Handle network errors or other exceptions
        _message = 'Failed to connect to the server: $e';
        if (kIsWeb) {
          _message += '\nEnsure the server is running and CORS is configured if this is a web build.';
        } else if (Platform.isAndroid) {
          _message += '\nEnsure the server is running. If using an emulator, the server address should be http://10.0.2.2:5001. Check network permissions in AndroidManifest.xml if issues persist.';
        } else if (Platform.isIOS) {
           _message += '\nEnsure the server is running. If using a simulator, the server address should be http://127.0.0.1:5001. Check Info.plist for App Transport Security settings if issues persist.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Make button wider
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                if (_message.isNotEmpty)
                  Text(
                    _message,
                    style: TextStyle(
                      color: _message.toLowerCase().contains('error') || _message.toLowerCase().contains('invalid') || _message.toLowerCase().contains('failed')
                          ? Colors.red
                          : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
