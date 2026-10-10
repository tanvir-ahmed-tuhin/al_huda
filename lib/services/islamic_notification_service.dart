import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/islamic_special_day_model.dart';
import 'islamic_events_service.dart';
import 'prayer_service.dart';
import 'storage_service.dart';

class IslamicNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Storage Keys
  static const String keyNotificationsEnabled = 'islamic_notif_enabled';
  static const String keyNotify3DaysBefore = 'islamic_notif_3_days';
  static const String keyNotify1DayBefore = 'islamic_notif_1_day';
  static const String keyNotifyOnDayMorning = 'islamic_notif_morning';
  static const String keyNotifyOnDayEvening = 'islamic_notif_evening';
  static const String keyEventPrefix = 'islamic_notif_event_';

  /// Initialize notifications safely
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      // Create notification channel for Android
      if (!kIsWeb && Platform.isAndroid) {
        final androidPlatform = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlatform != null) {
          await androidPlatform.requestNotificationsPermission();
          await androidPlatform.createNotificationChannel(
            const AndroidNotificationChannel(
              'islamic_special_days_channel',
              'ইসলামিক বিশেষ দিন ও আমল',
              description: 'আসন্ন ইসলামিক বিশেষ দিন ও বিশেষ আমল সংক্রান্ত অগ্রিম নোটিফিকেশন',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );
        }
      }

      _isInitialized = true;

      // Reschedule all active reminders
      await scheduleAllReminders();
    } catch (e) {
      debugPrint('Error initializing IslamicNotificationService: $e');
    }
  }

  // Preference getters and setters
  static bool get areNotificationsEnabled {
    return StorageService.getBool(keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await StorageService.setBool(keyNotificationsEnabled, value);
    if (value) {
      await scheduleAllReminders();
    } else {
      await cancelAllNotifications();
    }
  }

  static bool get notify3DaysBefore {
    return StorageService.getBool(keyNotify3DaysBefore) ?? true;
  }

  static Future<void> setNotify3DaysBefore(bool value) async {
    await StorageService.setBool(keyNotify3DaysBefore, value);
    await scheduleAllReminders();
  }

  static bool get notify1DayBefore {
    return StorageService.getBool(keyNotify1DayBefore) ?? true;
  }

  static Future<void> setNotify1DayBefore(bool value) async {
    await StorageService.setBool(keyNotify1DayBefore, value);
    await scheduleAllReminders();
  }

  static bool get notifyOnDayMorning {
    return StorageService.getBool(keyNotifyOnDayMorning) ?? true;
  }

  static Future<void> setNotifyOnDayMorning(bool value) async {
    await StorageService.setBool(keyNotifyOnDayMorning, value);
    await scheduleAllReminders();
  }

  static bool isEventEnabled(String eventId) {
    return StorageService.getBool('$keyEventPrefix$eventId') ?? true;
  }

  static Future<void> setEventEnabled(String eventId, bool enabled) async {
    await StorageService.setBool('$keyEventPrefix$eventId', enabled);
    await scheduleAllReminders();
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Schedule advance reminders for upcoming Islamic events
  static Future<void> scheduleAllReminders() async {
    if (!areNotificationsEnabled) return;

    try {
      await cancelAllNotifications();

      final now = DateTime.now();
      final upcomingEvents = IslamicEventsService.getAllUpcomingEvents(fromDate: now);

      int notifIdCounter = 1000;

      for (final item in upcomingEvents) {
        final event = item.event;
        if (!isEventEnabled(event.id)) continue;

        final target = item.targetDate;

        // 1. Advance notification (3 days before at 9:00 AM)
        if (notify3DaysBefore) {
          final notifyTime3Days = DateTime(target.year, target.month, target.day - 3, 9, 0);
          if (notifyTime3Days.isAfter(now)) {
            await _scheduleSingleNotification(
              id: notifIdCounter++,
              scheduledDate: notifyTime3Days,
              title: 'আসন্ন বরকতময় দিন: ${event.title}',
              body: 'আর মাত্র ৩ দিন বাকি! জানুন এই দিনের তাৎপর্য ও বিশেষ কী কী আমল করতে হবে।',
              payload: event.id,
            );
          }
        }

        // 2. 1 day before (at 6:00 PM / Maghrib advance)
        if (notify1DayBefore) {
          final notifyTime1Day = DateTime(target.year, target.month, target.day - 1, 18, 0);
          if (notifyTime1Day.isAfter(now)) {
            await _scheduleSingleNotification(
              id: notifIdCounter++,
              scheduledDate: notifyTime1Day,
              title: 'আগামীকাল ${event.title}',
              body: 'মাগরিবের পর থেকেই শুরু হচ্ছে পবিত্র রজনী। এখনই বিশেষ দোয়া ও আমলনামা দেখে নিন।',
              payload: event.id,
            );
          }
        }

        // 3. On the day morning (at 6:30 AM)
        if (notifyOnDayMorning) {
          final notifyTimeMorning = DateTime(target.year, target.month, target.day, 6, 30);
          if (notifyTimeMorning.isAfter(now)) {
            await _scheduleSingleNotification(
              id: notifIdCounter++,
              scheduledDate: notifyTimeMorning,
              title: 'আজকের মোবারক দিন: ${event.title}',
              body: 'আজকের বিশেষ আমল, নফল সালাত, তসবিহ ও দোয়াগুলো সম্পন্ন করে অশেষ নেকি অর্জন করুন।',
              payload: event.id,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
    }
  }

  static Future<void> _scheduleSingleNotification({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'islamic_special_days_channel',
        'ইসলামিক বিশেষ দিন ও আমল',
        channelDescription: 'আসন্ন ইসলামিক বিশেষ দিন ও বিশেষ আমল সংক্রান্ত অগ্রিম নোটিফিকেশন',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Could not schedule notification ($id): $e');
    }
  }

  /// Send instant test notification to show the user how it works
  static Future<void> sendInstantTestNotification({
    IslamicSpecialDayModel? event,
  }) async {
    try {
      final sample = event ?? IslamicEventsService.specialDays[0]; // Shab-e-Qadr

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'islamic_special_days_channel',
        'ইসলামিক বিশেষ দিন ও আমল',
        channelDescription: 'আসন্ন ইসলামিক বিশেষ দিন ও বিশেষ আমল সংক্রান্ত অগ্রিম নোটিফিকেশন',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id: 999,
        title: 'আসন্ন বিশেষ দিন: ${sample.title}',
        body: 'আর মাত্র কয়েক দিন বাকি! মহিমান্বিত এই দিনের বিশেষ আমল, দোয়া ও ফজিলত অ্যাপে যুক্ত রয়েছে।',
        notificationDetails: platformDetails,
        payload: sample.id,
      );
    } catch (e) {
      debugPrint('Instant test notification error: $e');
    }
  }

  /// Formats advance alert message for in-app banners
  static String getAdvanceAlertBannerText(UpcomingEventResult result) {
    if (result.isToday) {
      return 'আজ ${result.event.title}! বিশেষ আমলসমূহ এখনই দেখে নিন →';
    } else if (result.isTomorrow) {
      return 'আগামীকাল ${result.event.title}! বিশেষ আমলের প্রস্তুতি নিন →';
    } else {
      return 'আসন্ন বরকতময় দিন: ${result.event.title} • আর ${PrayerService.toBanglaDigits(result.daysRemaining.toString())} দিন বাকি! বিশেষ আমল জানুন →';
    }
  }
}
