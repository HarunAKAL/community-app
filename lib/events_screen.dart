import 'package:communityapp1/home_screen.dart';
import 'package:communityapp1/profile_screen.dart';
import 'package:communityapp1/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_event_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String selectedCategory = 'Tümü';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etkinlikler'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade800,
                Colors.purple.shade800,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Text('Yaklaşan Etkinlikler',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Expanded(
                child: EventList(selectedCategory: selectedCategory),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade800, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                color: Colors.transparent,
                child: Text(
                  'Kategoriler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _createDrawerItem(
                icon: Icons.list,
                text: 'Tümü',
                onTap: () => _selectCategory('Tümü'),
              ),
              _createDrawerItem(
                icon: Icons.music_note,
                text: 'Konser',
                onTap: () => _selectCategory('Konser'),
              ),
              _createDrawerItem(
                icon: Icons.theater_comedy,
                text: 'Tiyatro',
                onTap: () => _selectCategory('Tiyatro'),
              ),
              _createDrawerItem(
                icon: Icons.movie,
                text: 'Sinema',
                onTap: () => _selectCategory('Sinema'),
              ),
              _createDrawerItem(
                icon: Icons.sports_soccer,
                text: 'Spor',
                onTap: () => _selectCategory('Spor'),
              ),
              _createDrawerItem(
                icon: Icons.mic,
                text: 'Stand Up',
                onTap: () => _selectCategory('Stand Up'),
              ),
              _createDrawerItem(
                icon: Icons.music_video,
                text: 'Opera ve Bale',
                onTap: () => _selectCategory('Opera ve Bale'),
              ),
              _createDrawerItem(
                icon: Icons.school,
                text: 'Seminer',
                onTap: () => _selectCategory('Seminer'),
              ),
              _createDrawerItem(
                icon: Icons.festival,
                text: 'Festival',
                onTap: () => _selectCategory('Festival'),
              ),
              _createDrawerItem(
                icon: Icons.travel_explore,
                text: 'Gezi',
                onTap: () => _selectCategory('Gezi'),
              ),
              _createDrawerItem(
                icon: Icons.more_horiz,
                text: 'Diğer',
                onTap: () => _selectCategory('Diğer'),
              ),
              ListTile(
                leading: Icon(Icons.add, color: Colors.black),
                title: Text('Yeni Etkinlik Oluştur'),
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateEventScreen()),
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

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      leading: Icon(
        icon,
        color: Colors.black,
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }
}

class EventList extends StatelessWidget {
  final String selectedCategory;

  EventList({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: selectedCategory == 'Tümü'
          ? FirebaseFirestore.instance.collection('events').snapshots()
          : FirebaseFirestore.instance
              .collection('events')
              .where('category', isEqualTo: selectedCategory)
              .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final events = snapshot.data!.docs;
        final currentDate = DateTime.now();
        final upcomingEvents = events.where((event) {
          final eventDate = event['date'].toDate();
          return eventDate.isAfter(currentDate);
        }).toList();
        return ListView.builder(
          itemCount: upcomingEvents.length,
          itemBuilder: (context, index) {
            var eventData = upcomingEvents[index];
            return EventListItem(eventData: eventData);
          },
        );
      },
    );
  }
}

class EventListItem extends StatelessWidget {
  final QueryDocumentSnapshot eventData;

  EventListItem({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventData: eventData),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventData['name'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Kategori: ${eventData['category']}',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot eventData;
  EventDetailScreen({required this.eventData}) {
    initializeDateFormatting('tr_TR');
  }
  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    return DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(dateTime);
  }

  Future<bool> _checkIfUserHasJoined(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return false;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('past_events')
        .where('etkinlik_id', isEqualTo: eventId)
        .where('kullanıcı_id', isEqualTo: userId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  void _joinEvent(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş yapmalısınız.')),
      );
      return;
    }

    bool hasJoined = await _checkIfUserHasJoined(eventData['id']);
    if (hasJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu etkinliğe zaten katıldınız.')),
      );
    } else {
      FirebaseFirestore.instance.collection('past_events').add({
        'etkinlik_id': eventData['id'],
        'kullanıcı_id': userId,
        'etkinlik_adı': eventData['name'],
        'kategori': eventData['category'],
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinliğe katıldınız.')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Etkinliğe katılırken bir hata oluştu: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etkinlik Detayı'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Etkinlik Adı: ${eventData['name']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Kategori: ${eventData['category']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Tarih: ${_formatDate(eventData['date'])}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Yer: ${eventData['address']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Saat: ${eventData['time']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Koşullar: ${eventData['conditions']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Yaş sınırı: ${eventData['age_limit']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _joinEvent(context),
              child: Text('Katıl'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
