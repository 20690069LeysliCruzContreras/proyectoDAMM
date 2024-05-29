import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VotingHistoryPage extends StatefulWidget {
  final String userId;

  VotingHistoryPage({required this.userId});

  @override
  _VotingHistoryPageState createState() => _VotingHistoryPageState();
}

class _VotingHistoryPageState extends State<VotingHistoryPage> {
  List<dynamic> userVotingHistory = [];

  @override
  void initState() {
    super.initState();
    fetchUserVotingHistory();
  }

  Future<void> fetchUserVotingHistory() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/user-voting-history/${widget.userId}'));

      if (response.statusCode == 200) {
        setState(() {
          userVotingHistory = jsonDecode(response.body);
        });
      } else {
        print('Error al obtener el historial de votaciones');
      }
    } catch (error) {
      print('Error de conexión: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Votaciones'),
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
        child: userVotingHistory.isEmpty
            ? Center(
                child: Text(
                  'No hay historial de votaciones.',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: userVotingHistory.length,
                itemBuilder: (context, index) {
                  var voting = userVotingHistory[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voting['title'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Opciones:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          SizedBox(height: 5),
                          ...voting['options'].map<Widget>((option) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                '${option['text']}: ${option['votesCount']} votos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
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
