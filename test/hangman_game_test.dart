import 'package:ahorcado_hoja/src/game/hangman_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HangmanGame', () {
    test('reveals a correct letter without adding a mistake', () {
      final HangmanGame game = HangmanGame(word: 'CASA', hint: 'Hogar');

      final GuessResult result = game.guess('a');

      expect(result, GuessResult.correct);
      expect(game.visibleCharacters, <String>['', 'A', '', 'A']);
      expect(game.mistakes, 0);
    });

    test('counts repeated incorrect letters only once', () {
      final HangmanGame game = HangmanGame(word: 'CASA', hint: 'Hogar');

      expect(game.guess('x'), GuessResult.incorrect);
      expect(game.guess('X'), GuessResult.repeated);
      expect(game.mistakes, 1);
    });

    test('matches accented vowels with their unaccented key', () {
      final HangmanGame game = HangmanGame(word: 'MURCIÉLAGO', hint: 'Animal');

      game.guess('e');

      expect(game.visibleCharacters[5], 'É');
    });

    test('wins after every distinct letter is guessed', () {
      final HangmanGame game = HangmanGame(word: 'ALA', hint: 'Vuelo');

      game.guess('a');
      final GuessResult result = game.guess('l');

      expect(result, GuessResult.won);
      expect(game.isWon, isTrue);
      expect(game.isFinished, isTrue);
    });

    test('loses after reaching the maximum mistakes', () {
      final HangmanGame game = HangmanGame(
        word: 'A',
        hint: 'Letra',
        maxMistakes: 2,
      );

      game.guess('x');
      final GuessResult result = game.guess('y');

      expect(result, GuessResult.lost);
      expect(game.isLost, isTrue);
      expect(game.mistakesLeft, 0);
    });
  });
}
