import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_maps/Views/HelpPage.dart';
import 'package:todo_maps/Views/WelcomePage.dart';
import 'Views/HomePage.dart';

String initialRouter = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('firstRun') == null) {
    initialRouter = '/welcome';
  } else {
    initialRouter = '/home';
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(TodoMapsApp()));

  runApp(TodoMapsApp());
}

class TodoMapsApp extends StatelessWidget {
  const TodoMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo Maps',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Color(0xFF121212),
        ),
        initialRoute: initialRouter,
        routes: {
          '/welcome': (context) => WelcomePage(),
          '/home': (context) => HomePage(),
          '/help': (context) => HelpPage(),
        });
  }
}
