import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/services/db_service.dart';

class WorkerVerificationDetailScreen extends StatelessWidget {
  final WorkerModel worker;

  const WorkerVerificationDetailScreen({super.key, required this.worker});

  void _updateStatus(BuildContext context, String status) async {
    await DbService().updateWorkerStatus(worker.uid, status);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Worker $status!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Worker")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: worker.profileImage != null ? NetworkImage(worker.profileImage!) : null,
                child: worker.profileImage == null ? Icon(Icons.person, size: 60) : null,
              ),
            ),
            SizedBox(height: 20),
            
            // Details
            _buildDetailRow(Icons.person, "Name", worker.name),
            _buildDetailRow(Icons.category, "Category", worker.category),
            _buildDetailRow(Icons.phone, "Phone", worker.phone),
            _buildDetailRow(Icons.home, "Address", worker.address ?? "Not Provided"),
            _buildDetailRow(Icons.description, "Description", worker.description),
            
            SizedBox(height: 20),
            Text("Certificate / ID Proof", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!)
              ),
              child: worker.certificateUrl != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(worker.certificateUrl!, fit: BoxFit.cover))
                  : Center(child: Text("No Certificate Uploaded")),
            ),
            
            SizedBox(height: 30),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, "Rejected"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Reject Application"),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(context, "Approved"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Approve Worker"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
