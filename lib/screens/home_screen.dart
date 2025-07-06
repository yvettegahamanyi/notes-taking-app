import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_application/widgets/note_card.dart';
import 'package:note_application/widgets/note_dialog.dart';

import '/bloc/notes_bloc.dart';
import '/bloc/notes_event.dart';
import '/bloc/notes_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _editingNoteId;

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadNotes());
  }

  void _showNoteDialog({String? id, String? initialText}) {
    _editingNoteId = id;
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (context) => NoteDialog(
        initialText: initialText,
        isEditing: isEditing,
        onSave: (text) {
          if (isEditing) {
            context.read<NotesBloc>().add(UpdateNote(_editingNoteId!, text));
          } else {
            context.read<NotesBloc>().add(AddNote(text));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showNoteDialog(),
      ),
      body: SafeArea(
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is NotesError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error loading notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(state.message),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NotesBloc>().add(LoadNotes()),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotesLoaded) {
              final notes = state.notes;

              if (notes.isEmpty) {
                return Center(
                  child: Text(
                    'Nothing here yet—tap ➕ to add a note.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return NoteCard(
                    note: note,
                    onEdit: () => _showNoteDialog(
                      id: note['id'],
                      initialText: note['text'],
                    ),
                    onDelete: () =>
                        context.read<NotesBloc>().add(DeleteNote(note['id'])),
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
