import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsService {
  final CollectionReference _contactsCollection =
      FirebaseFirestore.instance.collection('emergency_contacts');

  // Add new contact
  Future<void> addContact(Map<String, dynamic> contactData) async {
    await _contactsCollection.add(contactData);
  }

  // Update contact
  Future<void> updateContact(String id, Map<String, dynamic> contactData) async {
    await _contactsCollection.doc(id).update(contactData);
  }

  // Delete contact
  Future<void> deleteContact(String id) async {
    await _contactsCollection.doc(id).delete();
  }

  // Fetch contacts stream
  Stream<QuerySnapshot> getContactsStream() {
    return _contactsCollection.orderBy('name').snapshots();
  }
}
