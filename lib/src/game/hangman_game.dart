enum GuessResult { correct, incorrect, repeated, won, lost }

class HangmanGame {
  HangmanGame({
    required this.word,
    required this.hint,
    this.maxMistakes = 6,
  })  : assert(word.trim().isNotEmpty),
        assert(maxMistakes > 0);

  final String word;
  final String hint;
  final int maxMistakes;
  final Set<String> guessedLetters = <String>{};

  int get mistakes => guessedLetters
      .where((String letter) => !normalizedWord.contains(letter))
      .length;

  int get mistakesLeft => maxMistakes - mistakes;
  bool get isWon =>
      normalizedWord.split('').where(_isLetter).every(guessedLetters.contains);
  bool get isLost => mistakes >= maxMistakes;
  bool get isFinished => isWon || isLost;

  String get normalizedWord => _normalize(word);

  List<String> get visibleCharacters => word.split('').map((String character) {
        if (!_isLetter(character)) {
          return character;
        }

        return guessedLetters.contains(_normalize(character)) ? character : '';
      }).toList(growable: false);

  GuessResult guess(String letter) {
    if (isFinished) {
      return isWon ? GuessResult.won : GuessResult.lost;
    }

    final String normalizedLetter = _normalize(letter);
    if (normalizedLetter.length != 1 || !_isLetter(normalizedLetter)) {
      return GuessResult.repeated;
    }
    if (!guessedLetters.add(normalizedLetter)) {
      return GuessResult.repeated;
    }
    if (isWon) {
      return GuessResult.won;
    }
    if (isLost) {
      return GuessResult.lost;
    }

    return normalizedWord.contains(normalizedLetter)
        ? GuessResult.correct
        : GuessResult.incorrect;
  }

  static String _normalize(String value) {
    const Map<String, String> accents = <String, String>{
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
    };

    return value
        .trim()
        .toLowerCase()
        .split('')
        .map((String character) => accents[character] ?? character)
        .join();
  }

  static bool _isLetter(String character) {
    return RegExp(r'^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ]$').hasMatch(character);
  }
}
