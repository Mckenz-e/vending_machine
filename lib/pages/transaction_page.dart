import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/item.dart';
import '../services/stock_service.dart';
import '../widgets/item_image.dart';
import '../widgets/money_list.dart';

class TransactionPage extends StatefulWidget {
  final Map<Item, int> cart;

  const TransactionPage({super.key, required this.cart});

  @override
  State<TransactionPage> createState() {
    return _TransactionPageState();
  }
}

class _TransactionPageState extends State<TransactionPage> {
  final StockService _service = StockService();
  String _payment = 'cash';
  int _inserted = 0;

  int get _total {
    int total = 0;
    widget.cart.forEach((item, amount) {
      total = total + item.price * amount;
    });
    return total;
  }

  Future<void> _pay() async {
    final paid = _payment == 'cash' ? _inserted : _total;

    try {
      await _service.buyItems(widget.cart, _payment, paid);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      return;
    }

    await _showMoneyDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      title: 'Thank you!',
      message: 'Please take your booster packs.',
      money: paid - _total,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _returnMoney() async {
    final amount = _inserted;
    setState(() {
      _inserted = 0;
    });

    await _showMoneyDialog(
      icon: const Icon(Icons.undo, size: 48),
      title: 'Returned $amount ฿',
      message: 'Please take your money.',
      money: amount,
    );
  }

  Future<void> _showMoneyDialog({
    required Icon icon,
    required String title,
    required String message,
    required int money,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: icon,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              if (money > 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Your money: $money ฿',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                MoneyList(amount: money),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String get _screenMessage {
    if (_inserted == 0) return 'Insert money to pay $_total ฿';
    if (_inserted < _total) return 'Insert ${_total - _inserted} ฿ more';
    return 'Ready! Press BUY';
  }

  Widget _buildCashPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: darkBrown,
            border: Border.all(color: gold, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '฿$_inserted',
                style: const TextStyle(
                  color: gold,
                  fontSize: 36,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(_screenMessage, style: const TextStyle(color: gold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Insert money'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [...coins, ...bills].map((value) {
            return OutlinedButton.icon(
              icon: Icon(
                isCoin(value) ? Icons.monetization_on : Icons.payments,
              ),
              label: Text('฿$value'),
              onPressed: () {
                setState(() {
                  _inserted = _inserted + value;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.shopping_cart),
          label: const Text('BUY'),
          onPressed: _inserted >= _total ? _pay : null,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.undo),
          label: const Text('Return change'),
          onPressed: _inserted > 0 ? _returnMoney : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ...widget.cart.entries.map((entry) {
                  final item = entry.key;
                  return ListTile(
                    leading: ItemImage(item: item, size: 40),
                    title: Text(item.name),
                    subtitle: Text('${item.price} ฿ x ${entry.value}'),
                    trailing: Text('${item.price * entry.value} ฿'),
                  );
                }),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '$_total ฿',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Choose payment method'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'cash',
                label: Text('Cash'),
                icon: Icon(Icons.payments),
              ),
              ButtonSegment(
                value: 'online',
                label: Text('Online'),
                icon: Icon(Icons.qr_code),
              ),
            ],
            selected: {_payment},
            onSelectionChanged: (selected) {
              setState(() {
                _payment = selected.first;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_payment == 'cash')
            _buildCashPanel()
          else ...[
            const Icon(Icons.qr_code_2, size: 160),
            const Text(
              'Scan to pay, then press Confirm',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _pay,
              child: const Text('Confirm online payment'),
            ),
          ],
        ],
      ),
    );
  }
}
