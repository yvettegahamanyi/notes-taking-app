# Notes App

A Flutter application for managing notes with Firebase authentication and Firestore database.

## Features

- User authentication (sign up/sign in)
- CRUD operations for notes

## Setup Instructions

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase:
   - Create a Firebase project
   - connect it to the app
4. Run the app: `flutter run`

## State Management

Uses BLoC pattern for state management:

- AuthBloc: Handles authentication state
- NotesBloc: Manages notes CRUD operations
