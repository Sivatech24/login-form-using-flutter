import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter PostgreSQL Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final PostgreSQLConnection _connection = PostgreSQLConnection(
    '192.168.1.100',
    //'localhost',
    5432, // PostgreSQL default port
    'my_database',
    username: 'my_username',
    password: 'my_password',
  );

  String _username = '';
  String _password = '';

  Future<void> _connectToDatabase() async {
    await _connection.open();
  }

  Future<void> _verifyCredentials() async {
    final results = await _connection.query(
      'SELECT * FROM users WHERE username = @username AND password = @password',
      substitutionValues: {
        'username': _username,
        'password': _password,
      },
    );
    if (results.isNotEmpty) {
      print('Login successful');
      // Navigate to the next screen or perform other actions
    } else {
      print('Invalid username or password');
    }
  }

  @override
  void dispose() {
    _connection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) => _username = value.trim(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => _password = value.trim(),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _connectToDatabase();
                    await _verifyCredentials();
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
