import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/emergency_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class AdminManageEmergencyScreen extends StatefulWidget {
  const AdminManageEmergencyScreen({super.key});

  @override
  State<AdminManageEmergencyScreen> createState() => _AdminManageEmergencyScreenState();
}

class _AdminManageEmergencyScreenState extends State<AdminManageEmergencyScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCategory = 'Police';
  final List<String> _categories = ['Police', 'Ambulance', 'Fire', 'Hospital', 'Electricity', 'Other'];

  void _showAddDialog() {
    _nameController.clear();
    _phoneController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Emergency Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: InputDecoration(labelText: "Category"),
            ),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Name (e.g. Police Station)")),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                final contact = EmergencyModel(
                  id: Uuid().v4(),
                  name: _nameController.text,
                  phone: _phoneController.text,
                  category: _selectedCategory,
                );
                await DbService().addEmergencyContact(contact);
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Helpline"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: StreamBuilder<List<EmergencyModel>>(
        stream: DbService().getEmergencyContacts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final contacts = snapshot.data!;
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.phone)),
                  title: Text(contact.name),
                  subtitle: Text("${contact.category} • ${contact.phone}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(contact),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(EmergencyModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete ${contact.name}?"),
        content: Text("Are you sure you want to delete this contact?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              await DbService().deleteEmergencyContact(contact.id);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
