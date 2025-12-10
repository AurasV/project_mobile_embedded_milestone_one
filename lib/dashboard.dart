import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_pills_form.dart';
import 'app_bottom_nav.dart';
import 'pills_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PillsProvider>(context, listen: false).listenToMedications();
    });
  }

  Future<void> _navigateToAddPills() async {
    final result = await Navigator.pushNamed(context, '/add_pills_form');
    if (result != null && result is PillData) {
      if (mounted) {
        Provider.of<PillsProvider>(context, listen: false).addPill(result);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pill added successfully!')),
        );
      }
    }
  }

  Widget _buildScheduleItem(BuildContext context, PillData pill) {
    final theme = Theme.of(context);
    final nextAlarm = pill.getNextAlarmTime();
    final timeStr = '${pill.time.hour.toString().padLeft(2, '0')}:${pill.time.minute.toString().padLeft(2, '0')}';
    final pillCountStr = '${pill.amount} ${pill.type}';
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/medication_detail',
          arguments: pill,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeStr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(pill.name, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(pill.getFrequencyDescription(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  if (nextAlarm != null)
                    Text(
                      'Next: ${nextAlarm.day}/${nextAlarm.month} ${nextAlarm.hour}:${nextAlarm.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(pillCountStr,
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text('${pill.duration} days',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Schedule',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _navigateToAddPills,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Medicine'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<PillsProvider>(
                builder: (context, pillsProvider, child) {
                  final userPills = pillsProvider.pills;
                  return userPills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medication_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No medications added yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Medicine" to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: userPills.map((pill) => _buildScheduleItem(context, pill)).toList(),
                        );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentRoute: '/dashboard'),
      ),
    );
  }
}
