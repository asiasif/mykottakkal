import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/herb_model.dart';
import 'package:mykottakkal/services/db_service.dart';

class HerbFinderScreen extends StatefulWidget {
  const HerbFinderScreen({super.key});

  @override
  State<HerbFinderScreen> createState() => _HerbFinderScreenState();
}

class _HerbFinderScreenState extends State<HerbFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // Warm Cream
      appBar: AppBar(
        title: Text("Digital Herb Finder", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32), // Deep Herbal Green
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Card Section
          _buildSearchBox(),

          // Herbs List
          Expanded(
            child: StreamBuilder<List<HerbModel>>(
              stream: DbService().getHerbs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text("No medicinal herbs loaded.", style: GoogleFonts.outfit(color: Colors.grey)),
                  );
                }

                // Filtering based on search query
                final query = _searchQuery.toLowerCase().trim();
                final herbs = snapshot.data!.where((herb) {
                  return herb.name.toLowerCase().contains(query) ||
                      herb.localName.toLowerCase().contains(query) ||
                      herb.scientificName.toLowerCase().contains(query);
                }).toList();

                if (herbs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text("No herbs match your search.", style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: herbs.length,
                  itemBuilder: (context, index) {
                    final herb = herbs[index];
                    return _buildHerbCard(context, herb);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2E7D32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: "Search (e.g. Tulsi, Arya, Curcuma)",
            hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildHerbCard(BuildContext context, HerbModel herb) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showHerbDetails(context, herb),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  herb.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.spa, color: Color(0xFF2E7D32), size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    herb.name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF3E2723)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    herb.localName,
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF2E7D32), fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    herb.scientificName,
                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHerbDetails(BuildContext context, HerbModel herb) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: const BoxDecoration(
            color: Color(0xFFF9F5F0), // Warm Cream
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(herb.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              // Scrollable Details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(herb.name, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.spa, color: Color(0xFFD4AF37), size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              herb.localName,
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Scientific Name: ${herb.scientificName}",
                        style: GoogleFonts.outfit(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                      ),
                      const Divider(height: 32),

                      // Benefits
                      Text("Medicinal Benefits", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723))),
                      const SizedBox(height: 8),
                      Text(
                        herb.benefits,
                        style: GoogleFonts.outfit(fontSize: 15, color: Colors.grey[800], height: 1.6),
                      ),
                      const SizedBox(height: 24),

                      // How to use
                      Text("How to Use / Mode of Intake", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF3E2723))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.2)),
                        ),
                        child: Text(
                          herb.howToUse,
                          style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF3E2723), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
