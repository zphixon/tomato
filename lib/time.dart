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

  Duration(this.amount, this.magnitude);

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
  IntervalPeriod(this.active, this.every);

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

  Timer(this.interval, this.noto);

  Timer.fromJson(Map<String, dynamic> json)
      : interval = IntervalPeriod.fromJson(json['interval']),
        noto = json['noto'];

  Map<String, dynamic> toJson() => {
        'interval': interval.toJson(),
        'noto': noto,
      };
}

class Schedule {
  TimeOfDay? start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? end = const TimeOfDay(hour: 12 + 5, minute: 0);

  bool monday = true;
  bool tuesday = true;
  bool wednesday = true;
  bool thursday = true;
  bool friday = true;
  bool saturday = false;
  bool sunday = false;

  Schedule({
    this.start,
    this.end,
    this.monday = true,
    this.tuesday = true,
    this.wednesday = true,
    this.thursday = true,
    this.friday = true,
    this.saturday = false,
    this.sunday = false,
  });
}
