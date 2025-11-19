import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_pills_form.dart';
import 'pills_provider.dart';

class MedicationDetailScreen extends StatelessWidget {
  final PillData medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextAlarm = medication.getNextAlarmTime();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit_medication',
                arguments: medication,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.medication, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${medication.amount} ${medication.type}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details
            _buildDetailItem(context, Icons.access_time, 'Time',
                '${medication.time.hour.toString().padLeft(2, '0')}:${medication.time.minute.toString().padLeft(2, '0')}'),
            _buildDetailItem(context, Icons.repeat, 'Frequency',
                medication.getFrequencyDescription()),
            _buildDetailItem(context, Icons.calendar_today, 'Start Date',
                '${medication.startDate.day}/${medication.startDate.month}/${medication.startDate.year}'),
            _buildDetailItem(context, Icons.timelapse, 'Duration',
                '${medication.duration} days'),
            if (nextAlarm != null)
              _buildDetailItem(context, Icons.alarm, 'Next Reminder',
                  '${nextAlarm.day}/${nextAlarm.month} at ${nextAlarm.hour}:${nextAlarm.minute.toString().padLeft(2, '0')}'),
            
            const SizedBox(height: 32),

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Medication'),
                      content: Text(
                          'Are you sure you want to delete ${medication.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await Provider.of<PillsProvider>(context, listen: false)
                        .removePill(medication);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Medication deleted successfully')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Delete Medication', style: TextStyle(fontSize: 16)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
