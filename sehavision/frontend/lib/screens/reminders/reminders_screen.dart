import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../../models/medicine.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      await reminderProvider.loadReminders(token: authProvider.token!);
    }
  }

  Future<void> _toggleReminder(int reminderId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      await reminderProvider.toggleReminder(reminderId, authProvider.token!);
    }
  }

  Future<void> _deleteReminder(int reminderId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      final success = await reminderProvider.deleteReminder(
        reminderId,
        authProvider.token!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التذكير بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(int reminderId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التذكير'),
        content: Text('هل أنت متأكد من أنك تريد حذف "$title"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReminder(reminderId);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.reminders),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList(reminderProvider.reminders),
          _buildRemindersList(reminderProvider.getTodaysReminders()),
          _buildRemindersList(reminderProvider.upcomingReminders),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReminderScreen(
                medicine: Medicine.empty(), // Will be handled in the screen
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemindersList(List<dynamic> reminders) {
    if (reminders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reminders found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _buildReminderCard(reminder);
        },
      ),
    );
  }

  Widget _buildReminderCard(dynamic reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              reminder.isActive ? AppTheme.primaryColor : Colors.grey,
          child: Icon(
            reminder.isActive
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          reminder.title,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null)
              Text(reminder.description!, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  reminder.timeDisplay,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  reminder.frequencyDisplay,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    reminder.isActive ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(reminder.isActive ? 'إيقاف' : 'استئناف'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.errorColor),
                  const SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                _toggleReminder(reminder.id);
                break;
              case 'delete':
                _showDeleteDialog(reminder.id, reminder.title);
                break;
            }
          },
        ),
        onTap: () {
          // TODO: Navigate to reminder detail or edit screen
        },
      ),
    );
  }
}
