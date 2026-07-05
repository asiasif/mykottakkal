import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/shop_order_model.dart';
import 'package:intl/intl.dart';

class ShopOrdersScreen extends StatefulWidget {
  final String shopId;
  const ShopOrdersScreen({super.key, required this.shopId});

  @override
  State<ShopOrdersScreen> createState() => _ShopOrdersScreenState();
}

class _ShopOrdersScreenState extends State<ShopOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Orders"),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ShopOrderModel>>(
        stream: DbService().getShopOrdersForShop(widget.shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 16),
                        Text("No orders yet", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                )
            );

          final orders = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 3,
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
                          Text("Order #${order.id.substring(0, 6)}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                          children: [
                              Icon(Icons.person, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(order.userName, style: TextStyle(fontWeight: FontWeight.bold)),
                              Spacer(),
                              Icon(Icons.access_time, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(DateFormat('MMM dd, hh:mm a').format(order.timestamp), style: TextStyle(fontSize: 12)),
                          ],
                      ),
                       Row(
                          children: [
                              Icon(Icons.phone, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(order.userPhone, style: TextStyle(color: Colors.blue)),
                          ],
                      ),
                      Divider(height: 24),
                      Text("Items:", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      SizedBox(height: 6),
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${item['name']} x ${item['quantity']}"),
                            Text("₹${(item['price'] * item['quantity']).toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )).toList(),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                   Text("Payment: ${order.paymentMethod}", style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                                   Text("Total: ₹${order.totalAmount.toStringAsFixed(0)}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
                              ],
                          ),
                          if (order.status == 'Pending')
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _updateStatus(order.id, 'Rejected'),
                                  tooltip: "Reject",
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(order.id, 'Accepted'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 16)),
                                  child: Text("Accept", style: TextStyle(color: Colors.white)),
                                )
                              ],
                            )
                           else if (order.status == 'Accepted')
                                ElevatedButton(
                                  onPressed: () => _updateStatus(order.id, 'Completed'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(horizontal: 16)),
                                  child: Text("Mark Completed", style: TextStyle(color: Colors.white)),
                                )
                        ],
                      )
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

  Future<void> _updateStatus(String orderId, String status) async {
    await DbService().updateShopOrderStatus(orderId, status);
  }
}
