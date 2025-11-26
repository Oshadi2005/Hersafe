import 'package:flutter/material.dart';
import 'contacts_service.dart';

class EditContactScreen extends StatefulWidget {
  final String contactId;
  final Map<String, dynamic> existingData;

  const EditContactScreen({
    super.key,
    required this.contactId,
    required this.existingData,
  });

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  final ContactsService _contactsService = ContactsService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingData['name']);
    _phoneCtrl = TextEditingController(text: widget.existingData['phone']);
  }

  void _updateContact() async {
    if (_formKey.currentState!.validate()) {
      await _contactsService.updateContact(widget.contactId, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contact')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateContact,
                child: const Text('Update Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
