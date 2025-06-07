import 'package:flutter/material.dart';

/// Indicele opțiunii de frecvență:
/// 0 = Every day
/// 1 = Every other day
/// 2 = Specific days of the week
/// 3 = Every X days
enum FrequencyOption { everyDay, everyOtherDay, specificDaysOfWeek, everyXDays }

extension FrequencyOptionExtension on FrequencyOption {
  String get label {
    switch (this) {
      case FrequencyOption.everyDay:
        return 'Every day';
      case FrequencyOption.everyOtherDay:
        return 'Every other day';
      case FrequencyOption.specificDaysOfWeek:
        return 'Specific days of the week';
      case FrequencyOption.everyXDays:
        return 'Every X days';
    }
  }
}

/// Widget-ul care afișează un ListTile cu textul curent („Every day” etc.)
/// și la tap deschide dialogul de selectare a modului de frecvență.
class FrequencyPicker extends StatefulWidget {
  /// Opțiunea inițială (dacă venim la edit, de ex)
  final FrequencyOption initialOption;

  /// Dacă s-a ales `FrequencyOption.everyXDays`, acest param
  /// va conține valoarea X (câte zile).
  final int initialEveryXDays;

  /// Dacă s-a ales `FrequencyOption.specificDaysOfWeek`, aici e lista zilelor alese
  /// (numerotate 1 = Luni, …, 7 = Duminică). Poate fi goală.
  final List<int> initialSelectedWeekdays;

  /// Callback apelat când utilizatorul confirmă o nouă frecvență.
  /// Transmite:
  ///   - opțiunea aleasă,
  ///   - dacă e cazul, valoarea X (numărul de zile),
  ///   - și, dacă e cazul, lista de `selectedWeekdays`.
  final void Function(
    FrequencyOption chosen,
    int everyXDays,
    List<int> selectedWeekdays,
  )
  onFrequencyChanged;

  const FrequencyPicker({
    super.key,
    required this.initialOption,
    required this.initialEveryXDays,
    required this.initialSelectedWeekdays,
    required this.onFrequencyChanged,
  });

  @override
  State<FrequencyPicker> createState() => _FrequencyPickerState();
}

class _FrequencyPickerState extends State<FrequencyPicker> {
  late FrequencyOption _selectedOption;
  late int _tempEveryX;
  late Set<int> _tempSelectedWeekdays;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialOption;
    _tempEveryX = widget.initialEveryXDays;
    _tempSelectedWeekdays = widget.initialSelectedWeekdays.toSet();
  }

  Future<void> _showFrequencyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        // Folosim StatefulBuilder pentru a putea actualiza
        // temporar în dialog valorile _selectedOption și _tempEveryX.
        return StatefulBuilder(
          builder: (ctx2, setStateDialog) {
            return AlertDialog(
              scrollable: true,
              title: const Text('How often do you take it?'),

              content: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx2).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Generăm RadioListTile pentru fiecare opțiune
                      for (var option in FrequencyOption.values)
                        RadioListTile<FrequencyOption>(
                          title: Text(option.label),
                          value: option,
                          groupValue: _selectedOption,
                          onChanged: (val) {
                            setStateDialog(() {
                              _selectedOption = val!;
                            });
                          },
                        ),

                      const SizedBox(height: 8),

                      // Dacă s-a selectat „Every X days”, afișăm TextField pentru X
                      if (_selectedOption == FrequencyOption.everyXDays)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextFormField(
                            initialValue: _tempEveryX.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Every X days (X days)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final parsed = int.tryParse(v) ?? _tempEveryX;
                              setStateDialog(() {
                                _tempEveryX = parsed <= 0 ? 1 : parsed;
                              });
                            },
                          ),
                        ),

                      // Dacă e „Specific days of the week”, afișăm 7 checkbox-uri
                      if (_selectedOption == FrequencyOption.specificDaysOfWeek)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              // Vom afișa 7 rânduri cu zilele: Luni → Duminică
                              for (int weekday = 1; weekday <= 7; weekday++)
                                CheckboxListTile(
                                  title: Text(_weekdayName(weekday)),
                                  value: _tempSelectedWeekdays.contains(
                                    weekday,
                                  ),
                                  onChanged: (checked) {
                                    setStateDialog(() {
                                      if (checked == true) {
                                        _tempSelectedWeekdays.add(weekday);
                                      } else {
                                        _tempSelectedWeekdays.remove(weekday);
                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx2).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Confirmăm alegerea—îl anunțăm pe părinte
                    widget.onFrequencyChanged(
                      _selectedOption,
                      _tempEveryX,
                      _tempSelectedWeekdays.toList(),
                    );
                    Navigator.of(ctx2).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
    // După ce dialogul se închide, vrem să reconstruim widget-ul afișat
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Textul pe care îl afișăm în ListTile, în funcție de _selectedOption
    String displayedLabel;
    switch (_selectedOption) {
      case FrequencyOption.everyDay:
        displayedLabel = 'Every day';
        break;
      case FrequencyOption.everyOtherDay:
        displayedLabel = 'Every other day';
        break;
      case FrequencyOption.specificDaysOfWeek:
        if (_tempSelectedWeekdays.isEmpty) {
          displayedLabel = 'No days selected';
        } else {
          final sortedDays = _tempSelectedWeekdays.toList()..sort();
          // use full weekday names or abbreviations:
          final labels = sortedDays.map((d) => _weekdayName(d));
          displayedLabel = labels.join(', ');
        }
        break;
      case FrequencyOption.everyXDays:
        displayedLabel = 'Every $_tempEveryX day${_tempEveryX > 1 ? 's' : ''}';
        break;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'How often do you take it?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(displayedLabel),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: _showFrequencyDialog,
    );
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Luni';
      case DateTime.tuesday:
        return 'Marți';
      case DateTime.wednesday:
        return 'Miercuri';
      case DateTime.thursday:
        return 'Joi';
      case DateTime.friday:
        return 'Vineri';
      case DateTime.saturday:
        return 'Sâmbătă';
      case DateTime.sunday:
        return 'Duminică';
      default:
        return '';
    }
  }
}
