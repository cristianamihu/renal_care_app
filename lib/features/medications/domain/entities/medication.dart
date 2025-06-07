class Medication {
  final String id; // medId-ul Firestore
  final String name; // numele medicamentului
  final double dose; // doză (numerică)
  final String unit; // unitate (ex. "mg", "ml", "fiolă")
  final DateTime startDate; // data de start a tratamentului
  final DateTime? endDate; // data de sfârșit a tratamentului (poate fi null)
  final int frequency; // frecvența (în zile)
  final List<DateTime> times; // orele din zi
  final bool notificationsEnabled; // user vrea notificări sau nu
  final DateTime createdAt; // timestamp de creare
  final DateTime updatedAt; // timestamp de ultimă modificare
  final List<int> specificWeekdays;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.unit,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.times,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.specificWeekdays = const [],
  });
}
