import 'package:flutter/material.dart';

enum Magnitude {
  days,
  hours,
  minutes,
  seconds;

  @override
  String toString() {
    switch (this) {
      case Magnitude.days:
        return 'days';
      case Magnitude.hours:
        return 'hours';
      case Magnitude.minutes:
        return 'minutes';
      case Magnitude.seconds:
        return 'seconds';
    }
  }

  static Magnitude fromString(String s) {
    switch (s) {
      case 'days':
        return Magnitude.days;
      case 'hours':
        return Magnitude.hours;
      case 'minutes':
        return Magnitude.minutes;
      case 'seconds':
        return Magnitude.seconds;
      default:
        throw Exception('not a magnitude: $s');
    }
  }
}

class Duration {
  int amount;
  Magnitude magnitude;

  Duration({required this.amount, required this.magnitude});

  @override
  String toString() {
    String magnitudeSingular;
    switch (magnitude) {
      case Magnitude.days:
        magnitudeSingular = 'day';
        break;
      case Magnitude.hours:
        magnitudeSingular = 'hour';
        break;
      case Magnitude.minutes:
        magnitudeSingular = 'minute';
        break;
      case Magnitude.seconds:
        magnitudeSingular = 'second';
        break;
    }

    var maybeS = amount == 1 ? '' : 's';

    return '$amount $magnitudeSingular$maybeS';
  }

  Duration.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        magnitude = Magnitude.fromString(json['magnitude']);

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'magnitude': magnitude.toString(),
      };
}

class IntervalPeriod {
  Duration active, every;
  IntervalPeriod({required this.active, required this.every});

  IntervalPeriod.fromJson(Map<String, dynamic> json)
      : active = Duration.fromJson(json['active']),
        every = Duration.fromJson(json['every']);

  Map<String, dynamic> toJson() => {
        'active': active.toJson(),
        'every': every.toJson(),
      };
}

class Timer {
  IntervalPeriod interval;
  String noto;
  bool enabled = true;
  Schedule schedule = Schedule();

  Timer({required this.interval, required this.noto});

  Timer.fromJson(Map<String, dynamic> json)
      : interval = IntervalPeriod.fromJson(json['interval']),
        noto = json['noto'],
        enabled = json['enabled'] ?? true,
        schedule = json.containsKey('schedule')
            ? Schedule.fromJson(json['schedule'])
            : Schedule();

  Map<String, dynamic> toJson() => {
        'interval': interval.toJson(),
        'noto': noto,
        'enabled': enabled,
        'schedule': schedule.toJson(),
      };
}

enum Day {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday;

  @override
  String toString() {
    switch (this) {
      case Day.sunday:
        return 'sunday';
      case Day.monday:
        return 'monday';
      case Day.tuesday:
        return 'tuesday';
      case Day.wednesday:
        return 'wednesday';
      case Day.thursday:
        return 'thursday';
      case Day.friday:
        return 'friday';
      case Day.saturday:
        return 'saturday';
    }
  }

  static Day fromString(String s) {
    switch (s) {
      case 'sunday':
        return Day.sunday;
      case 'monday':
        return Day.monday;
      case 'tuesday':
        return Day.tuesday;
      case 'wednesday':
        return Day.wednesday;
      case 'thursday':
        return Day.thursday;
      case 'friday':
        return Day.friday;
      case 'saturday':
        return Day.saturday;
      default:
        throw Exception('not a day: $s');
    }
  }
}

class Schedule {
  TimeOfDay? start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? end = const TimeOfDay(hour: 12 + 5, minute: 0);

  Set<Day> days = const {
    Day.sunday,
    Day.monday,
    Day.tuesday,
    Day.wednesday,
    Day.thursday,
    Day.friday,
    Day.saturday,
  };

  Schedule({
    this.start,
    this.end,
    Set<Day>? days,
  }) {
    if (days != null) {
      this.days = days;
    }
  }

  Schedule.fromJson(Map<String, dynamic> json)
      : start = json.containsKey('start')
            ? TimeOfDay(
                hour: json['start']['hour'],
                minute: json['start']['minute'],
              )
            : null,
        end = json.containsKey('end')
            ? TimeOfDay(
                hour: json['end']['hour'],
                minute: json['end']['minute'],
              )
            : null,
        days = json.containsKey('days')
            ? (json['days'] as List)
                .map((e) => e as String)
                .map(Day.fromString)
                .toSet()
            : Day.values.toSet();

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (start != null) {
      map.putIfAbsent('start', () => start.toString());
    }
    if (end != null) {
      map.putIfAbsent('end', () => end.toString());
    }
    map.putIfAbsent('days', () => days.map((e) => e.toString()).toList());
    return map;
  }
}
