import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/daily_rates_model.dart';
import 'package:mykottakkal/models/agro_price_model.dart';
import 'package:intl/intl.dart';

class AdminManageRatesScreen extends StatefulWidget {
  const AdminManageRatesScreen({super.key});

  @override
  State<AdminManageRatesScreen> createState() => _AdminManageRatesScreenState();
}

class _AdminManageRatesScreenState extends State<AdminManageRatesScreen> {
  final _goldFormKey = GlobalKey<FormState>();
  final _g24Controller = TextEditingController();
  final _g22Controller = TextEditingController();
  final _silverController = TextEditingController();

  bool _isManualOverride = false;
  DailyRatesModel? _currentRates;

  @override
  void dispose() {
    _g24Controller.dispose();
    _g22Controller.dispose();
    _silverController.dispose();
    super.dispose();
  }

  void _populateRates(DailyRatesModel rates) {
    _currentRates = rates;
    _isManualOverride = rates.isManual;
    _g24Controller.text = rates.manualGold24k.toStringAsFixed(0);
    _g22Controller.text = rates.manualGold22k.toStringAsFixed(0);
    _silverController.text = rates.manualSilver.toStringAsFixed(2);
  }

  Future<void> _saveGoldRates() async {
    if (!_goldFormKey.currentState!.validate()) return;

    try {
      final double g24 = double.parse(_g24Controller.text);
      final double g22 = double.parse(_g22Controller.text);
      final double sil = double.parse(_silverController.text);

      final updated = DailyRatesModel(
        gold24k: _currentRates?.gold24k ?? 0.0,
        gold22k: _currentRates?.gold22k ?? 0.0,
        silver: _currentRates?.silver ?? 0.0,
        updatedAt: DateTime.now(),
        isManual: _isManualOverride,
        manualGold24k: g24,
        manualGold22k: g22,
        manualSilver: sil,
      );

      await DbService().updateDailyRates(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gold/Silver rates updated successfully!"), backgroundColor: Colors.green)
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    }
  }

  Future<void> _toggleManualMode(bool val) async {
    setState(() => _isManualOverride = val);
    if (_currentRates != null) {
      final updated = DailyRatesModel(
        gold24k: _currentRates!.gold24k,
        gold22k: _currentRates!.gold22k,
        silver: _currentRates!.silver,
        updatedAt: DateTime.now(),
        isManual: val,
        manualGold24k: _currentRates!.manualGold24k == 0.0 ? _currentRates!.gold24k : _currentRates!.manualGold24k,
        manualGold22k: _currentRates!.manualGold22k == 0.0 ? _currentRates!.gold22k : _currentRates!.manualGold22k,
        manualSilver: _currentRates!.manualSilver == 0.0 ? _currentRates!.silver : _currentRates!.manualSilver,
      );
      await DbService().updateDailyRates(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        title: Text("Manage Market Rates", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DailyRatesModel?>(
        stream: DbService().getDailyRates(),
        builder: (context, ratesSnap) {
          if (ratesSnap.hasData && ratesSnap.data != null && _currentRates == null) {
            _populateRates(ratesSnap.data!);
          }
          
          return StreamBuilder<List<AgroPriceModel>>(
            stream: DbService().getAgroPrices(),
            builder: (context, agroSnap) {
              final agroPrices = agroSnap.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Section 1: Gold & Silver Live vs Manual Override
                  _buildOverrideSection(),
                  const SizedBox(height: 24),

                  // Section 2: Agro Produce Wholesale Rates
                  _buildAgroProduceSection(agroPrices),
                ],
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildOverrideSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _goldFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Gold & Silver Rates", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                Switch.adaptive(
                  value: _isManualOverride,
                  activeColor: Colors.orange[800],
                  onChanged: _toggleManualMode,
                )
              ],
            ),
            Text("Enable manual override to enter custom rates for your city storefront.", 
              style: TextStyle(color: Colors.grey[650], fontSize: 12)
            ),
            const Divider(height: 30),

            if (!_isManualOverride) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("Active rates are currently fetched automatically from international metal markets.",
                        style: TextStyle(color: Colors.green[900], fontSize: 12)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _g24Controller,
              enabled: _isManualOverride,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("24K Gold Price (per Gram)"),
              validator: (value) => value == null || value.trim().isEmpty ? "Enter price" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _g22Controller,
              enabled: _isManualOverride,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("22K Gold Price (per Gram)"),
              validator: (value) => value == null || value.trim().isEmpty ? "Enter price" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _silverController,
              enabled: _isManualOverride,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration("Silver Price (per Gram)"),
              validator: (value) => value == null || value.trim().isEmpty ? "Enter price" : null,
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isManualOverride ? _saveGoldRates : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text("Save Gold & Silver Rates", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAgroProduceSection(List<AgroPriceModel> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kottakkal Wholesale Produce Prices", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("These local rates are managed manually. Click on any item to update today's wholesale rate.", 
            style: TextStyle(color: Colors.grey[650], fontSize: 12)
          ),
          const Divider(height: 30),

          if (items.isEmpty) ...[
            const Center(child: CircularProgressIndicator(color: Colors.green)),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("Price: ₹${item.price.round()} per ${item.unit} | Trend: ${item.trend.toUpperCase()}"),
                  trailing: Icon(Icons.edit, color: Colors.green[800], size: 20),
                  onTap: () => _showEditAgroDialog(item),
                );
              },
            )
          ]
        ],
      ),
    );
  }

  void _showEditAgroDialog(AgroPriceModel item) {
    final priceController = TextEditingController(text: item.price.toStringAsFixed(0));
    final unitController = TextEditingController(text: item.unit);
    String selectedTrend = item.trend;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Edit ${item.name}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price (₹)"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: "Unit (e.g., kg, bundle)"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedTrend,
                    decoration: const InputDecoration(labelText: "Price Trend"),
                    items: const [
                      DropdownMenuItem(value: 'stable', child: Text("Stable")),
                      DropdownMenuItem(value: 'up', child: Text("Increasing (Up)")),
                      DropdownMenuItem(value: 'down', child: Text("Decreasing (Down)")),
                    ],
                    onChanged: (val) => setDialogState(() => selectedTrend = val ?? 'stable'),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final price = double.tryParse(priceController.text) ?? item.price;
                    final unit = unitController.text.trim();
                    final updated = AgroPriceModel(
                      id: item.id,
                      name: item.name,
                      price: price,
                      unit: unit.isEmpty ? item.unit : unit,
                      trend: selectedTrend,
                      updatedAt: DateTime.now()
                    );
                    await DbService().updateAgroPrice(updated);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text("Updated ${item.name} daily price!"), backgroundColor: Colors.green)
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
                  child: const Text("Save"),
                )
              ],
            );
          }
        );
      }
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
