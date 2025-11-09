import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/quote_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('en_IN', null);  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.indigo.shade600;
    final secondary = Colors.blue.shade400;
    return MaterialApp(
      title: 'Product Quote Builder',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.indigo).copyWith(secondary: secondary),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: null),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)))),
      ),
      home: const QuoteFormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}