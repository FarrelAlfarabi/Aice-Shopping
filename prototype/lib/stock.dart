import 'data.dart';

/// Sample stock for the admin side and the product cards. All numbers are made
/// up ("contoh"). Kept in memory only.
class StockInfo {
  int stock;
  final int reorder; // reorder point: at or below this, a P1 alarm shows
  final bool nearExpiry;
  StockInfo(this.stock, this.reorder, {this.nearExpiry = false});
  bool get low => stock <= reorder;
}

Map<String, StockInfo> seedStock() {
  // Default: plenty of stock. A few are low, one is near expiry.
  final m = <String, StockInfo>{
    for (final p in catalog) p.id: StockInfo(p.soldOut ? 0 : 60, 20),
  };
  m['cone-vanila'] = StockInfo(15, 20); // low
  m['cup-blueberry'] = StockInfo(18, 25); // low
  m['cone-cokelat'] = StockInfo(84, 20);
  m['frozen-naget'] = StockInfo(22, 25); // low
  m['cup-original'] = StockInfo(114, 40);
  m['tub-stroberi'] = StockInfo(28, 10);
  m['cup-matcha'] = StockInfo(40, 20, nearExpiry: true);
  m['stik-cokelat'] = StockInfo(96, 30);
  // Everyday shelves: fresh greens sell out fast, rice moves in sacks.
  m['veg-bayam'] = StockInfo(12, 15, nearExpiry: true); // low, near expiry
  m['veg-tomat'] = StockInfo(34, 15);
  m['staple-beras'] = StockInfo(26, 10);
  m['staple-minyak'] = StockInfo(8, 12); // low
  m['snack-wafer'] = StockInfo(72, 24);
  m['drink-air'] = StockInfo(140, 48);
  return m;
}

/// Cold-chain failure alarm (P0). Low stock alarms (P1) are worked out from
/// [StockInfo.low] and are not stored.
class ColdAlarm {
  final String id;
  final String text;
  bool resolved;
  ColdAlarm(this.id, this.text, {this.resolved = false});
}

List<ColdAlarm> seedColdAlarms() => [
  ColdAlarm('p0-1', 'Freezer Toko Beku Makmur naik ke -9 °C'),
];

class Expense {
  final String label;
  final int amount;
  const Expense(this.label, this.amount);
}

const seedExpenses = <Expense>[
  Expense('Listrik freezer', 1850000),
  Expense('Bensin kurir', 920000),
  Expense('Es kering dan tas pendingin', 640000),
  Expense('Gaji bulanan', 3600000),
];

/// Sales from earlier this month that are not in the order list (sample).
const baselinePayments = 2400000;
