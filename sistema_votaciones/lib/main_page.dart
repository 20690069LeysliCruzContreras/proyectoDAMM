// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'create_voting_page.dart';
import 'voting_history_page.dart';
import 'voting_list_page.dart';
import 'no_voting_available_page.dart';
import 'auth_page.dart'; // Importa la página de autenticación
import 'dart:html' as html;

class MainPage extends StatefulWidget {
  final String userId;

  MainPage({required this.userId});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> votingData = [];
  String? userName;
  String? userEmail;

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

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/user/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['name'];
          userEmail = data['email'];
        });
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVotingData();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 24, color: Colors.white), // Icono de usuario
                  SizedBox(width: 8),
                  Text(
                    'Iniciaste Sesión como: ${userEmail ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ), // Muestra el correo del usuario
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateVotingPage()),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Crear Encuesta'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (votingData.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VotingListPage(
                          votingData: votingData,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoVotingAvailablePage(),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.view_list),
                label: Text('Visualizar Encuestas'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VotingHistoryPage(
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.history),
                label: Text('Ver Historial'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Regresa a la página de autenticación (AuthPage)
                  html.window.location.reload(); // Recarga la página
                },
                icon: Icon(Icons.logout),
                label: Text('Salir'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
