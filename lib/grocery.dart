// Main class of grocery
class Grocery {
  final int? id;
  final String name;
  Grocery({this.id, required this.name});

  factory Grocery.fromMap(Map<String, dynamic> json) {
    return Grocery(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
