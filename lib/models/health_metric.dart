class HealthMetric {
  final String id;
  final String name;
  final String icon;
  final String unit;
  final double? goal;

  HealthMetric({
    required this.id,
    required this.name,
    required this.icon,
    required this.unit,
    this.goal,
  });
}
