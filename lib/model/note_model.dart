import 'package:flutter/material.dart';

class Note {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool checked;

  Note({
    required this.id,
    required this.text,
    required this.createdAt,
    this.checked = false,
  });
}
