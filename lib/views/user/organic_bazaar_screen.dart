import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/organic_harvest_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/views/user/post_harvest_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class OrganicBazaarScreen extends StatefulWidget {
  const OrganicBazaarScreen({super.key});

  @override
  State<OrganicBazaarScreen> createState() => _OrganicBazaarScreenState();
}

class _OrganicBazaarScreenState extends State<OrganicBazaarScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', 'Vegetables', 'Fruits', 'Grains', 'Tubers', 'Others'];

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: Text("Organic Farmers' Bazaar", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search fresh organic produce...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                hintStyle: GoogleFonts.inter(color: Colors.grey[450]),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Category Selector
          Container(
            height: 50,
            color: Colors.transparent,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.green[800],
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[800],
                    ),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), 
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[200]!),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Fresh Harvest listings Grid
          Expanded(
            child: StreamBuilder<List<OrganicHarvestModel>>(
              stream: DbService().getApprovedOrganicHarvests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco_outlined, size: 70, color: Colors.green[200]),
                        const SizedBox(height: 16),
                        Text("No organic produce listed today.", 
                          style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16)
                        ),
                        const SizedBox(height: 8),
                        Text("Farmers can list fresh items using the '+' button.", 
                          style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)
                        ),
                      ],
                    ),
                  );
                }

                var items = snapshot.data!;

                // Filter by category
                if (_selectedCategory != 'All') {
                  items = items.where((i) => i.unit.toLowerCase() == _selectedCategory.toLowerCase() || 
                                            // Or map categories properly
                                            _matchCategory(i.description + i.title, _selectedCategory)
                                     ).toList();
                }

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  items = items.where((i) => 
                    i.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                    i.description.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Text("No items found matching '$_searchQuery'", 
                      style: GoogleFonts.inter(color: Colors.grey[500])
                    )
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildProduceCard(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please log in to post your harvest!"))
            );
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PostHarvestScreen()));
        },
        backgroundColor: Colors.green[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Post Harvest", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  bool _matchCategory(String content, String category) {
    final text = content.toLowerCase();
    final cat = category.toLowerCase();
    if (cat == 'vegetables') return text.contains('vegetable') || text.contains('tapioca') || text.contains('tomato') || text.contains('chilli') || text.contains('cucumber') || text.contains('yam');
    if (cat == 'fruits') return text.contains('fruit') || text.contains('banana') || text.contains('mango') || text.contains('jackfruit') || text.contains('papaya');
    if (cat == 'grains') return text.contains('grain') || text.contains('rice') || text.contains('paddy') || text.contains('ragi') || text.contains('corn');
    if (cat == 'tubers') return text.contains('tuber') || text.contains('tapioca') || text.contains('yam') || text.contains('potato') || text.contains('colocasia');
    return true; // fallback
  }

  Widget _buildProduceCard(BuildContext context, OrganicHarvestModel item) {
    return GestureDetector(
      onTap: () => _showDetailsSheet(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: DecorationImage(
                        image: item.imageUrl.isNotEmpty 
                            ? NetworkImage(item.imageUrl) 
                            : const AssetImage('assets/kottakkal_traditional_bg.png') as ImageProvider, 
                        fit: BoxFit.cover,
                      ),
                      color: Colors.green[50],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[800]!.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "105% Organic",
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹${item.price.round()}/${item.unit}", 
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.green[800])
                      ),
                      Text("Qty: ${item.quantity.round()}", 
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(item.location, 
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDetailsSheet(BuildContext context, OrganicHarvestModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(item.imageUrl, fit: BoxFit.cover)
                          : Container(color: Colors.green[50], child: const Icon(Icons.eco, color: Colors.green)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("₹${item.price.round()} per ${item.unit}", 
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green[800])
                        ),
                        const SizedBox(height: 4),
                        Text("Available Qty: ${item.quantity} ${item.unit}s", 
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Text("Product Description", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(item.description, 
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800], height: 1.4)
              ),
              const Divider(height: 30),
              
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text("Farmer: ${item.farmerName}", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text("Location: ${item.location}", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[750])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 8),
                  Text("Harvested: ${DateFormat('dd MMM yyyy').format(item.timestamp)}", 
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final Uri phoneUri = Uri(scheme: 'tel', path: item.phone);
                        if (await launchUrl(phoneUri)) {
                          // Launched dialer
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not launch phone dialer."))
                          );
                        }
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text("Call Farmer"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[800],
                        side: BorderSide(color: Colors.green[800]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final String text = "Hello ${item.farmerName}, I saw your harvest post for '${item.title}' (₹${item.price.round()}/${item.unit}) on My Kottakkal app and would like to buy it.";
                        final Uri whatsappUri = Uri.parse("https://wa.me/${item.phone}?text=${Uri.encodeComponent(text)}");
                        if (await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
                          // Launched WhatsApp
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not launch WhatsApp."))
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("WhatsApp"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
