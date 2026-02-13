import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'NotificationDatabaseHelper.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notifications;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    _notifications = DBHelper.instance.getData();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      // Parse the datetime string
      DateTime dateTime = DateTime.parse(dateString);

      // Format the date to show date, hour, and minute
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      // Return original string if parsing fails
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notifications,
        builder: (context, snapshot) {
          print("Snapshot data: ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/no_notification.png')),
                  SizedBox(height: 20),
                  Text(
                    'No Notification Found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  )
                ],
              ),
            );
            ;
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFFF6600),
                  child: Icon(Icons.notifications),
                ),
                title: Text(notification['title'] ?? 'No Title'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification['desc'] ?? 'No Description'),
                    Text(
                      _formatDate(notification['timestamp']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          await DBHelper.instance.clearALlnotification();
          setState(() {
            _fetchNotifications();
          });
        },
        child: Text('Clear'),
      ),
    );
  }
}
