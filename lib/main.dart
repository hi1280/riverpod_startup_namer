import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const ProviderScope(
    child: RandomWords(),
  ));
}

class RandomWord {
  RandomWord({required this.words, required this.saved});
  List<WordPair> words;
  Set<WordPair> saved;
}

class RandomWordNotifier extends StateNotifier<RandomWord> {
  RandomWordNotifier() : super(RandomWord(words: [], saved: {}));

  void addWords(List<WordPair> words) {
    state.words = [...state.words, ...words];
  }

  void removeSaved(WordPair value) {
    state.saved.remove(value);
  }

  void addSaved(WordPair value) {
    state.saved.add(value);
  }
}

final randomWordsProvider =
    StateNotifierProvider<RandomWordNotifier, RandomWord>((ref) {
  return RandomWordNotifier();
});

final alreadySavedProvider = Provider<bool>((ref) => false);

class RandomWords extends StatefulHookConsumerWidget {
  const RandomWords({super.key});

  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends ConsumerState<RandomWords> {
  final biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    final RandomWord randomWord = ref.watch(randomWordsProvider);
    bool alreadySaved = ref.watch(alreadySavedProvider);
    return MaterialApp(
      title: 'Startup Name Generator',
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Startup Name Generator'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              if (i.isOdd) return const Divider();

              final index = i ~/ 2;
              if (index >= randomWord.words.length) {
                ref
                    .read(randomWordsProvider.notifier)
                    .addWords(generateWordPairs().take(10).toList());
              }
              alreadySaved = randomWord.saved.contains(randomWord.words[index]);
              return ListTile(
                title: Text(
                  randomWord.words[index].asPascalCase,
                  style: biggerFont,
                ),
                trailing: Icon(
                  alreadySaved ? Icons.favorite : Icons.favorite_border,
                  color: alreadySaved ? Colors.red : null,
                  semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
                ),
                onTap: () {
                  if (alreadySaved) {
                    ref
                        .read(randomWordsProvider.notifier)
                        .removeSaved(randomWord.words[index]);
                  } else {
                    ref
                        .read(randomWordsProvider.notifier)
                        .addSaved(randomWord.words[index]);
                  }
                },
              );
            },
          )),
    );
  }
}
