
class Item {
  final String id;
  final String name;
  final int price; 

  const Item({required this.id, required this.name, required this.price});

  String get image {
    return 'assets/items/$id.png';
  }
}
