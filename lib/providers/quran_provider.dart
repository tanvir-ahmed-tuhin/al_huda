import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/surah_model.dart';
import '../services/quran_data_service.dart';
import '../services/storage_service.dart';

class QuranProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SurahSummary> _filteredSurahs = QuranDataService.surahList;
  String _searchQuery = '';
  
  SurahSummary? _currentSurah;
  List<Ayah> _currentAyahs = [];
  bool _isLoadingAyahs = false;
  
  // Audio Playback State
  int? _playingAyahIndex;
  PlayerState _playerState = PlayerState.stopped;
  bool _isAudioLoading = false;

  // Settings & Preferences
  double _arabicFontSize = 24.0;
  bool _showBangla = true;
  bool _showEnglish = false;
  List<BookmarkItem> _bookmarks = [];
  Map<String, dynamic> _lastRead = {'surahNumber': 1, 'ayahNumber': 1, 'surahNameBangla': 'আল-ফাতিহা'};

  // Getters
  List<SurahSummary> get filteredSurahs => _filteredSurahs;
  String get searchQuery => _searchQuery;
  SurahSummary? get currentSurah => _currentSurah;
  List<Ayah> get currentAyahs => _currentAyahs;
  bool get isLoadingAyahs => _isLoadingAyahs;
  int? get playingAyahIndex => _playingAyahIndex;
  PlayerState get playerState => _playerState;
  bool get isAudioLoading => _isAudioLoading;
  bool get isPlaying => _playerState == PlayerState.playing;
  double get arabicFontSize => _arabicFontSize;
  bool get showBangla => _showBangla;
  bool get showEnglish => _showEnglish;
  List<BookmarkItem> get bookmarks => _bookmarks;
  Map<String, dynamic> get lastRead => _lastRead;

  QuranProvider() {
    _init();
  }

  Future<void> _init() async {
    _arabicFontSize = StorageService.getArabicFontSize();
    _bookmarks = await StorageService.getBookmarks();
    _lastRead = StorageService.getLastRead();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _playNextAyah();
    });

    notifyListeners();
  }

  void searchSurahs(String query) {
    _searchQuery = query.trim().toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredSurahs = QuranDataService.surahList;
    } else {
      _filteredSurahs = QuranDataService.surahList.where((surah) {
        final query = _searchQuery;
        final numMatch = surah.number.toString() == query;
        final banglaMatch = surah.nameBangla.toLowerCase().contains(query);
        final englishMatch = surah.nameEnglish.toLowerCase().contains(query);
        final arabicMatch = surah.nameArabic.contains(query);
        final meaningMatch = surah.meaningBangla.toLowerCase().contains(query);
        return numMatch || banglaMatch || englishMatch || arabicMatch || meaningMatch;
      }).toList();
    }
    notifyListeners();
  }

  Future<void> loadSurah(SurahSummary surah) async {
    _currentSurah = surah;
    _isLoadingAyahs = true;
    _currentAyahs = [];
    stopAudio();
    notifyListeners();

    try {
      _currentAyahs = await QuranDataService.getSurahAyahs(surah.number);
    } catch (e) {
      // Error handling
    } finally {
      _isLoadingAyahs = false;
      notifyListeners();
    }
  }

  Future<void> setLastRead(int surahNumber, int ayahNumber, String surahNameBangla) async {
    _lastRead = {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahNameBangla': surahNameBangla,
    };
    await StorageService.saveLastRead(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      surahNameBangla: surahNameBangla,
    );
    notifyListeners();
  }

  // Audio Playback
  Future<void> playAyah(int index) async {
    if (index < 0 || index >= _currentAyahs.length) return;

    final ayah = _currentAyahs[index];
    if (ayah.audioUrl == null) return;

    if (_playingAyahIndex == index && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }

    if (_playingAyahIndex == index && _playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    _playingAyahIndex = index;
    _isAudioLoading = true;
    notifyListeners();

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(ayah.audioUrl!));
    } catch (e) {
      // Audio playback error
    } finally {
      _isAudioLoading = false;
      notifyListeners();
    }
  }

  void _playNextAyah() {
    if (_playingAyahIndex != null && _playingAyahIndex! + 1 < _currentAyahs.length) {
      playAyah(_playingAyahIndex! + 1);
    } else {
      stopAudio();
    }
  }

  Future<void> playPreviousAyah() async {
    if (_playingAyahIndex != null && _playingAyahIndex! > 0) {
      await playAyah(_playingAyahIndex! - 1);
    }
  }

  Future<void> playNextAyahManual() async {
    if (_playingAyahIndex != null && _playingAyahIndex! + 1 < _currentAyahs.length) {
      await playAyah(_playingAyahIndex! + 1);
    }
  }

  Future<void> stopAudio() async {
    _playingAyahIndex = null;
    await _audioPlayer.stop();
    notifyListeners();
  }

  // Bookmarks
  Future<void> toggleBookmark(Ayah ayah, String surahNameBangla, String surahNameArabic) async {
    final item = BookmarkItem(
      surahNumber: ayah.surahNumber,
      surahNameBangla: surahNameBangla,
      surahNameArabic: surahNameArabic,
      ayahNumber: ayah.numberInSurah,
      ayahTextArabic: ayah.textArabic,
      ayahTextBangla: ayah.translationBangla,
      savedAt: DateTime.now(),
    );

    await StorageService.toggleBookmark(item);
    _bookmarks = await StorageService.getBookmarks();
    notifyListeners();
  }

  bool isAyahBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarks.any((b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
  }

  // Settings
  void setArabicFontSize(double size) {
    _arabicFontSize = size;
    StorageService.saveArabicFontSize(size);
    notifyListeners();
  }

  void toggleBangla(bool val) {
    _showBangla = val;
    notifyListeners();
  }

  void toggleEnglish(bool val) {
    _showEnglish = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
