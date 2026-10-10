import 'package:flutter/material.dart';
import '../models/islamic_special_day_model.dart';
import '../services/islamic_events_service.dart';
import '../services/islamic_notification_service.dart';
import '../services/storage_service.dart';

class IslamicEventsProvider extends ChangeNotifier {
  List<UpcomingEventResult> _upcomingEvents = [];
  String _selectedCategory = 'সকল';
  bool _isLoading = false;

  // Notification state
  bool _notificationsEnabled = true;
  bool _notify3DaysBefore = true;
  bool _notify1DayBefore = true;
  bool _notifyOnDayMorning = true;

  IslamicEventsProvider() {
    _loadData();
  }

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  List<UpcomingEventResult> get upcomingEvents => _upcomingEvents;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get notify3DaysBefore => _notify3DaysBefore;
  bool get notify1DayBefore => _notify1DayBefore;
  bool get notifyOnDayMorning => _notifyOnDayMorning;

  UpcomingEventResult? get nextMajorEvent {
    if (_upcomingEvents.isEmpty) return null;
    return _upcomingEvents.first;
  }

  List<UpcomingEventResult> get filteredEvents {
    if (_selectedCategory == 'সকল') {
      return _upcomingEvents;
    }
    return _upcomingEvents.where((e) => e.event.category == _selectedCategory).toList();
  }

  void _loadData() {
    _isLoading = true;
    _notificationsEnabled = IslamicNotificationService.areNotificationsEnabled;
    _notify3DaysBefore = IslamicNotificationService.notify3DaysBefore;
    _notify1DayBefore = IslamicNotificationService.notify1DayBefore;
    _notifyOnDayMorning = IslamicNotificationService.notifyOnDayMorning;

    refreshEvents();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void refreshEvents() {
    _upcomingEvents = IslamicEventsService.getAllUpcomingEvents();
    notifyListeners();
  }

  // Amal completion status
  String _getAmalStorageKey(String eventId, String amalId) => 'amal_${eventId}_$amalId';

  bool isAmalCompleted(String eventId, String amalId) {
    return StorageService.getBool(_getAmalStorageKey(eventId, amalId)) ?? false;
  }

  Future<void> toggleAmalCompletion(String eventId, String amalId) async {
    final key = _getAmalStorageKey(eventId, amalId);
    final current = StorageService.getBool(key) ?? false;
    await StorageService.setBool(key, !current);
    notifyListeners();
  }

  Map<String, int> getCompletionStats(IslamicSpecialDayModel event) {
    int total = event.amals.length;
    int completed = 0;
    for (final amal in event.amals) {
      if (isAmalCompleted(event.id, amal.id)) {
        completed++;
      }
    }
    return {'total': total, 'completed': completed};
  }

  // Notification settings controls
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await IslamicNotificationService.setNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> setNotify3DaysBefore(bool value) async {
    _notify3DaysBefore = value;
    await IslamicNotificationService.setNotify3DaysBefore(value);
    notifyListeners();
  }

  Future<void> setNotify1DayBefore(bool value) async {
    _notify1DayBefore = value;
    await IslamicNotificationService.setNotify1DayBefore(value);
    notifyListeners();
  }

  Future<void> setNotifyOnDayMorning(bool value) async {
    _notifyOnDayMorning = value;
    await IslamicNotificationService.setNotifyOnDayMorning(value);
    notifyListeners();
  }

  bool isEventNotificationEnabled(String eventId) {
    return IslamicNotificationService.isEventEnabled(eventId);
  }

  Future<void> toggleEventNotification(String eventId) async {
    final current = isEventNotificationEnabled(eventId);
    await IslamicNotificationService.setEventEnabled(eventId, !current);
    notifyListeners();
  }

  Future<void> sendTestNotification(IslamicSpecialDayModel? event) async {
    await IslamicNotificationService.sendInstantTestNotification(event: event);
  }
}
