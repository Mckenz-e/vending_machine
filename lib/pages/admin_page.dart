import 'package:flutter/material.dart';

import '../data/item_list.dart';
import '../models/item.dart';
import '../services/stock_service.dart';
import '../widgets/item_image.dart';

const String adminPin = '1234';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  final StockService _service = StockService();
  Map<String, int> _stock = {};

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  Future<void> _loadStock() async {
    final stock = await _service.loadStock();
    setState(() {
      _stock = stock;
    });
  }

  Future<void> _askAmount(Item item) async {
    final controller = TextEditingController(text: '1');

    final amount = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ${item.name}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'How many?'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, int.tryParse(controller.text));
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (amount == null || amount <= 0) return;
    await _service.addStock(item.id, amount);
    await _loadStock();
  }

  Future<void> _clear(Item item) async {
    await _service.clearStock(item.id);
    await _loadStock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Fill the machine')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: allItems.length,
        itemBuilder: (context, i) {
          final item = allItems[i];
          final count = _stock[item.id];
          final inMachine = count != null;

          return Card(
            child: ListTile(
              leading: ItemImage(item: item, size: 40),
              title: Text(item.name),
              subtitle: Text(
                inMachine
                    ? '${item.price} ฿  •  In machine: $count'
                    : '${item.price} ฿',
              ),
              trailing: inMachine
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove from machine',
                      onPressed: () {
                        _clear(item);
                      },
                    )
                  : const Icon(Icons.add_circle_outline),
              onTap: () {
                _askAmount(item);
              },
            ),
          );
        },
      ),
    );
  }
}
