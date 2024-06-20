import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  Future<void> _changePassword() async {
    final String email = _emailController.text.trim();
    final String newPassword = _newPasswordController.text;
    final String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      setState(() {
        _errorMessage = 'Şifreler eşleşmiyor';
      });
      return;
    }

    try {
      final currentUser = _auth.currentUser;
      await currentUser!.updatePassword(newPassword);
      setState(() {
        _errorMessage = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Şifre başarıyla değiştirildi'),
        duration: Duration(seconds: 2),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Şifre değiştirilemedi: ${e.message}'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifre Değiştir', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade800, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email boş olamaz';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Eski Şifre',
                      labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Eski şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Yeni Şifre',
                      labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Yeni şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Yeni Şifreyi Tekrar Girin',
                      labelStyle: TextStyle(color: Colors.white)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Yeni şifre tekrarı boş olamaz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _changePassword();
                    }
                  },
                  child: Text('Kaydet ve Güncelle'),
                ),
                SizedBox(height: 8),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
