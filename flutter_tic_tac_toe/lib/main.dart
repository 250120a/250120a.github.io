import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Tic-Tac-Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TicTacToePage(),
    );
  }
}

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  static const int boardSize = 9;
  static const List<List<int>> _winningPatterns = <List<int>>[
    <int>[0, 1, 2],
    <int>[3, 4, 5],
    <int>[6, 7, 8],
    <int>[0, 3, 6],
    <int>[1, 4, 7],
    <int>[2, 5, 8],
    <int>[0, 4, 8],
    <int>[2, 4, 6],
  ];

  late List<String?> _board;
  String _currentPlayer = 'X';
  bool _isGameOver = false;
  String? _winner;
  int _scoreX = 0;
  int _scoreO = 0;

  @override
  void initState() {
    super.initState();
    _board = List<String?>.filled(boardSize, null);
  }

  void _handleTap(int index) {
    if (_board[index] != null || _isGameOver) {
      return;
    }

    setState(() {
      _board[index] = _currentPlayer;
      _winner = _checkWinner();

      if (_winner != null) {
        _isGameOver = true;
        if (_winner == 'X') {
          _scoreX++;
        } else if (_winner == 'O') {
          _scoreO++;
        }
      } else if (!_board.contains(null)) {
        _isGameOver = true;
      } else {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  String? _checkWinner() {
    for (final List<int> pattern in _winningPatterns) {
      final String? a = _board[pattern[0]];
      final String? b = _board[pattern[1]];
      final String? c = _board[pattern[2]];

      if (a != null && a == b && a == c) {
        return a;
      }
    }
    return null;
  }

  void _resetBoard({bool keepScores = true}) {
    setState(() {
      _board = List<String?>.filled(boardSize, null);
      _currentPlayer = 'X';
      _winner = null;
      _isGameOver = false;
      if (!keepScores) {
        _scoreX = 0;
        _scoreO = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String statusMessage = _winner != null
        ? 'Player $_winner wins!'
        : _isGameOver
            ? 'It\'s a draw!'
            : 'Player $_currentPlayer\'s turn';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Tic-Tac-Toe'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ScoreBoard(scoreX: _scoreX, scoreO: _scoreO, colors: colors),
                const SizedBox(height: 24),
                _Board(
                  board: _board,
                  colors: colors,
                  onTap: _handleTap,
                  winningPattern: _highlightPattern(),
                ),
                const SizedBox(height: 24),
                Text(
                  statusMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: () => _resetBoard(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _resetBoard(keepScores: false),
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Reset Scores'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<int>? _highlightPattern() {
    if (_winner == null) {
      return null;
    }
    for (final List<int> pattern in _winningPatterns) {
      final String? a = _board[pattern[0]];
      final String? b = _board[pattern[1]];
      final String? c = _board[pattern[2]];
      if (a != null && a == b && a == c) {
        return pattern;
      }
    }
    return null;
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({
    required this.scoreX,
    required this.scoreO,
    required this.colors,
  });

  final int scoreX;
  final int scoreO;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _ScoreTile(label: 'Player X', score: scoreX, color: colors.primary),
            _ScoreTile(label: 'Player O', score: scoreO, color: colors.secondary),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.score,
    required this.color,
  });

  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.board,
    required this.colors,
    required this.onTap,
    this.winningPattern,
  });

  final List<String?> board;
  final ColorScheme colors;
  final void Function(int index) onTap;
  final List<int>? winningPattern;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: board.length,
        itemBuilder: (BuildContext context, int index) {
          final String? value = board[index];
          final bool isHighlighted =
              winningPattern != null && winningPattern!.contains(index);

          return _BoardTile(
            value: value,
            onTap: () => onTap(index),
            colors: colors,
            isHighlighted: isHighlighted,
          );
        },
      ),
    );
  }
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({
    required this.value,
    required this.onTap,
    required this.colors,
    required this.isHighlighted,
  });

  final String? value;
  final VoidCallback onTap;
  final ColorScheme colors;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isHighlighted
        ? colors.tertiaryContainer
        : colors.surfaceVariant;
    final Color borderColor = isHighlighted ? colors.tertiary : colors.outline;
    final Color textColor = value == 'X' ? colors.primary : colors.secondary;

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: isHighlighted ? 3 : 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: value == null ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: AnimatedScale(
            scale: value == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: value != null ? textColor : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ) ??
                  TextStyle(
                    fontSize: 48,
                    color: value != null ? textColor : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
              child: Text(value ?? ''),
            ),
          ),
        ),
      ),
    );
  }
}
