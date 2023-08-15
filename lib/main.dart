import 'package:flutter/material.dart';
import 'package:flutter_memory_match/game_page.dart';
import 'package:flutter_memory_match/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da memória',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/game": (context) => GamePage(
              numPairs: ModalRoute.of(context)!.settings.arguments as int,
            ),
      },
    );
  }
}
