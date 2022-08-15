import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const RandomWords(),
    );
  }
}

@immutable
class Word {
  final WordPair wordPair;
  final bool isFavorite;

  const Word({required this.wordPair, this.isFavorite = false});
}

class WordListNotifier extends StateNotifier<List<Word>> {
  WordListNotifier() : super([]) {
    state = [
      for (var wordPair in generateWordPairs().take(10))
        Word(wordPair: wordPair)
    ];
  }

  void add(WordPair wordPair) {
    state = [...state, Word(wordPair: wordPair)];
  }

  Future<void> addAll(List<WordPair> wordPairs) async {
    await Future.delayed(const Duration(milliseconds: 10));
    for (var wordPair in wordPairs) {
      add(wordPair);
    }
  }

  void toggle(int idx) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          Word(wordPair: state[i].wordPair, isFavorite: !state[idx].isFavorite)
        else
          state[i],
    ];
  }
}

final wordListProvider =
    StateNotifierProvider<WordListNotifier, List<Word>>((ref) {
  return WordListNotifier();
});

class RandomWords extends StatefulHookConsumerWidget {
  const RandomWords({super.key});

  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends ConsumerState<RandomWords> {
  final biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: [
          IconButton(
            onPressed: pushSaved,
            icon: const Icon(Icons.list),
            tooltip: 'Saved Suggestions',
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: words.length,
        itemBuilder: (context, index) {
          if (index >= words.length - 1) {
            ref
                .read(wordListProvider.notifier)
                .addAll(generateWordPairs().take(10).toList());
          }
          return ListTile(
            title: Text(
              words[index].wordPair.asPascalCase,
              style: biggerFont,
            ),
            trailing: Icon(
              words[index].isFavorite ? Icons.favorite : Icons.favorite_border,
              color: words[index].isFavorite ? Colors.red : null,
              semanticLabel:
                  words[index].isFavorite ? 'Remove from saved' : 'Save',
            ),
            onTap: () {
              ref.read(wordListProvider.notifier).toggle(index);
            },
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }

  void pushSaved() {
    final words = ref.watch(wordListProvider);
    final saved = words.where((word) => word.isFavorite == true);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.wordPair.asPascalCase,
                  style: biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
