import 'package:flutter/material.dart';
import 'package:cake_aide_basic/screens/reminders/add_reminder_screen.dart';
import 'package:cake_aide_basic/screens/reminders/edit_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<ReminderItem> _reminders = [
    ReminderItem(
      title: 'Order Spider-Man cake ingredients',
      description: 'Need to get red and blue food coloring, vanilla extract, and cake flour',
      time: 'Today, 10:00 AM',
      isCompleted: false,
      priority: ReminderPriority.high,
      notes: 'Check specialty baking store first',
    ),
    ReminderItem(
      title: 'Prep Barbie cake decorations',
      description: 'Create fondant figures and edible glitter decorations',
      time: 'Tomorrow, 2:00 PM',
      isCompleted: false,
      priority: ReminderPriority.medium,
      notes: 'Pink and purple color scheme',
    ),
    ReminderItem(
      title: 'Follow up with client about birthday cake',
      description: 'Confirm final design details and delivery time',
      time: 'Wed, 9:00 AM',
      isCompleted: true,
      priority: ReminderPriority.low,
      notes: 'Client prefers morning calls',
    ),
  ];

  void _updateReminder(int index, ReminderItem updatedReminder) {
    setState(() {
      _reminders[index] = updatedReminder;
    });
  }

  void _deleteReminder(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _reminders.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return ReminderCard(
                  reminder: reminder,
                  index: index,
                  onToggle: () {
                    setState(() {
                      reminder.isCompleted = !reminder.isCompleted;
                    });
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditReminderScreen(
                          reminder: reminder,
                          index: index,
                          onUpdate: _updateReminder,
                        ),
                      ),
                    );
                  },
                  onDelete: () => _deleteReminder(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReminderScreen(),
            ),
          );
          
          if (result != null && result is ReminderItem) {
            setState(() {
              _reminders.add(result);
            });
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

enum ReminderPriority { low, medium, high }

class ReminderItem {
  String title;
  String description;
  String time;
  bool isCompleted;
  ReminderPriority priority;
  String notes;

  ReminderItem({
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    required this.priority,
    required this.notes,
  });
}

class ReminderCard extends StatelessWidget {
  final ReminderItem reminder;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.index,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor() {
    switch (reminder.priority) {
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: reminder.isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: reminder.isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: reminder.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: reminder.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: reminder.isCompleted
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}