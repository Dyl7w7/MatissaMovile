import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  @override
  _DatePickerFieldState createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
late TextEditingController _dateController;
late DateTime _selectedDate;

@override
void initState() {
super.initState();
_dateController = TextEditingController();
_selectedDate = DateTime.now();
}

@override
void dispose() {
_dateController.dispose();
super.dispose();
}

Future<void> _selectDate(BuildContext context) async {
final DateTime? pickedDate = await showDatePicker(
context: context,
initialDate: _selectedDate,
firstDate: DateTime(2000),
lastDate: DateTime(2101),
);
if (pickedDate != null && pickedDate != _selectedDate) {
setState(() {
_selectedDate = pickedDate;
_dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
});
}
}

@override
Widget build(BuildContext context) {
return Material(
child: Row(
children: [
Expanded(
child: TextField(
controller: _dateController,
readOnly: true,
decoration: InputDecoration(
labelText: 'Fecha',
border: OutlineInputBorder(),
),
),
),
SizedBox(width: 10),
ElevatedButton(
onPressed: () => _selectDate(context),
child: Text('Seleccionar Fecha'),
),
],
),
);
}
}