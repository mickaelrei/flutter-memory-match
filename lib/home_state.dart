import 'package:flutter/material.dart';
import 'package:flutter_memory_match/game_config.dart';

class HomeState with ChangeNotifier {
  HomeState();

  // Pontuação máxima atual
  int _highscore = 0;
  int get highscore => _highscore;

  // Lista de pontuações
  final scores = <int>[];

  // Número de pares pro próximo jogo
  int _numPairs = GameConfig.minPairs;

  int get numPairs => _numPairs;

  // Função que atualiza o número de pares pro próximo jogo
  void setPairs(int pairs) {
    if (!GameConfig.possibleNumPairs.contains(pairs)) return;

    _numPairs = pairs;
    notifyListeners();
  }

  // Função pra cadastrar nova pontuação
  void newScore(int score) {
    // Adiciona na lista de tentativas
    scores.add(score);

    // Atualiza pontuação máxima caso necessário
    if (score > _highscore) {
      _highscore = score;
    }

    // Atualiza tela
    notifyListeners();
  }
}
