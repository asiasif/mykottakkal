import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/models/dish_model.dart';
import 'package:mykottakkal/models/shop_order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mykottakkal/models/user_model.dart'; // Import

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final Map<String, int> _cart = {}; // dishId -> quantity
  // We need to store Dish details for the order because cart only has ID
  final Map<String, DishModel> _dishDetails = {}; 
  bool _isPlacingOrder = false;

  void _addToCart(DishModel dish) {
    setState(() {
      _cart[dish.id] = (_cart[dish.id] ?? 0) + 1;
      _dishDetails[dish.id] = dish;
    });
  }

  void _removeFromCart(String dishId) {
    setState(() {
      if (_cart.containsKey(dishId)) {
        _cart[dishId] = _cart[dishId]! - 1;
        if (_cart[dishId]! <= 0) {
          _cart.remove(dishId);
          _dishDetails.remove(dishId);
        }
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    _cart.forEach((id, qty) {
      if (_dishDetails.containsKey(id)) {
        total += _dishDetails[id]!.price * qty;
      }
    });
    return total;
  }

  void _showCheckoutSheet() {
    if (_cart.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamBuilder<UserModel?>(
        stream: DbService().getUser(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
            final userPoints = snapshot.data?.points ?? 0;
            return CheckoutSheet(
                shop: widget.shop,
                cart: _cart,
                dishDetails: _dishDetails,
                totalAmount: _calculateTotal(),
                userPoints: userPoints, // Pass points
                onOrderPlaced: () {
                    setState(() {
                        _cart.clear();
                        _dishDetails.clear();
                    });
                    Navigator.pop(context); // Close sheet
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Placed Successfully!")));
                },
            );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.shop.shopName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              background: widget.shop.imageUrl != null 
                ? Image.network(widget.shop.imageUrl!, fit: BoxFit.cover)
                : Container(color: Color(0xFF2E7D32), child: Icon(Icons.store, size: 80, color: Colors.white24)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                        children: [
                            if (widget.shop.shopType.isNotEmpty)
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                    child: Text(widget.shop.shopType, style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                                ),
                            Spacer(),
                            if (widget.shop.deliveryAvailable)
                                Row(
                                    children: [
                                        Icon(Icons.delivery_dining, color: Colors.green, size: 16),
                                        SizedBox(width: 4),
                                        Text("Delivery Available", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                )
                        ],
                    ),
                  SizedBox(height: 12),
                  Text(widget.shop.address, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (widget.shop.description.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(widget.shop.description, style: TextStyle(color: Colors.grey[800])),
                  ],
                  SizedBox(height: 16),
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                          onPressed: () => launchUrl(Uri.parse("tel:${widget.shop.mobile}")),
                          icon: Icon(Icons.call),
                          label: Text("Call Shop"),
                      ),
                  ),
                  SizedBox(height: 24),
                  Text(widget.shop.shopType == 'Restaurant' || widget.shop.shopType == 'Cafe' ? "Menu" : "Products", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          StreamBuilder<List<DishModel>>(
            stream: DbService().getDishesByShop(widget.shop.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No items available."))));

              final dishes = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dish = dishes[index];
                    final qty = _cart[dish.id] ?? 0;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: dish.imageUrl.isNotEmpty
                                ? Image.network(dish.imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                                : Container(width: 80, height: 80, color: Colors.grey[100], child: Icon(Icons.fastfood, color: Colors.grey)),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(dish.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                                    if (dish.isRescueItem)
                                       Container(
                                          margin: EdgeInsets.only(left: 8),
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                          child: Text("50% OFF", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                       )
                                  ],
                                ),
                                if (dish.isRescueItem && dish.originalPrice != null)
                                   Text("₹${dish.originalPrice!.toStringAsFixed(0)}", style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12)),
                                Text("₹${dish.price.toStringAsFixed(0)}", style: TextStyle(color: dish.isRescueItem ? Colors.orange[800] : Colors.green[700], fontWeight: FontWeight.bold)),
                                if (dish.description.isNotEmpty)
                                    Text(dish.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          if (dish.isAvailable)
                            qty == 0
                              ? ElevatedButton(
                                  onPressed: () => _addToCart(dish),
                                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2E7D32), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero),
                                  child: Text("ADD", style: TextStyle(fontSize: 12)),
                                )
                              : Container(
                                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      IconButton(icon: Icon(Icons.remove, size: 16, color: Colors.green), onPressed: () => _removeFromCart(dish.id)),
                                      Text("$qty", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                      IconButton(icon: Icon(Icons.add, size: 16, color: Colors.green), onPressed: () => _addToCart(dish)),
                                    ],
                                  ),
                                )
                           else
                                Text("Sold Out", style: TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                  childCount: dishes.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for cart details
        ],
      ),
      bottomSheet: _cart.isNotEmpty ? Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text("${_cart.length} Items", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text("₹${_calculateTotal().toStringAsFixed(0)}", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: _showCheckoutSheet,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("View Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ) : null,
    );
  }
}

class CheckoutSheet extends StatefulWidget {
  final ShopModel shop;
  final Map<String, int> cart;
  final Map<String, DishModel> dishDetails;
  final double totalAmount;
  final int userPoints; // New
  final VoidCallback onOrderPlaced;

  const CheckoutSheet({
    super.key,
    required this.shop,
    required this.cart,
    required this.dishDetails,
    required this.totalAmount,
    required this.userPoints, // New
    required this.onOrderPlaced,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  String _paymentMethod = 'COD'; // COD or Online
  bool _isPlacingOrder = false;
  final _userPhoneController = TextEditingController();
  bool _applyGreenPoints = false; // Toggle state

  double get _discountAmount {
      if (!_applyGreenPoints) return 0.0;
      // MAX DISCOUNT: 50% of Total or Points Value, whichever is lower
      // Rate: 10 Points = 5 Rs. (0.5 Rs per point)
      double pointsValue = widget.userPoints * 0.5;
      double maxAllowedDiscount = widget.totalAmount * 0.5; 
      
      return pointsValue < maxAllowedDiscount ? pointsValue : maxAllowedDiscount;
  }

  double get _finalAmount => widget.totalAmount - _discountAmount;
  int get _pointsToRedeem => (_discountAmount * 2).toInt(); // Reverse calc


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: 24),
            Text("Order Summary", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Flexible(
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.cart.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, index) {
                        String dishId = widget.cart.keys.elementAt(index);
                        int qty = widget.cart[dishId]!;
                        DishModel dish = widget.dishDetails[dishId]!;
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text("${dish.name} x $qty"),
                                Text("₹${(dish.price * qty).toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                        );
                    },
                ),
            ),
            Divider(thickness: 2),
            
            // Green Points Section
            if (widget.userPoints > 0)
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.green[50], 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3))
                    ),
                    child: Row(
                        children: [
                            Icon(Icons.eco, color: Colors.green),
                            SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text("Use Green Points", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[900])),
                                        Text("Available: ${widget.userPoints} (Max ₹${(widget.userPoints * 0.5).toStringAsFixed(0)} off)", style: TextStyle(fontSize: 12, color: Colors.green[700])),
                                    ],
                                ),
                            ),
                            Switch(
                                value: _applyGreenPoints, 
                                activeColor: Colors.green,
                                onChanged: (val) {
                                  setState(() => _applyGreenPoints = val);
                                }
                            )
                        ],
                    ),
                ),

            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text("Total Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            if (_applyGreenPoints)
                                Text("Original: ₹${widget.totalAmount.toStringAsFixed(0)}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                            if (_applyGreenPoints)
                                Text("- ₹${_discountAmount.toStringAsFixed(0)}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("₹${_finalAmount.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800])),
                        ],
                    )
                ],
            ),
            SizedBox(height: 24),
            Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
                children: [
                    Expanded(
                        child: RadioListTile(
                            title: Text("Cash on Delivery"),
                            value: 'COD',
                            groupValue: _paymentMethod,
                            onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                            activeColor: Color(0xFF2E7D32),
                            contentPadding: EdgeInsets.zero,
                        ),
                    ),
                    Expanded(
                        child: RadioListTile(
                            title: Text("Pay Now"),
                            value: 'Online',
                            groupValue: _paymentMethod,
                            onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                            activeColor: Color(0xFF2E7D32),
                            contentPadding: EdgeInsets.zero,
                        ),
                    ),
                ],
            ),
            SizedBox(height: 16),
             TextFormField(
                controller: _userPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Contact Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.phone),
                ),
            ),
            SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _isPlacingOrder ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isPlacingOrder 
                        ? CircularProgressIndicator(color: Colors.white) 
                        : Text(_paymentMethod == 'Online' ? "Pay & Order" : "Place Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ),
            SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
      if (_userPhoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter contact number")));
          return;
      }
      setState(() => _isPlacingOrder = true);

      try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) throw Exception("User not logged in");

          // Simulate Online Payment
          if (_paymentMethod == 'Online') {
              await Future.delayed(Duration(seconds: 2)); // Simulate processing
              // In real app, integrate Razorpay/Stripe here
          }

          // Construct Order Item List
          List<Map<String, dynamic>> orderItems = [];
          widget.cart.forEach((id, qty) {
              DishModel dish = widget.dishDetails[id]!;
              orderItems.add({
                  'dishId': dish.id,
                  'name': dish.name,
                  'price': dish.price,
                  'quantity': qty,
              });
          });

          final order = ShopOrderModel(
              id: Uuid().v4(),
              shopId: widget.shop.uid,
              shopName: widget.shop.shopName,
              userId: user.uid,
              userName: user.displayName ?? 'User',
              userPhone: _userPhoneController.text,
              items: orderItems,
              totalAmount: _finalAmount, // Apply Discount
              status: 'Pending',
              paymentMethod: _paymentMethod,
              isPaid: _paymentMethod == 'Online',
              timestamp: DateTime.now(),
              discountApplied: _discountAmount,
              pointsRedeemed: _pointsToRedeem,
          );

          await DbService().placeShopOrder(order);

          // Deduct Points
          if (_applyGreenPoints && _pointsToRedeem > 0) {
              await DbService().deductPoints(user.uid, _pointsToRedeem);
          }

          widget.onOrderPlaced(); // Callback to clear cart and close

      } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
          if (mounted) setState(() => _isPlacingOrder = false);
      }
  }
}
