import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/services/db_service.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Settings", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: user == null 
          ? const Center(child: Text("Not Logged In"))
          : StreamBuilder<WorkerModel?>(
              stream: DbService().getWorker(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Worker data not found."));
                }

                final worker = snapshot.data!;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                       const SizedBox(height: 20),
                       // Profile Image
                       Center(
                         child: CircleAvatar(
                           radius: 60,
                           backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                           backgroundImage: worker.profileImage != null ? NetworkImage(worker.profileImage!) : null,
                           child: worker.profileImage == null 
                            ? Text(worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)) 
                            : null,
                         ),
                       ),
                       const SizedBox(height: 20),
                       Text(worker.name, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                       Text(worker.category, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                       const SizedBox(height: 40),

                       // Info Cards
                       _buildInfoTile(context, Icons.phone, "Phone", worker.phone),
                       const SizedBox(height: 16),
                       _buildInfoTile(context, Icons.email, "Email", user.email ?? "No Email"),
                       const SizedBox(height: 16),
                       _buildInfoTile(context, Icons.work, "Category", worker.category),
                       
                       const SizedBox(height: 20),
                       _buildLocationButton(context, worker),
                       const SizedBox(height: 20),
                       
                       // Edit Button (Placeholder)
                       SizedBox(
                         width: double.infinity,
                         child: ElevatedButton.icon(
                           onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Editing coming soon!")));
                           },
                           icon: const Icon(Icons.edit),
                           label: const Text("Edit Profile"),
                           style: ElevatedButton.styleFrom(
                             padding: const EdgeInsets.symmetric(vertical: 16),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                         ),
                       )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLocationButton(BuildContext context, WorkerModel worker) {
     return SizedBox(
       width: double.infinity,
       child: ElevatedButton.icon(
         onPressed: () async {
            try {
              LocationPermission permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  throw Exception('Location permissions are denied');
                }
              }
              
              if (permission == LocationPermission.deniedForever) {
                throw Exception('Location permissions are permanently denied.');
              }

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Getting location...")));
              Position position = await Geolocator.getCurrentPosition();
              
              await DbService().updateWorkerLocation(worker.uid, position.latitude, position.longitude);
              
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location Updated Successfully!")));
              }

            } catch (e) {
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            }
         },
         icon: const Icon(Icons.my_location),
         label: Text(
           worker.latitude != null ? "Update My Location" : "Set My Location (Required for search)",
           style: const TextStyle(fontWeight: FontWeight.bold),
         ),
         style: ElevatedButton.styleFrom(
           backgroundColor: worker.latitude != null ? Colors.blue : Colors.redAccent,
           foregroundColor: Colors.white,
           padding: const EdgeInsets.symmetric(vertical: 16),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         ),
       ),
     );
  }


}
