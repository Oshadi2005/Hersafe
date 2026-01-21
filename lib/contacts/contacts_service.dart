import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'trusted_contact_model.dart';

class ContactsService {
  static const _storageKey = 'trusted_contacts';

  // Get all contacts
  Future<List<TrustedContact>> getContactsAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return [];
    final List decoded = json.decode(jsonStr);
    return decoded.map((e) => TrustedContact.fromJson(e)).toList();
  }

  // Add a new contact
  Future<void> addContactAsync(TrustedContact contact) async {
    final contacts = await getContactsAsync();
    contacts.add(contact);
    await _saveContacts(contacts);
  }

  // Update an existing contact
  Future<void> updateContactAsync(int index, TrustedContact contact) async {
    final contacts = await getContactsAsync();
    if (index >= 0 && index < contacts.length) {
      contacts[index] = contact;
      await _saveContacts(contacts);
    }
  }

  // Delete a contact
  Future<void> deleteContact(int index) async {
    final contacts = await getContactsAsync();
    if (index >= 0 && index < contacts.length) {
      contacts.removeAt(index);
      await _saveContacts(contacts);
    }
  }

  // Save contacts to SharedPreferences
  Future<void> _saveContacts(List<TrustedContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(contacts.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }
}
