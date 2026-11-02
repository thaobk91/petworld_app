import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petworld_app/app/app.dart';
import 'package:petworld_app/core/storage/photo_storage.dart';
import 'package:petworld_app/core/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final documents = await getApplicationDocumentsDirectory();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDocumentsPathProvider.overrideWithValue(documents.path),
      ],
      child: const PetWorldApp(),
    ),
  );
}
