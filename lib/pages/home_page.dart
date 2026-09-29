import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/item_list.dart';
import '../models/item.dart';
import '../services/stock_service.dart';
import '../widgets/item_image.dart';
import 'admin_page.dart';
import 'transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final StockService _service = StockService();
  late Future<Map<String, int>> _futureStock;

  final Map<Item, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _futureStock = _service.loadStock();
  }

  void _reload() {
    setState(() {
      _futureStock = _service.loadStock();
    });
  }

  void _addToCart(Item item, int stock) {
    final current = _cart[item] ?? 0;
    if (current >= stock) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only $stock ${item.name} left')),
      );
      return;
    }
    setState(() {
      _cart[item] = current + 1;
    });
  }

  void _removeFromCart(Item item) {
    setState(() {
      final current = _cart[item]!;
      if (current <= 1) {
        _cart.remove(item);
      } else {
        _cart[item] = current - 1;
      }
    });
  }

  int get _totalCount {
    int count = 0;
    _cart.forEach((item, amount) {
      count = count + amount;
    });
    return count;
  }

  int get _totalPrice {
    int total = 0;
    _cart.forEach((item, amount) {
      total = total + item.price * amount;
    });
    return total;
  }

  Future<bool> _askPin() async {
    final controller = TextEditingController();

    final pin = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.lock, size: 48),
          title: const Text('Admin only'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            autofocus: true,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(labelText: 'Enter PIN'),
            onSubmitted: (value) {
              Navigator.pop(context, value);
            },
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
                Navigator.pop(context, controller.text);
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );

    if (pin == null) return false;
    if (pin != adminPin) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN')),
      );
      return false;
    }
    return true;
  }

  Future<void> _openAdmin() async {
    final unlocked = await _askPin();
    if (!unlocked || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const AdminPage();
        },
      ),
    );
    _cart.clear();
    _reload();
  }

  Future<void> _checkout() async {
    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TransactionPage(cart: Map.of(_cart));
        },
      ),
    );
    if (paid == true) {
      _cart.clear();
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yu-Gi-Oh! Booster Machine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin',
            onPressed: _openAdmin,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [brown, darkBrown],
            ),
            border: Border.all(color: gold, width: 3),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              const _Marquee(),
              Expanded(child: _buildWindow()),
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWindow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1C0E), Color(0xFF120B04)],
        ),
        border: Border.all(color: Colors.black, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FutureBuilder<Map<String, int>>(
        future: _futureStock,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          final stock = snapshot.data!;
          final items = allItems.where((item) {
            return stock.containsKey(item.id);
          }).toList();

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Machine is empty.\nAdd packs in Admin page.',
                textAlign: TextAlign.center,
                style: TextStyle(color: parchment),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.5,
              crossAxisSpacing: 4,
              mainAxisSpacing: 10,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final code = '${String.fromCharCode(65 + i ~/ 3)}${i % 3 + 1}';
              return _Slot(
                item: item,
                code: code,
                stock: stock[item.id]!,
                inCart: _cart[item] ?? 0,
                onAdd: () {
                  _addToCart(item, stock[item.id]!);
                },
                onRemove: () {
                  _removeFromCart(item);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildControlPanel() {
    final hasItems = _cart.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: gold),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hasItems ? '$_totalCount PACKS  ฿$_totalPrice' : 'CHOOSE A PACK',
                style: const TextStyle(
                  color: gold,
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: darkBrown,
              disabledBackgroundColor: brown,
              disabledForegroundColor: parchment.withValues(alpha: 0.5),
              minimumSize: const Size(0, 52),
            ),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: hasItems ? _checkout : null,
          ),
        ],
      ),
    );
  }
}

class _Marquee extends StatelessWidget {
  const _Marquee();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB8902A), gold, Color(0xFFB8902A)]),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: gold.withValues(alpha: 0.6), blurRadius: 12),
        ],
      ),
      child: const Text(
        'BOOSTER PACKS',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: darkBrown,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final Item item;
  final String code;
  final int stock;
  final int inCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _Slot({
    required this.item,
    required this.code,
    required this.stock,
    required this.inCart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final soldOut = stock <= 0;
    final selected = inCart > 0;

    return GestureDetector(
      onTap: soldOut ? null : onAdd,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: selected ? gold : Colors.transparent, width: 2),
                boxShadow: selected
                    ? [BoxShadow(color: gold.withValues(alpha: 0.5), blurRadius: 10)]
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: soldOut ? 0.3 : 1,
                      child: ItemImage(item: item, size: 170),
                    ),
                  ),
                  if (soldOut)
                    Center(
                      child: Transform.rotate(
                        angle: -0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: Colors.red.shade800,
                          child: const Text(
                            'SOLD OUT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  if (selected) ...[
                    Positioned(
                      top: 2,
                      right: 2,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: gold,
                        child: Text(
                          '$inCart',
                          style: const TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -8,
                      left: -8,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        tooltip: 'Remove one',
                        onPressed: onRemove,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFBDBDBD), Color(0xFF616161)],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '$code  ฿${item.price}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: gold,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: parchment, fontSize: 11),
          ),
          Text(
            soldOut ? 'Sold out' : 'Left: $stock',
            style: TextStyle(color: parchment.withValues(alpha: 0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
