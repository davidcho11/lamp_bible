import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bible_reading_provider.dart';
import 'providers/bible_books_provider.dart';
import 'providers/reading_history_provider.dart';
import 'providers/csv_import_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BibleReadingProvider()),
        ChangeNotifierProvider(create: (_) => BibleBooksProvider()),
        ChangeNotifierProvider(create: (_) => ReadingHistoryProvider()),
        ChangeNotifierProvider(create: (_) => CsvImportProvider()),
      ],
      child: MaterialApp(
        title: '함께 성경 읽기',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
