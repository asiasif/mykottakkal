import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/services/db_service.dart';

class ShopVerificationDetailScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopVerificationDetailScreen({super.key, required this.shop});

  @override
  State<ShopVerificationDetailScreen> createState() => _ShopVerificationDetailScreenState();
}

class _ShopVerificationDetailScreenState extends State<ShopVerificationDetailScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    await DbService().updateShopStatus(widget.shop.uid, status);
    setState(() => _isUpdating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Shop $status")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Shop"), backgroundColor: Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: widget.shop.imageUrl != null ? DecorationImage(image: NetworkImage(widget.shop.imageUrl!), fit: BoxFit.cover) : null,
              ),
              child: widget.shop.imageUrl == null ? Icon(Icons.store, size: 60) : null,
            ),
            SizedBox(height: 20),

            _buildDetailRow("Shop Name", widget.shop.shopName, isTitle: true),
            _buildDetailRow("Type", widget.shop.shopType),
            _buildDetailRow("Owner", widget.shop.ownerName),
            _buildDetailRow("Mobile", widget.shop.mobile),
            _buildDetailRow("Email", widget.shop.email),
            _buildDetailRow("Email", widget.shop.email),
            _buildDetailRow("Address", widget.shop.address),
            if (widget.shop.googleMapLink != null && widget.shop.googleMapLink!.isNotEmpty)
              _buildDetailRow("Location Link", widget.shop.googleMapLink!),
            _buildDetailRow("Description", widget.shop.description),
            _buildDetailRow("Delivery", widget.shop.deliveryAvailable ? "Yes" : "No"),
            
            if (widget.shop.licenseUrl != null) ...[
              SizedBox(height: 20),
              Text("License / Proof", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Image.network(widget.shop.licenseUrl!, height: 200, fit: BoxFit.cover),
            ],

            SizedBox(height: 40),
            if (widget.shop.status == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : () => _updateStatus('Rejected'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 16)),
                      child: Text("Reject", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : () => _updateStatus('Approved'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 16)),
                      child: Text("Approve", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: widget.shop.status == 'Approved' ? Colors.green[100] : Colors.red[100], borderRadius: BorderRadius.circular(20)),
                  child: Text(widget.shop.status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: widget.shop.status == 'Approved' ? Colors.green[800] : Colors.red[800])),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          SizedBox(height: 4),
          Text(value, style: isTitle ? GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold) : TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
