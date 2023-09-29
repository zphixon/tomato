import 'package:flutter/material.dart';
import 'time.dart' as time;

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
  List<time.Timer> timers = [
    time.Timer(
      time.IntervalPeriod(
        time.Duration(10, time.Magnitude.minutes),
        time.Duration(1, time.Magnitude.hours),
      ),
      'Stand up',
    ),
    time.Timer(
      time.IntervalPeriod(
        time.Duration(10, time.Magnitude.minutes),
        time.Duration(1, time.Magnitude.hours),
      ),
      'Sit down',
    ),
    time.Timer(
      time.IntervalPeriod(
        time.Duration(10, time.Magnitude.minutes),
        time.Duration(1, time.Magnitude.hours),
      ),
      'Jump around',
    ),
    time.Timer(
      time.IntervalPeriod(
        time.Duration(10, time.Magnitude.minutes),
        time.Duration(1, time.Magnitude.hours),
      ),
      'Screech',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    updateActive(idx, newActive) {
      setState(() {
        timers[idx].interval.active = newActive;
      });
    }

    updateEvery(idx, newEvery) {
      setState(() {
        timers[idx].interval.every = newEvery;
      });
    }

    updateNoto(idx, newNoto) {
      setState(() {
        timers[idx].noto = newNoto;
      });
    }

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
      body: TimerList(
        updateNoto: updateNoto,
        updateActive: updateActive,
        updateEvery: updateEvery,
        timers: timers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add timer',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TimerList extends StatelessWidget {
  final Function(int idx, String newNoto) updateNoto;
  final Function(int idx, time.Duration newActive) updateActive;
  final Function(int idx, time.Duration newEvery) updateEvery;
  final List<time.Timer> timers;

  const TimerList({
    super.key,
    required this.updateNoto,
    required this.updateActive,
    required this.updateEvery,
    required this.timers,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: timers.length,
      itemBuilder: (ctx, idx) {
        var pad = idx + 1 == timers.length
            ? const EdgeInsets.only(bottom: 60.0)
            : EdgeInsets.zero;

        doUpdateNoto(String newNoto) => updateNoto(idx, newNoto);
        doUpdateActive(time.Duration newActive) => updateActive(idx, newActive);
        doUpdateEvery(time.Duration newEvery) => updateEvery(idx, newEvery);

        return TimerCard(
          pad: pad,
          timer: timers[idx],
          doUpdateNoto: doUpdateNoto,
          doUpdateActive: doUpdateActive,
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
    required this.timer,
    required this.doUpdateNoto,
    required this.doUpdateActive,
    required this.doUpdateEvery,
  });

  final EdgeInsets pad;

  final time.Timer timer;
  final Function(String newNoto) doUpdateNoto;
  final Function(time.Duration newValue) doUpdateActive;
  final Function(time.Duration newValue) doUpdateEvery;

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

    List<Widget> cards = [
      SelectableCard(
        onTap: () async {
          var text = await showDialog(
            context: context,
            builder: (context) => StringSelector(
              start: widget.timer.noto,
              title: 'Notification text',
            ),
          );

          if (text != null) {
            widget.doUpdateNoto(text);
          }
        },
        label: Text(widget.timer.noto),
      ),
      Text('for'),
      SelectableCard(
        onTap: () async {
          var selected = await showDialog<time.Duration>(
            context: context,
            builder: (ctx) => DurationSelector(
              start: widget.timer.interval.active,
              title: 'Select length of alert',
            ),
          );
          if (selected != null) {
            widget.doUpdateActive(selected);
          }
        },
        label: Text(widget.timer.interval.active.toString()),
      ),
      Text('every'),
      SelectableCard(
        onTap: () async {
          var selected = await showDialog<time.Duration>(
            context: context,
            builder: (ctx) => DurationSelector(
              start: widget.timer.interval.every,
              title: 'Select time between alerts',
            ),
          );
          if (selected != null) {
            widget.doUpdateEvery(selected);
          }
        },
        label: Text(widget.timer.interval.every.toString()),
      ),
    ];

    var toggleExpandButton = IconButton(
      icon: Icon(_expanded
          ? Icons.arrow_drop_up_rounded
          : Icons.arrow_drop_down_rounded),
      onPressed: toggleExpand,
    );

    Widget innerContent;
    if (_expanded) {
      innerContent = Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: cards[0]),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: cards.sublist(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          toggleExpandButton,
        ],
      );
    } else {
      innerContent = Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cards,
              ),
            ),
          ),
          toggleExpandButton,
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
            child: innerContent,
          ),
        ),
      ),
    );
  }
}

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.onTap,
    required this.label,
  });

  final Future Function() onTap;
  final Text label;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 15.0,
          ),
          child: label,
        ),
      ),
    );
  }
}

class DurationSelector extends StatefulWidget {
  final time.Duration start;
  final String title;

  const DurationSelector({
    super.key,
    required this.start,
    required this.title,
  });

  @override
  State<DurationSelector> createState() => _DurationSelectorState();
}

class _DurationSelectorState extends State<DurationSelector> {
  final _formKey = GlobalKey<FormState>();

  String? _validNumber(String? value, time.Magnitude magnitude) {
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

    if (magnitude == time.Magnitude.days && parsed > 365) {
      return 'Too many days';
    } else if (magnitude == time.Magnitude.hours && parsed > 8760) {
      return 'Too many hours';
    } else if (magnitude == time.Magnitude.minutes && parsed > 525600) {
      return 'Too many minutes';
    } else if (magnitude == time.Magnitude.seconds && parsed > 31536000) {
      return 'Too many seconds';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var amountController =
        TextEditingController(text: widget.start.amount.toString());
    var magnitude = widget.start.magnitude;

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
          DropdownMenu<time.Magnitude>(
            requestFocusOnTap: false,
            initialSelection: widget.start.magnitude,
            dropdownMenuEntries: time.Magnitude.values
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
              time.Duration(int.parse(amountController.text), magnitude),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class StringSelector extends StatefulWidget {
  final String start;
  final String title;

  const StringSelector({
    super.key,
    required this.start,
    required this.title,
  });

  @override
  State<StringSelector> createState() => _StringSelectorState();
}

class _StringSelectorState extends State<StringSelector> {
  final _formKey = GlobalKey<FormState>();

  String? _validString(String? value) {
    if (value == null || value.isEmpty) {
      return 'Value required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var amountController = TextEditingController(text: widget.start);

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(hintText: 'Text'),
            validator: (value) => _validString(value),
          ),
        ),
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

            Navigator.pop(context, amountController.text);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
