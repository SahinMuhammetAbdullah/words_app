import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts flutterTts = FlutterTts();
  
  // Hedef İngilizce dil kodu
  final String targetLanguage = "en-US";

  TTSService() {
    _initTts();
  }

  void _initTts() async {
    // 1. Dili Ayarla (Hızlı başlangıç)
    await flutterTts.setLanguage(targetLanguage);
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5); 
    await flutterTts.setPitch(1.0);
    
    // 2. Yüklü Sesleri Kontrol Et ve İngilizce Bir Ses Seç (Agresif Kontrol)
    try {
      final List<dynamic>? voices = await flutterTts.getVoices;
      
      if (voices != null) {
        // En-US dil kodunu içeren bir ses arıyoruz
        final List<Map<String, String>> availableVoices = voices.map((voice) {
          return Map<String, String>.from(voice as Map);
        }).toList();

        final preferredVoice = availableVoices.firstWhere(
          (voice) => voice['locale']!.startsWith('en-') && voice['name']!.toLowerCase().contains('us'),
          // Eğer en-US spesifik bir ses bulunamazsa, genel bir İngilizce ses dene
          orElse: () => availableVoices.firstWhere(
            (voice) => voice['locale']!.startsWith('en'),
            orElse: () => <String, String>{'name': 'default', 'locale': 'en-US'}
          ),
        );

        if (preferredVoice['name'] != 'default') {
          await flutterTts.setVoice({"name": preferredVoice['name']!, "locale": preferredVoice['locale']!});
          print('TTS Başarılı: ${preferredVoice['name']} sesi kullanılıyor.');
        } else {
           print('TTS Uyarı: En-US sesi bulunamadı, varsayılan ses kullanılıyor.');
        }
      }
    } catch (e) {
      print("TTS Ses Seçimi Hatası: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      // Konuşmadan önce dili tekrar kontrol etme (Bazı cihazlar için gerekli)
      await flutterTts.setLanguage(targetLanguage); 
      await flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}