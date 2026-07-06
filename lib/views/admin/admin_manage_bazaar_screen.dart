import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/organic_harvest_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:intl/intl.dart';

class AdminManageBazaarScreen extends StatelessWidget {
  const AdminManageBazaarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBFC),
        appBar: AppBar(
          title: Text("Moderate Farmers' Bazaar", 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.green[800],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green[800],
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Pending Review"),
              Tab(text: "Active Listings"),
            ],
          ),
        ),
        body: StreamBuilder<List<OrganicHarvestModel>>(
          stream: DbService().getOrganicHarvests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text("No organic bazaar listings found.", style: GoogleFonts.inter(color: Colors.grey[500])),
              );
            }

            final allItems = snapshot.data!;
            final pending = allItems.where((item) => !item.isApproved).toList();
            final active = allItems.where((item) => item.isApproved).toList();

            return TabBarView(
              children: [
                _buildList(context, pending, isPending: true),
                _buildList(context, active, isPending: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<OrganicHarvestModel> items, {required bool isPending}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(isPending ? "No pending harvest listings." : "No active listings.",
              style: GoogleFonts.inter(color: Colors.grey[500])
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 80,
                        height: 80,
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
                          Text(item.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("Price: ₹${item.price.round()}/${item.unit} | Qty: ${item.quantity}",
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.green[800], fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 6),
                          Text("Farmer: ${item.farmerName} (${item.phone})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text("Location: ${item.location}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text("Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(item.timestamp)}", 
                            style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Text(
                  item.description,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),

              // Actions Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending) ...[
                      TextButton.icon(
                        onPressed: () => _rejectItem(context, item),
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        label: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _approveItem(context, item),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Approve"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    ] else ...[
                      TextButton.icon(
                        onPressed: () => _rejectItem(context, item),
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        label: const Text("Delete / Remove", style: TextStyle(color: Colors.red)),
                      ),
                    ]
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _approveItem(BuildContext context, OrganicHarvestModel item) async {
    try {
      await DbService().approveOrganicHarvest(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Approved '${item.title}' successfully!"), backgroundColor: Colors.green)
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    }
  }

  void _rejectItem(BuildContext context, OrganicHarvestModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        content: Text("Are you sure you want to remove the listing '${item.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DbService().deleteOrganicHarvest(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Removed '${item.title}' listing."), backgroundColor: Colors.orange)
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }
}
