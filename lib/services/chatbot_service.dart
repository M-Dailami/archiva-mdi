import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archivafinal/models/place_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotService {
  static const String _apiKey =
      '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';
  static const String _apiUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const List<String> _models = [
    'openai/gpt-oss-120b:free',                  
    'meta-llama/llama-3.3-70b-instruct:free',    
    'nousresearch/hermes-3-llama-3.1-405b:free', 
    'deepseek/deepseek-v4-flash:free',          
    'google/gemma-4-31b-it:free',               
  ];

  bool _initialized = false;
  List<Place> _places = [];
  List<Map<String, String>> _messages = [];

  Future<void> init(List<Place> places) async {
    if (_initialized) return;
    _places = places;
    final index = StringBuffer();
    index.writeln('DAFTAR TEMPAT BERSEJARAH DI ARCHIVA:');
    for (final place in places) {
      index.writeln('- ${place.name} (${place.category}, ${place.province})');
    }

    final systemInstruction =
        'Kamu adalah Archiva Bot, asisten virtual yang ramah dan berpengetahuan luas '
        'tentang tempat-tempat bersejarah di Indonesia. Kamu membantu pengguna memahami '
        'sejarah, budaya, dan informasi mengenai tempat bersejarah yang tersedia di '
        'aplikasi Archiva.\n\n'
        'ATURAN:\n'
        '1. Jawab berdasarkan data konteks relevan yang disertakan di setiap pesan.\n'
        '2. Jika tidak ada konteks yang relevan atau pertanyaan di luar topik sejarah, '
        'jawab dengan sopan bahwa kamu hanya bisa menjawab tentang tempat bersejarah '
        'yang ada di Archiva.\n'
        '3. WAJIB menggunakan Bahasa Indonesia yang baku dan benar — BUKAN Bahasa Melayu Malaysia. '
        'Gunakan kosakata Indonesia seperti: "tidak" (bukan "tidak" versi Malaysia/Melayu seperti "tak"), '
        '"saya" (bukan "aku" atau "saye"), "apa" (bukan "ape"), "bagaimana" (bukan "macam mana"), '
        '"kenapa" (bukan "kenape"), "sangat" (bukan "amat"), "sudah" (bukan "dah"), '
        '"mobil" bukan "kereta", "toko" bukan "kedai". '
        'Kamu adalah asisten untuk aplikasi Indonesia, bicara seperti orang Indonesia.\n'
        '4. Berikan jawaban yang ringkas namun informatif (maksimal 3-4 paragraf).\n'
        '5. Jika relevan, sarankan pengguna untuk membuka modul pembelajaran atau kuis '
        'di aplikasi untuk memperdalam pengetahuan.\n\n'
        'Berikut daftar tempat yang tersedia:\n'
        '$index';

    _messages = [
      {'role': 'system', 'content': systemInstruction},
    ];

    _initialized = true;
  }

   List<Place> _findRelevantPlaces(String message) {
    final query = message.toLowerCase();
    final words =
        query.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();

    final scored = _places.map((place) {
      int score = 0;

      if (place.name.toLowerCase().contains(query)) score += 10;
      if (place.location.toLowerCase().contains(query)) score += 5;
      if (place.province.toLowerCase().contains(query)) score += 5;
      if (place.category.toLowerCase().contains(query)) score += 3;
      if (place.description.toLowerCase().contains(query)) score += 2;

      // Cocokkan per modul
      for (final m in place.modules) {
        if (m.title.toLowerCase().contains(query)) score += 4;
        if (m.content.toLowerCase().contains(query)) score += 2;
        for (final f in m.keyFacts) {
          if (f.toLowerCase().contains(query)) score += 3;
        }
      }

      // Cocokkan per kata (bobot lebih rendah)
      for (final word in words) {
        if (place.name.toLowerCase().contains(word)) score += 5;
        if (place.location.toLowerCase().contains(word)) score += 2;
        if (place.province.toLowerCase().contains(word)) score += 2;
        if (place.description.toLowerCase().contains(word)) score += 1;
        for (final m in place.modules) {
          if (m.title.toLowerCase().contains(word)) score += 3;
          if (m.content.toLowerCase().contains(word)) score += 1;
          for (final f in m.keyFacts) {
            if (f.toLowerCase().contains(word)) score += 2;
          }
        }
      }

      return _ScoredPlace(place, score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));

    // Kembalikan hanya tempat dengan skor berarti (maksimal 2 tempat teratas)
    return scored
        .where((s) => s.score > 0)
        .take(2)
        .map((s) => s.place)
        .toList();
  }

  /// Buat string konteks ringkas hanya untuk tempat-tempat yang relevan.
  String _buildContext(List<Place> places) {
    if (places.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('[DATA RELEVAN UNTUK PERTANYAAN INI]:');
    for (final place in places) {
      buffer.writeln('## ${place.name}');
      buffer.writeln('Lokasi: ${place.location}, ${place.province}');
      buffer.writeln('Kategori: ${place.category}');
      buffer.writeln('Jam Buka: ${place.openHours} | Tiket: ${place.ticketPrice}');
      buffer.writeln('Deskripsi: ${place.description}');
      if (place.modules.isNotEmpty) {
        buffer.writeln('Materi Pembelajaran:');
        for (final m in place.modules) {
          buffer.writeln('  - ${m.title} (${m.period}): ${m.content}');
          if (m.keyFacts.isNotEmpty) {
            buffer.writeln('    Fakta Kunci: ${m.keyFacts.join(', ')}');
          }
        }
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<String> sendMessage(String message) async {
    if (!_initialized) {
      return 'Chatbot belum siap. Silakan tunggu sebentar...';
    }

    try {
      // Pencarian lokal: temukan 1–2 tempat paling relevan untuk pertanyaan ini
      final relevant = _findRelevantPlaces(message);
      final context = _buildContext(relevant);

      // Tambahkan konteks ke pesan user hanya jika ada data yang relevan
      final augmentedMessage = [
        if (context.isNotEmpty) context,
        message,
        // Diulang setiap pesan — model gratis sering mengabaikan system prompt
        '\n[INSTRUKSI WAJIB: Balas HANYA dalam Bahasa Indonesia yang baku. '
            'DILARANG menggunakan Bahasa Melayu Malaysia. '
            'Gunakan kata: "tidak" bukan "tak", "bagaimana" bukan "macam mana", '
            '"sudah" bukan "dah", "saya" bukan "saye".]',
      ].join('\n\n');

      // Tambahkan pesan user ke riwayat
      _messages.add({'role': 'user', 'content': augmentedMessage});

      
      http.Response? lastResponse;
      for (final model in _models) {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
            'HTTP-Referer': 'https://archiva-app.example.com',
            'X-Title': 'Archiva App',
          },
          body: jsonEncode({
            'model': model,
            'messages': _messages,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final reply =
              data['choices'][0]['message']['content'] as String? ??
              'Maaf, saya tidak bisa menjawab saat ini.';

          // Tambahkan balasan asisten ke riwayat untuk konteks multi-giliran
          _messages.add({'role': 'assistant', 'content': reply});
          return reply;
        }

        // 429 (batas rate) atau 404 (tidak ada endpoint) → coba model berikutnya
        lastResponse = response;
        if (response.statusCode != 429 && response.statusCode != 404) break;
      }

      // Semua model gagal — tampilkan pesan error yang ramah
      return 'Maaf, sistem sedang sibuk (${lastResponse!.statusCode}). '
          'Silakan coba lagi dalam beberapa saat.';
    } catch (e) {
      return 'Terjadi kesalahan koneksi: $e';
    }
  }

  void reset() {
    // Pertahankan hanya pesan sistem, hapus sisa riwayat
    if (_messages.isNotEmpty) {
      _messages = [_messages.first];
    }
  }

  bool get isInitialized => _initialized;
}

/// Kelas pembantu internal untuk memberi skor relevansi tempat.
class _ScoredPlace {
  final Place place;
  final int score;
  const _ScoredPlace(this.place, this.score);
}
