import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskService {
  static const String _keyTasks = 'daily_tasks_data';
  static const String _keyLastTaskDate = 'last_task_date';

  static final List<TaskItem> defaultTasks = [
    const TaskItem(id: 'fajr', title: 'ফজরের নামাজ জামাতে আদায়', category: 'নামাজ', points: 20),
    const TaskItem(id: 'dhuhr', title: 'যোহরের নামাজ সময়মতো আদায়', category: 'নামাজ', points: 15),
    const TaskItem(id: 'asr', title: 'আসরের নামাজ সময়মতো আদায়', category: 'নামাজ', points: 15),
    const TaskItem(id: 'maghrib', title: 'মাগরিবের নামাজ আদায়', category: 'নামাজ', points: 15),
    const TaskItem(id: 'isha', title: 'ইশার নামাজ ও বিতর আদায়', category: 'নামাজ', points: 15),
    const TaskItem(id: 'quran_read', title: 'কমপক্ষে ১ পৃষ্ঠা কুরআন তিলাওয়াত', category: 'কুরআন', points: 20),
    const TaskItem(id: 'surah_mulk', title: 'রাতে সূরা আল-মুলক তিলাওয়াত', category: 'কুরআন', points: 25),
    const TaskItem(id: 'morning_dhikr', title: 'সকালের মাসনূন দোয়া ও জিকির', category: 'যিকির', points: 15),
    const TaskItem(id: 'evening_dhikr', title: 'সন্ধ্যার মাসনূন দোয়া ও জিকির', category: 'যিকির', points: 15),
    const TaskItem(id: 'istighfar_100', title: '১০০ বার আস্তাগফিরুল্লাহ পাঠ', category: 'যিকির', points: 15),
    const TaskItem(id: 'sadaqah', title: 'সদকা বা কাউকে সাহায্য করা', category: 'নেক আমল', points: 20),
  ];

  static Future<List<TaskItem>> loadTodayTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    final lastSavedDate = prefs.getString(_keyLastTaskDate);

    // If date changed, reset tasks
    if (lastSavedDate != todayStr) {
      await prefs.setString(_keyLastTaskDate, todayStr);
      final tasksJson = defaultTasks.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_keyTasks, tasksJson);
      return defaultTasks;
    }

    final rawList = prefs.getStringList(_keyTasks);
    if (rawList == null || rawList.isEmpty) {
      final tasksJson = defaultTasks.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_keyTasks, tasksJson);
      return defaultTasks;
    }

    return rawList.map((str) => TaskItem.fromJson(jsonDecode(str))).toList();
  }

  static Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDateString();
    await prefs.setString(_keyLastTaskDate, todayStr);
    final tasksJson = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_keyTasks, tasksJson);
  }

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
