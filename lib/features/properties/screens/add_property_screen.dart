import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedType = 'Apartment';
  final List<String> _propertyTypes = ['Apartment', 'House', 'Villa', 'Studio'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        middle: const Text('Add Property'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _submitProperty,
          child: const Text('Post'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                'Property Details',
                [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Property Title',
                    placeholder: 'e.g., 2BHK Apartment in Koramangala',
                  ),
                  const SizedBox(height: 16),
                  _buildPropertyTypePicker(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Monthly Rent (₹)',
                    placeholder: 'e.g., 25000',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Location',
                [
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    placeholder: 'Enter complete address',
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Description',
                [
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Property Description',
                    placeholder: 'Describe your property...',
                    maxLines: 5,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          maxLines: maxLines,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showPropertyTypePicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedType,
                  style: const TextStyle(color: CupertinoColors.label),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPropertyTypePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CupertinoColors.systemGrey4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedType = _propertyTypes[index];
                  });
                },
                children: _propertyTypes
                    .map((type) => Center(child: Text(type)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: CupertinoButton(
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(12),
        onPressed: _submitProperty,
        child: const Text(
          'Post Property',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _submitProperty() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement property submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property posted successfully!'),
          backgroundColor: CupertinoColors.systemGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}