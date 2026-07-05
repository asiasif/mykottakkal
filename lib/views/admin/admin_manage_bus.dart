import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/bus_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';

class AdminManageBusScreen extends StatefulWidget {
  const AdminManageBusScreen({super.key});

  @override
  State<AdminManageBusScreen> createState() => _AdminManageBusScreenState();
}

class _AdminManageBusScreenState extends State<AdminManageBusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Manage Bus Timings", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<BusModel>>(
        stream: DbService().getBusTimings(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No bus timings added.", style: GoogleFonts.outfit(color: Colors.grey)));

          final buses = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo[50],
                    child: Icon(Icons.directions_bus, color: Colors.indigo),
                  ),
                  title: Text("${bus.busName} (${bus.type})", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text("${bus.route}\nTime: ${bus.time}"),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300]),
                    onPressed: () => _deleteBus(bus.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBusDialog,
        backgroundColor: Colors.indigo,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add Bus", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _deleteBus(String id) async {
    bool confirm = await showDialog(
        context: context, 
        builder: (_) => AlertDialog(
            title: Text("Delete Bus?"),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete"))
            ],
        )
    ) ?? false;
    
    if (confirm) {
        await DbService().deleteBusTiming(id);
    }
  }

  void _showAddBusDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    String type = 'Private';
    String route = 'Kottakkal -> Malappuram';
    
    final List<String> routes = [
      'Kottakkal -> Malappuram',
      'Kottakkal -> Tirur',
      'Kottakkal -> Perinthalmanna',
      'Kottakkal -> Kozhikode',
      'Kottakkal -> Thrissur'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Add Bus Timing"),
          content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      DropdownButtonFormField<String>(
                        value: route,
                        decoration: InputDecoration(labelText: "Route"),
                        items: routes.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 14)))).toList(),
                        onChanged: (val) => setDialogState(() => route = val!),
                      ),
                      SizedBox(height: 12),
                      TextField(controller: nameController, decoration: InputDecoration(labelText: "Bus Name (e.g. KSRTC)")),
                      SizedBox(height: 12),
                      TextField(controller: timeController, decoration: InputDecoration(labelText: "Time (e.g. 08:30 AM)")),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: InputDecoration(labelText: "Type"),
                        items: ['Private', 'KSRTC', 'Limited Stop'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setDialogState(() => type = val!),
                      ),
                  ],
              )
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                  if (nameController.text.isEmpty || timeController.text.isEmpty) return;

                  final bus = BusModel(
                      id: Uuid().v4(),
                      route: route,
                      busName: nameController.text,
                      time: timeController.text,
                      type: type,
                  );

                  await DbService().addBusTiming(bus);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bus Added!")));
              },
              child: Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}
