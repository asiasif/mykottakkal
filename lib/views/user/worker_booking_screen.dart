import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';

class WorkerBookingScreen extends StatefulWidget {
  final WorkerModel worker;

  const WorkerBookingScreen({super.key, required this.worker});

  @override
  State<WorkerBookingScreen> createState() => _WorkerBookingScreenState();
}

class _WorkerBookingScreenState extends State<WorkerBookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
  }




  
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location services are disabled.')));
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permissions are denied')));
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permissions are permanently denied.')));
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _confirmBooking() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select a date")));
      return;
    }

    setState(() => _isBooking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1. Get Location
      Position? position = await _getCurrentLocation();
      
      // 2. Check Availability
      bool isAvailable = await DbService().isWorkerAvailable(widget.worker.uid, _selectedDay!);
      if (!isAvailable) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("Just booked! Please select another date."),
             backgroundColor: Colors.red,
           ));

           // _fetchBookedDates(); // No longer needed with Stream
           setState(() {
             _selectedDay = null;
             _isBooking = false;
           });
        }
        return;
      }

      final booking = BookingModel(
        id: Uuid().v4(),
        workerId: widget.worker.uid,
        workerName: widget.worker.name,
        userId: user.uid,
        userName: user.displayName ?? "User",
        userPhone: "Not Provided", 
        serviceCategory: widget.worker.category,
        bookingDate: _selectedDay!,
        status: 'Pending',
        timestamp: DateTime.now(),
        userLatitude: position?.latitude, // Save Loc
        userLongitude: position?.longitude, // Save Loc
      );

      await DbService().createBooking(booking);
      
      // ... success dialog ...


      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text("Booking Request Sent!"),
            content: Text("Your request for ${widget.worker.name} on ${_selectedDay.toString().split(' ')[0]} has been sent."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book ${widget.worker.name}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker Abstract
              Row(
                children: [
                   CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.worker.profileImage != null ? NetworkImage(widget.worker.profileImage!) : null,
                    child: widget.worker.profileImage == null ? Icon(Icons.person, size: 30) : null,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.worker.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(widget.worker.category, style: TextStyle(color: Colors.grey[600])),
                    ],
                  )
                ],
              ),
              SizedBox(height: 24),
              
              Text("Select Date from Calendar", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              
              // Legend
              Row(
                children: [
                  _buildLegendItem(Colors.green, "Available"),
                  SizedBox(width: 12),
                  _buildLegendItem(Colors.red[300]!, "Booked"),
                  SizedBox(width: 12),
                  _buildLegendItem(Colors.blue, "Selected"),
                ],
              ),
              SizedBox(height: 16),

              // Calendar
              StreamBuilder<List<DateTime>>(
                stream: DbService().getBookedDatesStream(widget.worker.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  final bookedDates = snapshot.data ?? [];
                  
                  bool isBooked(DateTime day) {
                    return bookedDates.any((bookedDate) => 
                      bookedDate.year == day.year && 
                      bookedDate.month == day.month && 
                      bookedDate.day == day.day
                    );
                  }

                  return TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(Duration(days: 60)),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    enabledDayPredicate: (day) => !isBooked(day), // Disable interactions for booked days
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.green.withOpacity(0.5), shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (isBooked(day)) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.red[300], shape: BoxShape.circle),
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return null; // Default style
                      },
                      disabledBuilder: (context, day, focusedDay) {
                         if (isBooked(day)) {
                          return Container(
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.red[100], shape: BoxShape.circle), // Lighter red for disabled interaction
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return null;
                      }
                    ),
                  );
                }
              ),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isBooking || _selectedDay == null) ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isBooking 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Confirm Booking", style: GoogleFonts.outfit(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
