import 'package:communityapp1/chat_screen.dart';
import 'package:communityapp1/events_screen.dart';
import 'package:communityapp1/profile_screen.dart';
import 'package:communityapp1/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  String name;

  Community({required this.id, required this.name});
}

class CommunityManager {
  late List<Community> _createdCommunities;
  late List<Community> _joinedCommunities;
  final String userId;

  List<Community> get allCommunities =>
      [..._createdCommunities, ..._joinedCommunities];

  CommunityManager({required this.userId}) {
    _createdCommunities = [];
    _joinedCommunities = [];
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    QuerySnapshot createdSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('communities')
        .get();
    _createdCommunities = createdSnapshot.docs
        .map((doc) => Community(id: doc.id, name: doc['name']))
        .toList();

    QuerySnapshot joinedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('joinedCommunities')
        .get();
    _joinedCommunities = joinedSnapshot.docs
        .map((doc) => Community(id: doc.id, name: doc['name']))
        .toList();
  }

  Future<void> createCommunity(String name) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('communities')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('Bu isimde bir topluluk zaten var.');
    }

    DocumentReference communityDocRef =
        await FirebaseFirestore.instance.collection('communities').add({
      'name': name,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('communities')
        .doc(communityDocRef.id)
        .set({
      'name': name,
    });

    _createdCommunities.add(Community(id: communityDocRef.id, name: name));
  }

  Future<void> updateCommunity(String id, String newName) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('communities')
        .doc(id)
        .update({
      'name': newName,
    });
    Community community =
        _createdCommunities.firstWhere((element) => element.id == id);
    community.name = newName;
  }

  Future<void> deleteCommunity(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('communities')
        .doc(id)
        .delete();
    _createdCommunities.removeWhere((element) => element.id == id);
  }

  Future<void> joinCommunity(String communityName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('communities')
        .where('name', isEqualTo: communityName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot communityDoc = querySnapshot.docs.first;
      String communityId = communityDoc.id;

      DocumentSnapshot joinedCommunityDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('joinedCommunities')
          .doc(communityId)
          .get();

      if (joinedCommunityDoc.exists) {
        throw Exception('Zaten bu topluluğa katıldınız.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('joinedCommunities')
          .doc(communityId)
          .set({
        'name': communityName,
      });

      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('members')
          .doc(userId)
          .set({
        'userId': userId,
      });

      _joinedCommunities.add(Community(id: communityId, name: communityName));
    } else {
      throw Exception('Topluluk bulunamadı.');
    }
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Kullanıcı oturumu açık değil'),
        ),
      );
    }

    final CommunityManager communityManager =
        CommunityManager(userId: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Anasayfa', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade800, Colors.purple.shade800],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: communityManager._loadCommunities(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade800, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user.photoURL ?? ''),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Topluluklar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...communityManager.allCommunities.map((community) {
                    return ListTile(
                      title: Text(community.name,
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              communityId: community.id,
                              communityName: community.name,
                            ),
                          ),
                        );
                      },
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _showCommunityOptions(
                                  context, community.id, community.name);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              _showDeleteCommunityDialog(
                                  context, communityManager, community.id);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  ListTile(
                    leading: Icon(Icons.add, color: Colors.white),
                    title: Text(
                      'Topluluk Oluştur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      _showCreateCommunityDialog(context, communityManager);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.group_add, color: Colors.white),
                    title: Text(
                      'Topluluğa Katıl',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      _showJoinCommunityDialog(context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            'Topluluk Uygulamasına Hoş Geldiniz!',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
              icon: Icon(Icons.settings, color: Colors.black),
              label: Text(
                'Ayarlar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteCommunityDialog(BuildContext context,
    CommunityManager communityManager, String communityId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Topluluğu Sil'),
        content: Text('Bu topluluğu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              await communityManager.deleteCommunity(communityId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Topluluk silindi')),
              );
            },
            child: Text('Sil'),
          ),
        ],
      );
    },
  );
}

void _showCreateCommunityDialog(
    BuildContext context, CommunityManager communityManager) {
  final TextEditingController _nameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Topluluk Oluştur'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Topluluk Adı'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                try {
                  await communityManager.createCommunity(_nameController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Topluluk başarıyla oluşturuldu')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text('Oluştur'),
          ),
        ],
      );
    },
  );
}

void _showJoinCommunityDialog(BuildContext context) {
  final TextEditingController _nameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }
  final CommunityManager communityManager = CommunityManager(userId: user.uid);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Topluluğa Katıl'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Topluluk Adı'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              String communityName = _nameController.text.trim();

              if (communityName.isNotEmpty) {
                try {
                  await communityManager.joinCommunity(communityName);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '$communityName topluluğuna başarıyla katıldınız'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lütfen bir topluluk adı girin')),
                );
              }
            },
            child: Text('Katıl'),
          ),
        ],
      );
    },
  );
}

void _showCommunityOptions(
    BuildContext context, String communityId, String communityName) {
  final TextEditingController _nameController =
      TextEditingController(text: communityName);
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }
  final CommunityManager communityManager = CommunityManager(userId: user.uid);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Topluluk Seçenekleri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Topluluk Adı'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                await communityManager.updateCommunity(
                    communityId, _nameController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Topluluk adı güncellendi')),
                );
              }
            },
            child: Text('Güncelle'),
          ),
        ],
      );
    },
  );
}
