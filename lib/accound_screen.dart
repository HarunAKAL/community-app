import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _showDeleteConfirmation(
      BuildContext context, String userEmail, DateTime? creationDate) async {
    DateTime? registrationDate;
    if (_auth.currentUser != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      registrationDate =
          userDoc.exists ? userDoc['registration_date'].toDate() : null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Hesabı Sil",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hesabı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "E-posta Adresi: $userEmail",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Text(
                "Kayıt Tarihi: ${creationDate != null ? creationDate.toLocal().toString().split(' ')[0] : 'Bilinmiyor'}",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hayır",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(context);
              },
              child: Text(
                "Evet",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    try {
      await _auth.signOut();

      String userId = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(userId).delete();

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print("Hesap silinirken bir hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userEmail = _auth.currentUser?.email;

    DateTime? creationDate = _auth.currentUser?.metadata.creationTime;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hesap', style: TextStyle(color: Colors.white)),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              creationDate != null
                  ? Column(
                      children: [
                        Text(
                          '${creationDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tarihinden beri üyesiniz.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              ElevatedButton(
                onPressed: () =>
                    _showDeleteConfirmation(context, userEmail!, creationDate),
                child: Text(
                  'Hesabı Sil',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
