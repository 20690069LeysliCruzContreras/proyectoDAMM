import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VotingDetailsPage extends StatefulWidget {
  final String votingId;
  final String userId;
  final String title;
  final List<String> options;

  VotingDetailsPage({required this.votingId, required this.title, required this.options, required this.userId});

  @override
  _VotingDetailsPageState createState() => _VotingDetailsPageState();
}

class _VotingDetailsPageState extends State<VotingDetailsPage> {
  String? selectedOption;

  Future <void> _submitVote() async {
    print('Datos enviados en la solicitud de voto:');
    print('Voting ID: ${widget.votingId}, Option Text: $selectedOption, User ID: ${widget.userId}');
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/vote'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'votingId': widget.votingId,
          'optionText': selectedOption,
          'userId': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        _showMessage('Voto registrado correctamente: $selectedOption');
        setState(() {
          selectedOption = null;
        });
      } else {
        _showMessage('Error al registrar el voto en el frontend.');
      }
    } catch (error) {
      _showMessage('Error de conexión: $error');
    }
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona tu opción de voto:',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(widget.options[index]),
                        leading: Radio<String>(
                          value: widget.options[index],
                          groupValue: selectedOption,
                          onChanged: (String? value) {
                            setState(() {
                              selectedOption = value;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: selectedOption != null ? _submitVote : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Votar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
