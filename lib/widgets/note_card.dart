import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final Map<String, dynamic> note; // Using Map to match your existing structure
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.0),
      color: note['checked'] == true ? Colors.green[100] : Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Note text
            Expanded(
              child: Text(
                note['text'],
                style: TextStyle(
                  fontSize: 16.0,
                  decoration: note['checked'] == true
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: note['checked'] == true
                      ? Colors.green
                      : Colors.black87,
                ),
              ),
            ),
            // Edit and Delete buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
