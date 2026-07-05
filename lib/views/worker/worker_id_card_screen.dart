import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:http/http.dart' as http; // For fetching profile image for PDF

class WorkerIdCardScreen extends StatelessWidget {
  final WorkerModel worker;

  const WorkerIdCardScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My ID Card"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: PdfPreview(
        build: (format) => _generatePdf(format, worker),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, WorkerModel worker) async {
    final pdf = pw.Document();

    // Fetch Profile Image
    pw.ImageProvider? profileImage;
    if (worker.profileImage != null) {
      try {
        final response = await http.get(Uri.parse(worker.profileImage!));
        profileImage = pw.MemoryImage(response.bodyBytes);
      } catch (e) {
        print("Error loading profile image for PDF: $e");
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 300,
              height: 450,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal, width: 4),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                   // Header
                   pw.Container(
                     height: 80,
                     width: double.infinity,
                     color: PdfColors.teal,
                     alignment: pw.Alignment.center,
                     child: pw.Text("KOTTAKKAL CONNECT", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                   ),
                   pw.SizedBox(height: 20),
                   
                   // Photo
                   pw.Container(
                     height: 120,
                     width: 120,
                     decoration: pw.BoxDecoration(
                       shape: pw.BoxShape.circle,
                       border: pw.Border.all(color: PdfColors.grey, width: 2),
                       image: profileImage != null ? pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover) : null,
                     ),
                   ),
                   pw.SizedBox(height: 20),
                   
                   // Name & Role
                   pw.Text(worker.name.toUpperCase(), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                   pw.Text(worker.category, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                   
                   pw.SizedBox(height: 30),
                   
                   // Details
                   _buildPdfDetail("Phone", worker.phone),
                   _buildPdfDetail("Worker ID", worker.uid.substring(0, 8).toUpperCase()),
                   _buildPdfDetail("Verified On", worker.approvedDate != null ? "${worker.approvedDate!.year}-${worker.approvedDate!.month}-${worker.approvedDate!.day}" : "N/A"),
                   
                   pw.Spacer(),
                   
                   // Footer
                   pw.Container(
                     padding: const pw.EdgeInsets.all(10),
                     color: PdfColors.grey200,
                     width: double.infinity,
                     child: pw.Column(children: [
                        pw.Text("VERIFIED WORKER", style: pw.TextStyle(color: PdfColors.green, fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.SizedBox(height: 4),
                        pw.Text("This card acts as proof of verification on Kottakkal Connect platform.", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey), textAlign: pw.TextAlign.center),
                     ])
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfDetail(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("$label: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }
}
