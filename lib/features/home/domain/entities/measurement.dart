class Measurement {
  final double weight; // kg
  final double height; // cm
  final double bmi;
  final double glucose; // mg/dL sau mmol/L
  final int systolic; //mmHg
  final int diastolic; //mmHg
  final double temperature; // °C
  final DateTime date;
  final String moment; // momentul zilei (ex: "Dimineața", "După prânz" etc.)

  Measurement({
    required this.weight,
    required this.height,
    required this.bmi,
    required this.glucose,
    required this.systolic,
    required this.diastolic,
    required this.temperature,
    required this.date,
    required this.moment,
  });
}
