import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class VotingListPage extends StatefulWidget {
  final List<Map<String, dynamic>> votingData;
  final String userId;

  VotingListPage({required this.votingData,required this.userId});

  @override
  _VotingListPageState createState() => _VotingListPageState();
}

class _VotingListPageState extends State<VotingListPage> {
  List<Map<String, dynamic>> votingData = [];
  final StreamController<List<Map<String, dynamic>>> _streamController = StreamController();

  @override
  void initState() {
    super.initState();
    fetchVotingData();
    listenForVotingUpdates();
  }

  Future<void> fetchVotingData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/active-votings'));
    if (response.statusCode == 200) {
      setState(() {
        votingData = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
      _streamController.add(votingData);
    } else {
      print('Error al obtener la lista de encuestas');
    }
  }

  void listenForVotingUpdates() async {
    final client = http.Client();
    final request = http.Request('GET', Uri.parse('http://localhost:3000/voting-updates'));
    final response = await client.send(request);

    response.stream.transform(utf8.decoder).listen((data) {
      if (data.startsWith('data: ')) {
        final newVoting = jsonDecode(data.substring(6));
        setState(() {
          votingData.add(newVoting);
        });
        _streamController.add(votingData);
      }
    });
  }

  Future<void> vote(String votingId, String optionText, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/vote'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'votingId': votingId,
        'optionText': optionText,
        'userId': widget.userId,
      }),
    );

    if (response.statusCode == 200) {
      print('Voto registrado correctamente');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voto registrado correctamente'),
        ),
      );
    } else {
      print('Error al registrar el voto');
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Encuestas'),
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
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar encuestas'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay encuestas disponibles'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final voting = snapshot.data![index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voting['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...((voting['options'] as List<dynamic>).map((option) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(option['text']),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () => vote(voting['_id'], option['text'], context),
                                      child: Text('Votar'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          }).toList()),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
