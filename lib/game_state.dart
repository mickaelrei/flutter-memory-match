import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:core';

class GameState with ChangeNotifier {
  GameState({
    required this.numPairs,
    required this.context,
  }) {
    // Inicia os pares aleatoriamente
    initPairs();

    // Define a duração do jogo
    duration = max(GameState.minDuration, 10 * numPairs);

    // Inicia a pontuação
    _startTime = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  }

  // Contexto
  final BuildContext context;

  // Tempo máximo de jogo
  static const int minDuration = 1 * 60;

  // Usado pra gerar os pares aleatoriamente
  final random = Random();

  // Tempo de jogo e pontuação
  late final int duration;
  late int _startTime;

  int get score {
    final now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    // Duração - tempo passado
    return max(0, duration - (now - _startTime));
  }

  // Numero de pares no jogo
  final int numPairs;

  // Lista de pares
  final _pairs = <Pair>[];

  List<Pair> get pairs => List.unmodifiable(_pairs);

  // Lista que guarda a posição (index) dos pares revelados
  final _revealedPairs = <int>[];

  List<int> get revealedPairs => List.unmodifiable(_revealedPairs);

  // Lista que guarda o conteúdo de cada carta
  final _cardContents = <String>[];

  // Par que o usuário está atualmente revelando
  final Pair currentPair = Pair();

  // Se o usuário pode fazer uma tentativa ou não (esperando após erro)
  bool _canGuess = true;

  // Caso o ChangeNotifier já foi desfeito (dispose() foi chamado)
  bool _disposed = false;

  @override
  void dispose() {
    super.dispose();

    _disposed = true;
  }

  void initPairs() {
    // Limpa lista de pares caso tiver algo
    _pairs.clear();

    // Inicia lista de conteúdo das cartas com vazio
    _cardContents.clear();
    for (int i = 0; i < numPairs * 2; i++) {
      _cardContents.add("");
    }

    // Numeros disponiveis
    final indices = List<int>.generate(numPairs * 2, (index) => index);
    for (int i = 0; i < numPairs; i++) {
      // Pega duas posições aleatórias
      final index0 = indices.removeAt(random.nextInt(indices.length));
      final index1 = indices.removeAt(random.nextInt(indices.length));

      // Decide conteúdo do par
      String content = String.fromCharCode(65 + _pairs.length);
      _cardContents[index0] = content;
      _cardContents[index1] = content;

      // Adiciona par
      _pairs.add(Pair(first: index0, second: index1));
    }
  }

  // Função pra uma tentativa do usuário
  void guess(int index) async {
    if (!_canGuess || _disposed) return;

    // Se a carta já foi revelada
    if (isRevealed(index)) return;

    _canGuess = false;

    // Caso seja a primeira tentativa do par
    if (currentPair.first == -1) {
      currentPair.first = index;

      // Como é a primeira tentativa, só atualizar a tela e parar o processo
      notifyListeners();
      _canGuess = true;
      return;
    }

    // Caso seja a segunda tentativa do par
    if (currentPair.second == -1) {
      currentPair.second = index;

      // Atualiza a tela pra mostrar a tentativa atual
      notifyListeners();
    }

    // Checa se o usuário acertou algum par
    bool correct = false;
    for (int i = 0; i < _pairs.length; i++) {
      if (_pairs[i] == currentPair) {
        _revealedPairs.add(i);
        correct = true;
        break;
      }
    }

    // Se errou, esperar alguns segundos
    if (!correct) {
      await Future.delayed(const Duration(seconds: 1));

      // Após esperar o tempo por ter errado, o usuário já pode ter saído
      // da tela de jogo. Nesse caso, tentar atualizar a tela com
      // notifyListeners() irá gerar um erro
      if (_disposed) return;
    }

    if (won()) {
      // Pega pontuação final
      final finalScore = score;

      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Você venceu!"),
          content: Text("Pontuação: $finalScore"),
          actions: [
            TextButton(
              onPressed: () {
                // Sai do dialog
                Navigator.of(context).pop();
              },
              child: const Text("Voltar"),
            )
          ],
        ),
      );

      // Volta pra home, informando a pontuação
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(finalScore);

      return;
    }

    // Reinicia o par atual
    currentPair.first = -1;
    currentPair.second = -1;

    // Atualiza tela
    _canGuess = true;
    notifyListeners();
  }

  // Função que diz se tal carta está reveleada
  bool isRevealed(int index) {
    bool revealed = false;

    // Verifica se a posição é o primeiro ou segundo de algum par revelado
    for (int i in _revealedPairs) {
      if (_pairs[i].first == index || _pairs[i].second == index) {
        revealed = true;
        break;
      }
    }

    // Caso não esteja em um par revelado, verifica se é a tentativa atual
    final isCurrentPairFirst = currentPair.first == index;
    final isCurrentPairSecond = currentPair.second == index;
    return revealed || isCurrentPairFirst || isCurrentPairSecond;
  }

  // Função que retorna o conteúdo de uma carta
  String cardContent(int index) {
    // Se está fora do range de cartas, retorna vazio
    if (index < 0 || index >= numPairs * 2) {
      return "";
    }

    // Se não está revelada, retorna vazio
    if (!isRevealed(index)) {
      return "";
    }

    // Verifica se está em algum par já revelado
    for (int i in _revealedPairs) {
      if (_pairs[i].first == index || _pairs[i].second == index) {
        // Retorna código dessa posição
        return _cardContents[index];
      }
    }

    // Verifica se é o par atual
    if (currentPair.first == index || currentPair.second == index) {
      return _cardContents[index];
    }

    // Caso chegar aqui, a carta não está revelada
    return "";
  }

  // Função que retorna se o jogador ganhou
  bool won() {
    return _revealedPairs.length == _pairs.length;
  }

  // Função que retorna um botão da carta
  Color colorAt(int index) {
    // Define a cor do botão
    late final Color color;
    if (currentPair.first == index || currentPair.second == index) {
      // Caso seja da tentativa atual
      color = Colors.blue;
    } else if (isRevealed(index)) {
      // Se já foi revelado
      color = Colors.green;
    } else {
      // Se não foi revelado
      color = Colors.grey;
    }

    return color;
  }
}

// Classe pra representar um par no jogo da memória
class Pair {
  Pair({this.first = -1, this.second = -1, this.content = ""});

  // Indices na posição de cartas
  int first, second;

  // Conteúdo do par
  String content;

  @override
  String toString() {
    return "($first, $second)";
  }

  @override
  bool operator ==(Object other) {
    if (other is! Pair) return false;

    // Primeiro com primeiro, segundo com segundo
    final isFirst0 = first == other.first;
    final isSecond0 = second == other.second;

    // Primeiro com segundo, segundo com primeiro
    final isFirst1 = first == other.second;
    final isSecond1 = second == other.first;

    return (isFirst0 && isSecond0) || (isFirst1 && isSecond1);
  }

  @override
  int get hashCode => Object.hash(first, second);
}
