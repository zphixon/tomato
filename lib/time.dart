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
}

class IntervalPeriod {
  Duration active, every;
  IntervalPeriod(this.active, this.every);
}

class Timer {
  IntervalPeriod interval;
  String noto;

  Timer(this.interval, this.noto);
}

class Schedule {
  IntervalPeriod period;
  TimeOfDay? start;
  TimeOfDay? end;

  Schedule(this.period);
}