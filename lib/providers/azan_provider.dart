import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/azan_voice_model.dart';
import '../models/prayer_time_model.dart';
import '../services/azan_service.dart';
import '../services/prayer_service.dart';
import '../services/qibla_service.dart';
import '../services/storage_service.dart';

class AzanProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _checkTimer;

  bool _isMasterEnabled = true;
  AzanVoiceModel _selectedVoice = AzanService.azanVoices[0];
  bool _useFajrSpecial = true;
  final Map<String, bool> _prayerAzanEnabled = {
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };
  double _volume = 1.0;

  // Audio Playback State
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _playingVoiceId;
  PrayerName? _activePrayer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Tracking to prevent duplicate triggers on the same prayer on the same day
  String? _lastTriggeredKey;

  // Global navigator key to show alert dialog when azan starts
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Getters
  bool get isMasterEnabled => _isMasterEnabled;
  AzanVoiceModel get selectedVoice => _selectedVoice;
  bool get useFajrSpecial => _useFajrSpecial;
  Map<String, bool> get prayerAzanEnabled => _prayerAzanEnabled;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get playingVoiceId => _playingVoiceId;
  PrayerName? get activePrayer => _activePrayer;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  AzanProvider() {
    _init();
  }

  Future<void> _init() async {
    _isMasterEnabled = StorageService.isAzanMasterEnabled();
    final voiceId = StorageService.getSelectedAzanVoiceId();
    _selectedVoice = AzanService.getVoiceById(voiceId);
    _useFajrSpecial = StorageService.getUseFajrSpecial();
    _volume = StorageService.getAzanVolume();

    for (final p in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      _prayerAzanEnabled[p] = StorageService.isPrayerAzanEnabled(p);
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _isPlaying = false;
        _isLoading = false;
        _playingVoiceId = null;
        _activePrayer = null;
        _currentPosition = Duration.zero;
      }
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      _totalDuration = dur;
      notifyListeners();
    });

    // Autonomous prayer check every 15 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      try {
        final cityIndex = StorageService.getSelectedCityIndex();
        final city = (cityIndex >= 0 && cityIndex < QiblaService.defaultCities.length)
            ? QiblaService.defaultCities[cityIndex]
            : QiblaService.defaultCities[0];
        final pt = PrayerService.calculatePrayerTimes(
          latitude: city.latitude,
          longitude: city.longitude,
          locationName: city.nameBangla,
        );
        checkPrayerTimeTrigger(pt);
      } catch (_) {}
    });
  }

  // Settings modification
  Future<void> setMasterEnabled(bool enabled) async {
    _isMasterEnabled = enabled;
    await StorageService.saveAzanMasterEnabled(enabled);
    if (!enabled && _isPlaying) {
      await stopAzan();
    }
    notifyListeners();
  }

  Future<void> selectVoice(AzanVoiceModel voice) async {
    _selectedVoice = voice;
    await StorageService.saveSelectedAzanVoiceId(voice.id);
    notifyListeners();
  }

  Future<void> setUseFajrSpecial(bool val) async {
    _useFajrSpecial = val;
    await StorageService.saveUseFajrSpecial(val);
    notifyListeners();
  }

  Future<void> setPrayerAzanEnabled(String prayerName, bool enabled) async {
    _prayerAzanEnabled[prayerName] = enabled;
    await StorageService.savePrayerAzanEnabled(prayerName, enabled);
    notifyListeners();
  }

  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    await StorageService.saveAzanVolume(_volume);
    notifyListeners();
  }

  /// Play or pause a preview of an Azan voice in the voice picker
  Future<void> toggleVoicePreview(AzanVoiceModel voice) async {
    if (_isPlaying && _playingVoiceId == voice.id) {
      await stopAzan();
      return;
    }

    try {
      _isLoading = true;
      _playingVoiceId = voice.id;
      _activePrayer = null;
      notifyListeners();

      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(UrlSource(voice.audioUrl));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      _playingVoiceId = null;
      notifyListeners();
    }
  }

  /// Trigger Azan for a specific prayer (e.g. Fajr, Dhuhr)
  Future<void> triggerAzanForPrayer(PrayerName prayer, {bool isManualTest = false}) async {
    final prayerKey = prayer.name;
    if (!isManualTest) {
      if (!_isMasterEnabled) return;
      if (!(_prayerAzanEnabled[prayerKey] ?? true)) return;
    }

    AzanVoiceModel voiceToPlay = _selectedVoice;
    if (prayer == PrayerName.fajr && _useFajrSpecial) {
      voiceToPlay = AzanService.getFajrVoice();
    }

    try {
      _isLoading = true;
      _playingVoiceId = voiceToPlay.id;
      _activePrayer = prayer;
      notifyListeners();

      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(UrlSource(voiceToPlay.audioUrl));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      _playingVoiceId = null;
      _activePrayer = null;
      notifyListeners();
    }
  }

  /// Stop playing Azan immediately
  Future<void> stopAzan() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    _isPlaying = false;
    _isLoading = false;
    _playingVoiceId = null;
    _activePrayer = null;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  /// Periodic checker called by PrayerProvider to detect when prayer time hits
  void checkPrayerTimeTrigger(PrayerTimeModel pt) {
    if (!_isMasterEnabled) return;

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    // List of prayers with azan (excluding sunrise)
    final checkPrayers = [
      {'name': PrayerName.fajr, 'tod': pt.fajr},
      {'name': PrayerName.dhuhr, 'tod': pt.dhuhr},
      {'name': PrayerName.asr, 'tod': pt.asr},
      {'name': PrayerName.maghrib, 'tod': pt.maghrib},
      {'name': PrayerName.isha, 'tod': pt.isha},
    ];

    for (final item in checkPrayers) {
      final prayer = item['name'] as PrayerName;
      final tod = item['tod'] as TimeOfDay;

      // Check if current hour and minute match prayer time
      if (now.hour == tod.hour && now.minute == tod.minute) {
        final triggerKey = '${todayStr}_${prayer.name}';
        if (_lastTriggeredKey != triggerKey) {
          _lastTriggeredKey = triggerKey;
          // Trigger the azan audio playback
          triggerAzanForPrayer(prayer);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
