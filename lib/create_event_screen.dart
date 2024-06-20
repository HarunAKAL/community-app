import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventAgeLimitController =
      TextEditingController();
  final TextEditingController _eventAddressController = TextEditingController();
  final TextEditingController _eventConditionsController =
      TextEditingController();
  String _selectedCategory = 'Konser';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final _turkishInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZğĞıİçÇöÖşŞ\s]'));

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Etkinlik Oluştur'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Etkinlik Bilgileri',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Divider(height: 20, thickness: 2),
                TextFormField(
                  controller: _eventNameController,
                  inputFormatters: [_turkishInputFormatter],
                  decoration: InputDecoration(labelText: 'Etkinlik Adı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen etkinlik adını girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: <String>[
                    'Konser',
                    'Tiyatro',
                    'Sinema',
                    'Spor',
                    'Stand Up',
                    'Opera ve Bale',
                    'Seminer',
                    'Festival',
                    'Gezi',
                    'Diğer'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Kategori'),
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                      "Etkinlik Tarihi: ${DateFormat('yMd').format(_selectedDate)}"),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 20),
                ListTile(
                  title:
                      Text("Etkinlik Saati: ${_selectedTime.format(context)}"),
                  trailing: Icon(Icons.keyboard_arrow_down),
                  onTap: () => _selectTime(context),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _eventAgeLimitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Yaş Sınırı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen yaş sınırını girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _eventAddressController,
                  decoration: InputDecoration(labelText: 'Adres'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adresi girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _eventConditionsController,
                  decoration: InputDecoration(labelText: 'Koşullar'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen koşulları girin';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String eventId =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        FirebaseFirestore.instance
                            .collection('events')
                            .doc(eventId)
                            .set({
                          'id': eventId,
                          'name': _eventNameController.text,
                          'category': _selectedCategory,
                          'date': _selectedDate,
                          'time': _selectedTime.format(context),
                          'age_limit': _eventAgeLimitController.text,
                          'address': _eventAddressController.text,
                          'conditions': _eventConditionsController.text,
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Text('Etkinliği Oluştur',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
