abstract class GameConfig {
  // Lista de possíveis números de pares
  static const possibleNumPairs = <int>[
    6,
    8,
    10,
    12,
    14,
    15,
    24,
  ];

  // Menor número de pares possível
  static int get minPairs {
    return possibleNumPairs.reduce(
      (value, element) => value < element ? value : element,
    );
  }

  // Retorna quantas cartas ficam em cada linha dependendo do número de pares
  static int crossAxisCount(int numPairs) {
    assert(
      possibleNumPairs.contains(numPairs),
      "Invalid number of pairs: $numPairs",
    );

    switch (numPairs) {
      case 6:
      case 8:
        return 4;
      case 10:
        return 5;
      case 12:
        return 6;
      case 14:
        return 7;
      case 15:
        return 6;
      case 24:
        return 8;
      default:
        return 0;
    }
  }
}
