enum TimeMagnitude {
  days,
  hours,
  minutes,
  seconds;

  @override
  String toString() {
    switch (this) {
      case TimeMagnitude.days:
        return 'days';
      case TimeMagnitude.hours:
        return 'hours';
      case TimeMagnitude.minutes:
        return 'minutes';
      case TimeMagnitude.seconds:
        return 'seconds';
    }
  }
}

class Time {
  int amount;
  TimeMagnitude period;

  Time(this.amount, this.period);

  @override
  String toString() {
    String periodSingular;
    switch (period) {
      case TimeMagnitude.days:
        periodSingular = 'day';
        break;
      case TimeMagnitude.hours:
        periodSingular = 'hour';
        break;
      case TimeMagnitude.minutes:
        periodSingular = 'minute';
        break;
      case TimeMagnitude.seconds:
        periodSingular = 'second';
        break;
    }

    var maybeS = amount == 1 ? '' : 's';

    return '$amount $periodSingular$maybeS';
  }
}

class Interval {
  Time activeTime, every;
  Interval(this.activeTime, this.every);
}
