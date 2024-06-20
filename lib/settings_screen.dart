import 'package:communityapp1/accound_screen.dart';
import 'package:communityapp1/change_password_screen.dart';
import 'package:communityapp1/events_screen.dart';
import 'package:communityapp1/home_screen.dart';
import 'package:communityapp1/login_screen.dart';
import 'package:communityapp1/profile_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayarlar Sayfası',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(color: Colors.white)),
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
          padding: EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SwitchListTile(
                title:
                    Text('Bildirimler', style: TextStyle(color: Colors.white)),
                secondary: Icon(Icons.notifications, color: Colors.white),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              ListTile(
                title: Text('Hesap', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.account_circle, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Şifre Değiştir',
                    style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.lock, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                trailing: Icon(Icons.exit_to_app, color: Colors.white),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilSayfasi(),
                  ),
                );
              },
              icon: Icon(Icons.person, color: Colors.black),
              label: Text(
                'Profil',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              icon: Icon(Icons.home, color: Colors.black),
              label: Text(
                'Anasayfa',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.event, color: Colors.black),
              label: Text(
                'Etkinlikler',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
