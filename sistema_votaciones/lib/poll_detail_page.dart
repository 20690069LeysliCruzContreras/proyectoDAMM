import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PollDetailPage extends StatefulWidget {
  final String pollId;

  PollDetailPage({required this.pollId});

  @override
  _PollDetailPageState createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  Future<Map<String, dynamic>> _fetchPollDetails() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/polls/${widget.pollId}'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load poll details');
    }
  }

  Future<void> _submitVote(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://localhost:5000/votes/${widget.pollId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'option': option,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vote submitted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit vote')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poll Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPollDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var poll = snapshot.data!;
            return Column(
              children: <Widget>[
                Text(poll['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ...poll['options'].map<Widget>((option) {
                  return ListTile(
                    title: Text(option['option']),
                    trailing: Text('Votes: ${option['votes']}'),
                    onTap: () {
                      _submitVote(option['option']);
                    },
                  );
                }).toList(),
              ],
            );
          }
        },
      ),
    );
  }
}
