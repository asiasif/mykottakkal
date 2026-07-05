import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/views/shop/shop_registration_screen.dart';
import 'package:mykottakkal/views/shop/manage_menu_screen.dart';
import 'package:mykottakkal/views/shop/shop_orders_screen.dart'; // Import Orders Screen
import 'package:mykottakkal/models/shop_update_model.dart'; // Import Update Model
import 'package:uuid/uuid.dart'; // Import UUID
import 'package:mykottakkal/views/shop/manage_jobs_screen.dart'; // Import
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart'; // For rootBundle

class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text("Please Login First")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: FutureBuilder<ShopModel?>(
        future: DbService().getShopData(user.uid),
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
           
           if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
           
           if (!snapshot.hasData || snapshot.data == null) {
             return _buildRegistrationView(context);
           }

           final shop = snapshot.data!;
           
           return Column(
             children: [
               _buildHeader(shop),
               Expanded(
                 child: SingleChildScrollView(
                   padding: const EdgeInsets.all(20.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildStatusCard(shop),
                       SizedBox(height: 24),
                       
                       if (shop.status == 'Approved') ...[
                         Text("Shop Management", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                         SizedBox(height: 16),
                         _buildManagementGrid(context, shop),
                       ],
                     ],
                   ),
                 ),
               ),
             ],
           );
        },
      ),
    );
  }

  Widget _buildWrapperHeader(String title) {
     return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Color(0xFF2E7D32)),
        child: Text(title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
     );
  }

  Widget _buildRegistrationView(BuildContext context) {
    return Column(
      children: [
        _buildWrapperHeader("Shop Dashboard"),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text("You haven't registered a shop yet.", style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShopRegistrationScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2E7D32), foregroundColor: Colors.white),
                child: Text("Apply Now"),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ShopModel shop) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: shop.imageUrl != null ? NetworkImage(shop.imageUrl!) : null,
                backgroundColor: Colors.white,
                child: shop.imageUrl == null ? Icon(Icons.store, color: Colors.green) : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop.shopName, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(shop.shopType, style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ShopModel shop) {
    final color = _getStatusColor(shop.status);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(shop.status), color: color, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Account Status: ${shop.status}", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                SizedBox(height: 4),
                Text(_getStatusMessage(shop.status), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context, ShopModel shop) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildGridItem(context, _getManagementLabel(shop.shopType), Icons.inventory_2, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageMenuScreen(shopId: shop.uid, shopType: shop.shopType)))),
        _buildGridItem(context, "Orders", Icons.shopping_bag, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopOrdersScreen(shopId: shop.uid)))),
        _buildGridItem(context, "Jobs", Icons.work, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShopManageJobsScreen(shopId: shop.uid, shopName: shop.shopName)))),
        _buildGridItem(context, "Post Update", Icons.campaign, Colors.purple, () => _showPostUpdateDialog(context, shop)),
        _buildGridItem(context, "Shop ID", Icons.badge, Colors.blue, () => _generateAndDownloadIdCard(context, shop)),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(height: 12),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Approved': return Icons.check_circle;
      case 'Rejected': return Icons.cancel;
      default: return Icons.hourglass_empty;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'Approved': return "Congratulations! Your shop is now visible to users. You can download your certificate below.";
      case 'Rejected': return "Your application was not approved. Please contact support.";
      default: return "Your application is under review. This usually takes 24-48 hours.";
    }
  }


  void _showPostUpdateDialog(BuildContext context, ShopModel shop) {
    final _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Post Live Update"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("This message will appear on the User Home Screen notification bar."),
            SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Message",
                hintText: "e.g., Special Offer: 50% Off!",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_controller.text.isEmpty) return;
              
              final update = ShopUpdateModel(
                id: Uuid().v4(),
                shopName: shop.shopName,
                message: _controller.text.trim(),
                timestamp: DateTime.now(),
                isActive: true,
              );

              await DbService().postShopUpdate(update);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update Posted!")));
            },
            child: Text("Post"),
          )
        ],
      ),
    );
  }


  String _getManagementLabel(String shopType) {
    if (shopType == 'Restaurant' || shopType == 'Cafe') {
      return "Manage Menu";
    } else {
      return "Manage Products";
    }
  }

  Future<void> _generateAndDownloadIdCard(BuildContext context, ShopModel shop) async {
    final pdf = pw.Document();

    try {
      // Load Font (Optional, better to use default for simplicity if custom font fails)
      // final font = await PdfGoogleFonts.outfitRegular(); 
      
      // Load Logo or Placeholder
      final profileImage = await flutterImageProvider(NetworkImage(shop.imageUrl ?? "https://via.placeholder.com/150"));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Container(
                width: 300,
                height: 450,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green900, width: 4),
                  borderRadius: pw.BorderRadius.circular(20),
                  color: PdfColors.white,
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(color: PdfColors.green900, borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(16))),
                      width: double.infinity,
                      child: pw.Text("OFFICIAL SHOP ID", style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: 100,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: PdfColors.green, width: 2),
                        image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(shop.shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.Text(shop.shopType, style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                    pw.SizedBox(height: 20),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    _buildInfoRow("Shop ID", shop.uid.substring(0, 8).toUpperCase()),
                    _buildInfoRow("Owner", shop.ownerName),
                    _buildInfoRow("Contact", shop.mobile),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.SizedBox(height: 20),
                    pw.Container(
                       padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                       decoration: pw.BoxDecoration(color: PdfColors.green100, borderRadius: pw.BorderRadius.circular(20)),
                       child: pw.Text("VERIFIED PARTNER", style: pw.TextStyle(color: PdfColors.green900, fontWeight: pw.FontWeight.bold))
                    ),
                    pw.Spacer(),
                    pw.Text("Kottakkal City App", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${shop.shopName}_ID_Card.pdf',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generating ID: $e")));
    }
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 40),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
