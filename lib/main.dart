import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_android/path_provider_android.dart';

import 'time.dart' as time;

void main() {
  assert(Platform.isAndroid);
  runApp(const MyApp());
}

class Settings {
  List<time.Timer> timers;
  Settings(this.timers);

  static Settings fromJson(Map<String, dynamic> json) {
    List<time.Timer> timers = List.from(json['timers'].map((e) {
      time.Timer timer = time.Timer.fromJson(e);
      return timer;
    }));
    return Settings(timers);
    //: timers =
  }

  Map<String, dynamic> toJson() => {
        'timers': timers.map((e) => e.toJson()).toList(),
      };
}

class SettingsStorage {
  static bool registered = false;

  Future<String> get _localPath async {
    if (!registered) {
      WidgetsFlutterBinding.ensureInitialized();
      PathProviderAndroid.registerWith();
      registered = true;
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<Settings?> readSettings() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(contents);

      return Settings.fromJson(json);
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }

  Future<File> writeSettings(Settings settings) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(settings));
  }
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
      home: MyHomePage(
        title: 'Interval timers',
        storage: SettingsStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.storage});

  final String title;
  final SettingsStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Settings settings = Settings([]);

  @override
  void initState() {
    super.initState();
    widget.storage.readSettings().then((value) {
      setState(() {
        if (value != null) {
          settings = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    updateActive(idx, newActive) {
      setState(() {
        settings.timers[idx].interval.active = newActive;
        widget.storage.writeSettings(settings);
      });
    }

    updateEvery(idx, newEvery) {
      setState(() {
        settings.timers[idx].interval.every = newEvery;
        widget.storage.writeSettings(settings);
      });
    }

    updateNoto(idx, newNoto) {
      setState(() {
        settings.timers[idx].noto = newNoto;
        widget.storage.writeSettings(settings);
      });
    }

    delete(idx) {
      setState(() {
        settings.timers.removeAt(idx);
        widget.storage.writeSettings(settings);
      });
    }

    create() {
      setState(() {
        settings.timers.add(time.Timer(
          noto: 'New timer',
          interval: time.IntervalPeriod(
            active: time.Duration(
              amount: 10,
              magnitude: time.Magnitude.minutes,
            ),
            every: time.Duration(
              amount: 1,
              magnitude: time.Magnitude.hours,
            ),
          ),
        ));
        widget.storage.writeSettings(settings);
      });
    }

    setEnabled(idx, newEnabled) {
      setState(() {
        settings.timers[idx].enabled = newEnabled;
        widget.storage.writeSettings(settings);
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
        delete: delete,
        setEnabled: setEnabled,
        timers: settings.timers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: create,
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
  final Function(int idx) delete;
  final Function(int idx, bool newEnabled) setEnabled;
  final List<time.Timer> timers;

  const TimerList({
    super.key,
    required this.updateNoto,
    required this.updateActive,
    required this.updateEvery,
    required this.delete,
    required this.setEnabled,
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
        doDelete() => delete(idx);
        doSetEnabled(bool newEnabled) => setEnabled(idx, newEnabled);

        return TimerCard(
          pad: pad,
          timer: timers[idx],
          doUpdateNoto: doUpdateNoto,
          doUpdateActive: doUpdateActive,
          doUpdateEvery: doUpdateEvery,
          doDelete: doDelete,
          doSetEnabled: doSetEnabled,
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
    required this.doDelete,
    required this.doSetEnabled,
  });

  final EdgeInsets pad;

  final time.Timer timer;
  final Function(String newNoto) doUpdateNoto;
  final Function(time.Duration newValue) doUpdateActive;
  final Function(time.Duration newValue) doUpdateEvery;
  final Function(bool newValue) doSetEnabled;
  final Function() doDelete;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    toggleExpanded() {
      setState(() {
        _expanded = !_expanded;
      });
    }

    var toggleExpandButton = IconButton(
      onPressed: toggleExpanded,
      icon: Icon(_expanded
          ? Icons.arrow_drop_up_rounded
          : Icons.arrow_drop_down_rounded),
    );

    List<Widget> expandedItems = [];
    if (_expanded) {
      expandedItems = [
        const Text('wowee'),
      ];
    }

    return Padding(
      padding: widget.pad,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: toggleExpanded,
          onLongPress: () {
            // TODO show popup that lets you delete/disable/etc
            widget.doDelete();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SelectableCard(
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
                    ),
                    Switch(value: widget.timer.enabled, onChanged: widget.doSetEnabled),
                    toggleExpandButton,
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('for'),
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
                      const Text('every'),
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
                    ],
                  ),
                ),
                ...expandedItems
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: <ButtonSegment<bool>>[
        ButtonSegment<bool>(
          value: true,
          label: enabled ? const Text('Enabled') : null,
          icon: enabled ? null : const Icon(Icons.check_circle),
        ),
        ButtonSegment<bool>(
          value: false,
          label: enabled ? null : const Text('Disabled'),
          icon: enabled ? const Icon(Icons.close_rounded) : null,
        ),
      ],
      selected: <bool>{enabled},
      onSelectionChanged: (Set<bool> newSelection) {
        setState(() {
          enabled = newSelection.first;
        });
      },
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
              time.Duration(
                amount: int.parse(amountController.text),
                magnitude: magnitude,
              ),
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
