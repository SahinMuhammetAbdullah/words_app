// lib/widgets/flashcard_view.dart

import 'package:flutter/material.dart';
import 'package:words_app/app_state.dart';
import 'package:words_app/core/models/word.dart';

// Ana kart tekrarı görünümü (Butonlar alta sabitlenmiş)
class RepetitionView extends StatelessWidget {
  final Word currentWord;
  final int totalCount;
  final int currentIndex;
  final Function(Word word, bool known) onAnswer;

  const RepetitionView({
    super.key,
    required this.currentWord,
    required this.totalCount,
    required this.currentIndex,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack( 
      children: [
        // 1. Ana İçerik (Kart ve Sayaç)
        Positioned.fill(
          bottom: 120, // Butonların yüksekliği kadar boşluk
          child: SingleChildScrollView( 
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    '${currentIndex + 1} / $totalCount',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                
                // Repetition Bileşeni
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Repetition(
                    word: currentWord,
                  ),
                ),
                const SizedBox(height: 40), // Alt butona kadar boşluk
              ],
            ),
          ),
        ),

        // 2. Butonları En Alta Sabitleme
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor, 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAnswer(currentWord, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Bilmiyorum', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAnswer(currentWord, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Biliyorum', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =======================================================
// FLASHCARD ARTIK KENDİ ÇEVİRME DURUMUNU YÖNETEN STATEFUL WIDGET'TIR
// =======================================================

class Repetition extends StatefulWidget {
  final Word word;

  const Repetition({
    super.key, 
    required this.word, 
  });

  @override
  State<Repetition> createState() => _RepetitionState();
}

class _RepetitionState extends State<Repetition> {
  bool _isFlipped = false;

  @override
  void didUpdateWidget(covariant Repetition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.word.headword != oldWidget.word.headword) {
      setState(() {
        _isFlipped = false; 
      });
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: _flipCard,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotationAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

          return AnimatedBuilder(
            animation: rotationAnimation,
            child: child,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center, 
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) 
                  ..rotateY(_isFlipped ? rotationAnimation.value * 3.14159 : (1.0 - rotationAnimation.value) * 3.14159), 
                child: child,
              );
            },
          );
        },
        child: _isFlipped ? _buildCardBack(context) : _buildCardFront(context),
      ),
    );
  }

  // Kartın Ön Yüzü (İngilizce Kelime + Cümle)
  Widget _buildCardFront(BuildContext context) {
    return Card(
      key: const ValueKey(true), 
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blue.shade700, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.word.headword, 
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                widget.word.pos, 
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Text(
                widget.word.sentence, 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.blue.shade700),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    tooltip: 'Kelimeyi oku',
                    onPressed: () => ListenableProvider.of<AppState>(context, listen: false).speak(widget.word.headword), 
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.hearing, color: Colors.blue),
                    tooltip: 'Cümleyi oku',
                    onPressed: () => ListenableProvider.of<AppState>(context, listen: false).speak(widget.word.sentence),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartın Arka Yüzü (Türkçe Anlamı + İngilizce ve Türkçe Cümleler)
  Widget _buildCardBack(BuildContext context) {
    return Card(
      key: const ValueKey(false), 
      elevation: 8,
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159), // Metni geri çevirir
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.word.turkish, 
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                
                Divider(color: Colors.white70),
                
                Text(
                  widget.word.sentence, 
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),

                Text(
                  widget.word.sentenceTr, 
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}