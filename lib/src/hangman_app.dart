// Hallmark · pre-emit critique: P5 H4 E5 S5 R4 V5
// Genre: playful · theme: notebook-paper · responsive: 320/375/414/768
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/hangman_game.dart';

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  static const Color _paper = Color(0xFFFFFCED);
  static const Color _ink = Color(0xFF263B52);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ahorcado de papel',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _ink,
          primary: _ink,
          surface: _paper,
        ),
        scaffoldBackgroundColor: _paper,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'serif',
            color: _ink,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
          titleLarge: TextStyle(
            fontFamily: 'monospace',
            color: _ink,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'monospace',
            color: _ink,
            height: 1.45,
          ),
        ),
      ),
      home: const HangmanPage(),
    );
  }
}

class _WordEntry {
  const _WordEntry(this.word, this.hint);

  final String word;
  final String hint;
}

class HangmanPage extends StatefulWidget {
  const HangmanPage({super.key});

  @override
  State<HangmanPage> createState() => _HangmanPageState();
}

class _HangmanPageState extends State<HangmanPage> {
  static const Color _paper = Color(0xFFFFFCED);
  static const Color _ink = Color(0xFF263B52);
  static const Color _mutedInk = Color(0xFF607080);
  static const Color _success = Color(0xFF4F765D);
  static const Color _mistake = Color(0xFFB8514C);

  static const List<_WordEntry> _words = <_WordEntry>[
    _WordEntry('MARIPOSA', 'Una visitante colorida del jardín.'),
    _WordEntry('CUADERNO', 'Guarda ideas entre sus páginas.'),
    _WordEntry('AVENTURA', 'Empieza cuando te atreves a salir.'),
    _WordEntry('BIBLIOTECA', 'Un lugar lleno de historias.'),
    _WordEntry('PLANETA', 'Gira alrededor de una estrella.'),
    _WordEntry('MURCIÉLAGO', 'Vuela de noche y duerme de día.'),
  ];

  static const List<String> _keyboard = <String>[
    'Q',
    'W',
    'E',
    'R',
    'T',
    'Y',
    'U',
    'I',
    'O',
    'P',
    'A',
    'S',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'Ñ',
    'Z',
    'X',
    'C',
    'V',
    'B',
    'N',
    'M',
  ];

  final FocusNode _focusNode = FocusNode();
  late HangmanGame _game;
  int _wordIndex = 0;
  String _message = 'Elige una letra para comenzar.';

  @override
  void initState() {
    super.initState();
    _wordIndex = Random().nextInt(_words.length);
    _game = _newGame(_wordIndex);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  HangmanGame _newGame(int index) {
    final _WordEntry entry = _words[index];
    return HangmanGame(word: entry.word, hint: entry.hint);
  }

  void _guess(String letter) {
    final GuessResult result = _game.guess(letter);
    setState(() {
      _message = switch (result) {
        GuessResult.correct => '¡Bien! Esa letra sí está.',
        GuessResult.incorrect => 'Esa letra no está. Sigue intentando.',
        GuessResult.repeated => 'Ya probaste esa letra.',
        GuessResult.won => '¡Lo lograste! La palabra era ${_game.word}.',
        GuessResult.lost => 'Se acabaron los intentos. Era ${_game.word}.',
      };
    });
  }

  void _restart() {
    setState(() {
      _wordIndex = (_wordIndex + 1) % _words.length;
      _game = _newGame(_wordIndex);
      _message = 'Nueva palabra. ¡Tú puedes!';
    });
    _focusNode.requestFocus();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    final String? character = event.character?.toUpperCase();
    if (character != null && _keyboard.contains(character)) {
      _guess(character);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final bool isWide = screen.width >= 820;
    final double horizontalPadding = screen.width < 380 ? 16 : 24;

    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _NotebookBackground()),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  22,
                  horizontalPadding,
                  36,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _Header(onRestart: _restart),
                        const SizedBox(height: 22),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: _drawingPanel()),
                              const SizedBox(width: 42),
                              Expanded(child: _gamePanel()),
                            ],
                          )
                        else ...<Widget>[
                          _drawingPanel(),
                          const SizedBox(height: 26),
                          _gamePanel(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawingPanel() {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.18,
          child: Semantics(
            label: 'Dibujo del ahorcado con ${_game.mistakes} errores',
            image: true,
            child: CustomPaint(
              painter: _HangmanPainter(
                mistakes: _game.mistakes,
                ink: _ink,
                mistake: _mistake,
              ),
            ),
          ),
        ),
        Text(
          _game.mistakesLeft == 1
              ? 'Queda 1 intento'
              : 'Quedan ${_game.mistakesLeft} intentos',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: _mutedInk,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _gamePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HintCard(hint: _game.hint),
        const SizedBox(height: 24),
        _WordDisplay(characters: _game.visibleCharacters),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            _message,
            key: ValueKey<String>(_message),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              color: _game.isWon
                  ? _success
                  : _game.isLost
                      ? _mistake
                      : _mutedInk,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (_game.isFinished)
          Center(
            child: FilledButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('OTRA PALABRA'),
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: _paper,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          )
        else
          _Keyboard(
            letters: _keyboard,
            guessedLetters: _game.guessedLetters,
            word: _game.normalizedWord,
            onGuess: _guess,
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final double titleSize = MediaQuery.sizeOf(context).width < 380 ? 34 : 44;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'AHORCADO',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: titleSize,
                      height: 1,
                    ),
              ),
              const SizedBox(height: 5),
              const Text(
                'UNA PALABRA · SEIS INTENTOS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFF607080),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.25,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Nueva palabra',
          onPressed: onRestart,
          icon: const Icon(Icons.refresh_rounded),
          color: const Color(0xFF263B52),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF1ECD8),
            minimumSize: const Size(48, 48),
            side: const BorderSide(color: Color(0xFF263B52), width: 1.5),
          ),
        ),
      ],
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.012,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF1ECD8),
          border: Border.all(color: const Color(0xFF263B52), width: 1.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33263B52),
              offset: Offset(4, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'PISTA',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFB8514C),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF263B52),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordDisplay extends StatelessWidget {
  const _WordDisplay({required this.characters});

  final List<String> characters;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Palabra: ${characters.map((String value) => value.isEmpty ? "vacío" : value).join(", ")}',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 7,
        runSpacing: 12,
        children: characters.map((String character) {
          if (character == ' ') {
            return const SizedBox(width: 16, height: 46);
          }

          return SizedBox(
            width: 31,
            height: 46,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF263B52), width: 2),
                ),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    character,
                    key: ValueKey<String>(character),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: Color(0xFF263B52),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({
    required this.letters,
    required this.guessedLetters,
    required this.word,
    required this.onGuess,
  });

  final List<String> letters;
  final Set<String> guessedLetters;
  final String word;
  final ValueChanged<String> onGuess;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double keyWidth = constraints.maxWidth < 380 ? 34 : 39;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 7,
          runSpacing: 8,
          children: letters.map((String letter) {
            final String normalized = letter.toLowerCase();
            final bool isGuessed = guessedLetters.contains(normalized);
            final bool isCorrect = isGuessed && word.contains(normalized);

            return SizedBox(
              width: keyWidth,
              height: 42,
              child: OutlinedButton(
                onPressed: isGuessed ? null : () => onGuess(letter),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: const Color(0xFF263B52),
                  disabledForegroundColor: isCorrect
                      ? const Color(0xFF4F765D)
                      : const Color(0xFFB8514C),
                  backgroundColor: isCorrect
                      ? const Color(0xFFDDE9DD)
                      : const Color(0xFFFFFCED),
                  disabledBackgroundColor: isCorrect
                      ? const Color(0xFFDDE9DD)
                      : const Color(0xFFF2DCD8),
                  side: BorderSide(
                    color: isCorrect
                        ? const Color(0xFF4F765D)
                        : isGuessed
                            ? const Color(0xFFB8514C)
                            : const Color(0xFF263B52),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: Text(letter),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _NotebookBackground extends StatelessWidget {
  const _NotebookBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NotebookPainter(
        paper: const Color(0xFFFFFCED),
        line: const Color(0xFFB8D6E3),
        margin: const Color(0xFFE58F8A),
      ),
    );
  }
}

class _NotebookPainter extends CustomPainter {
  const _NotebookPainter({
    required this.paper,
    required this.line,
    required this.margin,
  });

  final Color paper;
  final Color line;
  final Color margin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    final Paint linePaint = Paint()
      ..color = line.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (double y = 84; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    final double marginX = size.width < 600 ? 11 : 36;
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      Paint()
        ..color = margin.withValues(alpha: 0.7)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _NotebookPainter oldDelegate) => false;
}

class _HangmanPainter extends CustomPainter {
  const _HangmanPainter({
    required this.mistakes,
    required this.ink,
    required this.mistake,
  });

  final int mistakes;
  final Color ink;
  final Color mistake;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint standPaint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint personPaint = Paint()
      ..color = mistake
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double left = size.width * 0.2;
    final double top = size.height * 0.1;
    final double bottom = size.height * 0.88;
    final double arm = size.width * 0.58;
    final double ropeX = size.width * 0.67;
    final double ropeBottom = size.height * 0.27;
    final double headRadius = size.shortestSide * 0.09;

    canvas.drawLine(Offset(left * 0.55, bottom),
        Offset(size.width * 0.58, bottom), standPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left, top), standPaint);
    canvas.drawLine(Offset(left, top), Offset(arm, top), standPaint);
    canvas.drawLine(Offset(left, top + 34), Offset(left + 34, top), standPaint);
    canvas.drawLine(Offset(arm, top), Offset(ropeX, top), standPaint);
    canvas.drawLine(Offset(ropeX, top), Offset(ropeX, ropeBottom), standPaint);

    final Offset headCenter = Offset(ropeX, ropeBottom + headRadius);
    if (mistakes >= 1) {
      canvas.drawCircle(headCenter, headRadius, personPaint);
    }
    final Offset neck = Offset(ropeX, headCenter.dy + headRadius);
    final Offset hips = Offset(ropeX, size.height * 0.66);
    if (mistakes >= 2) {
      canvas.drawLine(neck, hips, personPaint);
    }
    if (mistakes >= 3) {
      canvas.drawLine(Offset(ropeX, size.height * 0.43),
          Offset(size.width * 0.52, size.height * 0.54), personPaint);
    }
    if (mistakes >= 4) {
      canvas.drawLine(Offset(ropeX, size.height * 0.43),
          Offset(size.width * 0.82, size.height * 0.54), personPaint);
    }
    if (mistakes >= 5) {
      canvas.drawLine(
          hips, Offset(size.width * 0.55, size.height * 0.8), personPaint);
    }
    if (mistakes >= 6) {
      canvas.drawLine(
          hips, Offset(size.width * 0.8, size.height * 0.8), personPaint);
      final Paint facePaint = Paint()
        ..color = mistake
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      final double faceY = headCenter.dy - 4;
      for (final double dx in <double>[-headRadius * 0.36, headRadius * 0.36]) {
        final Offset eye = Offset(headCenter.dx + dx, faceY);
        canvas.drawLine(eye.translate(-3, -3), eye.translate(3, 3), facePaint);
        canvas.drawLine(eye.translate(3, -3), eye.translate(-3, 3), facePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter oldDelegate) {
    return mistakes != oldDelegate.mistakes;
  }
}
