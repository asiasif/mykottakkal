import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/auto_stand_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class AdminManageStandsScreen extends StatefulWidget {
  const AdminManageStandsScreen({super.key});

  @override
  State<AdminManageStandsScreen> createState() => _AdminManageStandsScreenState();
}

class _AdminManageStandsScreenState extends State<AdminManageStandsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Manage Auto Stands", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<AutoStandModel>>(
        stream: DbService().getAutoStands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No stands added.", style: GoogleFonts.outfit(color: Colors.grey)));

          final stands = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: stands.length,
            itemBuilder: (context, index) {
              final stand = stands[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.amber[100],
                      child: Icon(Icons.local_taxi, color: Colors.amber[800]),
                  ),
                  title: Text(stand.standName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text("${stand.location}\n${stand.driverPhone}"),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300]),
                    onPressed: () => _deleteStand(stand.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStandDialog,
        backgroundColor: Colors.amber[800],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add Stand", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _deleteStand(String id) async {
    bool confirm = await showDialog(
        context: context, 
        builder: (_) => AlertDialog(
            title: Text("Delete Stand?"),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete"))
            ],
        )
    ) ?? false;
    
    if (confirm) {
        await DbService().deleteAutoStand(id);
    }
  }

  void _showAddStandDialog() {
    final nameController = TextEditingController();
    final locController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Auto Stand"),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: "Stand Name (e.g. Changuvetty)")),
                    TextField(controller: locController, decoration: InputDecoration(labelText: "Location")),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: "Contact Phone"), keyboardType: TextInputType.phone),
                ],
            )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) return;

                final stand = AutoStandModel(
                    id: Uuid().v4(),
                    standName: nameController.text,
                    location: locController.text,
                    driverPhone: phoneController.text,
                );

                await DbService().addAutoStand(stand);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stand Added!")));
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }
}
