import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class DhikrPreset {
  final String arabic;
  final String banglaPronunciation;
  final String banglaMeaning;
  final int defaultTarget;

  const DhikrPreset({
    required this.arabic,
    required this.banglaPronunciation,
    required this.banglaMeaning,
    this.defaultTarget = 33,
  });
}

class TasbihProvider extends ChangeNotifier {
  static final List<DhikrPreset> presets = [
    const DhikrPreset(
      arabic: 'سُبْحَانَ اللَّهِ',
      banglaPronunciation: 'সুবহানাল্লাহ',
      banglaMeaning: 'আল্লাহ অতি পবিত্র ও মহান।',
      defaultTarget: 33,
    ),
    const DhikrPreset(
      arabic: 'الْحَمْدُ لِلَّهِ',
      banglaPronunciation: 'আলহামদুলিল্লাহ',
      banglaMeaning: 'সমস্ত প্রশংসা একমাত্র আল্লাহর জন্য।',
      defaultTarget: 33,
    ),
    const DhikrPreset(
      arabic: 'اللَّهُ أَكْبَرُ',
      banglaPronunciation: 'আল্লাহু আকবার',
      banglaMeaning: 'আল্লাহ সর্বশ্রেষ্ঠ।',
      defaultTarget: 34,
    ),
    const DhikrPreset(
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      banglaPronunciation: 'লা ইলাহা ইল্লাল্লাহ',
      banglaMeaning: 'আল্লাহ ছাড়া কোনো সত্য উপাস্য নেই।',
      defaultTarget: 100,
    ),
    const DhikrPreset(
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      banglaPronunciation: 'আস্তাগফিরুল্লাহ',
      banglaMeaning: 'আমি আল্লাহর নিকট ক্ষমা প্রার্থনা করছি।',
      defaultTarget: 100,
    ),
    const DhikrPreset(
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      banglaPronunciation: 'আল্লাহুম্মা সাল্লি আলা মুহাম্মাদ',
      banglaMeaning: 'হে আল্লাহ! মুহাম্মাদ (সা.)-এর উপর শান্তি বর্ষণ করুন।',
      defaultTarget: 100,
    ),
    const DhikrPreset(
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      banglaPronunciation: 'লা হাওলা ওয়ালা কুওয়াতা ইল্লা বিল্লাহ',
      banglaMeaning: 'আল্লাহর সাহায্য ছাড়া কোনো উপায় বা শক্তি নেই।',
      defaultTarget: 100,
    ),
    const DhikrPreset(
      arabic: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      banglaPronunciation: 'হাসবুনাল্লাহু ওয়া নিমাল ওয়াকিল',
      banglaMeaning: 'আল্লাহই আমাদের জন্য যথেষ্ট, তিনি কতই না উত্তম অভিভাবক।',
      defaultTarget: 100,
    ),
  ];

  int _count = 0;
  int _target = 33;
  int _totalCount = 0;
  int _selectedPresetIndex = 0;
  bool _vibrationEnabled = true;

  int get count => _count;
  int get target => _target;
  int get totalCount => _totalCount;
  int get selectedPresetIndex => _selectedPresetIndex;
  DhikrPreset get currentPreset => presets[_selectedPresetIndex];
  bool get vibrationEnabled => _vibrationEnabled;
  double get progress => _target > 0 ? (_count / _target).clamp(0.0, 1.0) : 0.0;

  TasbihProvider() {
    _init();
  }

  Future<void> _init() async {
    _count = StorageService.getTasbihCount();
    _target = StorageService.getTasbihTarget();
    _totalCount = _count;
    notifyListeners();
  }

  void increment() {
    _count++;
    _totalCount++;

    if (_vibrationEnabled) {
      if (_count == _target) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    if (_count > _target && _target > 0) {
      _count = 1;
    }

    StorageService.saveTasbihState(_count, _target);
    notifyListeners();
  }

  void reset() {
    _count = 0;
    StorageService.saveTasbihState(_count, _target);
    notifyListeners();
  }

  void selectPreset(int index) {
    if (index >= 0 && index < presets.length) {
      _selectedPresetIndex = index;
      _target = presets[index].defaultTarget;
      _count = 0;
      StorageService.saveTasbihState(_count, _target);
      notifyListeners();
    }
  }

  void setTarget(int newTarget) {
    _target = newTarget;
    StorageService.saveTasbihState(_count, _target);
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }

  void addCustomDhikr(String title, String arabic, {int target = 100}) {
    final existingIndex = presets.indexWhere((p) => p.arabic == arabic);
    if (existingIndex >= 0) {
      selectPreset(existingIndex);
      return;
    }

    presets.add(
      DhikrPreset(
        arabic: arabic,
        banglaPronunciation: title,
        banglaMeaning: title,
        defaultTarget: target,
      ),
    );
    selectPreset(presets.length - 1);
  }
}
