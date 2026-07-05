import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/shop_order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserShopOrdersScreen extends StatelessWidget {
  const UserShopOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ShopOrderModel>>(
        stream: DbService().getShopOrdersForUser(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("No orders placed yet.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(order.shopName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      SizedBox(height: 4),
                       Text(DateFormat('MMM dd, hh:mm a').format(order.timestamp), style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Divider(height: 24),
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${item['name']} x ${item['quantity']}", style: TextStyle(color: Colors.black87)),
                             Text("₹${(item['price'] * item['quantity']).toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )).toList(),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("₹${order.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Accepted': color = Colors.blue; break;
      case 'Completed': color = Colors.green; break;
      case 'Rejected': color = Colors.red; break;
      case 'Cancelled': color = Colors.grey; break;
      default: color = Colors.orange;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
