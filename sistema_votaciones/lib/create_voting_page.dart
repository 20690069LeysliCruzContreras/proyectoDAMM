import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateVotingPage extends StatefulWidget {
  @override
  _CreateVotingPageState createState() => _CreateVotingPageState();
}

class _CreateVotingPageState extends State<CreateVotingPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController()
  ];

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    setState(() {
      if (_optionControllers.length > 1) {
        _optionControllers.removeAt(index);
      }
    });
  }

  void _clearFields() {
    _titleController.clear();
    _optionControllers.forEach((controller) => controller.clear());
    _startDate = null;
    _startTime = null;
    _endDate = null;
    _endTime = null;
    setState(() {});
  }

  void _createVoting() async {
    final String title = _titleController.text;
    final List<String> options =
        _optionControllers.map((controller) => controller.text).toList();

    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      _showMessage(
          'Por favor, seleccione la fecha y hora de inicio y finalización');
      return;
    }

    final DateTime startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final DateTime endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/create-voting'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'options': options,
          'startDate': startDateTime.toIso8601String(),
          'endDate': endDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _showMessage('Encuesta creada correctamente');
        _clearFields();
      } else {
        _showMessage('Error al crear la votación');
      }
    } catch (error) {
      _showMessage('Error de conexión: $error');
    }
  }

  void _showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Encuesta'),
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título de la Encuesta',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ..._optionControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Opción ${index + 1}',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.redAccent),
                      onPressed: () => _removeOptionField(index),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addOptionField,
                child: Text('Agregar Opción'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  _startDate != null
                      ? Text(_startDate!.toString().substring(0, 10),
                          style: TextStyle(color: Colors.white))
                      : Text('Fecha de Inicio no seleccionada',
                          style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _selectDate(context, isStartDate: true),
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  _startTime != null
                      ? Text('${_startTime!.hour}:${_startTime!.minute}',
                          style: TextStyle(color: Colors.white))
                      : Text('Hora de Inicio no seleccionada',
                          style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _selectTime(context, isStartTime: true),
                    icon: Icon(Icons.access_time, color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  _endDate != null
                      ? Text(_endDate!.toString().substring(0, 10),
                          style: TextStyle(color: Colors.white))
                      : Text('Fecha de Finalización no seleccionada',
                          style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _selectDate(context, isStartDate: false),
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  _endTime != null
                      ? Text('${_endTime!.hour}:${_endTime!.minute}',
                          style: TextStyle(color: Colors.white))
                      : Text('Hora de Finalización no seleccionada',
                          style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _selectTime(context, isStartTime: false),
                    icon: Icon(Icons.access_time, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createVoting,
                child: Text('Crear Encuesta'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

