import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/repositories/body_measurement_repository.dart';
import 'package:wellbeing/features/metrics/metrics_logic.dart';

void main() {
  group('age from date of birth', () {
    test('before and on the birthday', () {
      expect(ageOn('2000-06-15', '2026-06-14'), 25);
      expect(ageOn('2000-06-15', '2026-06-15'), 26);
      expect(ageOn('2000-06-15', '2026-12-31'), 26);
    });
    test('leap day birthdays', () {
      expect(ageOn('2004-02-29', '2026-02-28'), 21);
      expect(ageOn('2004-02-29', '2026-03-01'), 22);
    });
    test('missing, invalid or future dates give no age', () {
      expect(ageOn(null, '2026-01-01'), isNull);
      expect(ageOn('', '2026-01-01'), isNull);
      expect(ageOn('nonsense', '2026-01-01'), isNull);
      expect(ageOn('2030-01-01', '2026-01-01'), isNull);
    });
  });

  group('BMI', () {
    test('calculation uses kg / m squared', () {
      expect(calculateBmi(70, 175), closeTo(22.86, 0.01));
      expect(calculateBmi(null, 175), isNull);
      expect(calculateBmi(70, 0), isNull);
    });

    test('adult bands at the boundaries', () {
      BmiBand? band(double b) => assessBmi(bmi: b, age: 30).band;
      expect(band(18.4), BmiBand.underweight);
      expect(band(18.5), BmiBand.healthyRange);
      expect(band(24.9), BmiBand.healthyRange);
      expect(band(25), BmiBand.overweight);
      expect(band(29.9), BmiBand.overweight);
      expect(band(30), BmiBand.obesity);
      expect(assessBmi(bmi: 22, age: 18).status, BmiStatus.adult);
    });

    test('under 18 gets no adult category', () {
      final a = assessBmi(bmi: 22, age: 17);
      expect(a.status, BmiStatus.minor);
      expect(a.band, isNull);
    });

    test('no date of birth or no data', () {
      expect(assessBmi(bmi: 22, age: null).status, BmiStatus.needsDob);
      expect(assessBmi(bmi: 22, age: null).band, isNull);
      expect(assessBmi(bmi: null, age: 30).status, BmiStatus.noData);
    });
  });

  group('next measurement due', () {
    test('weekly and fortnightly', () {
      expect(
        nextMeasurementDue('2026-05-13', MeasurementCadence.weekly),
        '2026-05-20',
      );
      expect(
        nextMeasurementDue('2026-05-13', MeasurementCadence.biweekly),
        '2026-05-27',
      );
    });
    test('monthly and every two months, clamped to month end', () {
      expect(
        nextMeasurementDue('2026-05-13', MeasurementCadence.monthly),
        '2026-06-13',
      );
      expect(
        nextMeasurementDue('2026-01-31', MeasurementCadence.monthly),
        '2026-02-28',
      );
      expect(
        nextMeasurementDue('2026-12-15', MeasurementCadence.monthly),
        '2027-01-15',
      );
      expect(
        nextMeasurementDue('2026-12-31', MeasurementCadence.bimonthly),
        '2027-02-28',
      );
      expect(
        nextMeasurementDue('2026-05-13', MeasurementCadence.bimonthly),
        '2026-07-13',
      );
    });
    test('parse falls back to monthly', () {
      expect(MeasurementCadence.parse('weekly'), MeasurementCadence.weekly);
      expect(MeasurementCadence.parse('x'), MeasurementCadence.monthly);
      expect(MeasurementCadence.parse(null), MeasurementCadence.monthly);
    });
  });

  group('measurement notice', () {
    MeasurementNotice n(String? due, {bool on = true}) =>
        measurementNotice(enabled: on, due: due, today: '2026-05-13');

    test('nothing far ahead, when off, or without a date', () {
      expect(n('2026-05-16').visible, isFalse);
      expect(n('2026-05-13', on: false).visible, isFalse);
      expect(n(null).visible, isFalse);
    });
    test('two days before, tomorrow, today, overdue', () {
      expect(n('2026-05-15').message, 'Measurements day in 2 days');
      expect(n('2026-05-14').message, 'Measurements day is tomorrow');
      expect(n('2026-05-13').kind, MeasurementNoticeKind.dueToday);
      expect(n('2026-05-10').kind, MeasurementNoticeKind.overdue);
      expect(n('2026-05-10').message, 'Measurements were due 3 days ago');
    });
    test('no exclamation marks in copy', () {
      for (final d in [
        '2026-05-15',
        '2026-05-14',
        '2026-05-13',
        '2026-05-10',
      ]) {
        expect(n(d).message, isNot(contains('!')));
      }
    });
  });
}
