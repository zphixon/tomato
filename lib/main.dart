import 'package:flutter/material.dart';
import 'interval.dart' as interval;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Timers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Interval timers'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const TimerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add timer',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TimerList extends StatefulWidget {
  const TimerList({
    super.key,
  });

  @override
  State<TimerList> createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  List<interval.Interval> intervals = [
    interval.Interval(
      interval.Time(10, interval.TimeMagnitude.minutes),
      interval.Time(1, interval.TimeMagnitude.hours),
    ),
    interval.Interval(
      interval.Time(10, interval.TimeMagnitude.minutes),
      interval.Time(1, interval.TimeMagnitude.hours),
    ),
    interval.Interval(
      interval.Time(10, interval.TimeMagnitude.minutes),
      interval.Time(1, interval.TimeMagnitude.hours),
    ),
    interval.Interval(
      interval.Time(10, interval.TimeMagnitude.minutes),
      interval.Time(1, interval.TimeMagnitude.hours),
    ),
  ];

  _updateActive(int index, interval.Time newValue) {
    setState(() {
      intervals[index].activeTime = newValue;
    });
  }

  _updateEvery(int index, interval.Time newValue) {
    setState(() {
      intervals[index].every = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: intervals.length,
      itemBuilder: (ctx, idx) {
        var pad = idx + 1 == intervals.length
            ? const EdgeInsets.only(bottom: 60.0)
            : EdgeInsets.zero;

        var activeTime = intervals[idx].activeTime;
        var every = intervals[idx].every;
        doUpdateActive(newValue) => _updateActive(idx, newValue);
        doUpdateEvery(newValue) => _updateEvery(idx, newValue);

        return TimerCard(
          pad: pad,
          activeTime: activeTime,
          doUpdateActive: doUpdateActive,
          every: every,
          doUpdateEvery: doUpdateEvery,
        );
      },
    );
  }
}

class TimerCard extends StatefulWidget {
  const TimerCard({
    super.key,
    required this.pad,
    required this.activeTime,
    required this.doUpdateActive,
    required this.every,
    required this.doUpdateEvery,
  });

  final EdgeInsets pad;
  final interval.Time activeTime;
  final Function(dynamic newValue) doUpdateActive;
  final interval.Time every;
  final Function(dynamic newValue) doUpdateEvery;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    toggleExpand() {
      setState(() {
        _expanded = !_expanded;
      });
    }

    Widget content;
    if (_expanded) {
      content = Text('wowee!!!');
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: InkWell(
              onTap: () async {},
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 15.0,
                ),
                child: Text('Stand up'),
              ),
            ),
          ),
          Text('for'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: InkWell(
              onTap: () async {
                var selected = await showDialog<interval.Time>(
                  context: context,
                  builder: (ctx) => TimeSelector(
                    start: widget.activeTime,
                    title: 'Select length of alert',
                  ),
                );
                if (selected != null) {
                  widget.doUpdateActive(selected);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 15.0,
                ),
                child: Text(widget.activeTime.toString()),
              ),
            ),
          ),
          Text('every'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: InkWell(
              onTap: () async {
                var selected = await showDialog<interval.Time>(
                  context: context,
                  builder: (ctx) => TimeSelector(
                    start: widget.every,
                    title: 'Select time between alerts',
                  ),
                );
                if (selected != null) {
                  widget.doUpdateEvery(selected);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 15.0,
                ),
                child: Text(widget.every.toString()),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: toggleExpand,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: widget.pad,
      child: Card(
        child: InkWell(
          onTap: toggleExpand,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: content,
          ),
        ),
      ),
    );
  }
}

class TimeSelector extends StatefulWidget {
  final interval.Time start;
  final String title;

  const TimeSelector({
    super.key,
    required this.start,
    required this.title,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  final _formKey = GlobalKey<FormState>();

  String? _validNumber(String? value, interval.TimeMagnitude magnitude) {
    if (value == null) {
      return 'Value required';
    }

    var parsed = int.tryParse(value);
    if (null == parsed) {
      return 'Invalid number';
    }

    if (parsed <= 0) {
      return 'Not enough time';
    }

    if (magnitude == interval.TimeMagnitude.days && parsed > 365) {
      return 'Too many days';
    } else if (magnitude == interval.TimeMagnitude.hours && parsed > 8760) {
      return 'Too many hours';
    } else if (magnitude == interval.TimeMagnitude.minutes && parsed > 525600) {
      return 'Too many minutes';
    } else if (magnitude == interval.TimeMagnitude.seconds &&
        parsed > 31536000) {
      return 'Too many seconds';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var amountController =
        TextEditingController(text: widget.start.amount.toString());
    var magnitude = widget.start.period;

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Row(children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Number'),
                validator: (value) => _validNumber(value, magnitude),
              ),
            ),
          ),
          DropdownMenu<interval.TimeMagnitude>(
            requestFocusOnTap: false,
            initialSelection: widget.start.period,
            dropdownMenuEntries: interval.TimeMagnitude.values
                .map((value) =>
                    DropdownMenuEntry(label: value.toString(), value: value))
                .toList(),
            onSelected: (value) {
              if (value != null) {
                magnitude = value;
              }
            },
          ),
        ]),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState == null) {
              return;
            }

            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,
              interval.Time(int.parse(amountController.text), magnitude),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
