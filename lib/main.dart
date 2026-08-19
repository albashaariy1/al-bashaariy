import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


void main() {
  runApp(const AlBashaariyApp());
}

class AlBashaariyApp extends StatelessWidget {
  const AlBashaariyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AL BASHAARIY',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F2E8),
        fontFamily: 'Georgia',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123C2C),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

const deepGreen = Color(0xFF082A20);
const green = Color(0xFF123C2C);
const gold = Color(0xFFD8A63D);
const cream = Color(0xFFF7F2E8);
const ink = Color(0xFF1D2A24);



class OfflinePoemPage extends StatelessWidget {
  final String titleArabic;
  final String titleEnglish;
  final String arabic;
  final String english;

  const OfflinePoemPage({
    super.key,
    required this.titleArabic,
    required this.titleEnglish,
    required this.arabic,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        title: const Text('Offline Poem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              titleArabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: green,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(titleEnglish,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ink, fontSize: 12)),
            const SizedBox(height: 20),
            _offlineCard('النص العربي', 'Arabic Text',
                Text(arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 21,
                      height: 2,
                    ))),
            const SizedBox(height: 14),
            _offlineCard('الترجمة الإنجليزية', 'English Translation',
                Text(english,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 16,
                      height: 1.6,
                    ))),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.offline_pin_rounded, color: green),
                SizedBox(width: 6),
                Text('Available offline',
                    style: TextStyle(color: green, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _offlineCard(String ar, String en, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1D3B5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ar, textAlign: TextAlign.right,
              style: const TextStyle(color: green, fontWeight: FontWeight.w700)),
          Text(en, style: const TextStyle(color: ink, fontSize: 10)),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}

class PoemPage extends StatefulWidget {
  const PoemPage({super.key});

  @override
  State<PoemPage> createState() => _PoemPageState();
}

class _PoemPageState extends State<PoemPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool favorite = false;
  bool playing = false;
  bool downloaded = false;
  Directory? _offlineDirectory;

  final String arabicPoem = '''مَرَرْتُ إِلَى الْعُلَا بِشَدَائِدِ مُرٍّ
طَرِيقَتُهُ يَضِيقُ وَطُولُ مَيْلًا

وَمَنْ طَلَبَ الْعُلَا مِنْ غَيْرِ كَدٍّ
وَلَمْ يَذُقِ الْكَمِيلَ وَلَا قَلِيلًا''';

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });
    player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });
    player.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
        playing = false;
        position = Duration.zero;
      });
    });
  }

  final String englishTranslation = '''I passed towards the heights through bitter hardships;
its path is narrow and the distance is long.

Whoever seeks the heights without hard work
will not taste perfection, not even a little.''';
  @override
  void initState() {
    super.initState();
    _loadOfflineState();
  }

  Future<Directory> _getOfflineDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/al_bashaariy/offline_poems');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _offlineDirectory = dir;
    return dir;
  }

  Future<File> _offlineFile() async {
    final dir = await _getOfflineDirectory();
    return File('${dir.path}/marartu_ila_al_ula.json');
  }

  Future<void> _loadOfflineState() async {
    try {
      final file = await _offlineFile();
      if (await file.exists()) {
        setState(() => downloaded = true);
      }
    } catch (_) {}
  }

  Future<void> _saveOfflinePoem() async {
    try {
      final file = await _offlineFile();
      final data = {
        'titleArabic': 'مَرَرْتُ إِلَى الْعُلَا',
        'titleEnglish': 'I Passed Towards the Heights',
        'arabic': arabicPoem,
        'english': englishTranslation,
        'savedAt': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(data));
      setState(() => downloaded = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poem saved for offline reading.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save poem: $e')),
        );
      }
    }
  }

  Future<void> _removeOfflinePoem() async {
    try {
      final file = await _offlineFile();
      if (await file.exists()) {
        await file.delete();
      }
      setState(() => downloaded = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poem removed from offline reading.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove poem: $e')),
        );
      }
    }
  }

  Future<void> _toggleOfflinePoem() async {
    if (downloaded) {
      await _removeOfflinePoem();
    } else {
      await _saveOfflinePoem();
    }
  }

  Future<void> _openOfflinePoem() async {
    try {
      final file = await _offlineFile();
      if (!await file.exists()) return;
      final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfflinePoemPage(
            titleArabic: data['titleArabic'] as String? ?? '',
            titleEnglish: data['titleEnglish'] as String? ?? '',
            arabic: data['arabic'] as String? ?? '',
            english: data['english'] as String? ?? '',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open offline poem: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        foregroundColor: ink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text('قصيدة', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('Poem', style: TextStyle(fontSize: 11)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          children: [
            _poemHeader(),
            const SizedBox(height: 14),
            _actionBar(),
            const SizedBox(height: 18),
            _arabicCard(),
            const SizedBox(height: 14),
            _translationCard(),
            const SizedBox(height: 18),
            _audioProgress(),
            const SizedBox(height: 12),
            _bottomActions(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: downloaded ? _openOfflinePoem : null,
              icon: const Icon(Icons.offline_pin_rounded),
              label: const Text('Open Saved Offline Poem'),
              style: OutlinedButton.styleFrom(
                foregroundColor: green,
                side: const BorderSide(color: gold),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _poemHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [deepGreen, Color(0xFF31533F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.feather_rounded, color: gold, size: 38),
          const SizedBox(height: 8),
          const Text(
            'مَرَرْتُ إِلَى الْعُلَا',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'عبد القادر البشاري',
            style: TextStyle(color: gold, fontSize: 14),
          ),
          const SizedBox(height: 3),
          const Text(
            'ABDUL QADIR AL BASHAARIY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBar() {
    return Row(
      children: [
        Expanded(
          child: _smallAction(
            icon: favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: favorite ? 'Saved' : 'Favorite',
            color: favorite ? Colors.redAccent : green,
            onTap: () => setState(() => favorite = !favorite),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _smallAction(
            icon: Icons.share_outlined,
            label: 'Share',
            color: green,
            onTap: _share,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _smallAction(
            icon: downloaded ? Icons.download_done_rounded : Icons.download_rounded,
            label: downloaded ? 'Saved' : 'Download',
            color: downloaded ? gold : green,
            onTap: _toggleOfflinePoem,
          ),
        ),
      ],
    );
  }

  Widget _smallAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
          child: Column(
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 9, color: ink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arabicCard() {
    return _contentCard(
      titleAr: 'النص العربي',
      titleEn: 'Arabic Text',
      child: Text(
        arabicPoem,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: ink,
          fontSize: 22,
          height: 2.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _translationCard() {
    return _contentCard(
      titleAr: 'الترجمة الإنجليزية',
      titleEn: 'English Translation',
      child: Text(
        englishTranslation,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: ink,
          fontSize: 16,
          height: 1.65,
        ),
      ),
    );
  }

  Widget _contentCard({
    required String titleAr,
    required String titleEn,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1D3B5)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: gold, size: 17),
              const SizedBox(width: 7),
              Text(
                titleAr,
                style: const TextStyle(
                  color: green,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                titleEn,
                style: TextStyle(color: ink.withOpacity(.55), fontSize: 10),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE5D9C2)),
          child,
        ],
      ),
    );
  }

  Widget _audioProgress() {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.toDouble().clamp(0.0, max > 0 ? max : 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1D3B5)),
      ),
      child: Column(
        children: [
          Slider(
            value: value,
            min: 0,
            max: max > 0 ? max : 1,
            activeColor: gold,
            inactiveColor: const Color(0xFFE1D3B5),
            onChanged: max <= 0
                ? null
                : (v) => player.seek(Duration(milliseconds: v.round())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
    class _PoemPageState extends State<PoemPage> {
        final AudioPlayer audioPlayer = AudioPlayer();
          Duration position = Duration.zero;
            Duration duration = Duration.zero;
              bool isPlaying = false;

                @override
                  void initState() {
                      super.initState();
                          _initAudio();
                            }

                              void _initAudio() {
                                  audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
                                      audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
                                          audioPlayer.onPlayerStateChanged.listen((s) => setState(() => isPlaying = s == PlayerState.playing));
                                            }
    }   
 }   
                                                  audioPlayer.onPlayerStateChanged.listen((s) => setState(() => isPlaying = s == PlayerState.playing));
                                                      
                                                          // keep your other init code here
                                                            }
          }    ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _bottomActions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: deepGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _toggleAudio,
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: deepGreen,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(playing ? 'Pause Audio' : 'Listen to Poem'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Download',
            onPressed: _toggleOfflinePoem,
            icon: Icon(
              downloaded ? Icons.download_done_rounded : Icons.download_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            tooltip: 'Favorite',
            onPressed: () => setState(() => favorite = !favorite),
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: favorite ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    const title = 'مَرَرْتُ إِلَى الْعُلَا';
    const authorAr = 'عبد القادر البشاري';
    const authorEn = 'ABDUL QADIR AL BASHAARIY';

    final shareText = '''
━━━━━━━━━━━━━━━━━━━━
        AL BASHAARIY
━━━━━━━━━━━━━━━━━━━━

📜 $title

✍️ $authorAr
   $authorEn

العربية:
$arabicPoem

🇬🇧 English Translation:
$englishTranslation

━━━━━━━━━━━━━━━━━━━━
📚 AL BASHAARIY — Arabic Library
Read • Save • Share
━━━━━━━━━━━━━━━━━━━━
''';

    await Share.share(
      shareText.trim(),
      subject: 'AL BASHAARIY | $title',
    );
  
  Future<void> _toggleAudio() async {
    try {
      if (playing) {
        await Audio player.pause();
        setState(() => playing = false);
        return;
      }

      await Audio player.play(AssetSource('poem_audio.wav'));
      setState(() => isplaying = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio could not start: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int navIndex = 0;
  bool english = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _hero(context)),
            SliverToBoxAdapter(child: _sectionCards(context)),
            SliverToBoxAdapter(child: _todaysPicks(context)),
            SliverToBoxAdapter(child: _categories(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [deepGreen, Color(0xFF0E3B2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu_rounded, color: gold, size: 30),
              ),
              const Spacer(),
              Column(
                children: const [
                  Text(
                    'البشاري',
                    style: TextStyle(
                      color: gold,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'AL BASHAARIY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded,
                    color: gold, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Icon(Icons.auto_stories_rounded, color: gold, size: 34),
          const SizedBox(height: 2),
          Text(
            english ? 'Your Comprehensive Arabic Library' : 'مكتبتك العربية الشاملة',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(28),
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: ink),
                hintText: english
                    ? 'Search for a book, poem, story, quote...'
                    : 'ابحث عن كتاب، قصيدة، قصة، اقتباس...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune_rounded, color: green),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => english = !english),
              icon: const Icon(Icons.language_rounded, color: gold, size: 19),
              label: Text(
                english ? 'العربية' : 'English',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 4),
      child: Row(
        children: [
          Expanded(
            child: _mainCard(
              titleAr: 'البشاري',
              titleEn: 'AL BASHAARIY',
              subtitle: english ? 'My Content' : 'محتواي الخاص',
              icon: Icons.edit_note_rounded,
              dark: true,
              items: ['Poems', 'Quotes', 'Stories', 'Books'],
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _mainCard(
              titleAr: 'المكتبة العربية',
              titleEn: 'ARABIC LIBRARY',
              subtitle: english ? 'Explore the Library' : 'استكشف المكتبة',
              icon: Icons.menu_book_rounded,
              dark: false,
              items: ['Poems', 'Books', 'Stories', 'Islamic'],
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainCard({
    required String titleAr,
    required String titleEn,
    required String subtitle,
    required IconData icon,
    required bool dark,
    required List<String> items,
    required VoidCallback onTap,
  }) {
    final bg = dark ? deepGreen : const Color(0xFFFFFCF4);
    final fg = dark ? Colors.white : ink;
    final accent = dark ? gold : green;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? gold : const Color(0xFFD8C89E)),
        boxShadow: const [
          BoxShadow(blurRadius: 12, offset: Offset(0, 5), color: Color(0x14000000))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 38),
          const SizedBox(height: 6),
          Text(titleAr,
              textAlign: TextAlign.center,
              style: TextStyle(color: accent, fontSize: 21, fontWeight: FontWeight.w700)),
          Text(titleEn,
              textAlign: TextAlign.center,
              style: TextStyle(color: fg, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: dark ? Colors.white70 : ink.withOpacity(.7), fontSize: 12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: items.map((e) => _miniPill(e, accent, fg)).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: dark ? deepGreen : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(english ? 'Explore' : 'استكشف'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPill(String label, Color accent, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withOpacity(.55)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 9)),
    );
  }

  Widget _todaysPicks(BuildContext context) {
    final picks = [
      ('قصيدة اليوم', 'Poem of the Day', Icons.feather_rounded, 'مَرَرْتُ إِلَى الْعُلَا'),
      ('كتاب اليوم', 'Book of the Day', Icons.menu_book_rounded, 'أدب الدنيا والدين'),
      ('اقتباس اليوم', 'Quote of the Day', Icons.format_quote_rounded, 'العلم يبني بيوتاً...'),
      ('قصة اليوم', 'Story of the Day', Icons.auto_stories_rounded, 'قصة الرجل الصادق'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading('مختارات اليوم', "Today's Picks"),
          const SizedBox(height: 10),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: picks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final p = picks[i];
                final openPoem = i == 0;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: openPoem
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PoemPage()),
                          )
                      : null,
                  child: Container(
                  width: 190,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: i.isEven ? deepGreen : const Color(0xFF314735),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(p.$3, color: gold, size: 28),
                      const Spacer(),
                      Text(p.$1, style: const TextStyle(color: gold, fontSize: 13)),
                      Text(p.$2, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(height: 8),
                      Text(p.$4,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 6),
                      Text(english ? 'Read now  ›' : 'اقرأ الآن  ›',
                          style: const TextStyle(color: gold, fontSize: 11)),
                    ],
                  ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categories(BuildContext context) {
    final cats = [
      ('قصائد', 'Poems', Icons.feather_rounded),
      ('اقتباسات', 'Quotes', Icons.format_quote_rounded),
      ('قصص', 'Stories', Icons.auto_stories_rounded),
      ('كتب', 'Books', Icons.library_books_rounded),
      ('إسلامية', 'Islamic', Icons.mosque_rounded),
      ('لغة عربية', 'Arabic', Icons.translate_rounded),
      ('أدب', 'Literature', Icons.menu_book_rounded),
      ('تاريخ', 'History', Icons.history_edu_rounded),
      ('تعليمية', 'Education', Icons.school_rounded),
      ('المزيد', 'More', Icons.grid_view_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
      child: Column(
        children: [
          _heading('التصنيفات', 'Categories'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 7,
              mainAxisSpacing: 8,
              childAspectRatio: .78,
            ),
            itemBuilder: (_, i) {
              final c = cats[i];
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE1D3B5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c.$3, color: green, size: 25),
                      const SizedBox(height: 4),
                      Text(c.$1, textAlign: TextAlign.center,
                          style: const TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w600)),
                      Text(c.$2, textAlign: TextAlign.center,
                          style: const TextStyle(color: ink, fontSize: 8)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _heading(String ar, String en) {
    return Row(
      children: [
        Expanded(child: Divider(color: gold.withOpacity(.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(ar, style: const TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(en, style: const TextStyle(color: ink, fontSize: 10, letterSpacing: .8)),
            ],
          ),
        ),
        Expanded(child: Divider(color: gold.withOpacity(.5))),
      ],
    );
  }

  Widget _bottomNav() {
    final items = [
      (Icons.home_rounded, 'الرئيسية', 'Home'),
      (Icons.search_rounded, 'بحث', 'Search'),
      (Icons.bookmark_rounded, 'المفضلة', 'Favorites'),
      (Icons.download_rounded, 'التنزيلات', 'Downloads'),
      (Icons.person_rounded, 'الحساب', 'Profile'),
    ];

    return NavigationBar(
      selectedIndex: navIndex,
      onDestinationSelected: (i) => setState(() => navIndex = i),
      backgroundColor: deepGreen,
      indicatorColor: gold.withOpacity(.18),
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 9, color: Colors.white),
      ),
      destinations: items.map((e) => NavigationDestination(
        icon: Icon(e.$1, color: Colors.white70),
        selectedIcon: Icon(e.$1, color: gold),
        label: english ? e.$3 : e.$2,
      )).toList(),
    );
  }
}
