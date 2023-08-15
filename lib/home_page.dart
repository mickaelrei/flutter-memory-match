import 'package:flutter/material.dart';
import 'package:flutter_memory_match/game_config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_memory_match/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeState(),
      child: Consumer<HomeState>(
        builder: (_, homeState, __) {
          return Scaffold(
            appBar: AppBar(title: const Text("Menu")),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    "Pontuação máxima: ${homeState.highscore}",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Jogo da Memória",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: IconButton(
                    onPressed: () async {
                      // Entra na rota de jogo e espera retorno da pontuação
                      final score = await Navigator.of(context).pushNamed(
                        "/game",
                        arguments: homeState.numPairs,
                      ) as int?;

                      // O usuário pode ter só voltado pro menu sem terminar o jogo
                      // Neste caso, a pontuação é nula
                      if (score != null) {
                        // Cadastra nova pontuação
                        homeState.newScore(score);
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    color: Colors.green,
                    iconSize: 40,
                  ),
                ),
                DropdownMenu<int>(
                  initialSelection: homeState.numPairs,
                  onSelected: (value) => homeState.setPairs(value!),
                  dropdownMenuEntries: [
                    for (final pairs in GameConfig.possibleNumPairs)
                      DropdownMenuEntry(
                        value: pairs,
                        label: "$pairs pares",
                      )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
