import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mykottakkal/services/db_service.dart';
import 'package:mykottakkal/models/daily_rates_model.dart';
import 'package:mykottakkal/models/agro_price_model.dart';
import 'package:intl/intl.dart';

class DailyRatesScreen extends StatefulWidget {
  const DailyRatesScreen({super.key});

  @override
  State<DailyRatesScreen> createState() => _DailyRatesScreenState();
}

class _DailyRatesScreenState extends State<DailyRatesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _triggerAutoRefresh();
  }

  Future<void> _triggerAutoRefresh() async {
    // Get the current snapshot in a one-time fetch to see if we need refresh
    final DbService db = DbService();
    try {
      final rates = await db.getDailyRates().first;
      if (rates == null || 
          DateTime.now().difference(rates.updatedAt).inHours >= 6) {
        if (rates == null || !rates.isManual) {
          await _fetchLiveRatesAndSave(rates);
        }
      }
    } catch (e) {
      debugPrint("Auto refresh rates error: $e");
    }
  }

  Future<void> _fetchLiveRatesAndSave(DailyRatesModel? current) async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Gold Spot Price
      final goldResponse = await http.get(Uri.parse('https://api.gold-api.com/price/XAU'));
      // 2. Fetch Silver Spot Price
      final silverResponse = await http.get(Uri.parse('https://api.gold-api.com/price/XAG'));
      // 3. Fetch USD to INR Exchange Rate
      final exResponse = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));

      if (goldResponse.statusCode == 200 &&
          silverResponse.statusCode == 200 &&
          exResponse.statusCode == 200) {
        
        final goldData = jsonDecode(goldResponse.body);
        final silverData = jsonDecode(silverResponse.body);
        final exData = jsonDecode(exResponse.body);

        final double usdPriceGoldOz = (goldData['price'] as num).toDouble();
        final double usdPriceSilverOz = (silverData['price'] as num).toDouble();
        final double usdToInr = (exData['rates']['INR'] as num).toDouble();

        // Conversion logic: 1 Troy ounce = 31.1034768 Grams
        const double gramsPerOz = 31.1034768;
        final double gold24kPerGram = (usdPriceGoldOz / gramsPerOz) * usdToInr;
        final double gold22kPerGram = gold24kPerGram * 0.916; // Standard 91.6% purity
        final double silverPerGram = (usdPriceSilverOz / gramsPerOz) * usdToInr;

        final newRates = DailyRatesModel(
          gold24k: gold24kPerGram,
          gold22k: gold22kPerGram,
          silver: silverPerGram,
          updatedAt: DateTime.now(),
          isManual: current?.isManual ?? false,
          manualGold24k: current?.manualGold24k ?? 0.0,
          manualGold22k: current?.manualGold22k ?? 0.0,
          manualSilver: current?.manualSilver ?? 0.0,
        );

        await DbService().updateDailyRates(newRates);
      }
    } catch (e) {
      debugPrint("Error fetching live rates: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFC),
      appBar: AppBar(
        title: Text("Market & Commodity Rates", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () async {
              final current = await DbService().getDailyRates().first;
              await _fetchLiveRatesAndSave(current);
            },
          )
        ],
      ),
      body: StreamBuilder<DailyRatesModel?>(
        stream: DbService().getDailyRates(),
        builder: (context, ratesSnap) {
          final rates = ratesSnap.data;
          
          return StreamBuilder<List<AgroPriceModel>>(
            stream: DbService().getAgroPrices(),
            builder: (context, agroSnap) {
              final agroPrices = agroSnap.data ?? [];

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  
                  // Gold Rates Section
                  _buildGoldRatesCard(rates),
                  const SizedBox(height: 20),

                  // Silver Rates Section
                  _buildSilverRatesCard(rates),
                  const SizedBox(height: 24),

                  // Local Agro Produce Index Section
                  _buildAgroIndexSection(agroPrices),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Data fetched automatically from Google & FX markets.\nLocal prices may vary by jeweler or merchant taxes.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up, color: Colors.green[700], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kottakkal Market Updates", 
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[900])
                ),
                const SizedBox(height: 2),
                Text("Get live gold/silver rates and daily wholesale rates of local agricultural products.",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.green[800], height: 1.3)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoldRatesCard(DailyRatesModel? rates) {
    // Determine active rates based on manual override
    final bool isManual = rates?.isManual ?? false;
    final double g24 = isManual ? (rates?.manualGold24k ?? 0.0) : (rates?.gold24k ?? 0.0);
    final double g22 = isManual ? (rates?.manualGold22k ?? 0.0) : (rates?.gold22k ?? 0.0);
    final double sovereign = g22 * 8; // 8 grams per sovereign
    final String timeStr = rates != null 
        ? DateFormat('dd MMM yyyy, hh:mm a').format(rates.updatedAt) 
        : 'Loading...';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.amber.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: const Icon(Icons.star, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text("Gold Rate (Kottakkal)", 
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF5D4037))
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isManual ? Colors.orange[800] : Colors.green[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isManual ? "ADMIN RATE" : "LIVE RATE",
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // 22K Sovereign
            Text("22 Karat (1 Sovereign / 8g)", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text("₹${NumberFormat('#,##,###').format(sovereign.round())}",
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF3E2723))
            ),
            const Divider(height: 24, color: Colors.amber),
            
            // Sub rates row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("22K Gold (1 Gram)", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text("₹${NumberFormat('#,###').format(g22.round())}",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("24K Gold (1 Gram)", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text("₹${NumberFormat('#,###').format(g24.round())}",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("As of: $timeStr", style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildSilverRatesCard(DailyRatesModel? rates) {
    final bool isManual = rates?.isManual ?? false;
    final double silverG = isManual ? (rates?.manualSilver ?? 0.0) : (rates?.silver ?? 0.0);
    final double silverKg = silverG * 1000;
    final String timeStr = rates != null 
        ? DateFormat('dd MMM yyyy, hh:mm a').format(rates.updatedAt) 
        : 'Loading...';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                      child: const Icon(Icons.circle_outlined, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text("Silver Rate", 
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF37474F))
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isManual ? Colors.orange[800] : Colors.blueGrey[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isManual ? "ADMIN RATE" : "LIVE RATE",
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Silver (1 Kg)", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text("₹${NumberFormat('#,##,###').format(silverKg.round())}",
                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF263238))
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Silver (1 Gram)", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text("₹${silverG.toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF37474F))
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("As of: $timeStr", style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgroIndexSection(List<AgroPriceModel> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text("Kottakkal Agro Market (Wholesale)", 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle
                      ),
                      child: Icon(Icons.eco, color: Colors.green[700], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 2),
                          Text("Updated: ${DateFormat('dd MMM hh:mm a').format(item.updatedAt)}", 
                            style: TextStyle(fontSize: 10, color: Colors.grey[500])
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("₹${NumberFormat('#,###').format(item.price.round())}",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green[900])
                            ),
                            Text("per ${item.unit}", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(width: 10),
                        _buildTrendBadge(item.trend),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendBadge(String trend) {
    IconData icon;
    Color color;
    if (trend == 'up') {
      icon = Icons.arrow_upward;
      color = Colors.green;
    } else if (trend == 'down') {
      icon = Icons.arrow_downward;
      color = Colors.red;
    } else {
      icon = Icons.remove;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }
}
