import 'package:fruitlens/data/models/chat_turn.dart';
import 'package:fruitlens/services/chat_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Production [ChatService] backed by Google's Gemini Generative AI API.
class GeminiChatService implements ChatService {
  GeminiChatService({
    required String apiKey,
    String modelName = 'gemini-3.5-flash-lite',
    GenerativeModel? model,
  }) : _apiKey = apiKey,
       _injectedModel = model,
       _modelName = modelName;

  final String _apiKey;
  final String _modelName;
  final GenerativeModel? _injectedModel;

  static const String systemInstruction = '''
Anda adalah BananaLens AI, asisten ahli kematangan, nutrisi, dan kuliner pisang Indonesia yang ramah, ringkas, dan berbasis kesehatan.

BATASAN PEMBAHASAN (GUARDRAIL KETAT):
1. Anda HANYA diperbolehkan menjawab pertanyaan yang berhubungan dengan:
   - Pisang (jenis/varietas seperti kepok, raja, ambon, cavendish, tanduk, serta cara memilih pisang segar).
   - Tingkat kematangan pisang (mentah, matang, matang banget/overripe, busuk) dan ciri fisiknya.
   - Kandungan nutrisi, kalori, kalium, gula alami, serat, vitamin, dan manfaat kesehatan pisang.
   - Cara penyimpanan pisang agar tetap segar, higienis, dan awet.
   - Peringatan keselamatan pangan (indikasi busuk, jamur, fermentasi) serta potensi alergi pisang dan bahan olahannya.
   - Resep olahan makanan atau minuman berbahan dasar pisang yang sehat dan praktis.
2. JIKA pengguna bertanya di luar topik pisang, nutrisi, atau kuliner buah (misalnya tentang coding, matematika, politik, teknologi umum, gosip, tugas sekolah umum, dll.):
   - TOLAK SECARA SOPAN DAN RAMAH.
   - Arahkan kembali pengguna dengan santun, contoh: "Maaf, saya adalah BananaLens AI yang khusus membantu seputar pisang, tingkat kematangan, nutrisi, dan resep olahannya. Ada yang ingin kamu tanyakan tentang pisang hari ini?"

ATURAN PERCAKAPAN & GAYA BAHASA:
1. JANGAN PERNAH mengulang sapaan seperti "Halo", "Hai", "Selamat datang", atau memperkenalkan diri kembali di pesan kedua, ketiga, dan seterusnya!
2. Jika obrolan sedang berlangsung, langsung jawab ke inti informasi yang ditanyakan pengguna secara lugas, alami, dan to the point.
3. Gunakan Bahasa Indonesia yang santun, luwes, dan mudah dipahami.
4. Gunakan poin-poin (bullet points) jika menjelaskan resep atau langkah-langkah agar nyaman dan rapi dibaca di layar HP.
''';

  GenerativeModel get _model =>
      _injectedModel ??
      GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(systemInstruction),
      );

  @override
  Future<String> send({
    required List<ChatTurn> history,
    required String message,
    String? scanContext,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const ChatFailure(
        'Kunci API Gemini belum dikonfigurasi. Periksa file .env Anda.',
      );
    }

    try {
      final contents = <Content>[];

      // Convert prior conversation history turns, skipping any introductory model greetings
      // so the conversation with the API cleanly starts with user turns and alternates properly.
      for (final turn in history) {
        // Skip initial welcome message from the UI widget if it's the very first message
        if (contents.isEmpty && !turn.isUser) {
          continue;
        }

        // Avoid adding the current message if it was already appended to history
        if (turn.isUser && turn.text == message && turn == history.last) {
          continue;
        }

        if (turn.isUser) {
          contents.add(Content.text(turn.text));
        } else {
          contents.add(Content.model(<Part>[TextPart(turn.text)]));
        }
      }

      // Prepend scan context to current prompt if provided
      final promptWithContext = (scanContext != null && scanContext.isNotEmpty)
          ? '[Konteks Buah yang Dipindai: $scanContext]\n$message'
          : message;

      contents.add(Content.text(promptWithContext));

      final response = await _model.generateContent(contents);
      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        throw const ChatFailure('Tidak mendapatkan balasan dari asisten AI.');
      }

      return text;
    } on ChatFailure {
      rethrow;
    } catch (e) {
      throw ChatFailure(
        'Gagal berkomunikasi dengan Gemini: ${e.toString().replaceAll("Exception: ", "")}',
      );
    }
  }
}
