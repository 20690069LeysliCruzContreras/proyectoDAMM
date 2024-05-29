import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VotingListPage extends StatelessWidget {
  final List<Map<String, dynamic>> votingData;
  final String userId;

  VotingListPage({required this.votingData, required this.userId});

  Future<void> vote(String votingId, String optionText, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/vote'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'votingId': votingId,
        'optionText': optionText,
        'userId': userId,
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
        child: ListView.builder(
          itemCount: votingData.length,
          itemBuilder: (context, index) {
            final voting = votingData[index];
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
                              SizedBox(width: 10), // Añadir espacio entre los botones
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
                          SizedBox(height: 10), // Añadir espacio entre los botones
                        ],
                      );
                    }).toList()),
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
