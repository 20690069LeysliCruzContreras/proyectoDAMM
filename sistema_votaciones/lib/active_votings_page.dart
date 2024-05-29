import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActiveVotingsPage extends StatefulWidget {
  final String userId;

  ActiveVotingsPage({required this.userId});

  @override
  _ActiveVotingsPageState createState() => _ActiveVotingsPageState();
}

class _ActiveVotingsPageState extends State<ActiveVotingsPage> {
  List<Map<String, dynamic>> votingData = [];

  Future<void> fetchVotingData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/active-votings'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          votingData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Error al obtener las votaciones activas');
      }
    } catch (error) {
      print('Error de conexión: $error');
    }
  }

  Future<void> vote(String votingId, String optionText) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'votingId': votingId,
          'optionText': optionText,
          'userId': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        showMessage(context, 'Voto registrado correctamente');
        fetchVotingData(); // Actualizar las votaciones después de votar
      } else {
        showMessage(context, 'Error al registrar el voto');
      }
    } catch (error) {
      showMessage(context, 'Error de conexión: $error');
    }
  }

  void showMessage(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    fetchVotingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Votaciones Activas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: votingData.length,
          itemBuilder: (context, index) {
            final voting = votingData[index];
            return Card(
              color: Colors.white.withOpacity(0.8),
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voting['title'],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    ...voting['options'].map<Widget>((option) {
                      return ListTile(
                        title: Text(option['text']),
                        trailing: ElevatedButton(
                          onPressed: () => vote(voting['_id'], option['text']),
                          child: Text('Votar'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
