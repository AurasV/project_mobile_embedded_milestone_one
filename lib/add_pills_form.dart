import 'package:flutter/material.dart';

class PillData {
  final String name;
  final String type;
  final int amount;
  final int duration;
  final TimeOfDay time;
  final DateTime startDate;
  final String frequency; 
  final int frequencyValue;

  PillData({
    required this.name,
    required this.type,
    required this.amount,
    required this.duration,
    required this.time,
    required this.startDate,
    this.frequency = 'daily',
    this.frequencyValue = 1,
  });
}

class AddPillsFormScreen extends StatefulWidget {
  const AddPillsFormScreen({super.key});

  @override
  State<AddPillsFormScreen> createState() => _AddPillsFormScreenState();
}

class _AddPillsFormScreenState extends State<AddPillsFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  int _pillAmount = 2;
  int _durationDays = 14;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 6, minute: 0);
  DateTime _startDate = DateTime.now();
  String _frequency = 'daily';
  int _frequencyValue = 1;

  void _incrementAmount() {
    setState(() {
      _pillAmount++;
    });
  }

  void _decrementAmount() {
    setState(() {
      if (_pillAmount > 1) _pillAmount--;
    });
  }

  void _incrementDuration() {
    setState(() {
      _durationDays++;
    });
  }

  void _decrementDuration() {
    setState(() {
      if (_durationDays > 1) _durationDays--;
    });
  }

  void _incrementFrequencyValue() {
    setState(() {
      _frequencyValue++;
    });
  }

  void _decrementFrequencyValue() {
    setState(() {
      if (_frequencyValue > 1) _frequencyValue--;
    });
  }

  Future<void> _showAmountDialog() async {
    final controller = TextEditingController(text: _pillAmount.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Enter Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pillAmount = result;
      });
    }
  }

  Future<void> _showDurationDialog() async {
    final controller = TextEditingController(text: _durationDays.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Enter Duration (days)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter number of days',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _durationDays = result;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addPills() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pill name')),
      );
      return;
    }
    if (_typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pill type (e.g., pills, tablets, injection)')),
      );
      return;
    }

    final pill = PillData(
      name: _nameController.text,
      type: _typeController.text,
      amount: _pillAmount,
      duration: _durationDays,
      time: _selectedTime,
      startDate: _startDate,
      frequency: _frequency,
      frequencyValue: _frequencyValue,
    );

    Navigator.pop(context, pill);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Name
            Text(
              'Medication Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ibuprofen, 200 mg',
                suffixIcon: Icon(Icons.circle, color: theme.colorScheme.primary, size: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // Type
            Text(
              'Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                hintText: 'Pills, Tablets, Injection, Drops, etc.',
                suffixIcon: Icon(Icons.medication, color: theme.colorScheme.primary, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            
            // Amount
            Text(
              'Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _decrementAmount,
                    icon: const Icon(Icons.remove),
                    color: theme.colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: _showAmountDialog,
                    child: Text(
                      '$_pillAmount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _incrementAmount,
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Duration
            Text(
              'Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _decrementDuration,
                    icon: const Icon(Icons.remove),
                    color: theme.colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: _showDurationDialog,
                    child: Text(
                      '$_durationDays days',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _incrementDuration,
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Start Date
            Text(
              'Start Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _selectStartDate,
                icon: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                label: Text(
                  'Change date',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Frequency
            Text(
              'Frequency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Frequency dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _frequency,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'hourly', child: Text('Every X hours')),
                      DropdownMenuItem(value: 'days', child: Text('Every X days')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _frequency = value;
                        });
                      }
                    },
                  ),
                ),
                if (_frequency != 'daily') ...[
                  const SizedBox(width: 16),
                  // Frequency
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _decrementFrequencyValue,
                      icon: const Icon(Icons.remove),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_frequencyValue',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _incrementFrequencyValue,
                      icon: const Icon(Icons.add),
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),

            // Time
            Text(
              'Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: _selectTime,
                icon: Icon(Icons.access_time, color: theme.colorScheme.primary),
                label: Text(
                  '+ Add time',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addPills,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Add pills',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }
}
