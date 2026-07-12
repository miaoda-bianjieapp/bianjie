class StockStat {
  const StockStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  factory StockStat.fromJson(Map<String, dynamic> json) {
    return StockStat(
      label: json['label'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
    );
  }
}
