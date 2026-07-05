import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/ad_model.dart';
import 'package:mykottakkal/services/db_service.dart';

class AdminManageAdsScreen extends StatelessWidget {
  const AdminManageAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<AdModel>>(
        stream: DbService().getAds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No ads posted.", style: GoogleFonts.outfit(color: Colors.grey)));

          final ads = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(image: NetworkImage(ad.imageUrl), fit: BoxFit.cover),
                      color: Colors.grey[200],
                    ),
                  ),
                  title: Text(ad.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${ad.price.toInt()} • Posted by ${ad.sellerName}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[300]),
                    onPressed: () => _deleteAd(context, ad.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteAd(BuildContext context, String id) async {
    bool confirm = await showDialog(
        context: context, 
        builder: (_) => AlertDialog(
            title: Text("Delete Ad?"),
            content: Text("This will remove the item from the marketplace."),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete"))
            ],
        )
    ) ?? false;
    
    if (confirm) {
        await DbService().deleteAd(id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ad Deleted")));
    }
  }
}
