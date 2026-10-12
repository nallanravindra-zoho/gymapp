import '../../core/time/local_date.dart';

/// Pure rules for the profile and body-metrics features (R10).

/// Age in whole years on [today] (`yyyy-MM-dd`) for a date of birth [dob]
/// (`yyyy-MM-dd`). Null when [dob] is missing, unreadable or in the future.
/// Age is always calculated, never stored.
int? ageOn(String? dob, String today) {
  if (dob == null || dob.isEmpty) return null;
  final DateTime b;
  final DateTime t;
  try {
    b = parseLocalDate(dob);
    t = parseLocalDate(today);
  } catch (_) {
    return null;
  }
  if (b.isAfter(t)) return null;
  var age = t.year - b.year;
  if (t.month < b.month || (t.month == b.month && t.day < b.day)) age--;
  return age;
}

/// The age at which adult BMI categories apply.
const adultAge = 18;

enum BmiBand { underweight, healthyRange, overweight, obesity }

enum BmiStatus {
  /// No weight or height to calculate from.
  noData,

  /// A BMI exists but no date of birth, so it cannot be interpreted.
  needsDob,

  /// Under 18: adult categories must not be applied.
  minor,

  /// Adult: [BmiAssessment.band] is set.
  adult,
}

class BmiAssessment {
  const BmiAssessment(this.status, {this.bmi, this.band});
  final BmiStatus status;
  final double? bmi;
  final BmiBand? band;
}

/// Decides how a BMI may be interpreted. Adult bands (general reference
/// ranges) apply only for [age] >= 18.
BmiAssessment assessBmi({required double? bmi, required int? age}) {
  if (bmi == null) return const BmiAssessment(BmiStatus.noData);
  if (age == null) return BmiAssessment(BmiStatus.needsDob, bmi: bmi);
  if (age < adultAge) return BmiAssessment(BmiStatus.minor, bmi: bmi);
  final band = bmi < 18.5
      ? BmiBand.underweight
      : bmi < 25
      ? BmiBand.healthyRange
      : bmi < 30
      ? BmiBand.overweight
      : BmiBand.obesity;
  return BmiAssessment(BmiStatus.adult, bmi: bmi, band: band);
}

String bmiBandLabel(BmiBand b) => switch (b) {
  BmiBand.underweight => 'Below the general reference range',
  BmiBand.healthyRange => 'Within the general reference range',
  BmiBand.overweight => 'Above the general reference range',
  BmiBand.obesity => 'Well above the general reference range',
};

const nhsBmiUrl =
    'https://www.nhs.uk/health-assessment-tools/calculate-your-body-mass-index/';

/// How often measurements are due.
enum MeasurementCadence {
  weekly('weekly', 'Every week'),
  biweekly('biweekly', 'Every two weeks'),
  monthly('monthly', 'Every month'),
  bimonthly('bimonthly', 'Every two months');

  const MeasurementCadence(this.key, this.label);
  final String key;
  final String label;

  static MeasurementCadence parse(String? key) =>
      MeasurementCadence.values.firstWhere(
        (c) => c.key == key,
        orElse: () => MeasurementCadence.monthly,
      );
}

/// The date the next measurements are due after [from] (`yyyy-MM-dd`).
/// Months are calendar months; a day past the end of the target month moves
/// to that month's last day.
String nextMeasurementDue(String from, MeasurementCadence cadence) {
  switch (cadence) {
    case MeasurementCadence.weekly:
      return shiftLocalDate(from, 7);
    case MeasurementCadence.biweekly:
      return shiftLocalDate(from, 14);
    case MeasurementCadence.monthly:
      return _addMonths(from, 1);
    case MeasurementCadence.bimonthly:
      return _addMonths(from, 2);
  }
}

String _addMonths(String from, int months) {
  final d = parseLocalDate(from);
  final index = d.year * 12 + (d.month - 1) + months;
  final y = index ~/ 12;
  final m = index % 12 + 1;
  final last = DateTime.utc(y, m + 1, 0).day;
  return formatLocalDate(y, m, d.day > last ? last : d.day);
}

/// Days before measurement day that the heads-up appears.
const measurementLeadDays = 2;

enum MeasurementNoticeKind { none, upcoming, dueToday, overdue }

class MeasurementNotice {
  const MeasurementNotice(this.kind, [this.days = 0]);
  static const none = MeasurementNotice(MeasurementNoticeKind.none);

  final MeasurementNoticeKind kind;

  /// Days until (upcoming) or since (overdue) measurement day.
  final int days;

  bool get visible => kind != MeasurementNoticeKind.none;

  String get message => switch (kind) {
    MeasurementNoticeKind.none => '',
    MeasurementNoticeKind.upcoming =>
      days == 1
          ? 'Measurements day is tomorrow'
          : 'Measurements day in $days days',
    MeasurementNoticeKind.dueToday => 'Measurements day is today',
    MeasurementNoticeKind.overdue =>
      days == 1
          ? 'Measurements were due yesterday'
          : 'Measurements were due $days days ago',
  };

  @override
  bool operator ==(Object other) =>
      other is MeasurementNotice && other.kind == kind && other.days == days;
  @override
  int get hashCode => Object.hash(kind, days);
}

/// What to tell the person on [today] given their next due date.
MeasurementNotice measurementNotice({
  required bool enabled,
  required String? due,
  required String today,
  int leadDays = measurementLeadDays,
}) {
  if (!enabled || due == null) return MeasurementNotice.none;
  final diff = parseLocalDate(due).difference(parseLocalDate(today)).inDays;
  if (diff > leadDays) return MeasurementNotice.none;
  if (diff > 0) return MeasurementNotice(MeasurementNoticeKind.upcoming, diff);
  if (diff == 0) return const MeasurementNotice(MeasurementNoticeKind.dueToday);
  return MeasurementNotice(MeasurementNoticeKind.overdue, -diff);
}

/// Parses a typed decimal ("72", "72.5", "72,5"). Null for blank or invalid.
double? parseNumber(String s) {
  final v = double.tryParse(s.trim().replaceAll(',', '.'));
  return v;
}

String formatNumber(double v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(1);
}
