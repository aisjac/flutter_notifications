import 'package:flutter/material.dart';

import 'noti_service.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF667eea)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                MediaQuery
                    .of(context)
                    .size
                    .height -
                    MediaQuery
                        .of(context)
                        .padding
                        .top -
                    MediaQuery
                        .of(context)
                        .padding
                        .bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Bar Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your notification preferences',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Standard Notification Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                            child: Text(
                              "Standard Notifications",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ),
                          // Immediate Notification Card
                          _buildNotificationCard(
                            context: context,
                            title: 'Immediate Notification',
                            description: 'Send a notification right away',
                            icon: Icons.notifications_active,
                            gradientColors: const [
                              Color(0xFFf093fb),
                              Color(0xFFf5576c),
                            ],
                            onPressed: () {
                              NotiService().showNotification(
                                title: "Instant Alert! 🔔",
                                body:
                                "Your notification has been sent successfully",
                              );

                              // Show feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Notification sent!'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Scheduled Notification Card
                          _buildNotificationCard(
                            context: context,
                            title: 'Scheduled Notification',
                            description:
                            'Choose a time to schedule notification',
                            icon: Icons.schedule,
                            gradientColors: const [
                              Color(0xFF4facfe),
                              Color(0xFF00f2fe),
                            ],
                            onPressed: () => _showTimePicker(context, false),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Full Screen Notification Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                            child: Text(
                              "Full Screen Notifications",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                          ),
                          // Immediate Full Screen Notification Card
                          _buildNotificationCard(
                            context: context,
                            title: 'Immediate Full Screen',
                            description: 'Send a full screen notification now',
                            icon: Icons.fullscreen,
                            gradientColors: const [
                              Color(0xFFFF6B6B),
                              Color(0xFFFF8E53),
                            ],
                            onPressed: () {
                              NotiService().showFullScreenNotification(
                                title: "Full Screen Alert! 📱",
                                body: "This is an important full screen notification",
                              );

                              // Show feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Full screen notification sent!'),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Scheduled Full Screen Notification Card
                          _buildNotificationCard(
                            context: context,
                            title: 'Scheduled Full Screen',
                            description: 'Schedule a full screen notification',
                            icon: Icons.schedule_outlined,
                            gradientColors: const [
                              Color(0xFF11998e),
                              Color(0xFF38ef7d),
                            ],
                            onPressed: () => _showTimePicker(context, true),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, bool isFullScreen) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2d3748),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // Create DateTime from picked time
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Schedule the notification (regular or full screen)
      if (isFullScreen) {
        NotiService().scheduleFullScreenNotification(
          title: "Important Full Screen Alert ⏰",
          body: "This full screen notification was scheduled for ${pickedTime.format(context)}",
          scheduledDateTime: scheduledDateTime,
        );
      } else {
        NotiService().scheduleNotification(
          title: "Scheduled Reminder ⏰",
          body: "This notification was scheduled for ${pickedTime.format(context)}",
          scheduledDateTime: scheduledDateTime,
        );
      }

      // Determine if it's today or tomorrow
      final isToday = scheduledDateTime.isAfter(now);
      final dayText = isToday ? 'today' : 'tomorrow';

      // Show feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFullScreen
                  ? 'Full screen notification scheduled for ${pickedTime.format(context)} $dayText'
                  : 'Notification scheduled for ${pickedTime.format(context)} $dayText',
            ),
            backgroundColor: isFullScreen ? Colors.orange : Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2d3748),
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Send Notification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}