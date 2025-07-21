import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvailabilityDateFilter extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateChanged;

  const AvailabilityDateFilter({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<AvailabilityDateFilter> createState() => _AvailabilityDateFilterState();
}

class _AvailabilityDateFilterState extends State<AvailabilityDateFilter> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available From',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          
          // Quick date options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickDateChip('Immediately', DateTime.now()),
              _buildQuickDateChip('This Week', DateTime.now().add(const Duration(days: 7))),
              _buildQuickDateChip('This Month', DateTime.now().add(const Duration(days: 30))),
              _buildQuickDateChip('Next Month', DateTime.now().add(const Duration(days: 60))),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Custom date picker
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showDatePicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.calendar,
                    color: CupertinoColors.systemBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'Select custom date',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null
                          ? CupertinoColors.label
                          : CupertinoColors.secondaryLabel,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedDate != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _clearDate,
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: CupertinoColors.systemGrey,
                        size: 20,
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

  Widget _buildQuickDateChip(String label, DateTime date) {
    final isSelected = _selectedDate != null && 
        _selectedDate!.day == date.day && 
        _selectedDate!.month == date.month &&
        _selectedDate!.year == date.year;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _selectDate(date),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? CupertinoColors.systemBlue 
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected 
                ? CupertinoColors.white 
                : CupertinoColors.label,
          ),
        ),
      ),
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateChanged(date);
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
    widget.onDateChanged(null);
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate ?? DateTime.now(),
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (date) {
                  _selectDate(date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return '${difference} days from now';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}