import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class StockService {
  static const String keyStock = 'stock';
  static const String keyTransactions = 'transactions';

  Future<Map<String, int>> loadStock() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(keyStock);
    if (text == null) return {};

    final json = jsonDecode(text) as Map<String, dynamic>;
    return json.map((id, count) {
      return MapEntry(id, count as int);
    });
  }

  Future<void> _saveStock(Map<String, int> stock) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyStock, jsonEncode(stock));
  }

  Future<void> addStock(String id, int amount) async {
    final stock = await loadStock();
    stock[id] = (stock[id] ?? 0) + amount;
    await _saveStock(stock);
  }

  Future<void> clearStock(String id) async {
    final stock = await loadStock();
    stock.remove(id);
    await _saveStock(stock);
  }

  Future<void> buyItems(Map<Item, int> cart, String payment, int paid) async {
    final stock = await loadStock();

    cart.forEach((item, amount) {
      if ((stock[item.id] ?? 0) < amount) {
        throw Exception('${item.name} has only ${stock[item.id] ?? 0} left');
      }
    });

    int total = 0;
    cart.forEach((item, amount) {
      stock[item.id] = stock[item.id]! - amount;
      total = total + item.price * amount;
    });
    await _saveStock(stock);

    final prefs = await SharedPreferences.getInstance();
    final history = jsonDecode(prefs.getString(keyTransactions) ?? '[]') as List;
    history.add({
      'items': cart.entries.map((entry) {
        return {'id': entry.key.id, 'name': entry.key.name, 'amount': entry.value};
      }).toList(),
      'total': total,
      'payment': payment,
      'paid': paid,
      'change': paid - total,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(keyTransactions, jsonEncode(history));
  }
}
