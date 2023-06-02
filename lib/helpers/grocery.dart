class Grocery {
  final int? id;
  final String? name;
  final DateTime? dateTime;

  Grocery({this.id, this.name, this.dateTime});

  factory Grocery.fromMap(Map<String, dynamic> json) {
    return Grocery(
      id: json['id'],
      name: json['name'] as String?,
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
    );
  }
  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'dateTime': dateTime != null ? dateTime!.toIso8601String() : null,
  };
}
}
