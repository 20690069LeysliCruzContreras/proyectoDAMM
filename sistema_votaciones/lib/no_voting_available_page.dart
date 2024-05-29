import 'package:flutter/material.dart';

class NoVotingAvailablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encuestas Activas'),
      ),
      body: Center(
        child: Text('No hay encuestas disponibles en este momento.'),
      ),
    );
  }
}
