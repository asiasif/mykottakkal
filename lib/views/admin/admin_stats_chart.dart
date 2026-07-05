import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:intl/intl.dart';

class AdminStatsChart extends StatelessWidget {
  final List<BookingModel> bookings;

  const AdminStatsChart({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryPieChart(),
        SizedBox(height: 16),
        _buildWeeklyBarChart(),
      ],
    );
  }

  Widget _buildCategoryPieChart() {
    Map<String, int> categoryCounts = {};
    for (var booking in bookings) {
      categoryCounts[booking.serviceCategory] = (categoryCounts[booking.serviceCategory] ?? 0) + 1;
    }

    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    int colorIndex = 0;

    List<PieChartSectionData> sections = categoryCounts.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      final percentage = (entry.value / bookings.length * 100).toStringAsFixed(0);

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n$percentage%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Bookings by Category", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    // Get last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Map<int, int> dailyCounts = {};

    for (int i = 0; i < 7; i++) {
        dailyCounts[i] = 0; // Initialize 0 for last 7 days
    }

    for (var booking in bookings) {
       final bookingDate = DateTime(booking.bookingDate.year, booking.bookingDate.month, booking.bookingDate.day);
       final difference = today.difference(bookingDate).inDays;
       if (difference >= 0 && difference < 7) {
         // 0 is today, 6 is 7 days ago
         // We want to map it to 6 (today) down to 0 (7 days ago) for the chart X-axis
         // Let's say X axis 0 is 6 days ago, X axis 6 is today.
         final xIndex = 6 - difference;
         dailyCounts[xIndex] = (dailyCounts[xIndex] ?? 0) + 1;
       }
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyCounts[i]!.toDouble(),
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      );
    }
    
    // Calculate max Y for better scaling
    double maxY = 0;
    dailyCounts.forEach((key, value) {
      if (value > maxY) maxY = value.toDouble();
    });
    maxY = maxY + 2; // Add some buffer

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Bookings (Last 7 Days)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                     show: true,
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (double value, TitleMeta meta) {
                           final date = today.subtract(Duration(days: 6 - value.toInt()));
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(DateFormat('E').format(date), style: TextStyle(fontSize: 10)),
                           );
                         },
                       ),
                     ),
                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
