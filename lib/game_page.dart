import 'package:flutter/material.dart';
import 'package:flutter_memory_match/game_config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_memory_match/game_state.dart';

class GamePage extends StatelessWidget {
  const GamePage({required this.numPairs, super.key});

  final int numPairs;
  static const double padding = 15.0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(
        context: context,
        numPairs: numPairs,
      ),
      child: Consumer<GameState>(
        builder: (context, gameState, _) {
          return Scaffold(
            appBar: AppBar(title: const Text("Jogo da memória")),
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: GameConfig.crossAxisCount(numPairs),
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              padding: const EdgeInsets.all(GamePage.padding),
              itemCount: gameState.numPairs * 2,
              itemBuilder: (context, index) {
                final Color cardColor = gameState.colorAt(index);

                return ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(cardColor),
                  ),
                  onPressed: () => gameState.guess(index),
                  child: Text(
                    gameState.cardContent(index),
                    style: const TextStyle(
                      // fontSize: 35,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
