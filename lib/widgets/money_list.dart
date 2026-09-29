import 'package:flutter/material.dart';

const List<int> coins = [1, 2, 5, 10];
const List<int> bills = [20, 50, 100, 500, 1000];

bool isCoin(int value) {
  return coins.contains(value);
}

Map<int, int> breakdown(int amount) {
  final money = [...bills, ...coins];
  money.sort((a, b) {
    return b.compareTo(a);
  });

  final result = <int, int>{};
  int left = amount;
  for (final value in money) {
    final count = left ~/ value;
    if (count > 0) {
      result[value] = count;
      left = left - value * count;
    }
  }
  return result;
}

class MoneyList extends StatelessWidget {
  final int amount;

  const MoneyList({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: breakdown(amount).entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(isCoin(entry.key) ? Icons.monetization_on : Icons.payments),
              const SizedBox(width: 12),
              Text('฿${entry.key}'),
              const Spacer(),
              Text('x ${entry.value}'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
