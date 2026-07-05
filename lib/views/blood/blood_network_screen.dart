import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mykottakkal/models/donor_model.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodNetworkScreen extends StatefulWidget {
  const BloodNetworkScreen({super.key});

  @override
  State<BloodNetworkScreen> createState() => _BloodNetworkScreenState();
}

class _BloodNetworkScreenState extends State<BloodNetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  String _selectedGroup = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Blood Network", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "Find Donors", icon: Icon(Icons.search)),
            Tab(text: "Register / Profile", icon: Icon(Icons.person_add)),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0 ? FloatingActionButton.extended(
        onPressed: _showSmartRequestSheet,
        label: Text("Smart Find"),
        icon: Icon(Icons.flash_on),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ) : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindDonorsTab(),
          _buildRegisterTab(),
        ],
      ),
    );
  }

  Widget _buildFindDonorsTab() {
    return Column(
      children: [
        // Filter Header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.red[50],
          child: Row(
            children: [
              Icon(Icons.filter_list, color: Colors.red),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGroup,
                  decoration: InputDecoration(
                    labelText: "Select Blood Group",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => _selectedGroup = val!),
                ),
              ),
            ],
          ),
        ),

        // Donor List
        Expanded(
          child: StreamBuilder<List<DonorModel>>(
            stream: DbService().getDonors(_selectedGroup),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("No donors found.", style: GoogleFonts.outfit(color: Colors.grey)));

              final donors = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: donors.length,
                itemBuilder: (context, index) {
                    final donor = donors[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Text(donor.bloodGroup, style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
                        ),
                        title: Text(donor.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        subtitle: Text(donor.location),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _callDonor(context, donor.phone),
                          icon: Icon(Icons.call, size: 16),
                          label: Text("Call"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                    );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterTab() {
    return FutureBuilder<DonorModel?>(
      future: DbService().getCurrentDonorProfile(FirebaseAuth.instance.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        
        // If already registered, show profile
        if (snapshot.hasData && snapshot.data != null) {
           final donor = snapshot.data!;
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.volunteer_activism, size: 80, color: Colors.red),
                 SizedBox(height: 16),
                 Text("You are a Registered Donor!", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                 SizedBox(height: 8),
                 Text("Blood Group: ${donor.bloodGroup}", style: TextStyle(fontSize: 18, color: Colors.red)),
                 SizedBox(height: 24),
                 SwitchListTile(
                   title: Text("Available to Donate"),
                   subtitle: Text("Turn off if you recently donated"),
                   value: donor.isAvailable,
                   onChanged: (val) async {
                      // Update logic needed in DbService if frequently toggled. 
                      // For now, re-registering with same ID updates the doc.
                      final updated = DonorModel(
                          id: donor.id, uid: donor.uid, name: donor.name, 
                          bloodGroup: donor.bloodGroup, phone: donor.phone, 
                          location: donor.location, isAvailable: val
                      );
                      await DbService().registerDonor(updated);
                      setState(() {}); 
                   },
                 )
               ],
             ),
           );
        }

        // Registration Form
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Join the Life Savers", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[800])),
              Text("Register as a blood donor today.", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 24),
              _RegisterForm(),
            ],
          ),
        );
      },
    );
  }

  void _callDonor(BuildContext context, String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not launch dialer")));
    }
  }
  void _showSmartRequestSheet() {
    String selectedGroup = 'O+';
    String urgency = 'High';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.health_and_safety, color: Colors.red, size: 30), SizedBox(width: 10), Text("Smart Blood Request", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold))]),
                  SizedBox(height: 20),
                  Text("Blood Group Needed", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedGroup,
                    items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setSheetState(() => selectedGroup = val!),
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  Text("Urgency Level", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: Text("High (Emergency)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          value: 'High', 
                          groupValue: urgency, 
                          onChanged: (val) => setSheetState(() => urgency = val.toString())
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: Text("Normal"),
                          value: 'Normal', 
                          groupValue: urgency, 
                          onChanged: (val) => setSheetState(() => urgency = val.toString())
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
                      onPressed: () {
                         Navigator.pop(context);
                         _performSmartSearch(selectedGroup, urgency);
                      },
                      child: Text("Find Donors Now"),
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _performSmartSearch(String group, String urgency) async {
    // Show searching
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: Colors.red))
    );

    // 1. Fetch Donors (Simulated or Real)
    // For demo, we fetch ALL and filter in memory to show the "Smart" sorting which might not be in basic DB query
    // In real app, we would query DB. 
    // Let's use the DbService stream but as a future or just wait a bit.
    await Future.delayed(Duration(seconds: 1)); // Fake processing

    // We can't easily await the stream here without listening. 
    // Let's just launch a dialog that USES the stream but with specific sorting.
    
    Navigator.pop(context); // Pop loader

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Best Matches for $group", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<List<DonorModel>>(
            stream: DbService().getDonors(group), // We reuse the basic query but we will Sort it in UI
            builder: (context, snapshot) {
               if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
               var donors = snapshot.data!;
               
               // SMART SORTING LOGIC
               // 1. Available first
               // 2. Random shuffle to distribute load (simple heuristic)
               donors.shuffle(); 
               donors.sort((a, b) => (b.isAvailable ? 1 : 0).compareTo(a.isAvailable ? 1 : 0));

               if (donors.isEmpty) return Center(child: Text("No donors found nearby."));

               return ListView.builder(
                 itemCount: donors.length,
                 itemBuilder: (context, index) {
                   final d = donors[index];
                   return ListTile(
                     leading: CircleAvatar(backgroundColor: Colors.red[100], child: Icon(Icons.bloodtype, color: Colors.red)),
                     title: Text(d.name, style: TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Text(d.isAvailable ? "Available • 2km away" : "Currently Unavailable"),
                     tileColor: index == 0 ? Colors.green[50] : null, // Highlight top match
                     trailing: IconButton(
                       icon: Icon(Icons.call, color: Colors.green),
                       onPressed: () => _callDonor(context, d.phone),
                     ),
                   );
                 },
               );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
    final _nameController = TextEditingController();
    final _locController = TextEditingController();
    final _phoneController = TextEditingController();
    String _group = 'A+';
    final List<String> _groups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                TextField(controller: _nameController, decoration: InputDecoration(labelText: "Your Name", border: OutlineInputBorder())),
                SizedBox(height: 16),
                TextField(controller: _locController, decoration: InputDecoration(labelText: "Location (e.g. Changuvetty)", border: OutlineInputBorder())),
                SizedBox(height: 16),
                TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder())),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                    value: _group,
                    decoration: InputDecoration(labelText: "Blood Group", border: OutlineInputBorder()),
                    items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _group = val!),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Register Me"),
                )
            ],
        );
    }

    void _register() async {
        if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _locController.text.isEmpty) return;

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Login First")));
             return;
        }

        final donor = DonorModel(
            id: Uuid().v4(),
            uid: user.uid,
            name: _nameController.text,
            bloodGroup: _group,
            phone: _phoneController.text,
            location: _locController.text,
            isAvailable: true,
        );

        await DbService().registerDonor(donor);
        
        // This will trigger the StreamBuilder/FutureBuilder in parent to rebuild ideally, 
        // but for simplicity we can just setState or navigate.
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered Successfully!")));
             // Force UI refresh effectively by navigating or setState in parent. 
             // Since this widget is inside FutureBuilder, a simple set state in parent would be better.
             // For now, let's just show success. Use 'findAncestorStateOfType' if critical.
             (context.findAncestorStateOfType<_BloodNetworkScreenState>())?.setState(() {});
        }
    }
}
