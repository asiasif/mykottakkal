import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateInvoice(BookingModel booking) async {
    final doc = pw.Document();
    
    // Load a font (optional, but good for custom text)
    // final font = await PdfGoogleFonts.nunitoExtraLight();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Kottakkal City App', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed To:'),
                      pw.Text(booking.userName),
                      pw.Text(booking.userPhone),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice No: #${booking.id.substring(0, 8)}'),
                      pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(booking.bookingDate)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Description', 'Worker', 'Status', 'Amount'],
                data: [
                  [
                    booking.serviceCategory,
                    booking.workerName,
                    booking.status,
                    'Rs. 350.00' // Placeholder standard fee
                  ],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs. 350.00', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text('Thank you for using Kottakkal City App!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Invoice-${booking.id}.pdf',
    );
  }
}
