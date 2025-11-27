import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_notifications/setting_screen.dart';
import 'package:flutter_notifications/noti_service.dart';

// Global variable to store the latest notification data
class NotificationData {
  static String? title;
  static String? body;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String? notificationTitle;
  String? notificationBody;
  late final NotiService _notiService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notiService = NotiService();

    // Check if we have notification data
    _updateNotificationData();

    // Add listener for notification data changes
    _setupNotificationListener();
  }

  void _updateNotificationData() {
    setState(() {
      notificationTitle = NotificationData.title;
      notificationBody = NotificationData.body;
    });
  }

  void _setupNotificationListener() {
    // This is a simple polling approach - a better solution would be to use streams
    // but we'll keep it simple for now
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final newTitle = NotificationData.title;
        final newBody = NotificationData.body;

        if (newTitle != notificationTitle || newBody != notificationBody) {
          _updateNotificationData();
        }

        _setupNotificationListener();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - check for notification data
      _updateNotificationData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mosque Background with Blur
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mosque.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar with Settings Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prayer Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 5.0,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Notification Content Card
                  if (notificationTitle != null || notificationBody != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 32.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notification Icon and Title
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    notificationTitle ?? 'Notification',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Notification Message
                            Text(
                              notificationBody ?? 'No notification message',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Dismiss Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Cancel all scheduled notifications
                                  await _notiService.cancelAllNotification();

                                  // Clear notification data
                                  setState(() {
                                    notificationTitle = null;
                                    notificationBody = null;
                                    NotificationData.title = null;
                                    NotificationData.body = null;
                                  });

                                  // Show feedback to user
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('All notifications cleared'),
                                        backgroundColor: Colors.deepPurple,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Dismiss'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 32.0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none, size: 48, color: Colors.deepPurple),
                            SizedBox(height: 16),
                            Text(
                              'No active notifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your important notifications will appear here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
