
class Price {
  final String id;
  final String cropName;
  final double price;
  final String market;
  final DateTime lastUpdated;

  Price({
    required this.id,
    required this.cropName,
    required this.price,
    required this.market,
    required this.lastUpdated,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['id'] as String,
      cropName: json['cropName'] as String,
      price: (json['price'] as num).toDouble(),
      market: json['market'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
