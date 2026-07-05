import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mykottakkal/models/event_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/admin/admin_event_bookings_screen.dart'; // Import

class AdminAddEventScreen extends StatefulWidget {
  const AdminAddEventScreen({super.key});

  @override
  State<AdminAddEventScreen> createState() => _AdminAddEventScreenState();
}

class _AdminAddEventScreenState extends State<AdminAddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController(); // Simple string for now
  
  String _selectedType = 'Event';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post Event / News")),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Form
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("New Post", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: "Title"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: ['Event', 'News', 'Notice'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                      decoration: InputDecoration(labelText: "Type"),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: "Description"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(labelText: "Location (e.g. Town Hall)"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    SizedBox(height: 12),
                    ListTile(
                      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                      trailing: Icon(Icons.calendar_today),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context, 
                          initialDate: _selectedDate, 
                          firstDate: DateTime.now(), 
                          lastDate: DateTime(2030)
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Post Now"),
                    )
                  ],
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1),
          // Right Side: List
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Active Posts", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: StreamBuilder<List<EventModel>>(
                    stream: DbService().getEvents(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      final events = snapshot.data!;
                      if (events.isEmpty) return Center(child: Text("No active events"));

                      return ListView.separated(
                        itemCount: events.length,
                        separatorBuilder: (_,__) => Divider(),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return ListTile(
                            title: Text(event.title, style: fontWeightBold),
                            subtitle: Text("${event.type} • ${event.date}"),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    if (event.type == 'Event')
                                        IconButton(
                                            tooltip: "View Bookings",
                                            icon: Icon(Icons.people, color: Colors.blue),
                                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminEventBookingsScreen(eventId: event.id, eventTitle: event.title))),
                                        ),
                                    IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => DbService().deleteEvent(event.id),
                                    ),
                                ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  TextStyle get fontWeightBold => TextStyle(fontWeight: FontWeight.bold);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final event = EventModel(
        id: Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        location: _locationController.text,
        date: DateFormat('MMM d').format(_selectedDate),
        type: _selectedType,
        timestamp: DateTime.now(),
      );

      await DbService().addEvent(event);
      _titleController.clear();
      _descController.clear();
      _locationController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Posted!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
