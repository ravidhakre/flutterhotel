import 'package:cloud_firestore/cloud_firestore.dart';

class NightlyRateModel {
  final DateTime date;
  final double rate;

  NightlyRateModel({
    required this.date,
    required this.rate,
  });

  factory NightlyRateModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return NightlyRateModel(
      date: parseDate(map['date']),
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'rate': rate,
    };
  }
}
