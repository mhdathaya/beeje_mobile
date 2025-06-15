import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();
  List<model.Notification> notifications = [];
  bool isLoading = true;
  int currentPage = 1;
  int lastPage = 1;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  String? filterType;
  bool? filterIsRead;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (isLoading == false) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result = await _notificationService.getNotifications(
        type: filterType,
        isRead: filterIsRead,
      );

      setState(() {
        notifications = result.notifications;
        currentPage = result.currentPage;
        lastPage = result.lastPage;
        hasMoreData = result.nextPageUrl != null;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        setState(() {
          final index = notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            final updatedNotification = model.Notification(
              id: notifications[index].id,
              userId: notifications[index].userId,
              type: notifications[index].type,
              title: notifications[index].title,
              message: notifications[index].message,
              data: notifications[index].data,
              orderId: notifications[index].orderId,
              isRead: true,
              createdAt: notifications[index].createdAt,
              updatedAt: DateTime.now(),
            );
            notifications[index] = updatedNotification;
          }
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai notifikasi sebagai telah dibaca')),
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        setState(() {
          notifications = notifications.map((notification) {
            return model.Notification(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              data: notification.data,
              orderId: notification.orderId,
              isRead: true,
              createdAt: notification.createdAt,
              updatedAt: DateTime.now(),
            );
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua notifikasi telah ditandai sebagai dibaca')),
        );
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menandai semua notifikasi sebagai dibaca')),
      );
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        setState(() {
          notifications.removeWhere((n) => n.id == notificationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi berhasil dihapus')),
        );
      }
    } catch (e) {
      print('Error deleting notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus notifikasi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF6F4E37),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: notifications.isEmpty ? null : markAllAsRead,
            tooltip: 'Tandai semua sebagai dibaca',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('Tidak ada notifikasi'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
    );
  }

  Widget _buildNotificationItem(model.Notification notification) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(notification.createdAt);
    
    // Menentukan warna latar belakang berdasarkan status dibaca
    final backgroundColor = notification.isRead ? Colors.white : Colors.amber.shade50;
    
    // Menentukan ikon berdasarkan tipe notifikasi
    IconData notificationIcon;
    Color iconColor;
    
    switch (notification.type) {
      case 'order':
        notificationIcon = Icons.shopping_bag;
        iconColor = Colors.blue;
        break;
      case 'payment':
        notificationIcon = Icons.payment;
        iconColor = Colors.green;
        break;
      case 'promo':
        notificationIcon = Icons.local_offer;
        iconColor = Colors.red;
        break;
      default:
        notificationIcon = Icons.notifications;
        iconColor = Colors.orange;
    }

    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        deleteNotification(notification.id);
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            markAsRead(notification.id);
          }
          // Tambahkan navigasi ke halaman detail jika diperlukan
          // misalnya jika notifikasi terkait pesanan, navigasi ke halaman detail pesanan
        },
        child: Container(
          color: backgroundColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.2),
              child: Icon(notificationIcon, color: iconColor),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: !notification.isRead
                ? IconButton(
                    icon: const Icon(Icons.mark_email_read, color: Colors.green),
                    onPressed: () => markAsRead(notification.id),
                    tooltip: 'Tandai sebagai dibaca',
                  )
                : null,
          ),
        ),
      ),
    );
  }
}