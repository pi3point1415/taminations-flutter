/*

  Taminations Square Dance Animations
  Copyright (C) 2026 Brad Christie

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

import 'package:flutter/material.dart' as fm;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as pp;

import '../common_flutter.dart';
import '../call_index.dart';
import '../call_entry.dart';
import 'page.dart';

final _levelColor = {
  LevelData.B1 : Color.B1,
  LevelData.B2 : Color.B2,
  LevelData.MS : Color.MS,
  LevelData.BMS : Color.BMS,
  LevelData.SSD : Color.MS,
  LevelData.MS26 : Color.MS,
  LevelData.PLUS : Color.PLUS,
  LevelData.P26 : Color.PLUS,
  LevelData.A1 : Color.A1,
  LevelData.A2 : Color.A2,
  LevelData.ADV : Color.ADV,
  LevelData.C1 : Color.C1,
  LevelData.C2 : Color.C2,
  LevelData.C3A : Color.C3A,
  LevelData.C3B : Color.C3B,
  LevelData.CHALLENGE : Color.CHALLENGE,
  LevelData.INDEX : Color.LIGHTGRAY,
  LevelData.BANANDY : Color.C1,
  LevelData.NONE : Color.WHITE
};
extension LevelColor on LevelData {
  Color get color => _levelColor[this]!;
}

final groupOrder = ['ssd', 'b1', 'b2', 'ms', 'm26', 'plus', 'p26', 'a1', 'a2', 'e', 'c1', 'c2', 'c3a', 'c3b'];

final entries = callIndex.fold<Map<String, List<CallEntry>>>({}, (map, item) {
  (map[item.level] ??= []).add(item);
  return map;
}).entries.toList()..sort((a, b) => groupOrder.indexOf(a.key).compareTo(groupOrder.indexOf(b.key)));

final callData = entries.map((e) => e.value).toList();

List<CallEntry> selectedCalls = [];

final callSelector = GroupedExpandableList(data: callData, onSelectionChanged: (List<CallEntry> calls) {
  selectedCalls = calls;
},);

class StartPracticePage extends fm.StatefulWidget {

  @override
  _StartPracticePageState createState() => _StartPracticePageState();
}

class _StartPracticePageState extends fm.State<StartPracticePage> {

  @override
  fm.Widget build(fm.BuildContext context) {
    return  Page(
        child: StartPracticeFrame()
    );
  }
}

List<CallEntry> getSelectedCalls() {
  return selectedCalls;
}

//  Wrapper widget to handle taps
class _TapDetector extends fm.StatelessWidget {
  @override
  fm.Widget build(fm.BuildContext context) =>
      pp.Consumer<TamState>(
          builder: (context,appState,_) {
            return Button('Start', onPressed: () {
              appState.change(mainPage: MainPage.PRACTICE, callList: getSelectedCalls());
            });
      });
}

class _StartPracticeRadioGroup extends fm.StatelessWidget {

  final String groupValue;
  final List<String> values;
  final void Function(String? value) onChanged;
  _StartPracticeRadioGroup({
    required this.groupValue,
    required this.values,
    required this.onChanged});

  @override
  fm.Widget build(fm.BuildContext context) {
    return fm.Container(
        color: Color.FLOOR,
        margin: fm.EdgeInsets.only(left:20, bottom:10),
        child: fm.RadioGroup(
          onChanged: onChanged,
          groupValue: groupValue,
          child: fm.Row (
              children: values.map((v) => [
                fm.Radio<String>(
                    value: v,
                ),
                fm.Text(v)
              ]).expand((e) => e).toList()
          ),
        ));
  }
}

class StartPracticeFrame extends fm.StatefulWidget {
  @override
  _StartPracticeFrameState createState() => _StartPracticeFrameState();
}

class _StartPracticeFrameState extends fm.State<StartPracticeFrame> {

  @override
  fm.Widget build(fm.BuildContext context) {

    return pp.Consumer<Settings>(
        builder: (context, settings, child) {
          return fm.OrientationBuilder(
            builder: (context,orientation) {
              if (orientation == fm.Orientation.portrait)
                return fm.Container(
                  color: Color.FLOOR,
                  child: fm.Center(
                      child: fm.Text(
                          'Resize your window wider for Practice.',
                        textAlign: TextAlign.center,
                        style: fm.TextStyle(fontSize: 40),
                      ))
                );
              return fm.Container(
                color: Color.FLOOR,
                child: fm.Row(
                  crossAxisAlignment: fm.CrossAxisAlignment.stretch,
                  children: [
                    fm.Expanded(
                      child: fm.Container(
                        margin: fm.EdgeInsets.only(left:20,top:20),
                        child: fm.Column(
                          crossAxisAlignment: fm.CrossAxisAlignment.stretch,
                          children: [
                            fm.Text(
                                'Choose a Gender', style: fm.TextStyle(fontSize: 20)),
                            _StartPracticeRadioGroup(
                                groupValue: Settings.practiceGender,
                                values: ['Boy', 'Girl'],
                                onChanged: (value) {
                                  setState(() {
                                    Settings.practiceGender = value ?? 'Boy';
                                  });
                                }),
                            fm.Text('Speed for Practice',
                                style: fm.TextStyle(fontSize: 20)),
                            _StartPracticeRadioGroup(
                                groupValue: Settings.practiceSpeed,
                                values: ['Slow', 'Moderate', 'Normal'],
                                onChanged: (value) {
                                  setState(() {
                                    Settings.practiceSpeed = value ?? 'Slow';
                                  });
                                }),
                            if (TamUtils.isTouchDevice)
                              fm.Text(
                                  'Primary Control', style: fm.TextStyle(fontSize: 20)),
                            if (TamUtils.isTouchDevice)
                              _StartPracticeRadioGroup(
                                  groupValue: Settings.primaryControl,
                                  values: ['Left Finger', 'Right Finger'],
                                  onChanged: (value) {
                                    setState(() {
                                      Settings.primaryControl = value ?? 'Right Finger';
                                    });
                                  }),
                            if (!TamUtils.isTouchDevice)
                              fm.Text(
                                  'Mouse Control', style: fm.TextStyle(fontSize: 20)),
                            if (!TamUtils.isTouchDevice)
                              _StartPracticeRadioGroup(
                                  groupValue: Settings.mouseControl,
                                  values: ['Press mouse button to move',
                                    'Release mouse button to move'],
                                  onChanged: (value) {
                                    setState(() {
                                      Settings.mouseControl = value ?? 'Press mouse button to move';
                                    });
                                  }),
                            _StartPracticeRadioGroup(
                              groupValue: Settings.cardinalControl,
                              values: ['Use cardinal direction', 'Use facing direction'],
                              onChanged: (value) {
                                setState(() {
                                  Settings.cardinalControl = value ?? 'Use cardinal direction';
                                });
                              }
                            ),
                            _TapDetector(),
                          ],
                        ),
                      ),
                    ),
                    fm.Expanded(
                      child: callSelector
                    ),
                  ],
                ),
              );
            }
          );
        });

  }
}

class GroupedExpandableList extends fm.StatefulWidget {
  final List<List<CallEntry>> data;

  final void Function(List<CallEntry> selected)? onSelectionChanged;

  const GroupedExpandableList({super.key, required this.data, this.onSelectionChanged});

  @override
  fm.State<GroupedExpandableList> createState() => _GroupedExpandableListState();
}

class _GroupedExpandableListState extends fm.State<GroupedExpandableList> {
  late List<bool> _expanded;
  late List<List<bool>> _checked;

  @override
  void initState() {
    super.initState();
    _expanded = List.generate(widget.data.length, (_) => false);
    _checked = widget.data
        .map((group) => List.generate(group.length, (_) => false))
        .toList();
  }

  List<CallEntry> getSelectedItems() {
    final selected = <CallEntry>[];
    for (var g = 0; g < widget.data.length; g++) {
      for (var i = 0; i < widget.data[g].length; i++) {
        if (_checked[g][i]) selected.add(widget.data[g][i]);
      }
    }
    return selected;
  }

  bool _isGroupChecked(int groupIndex) =>
      _checked[groupIndex].every((c) => c);

  bool _isGroupIndeterminate(int groupIndex) {
    final group = _checked[groupIndex];
    final anyChecked = group.any((c) => c);
    final allChecked = group.every((c) => c);
    return anyChecked && !allChecked;
  }

  void _toggleGroup(int groupIndex, bool? value) {
    setState(() {
      _checked[groupIndex] = List.generate(
        widget.data[groupIndex].length,
            (_) => value ?? false,
      );
      widget.onSelectionChanged?.call(getSelectedItems());
    });
  }

  void _toggleItem(int groupIndex, int itemIndex, bool? value) {
    setState(() {
      _checked[groupIndex][itemIndex] = value ?? false;
      widget.onSelectionChanged?.call(getSelectedItems());
    });
  }

  @override
  fm.Widget build(fm.BuildContext context) {

    return fm.ListView.builder(
      itemCount: widget.data.length,
      itemBuilder: (context, groupIndex) {
        final group = widget.data[groupIndex];
        final isExpanded = _expanded[groupIndex];
        final isGroupChecked = _isGroupChecked(groupIndex);
        final isIndeterminate = _isGroupIndeterminate(groupIndex);

        return fm.Card(
          margin: const fm.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: fm.Column(
            children: [
              // Group header
              fm.Material(
                color: LevelData.find(group[0].level)!.color,
              child: fm.InkWell(
                  highlightColor: LevelData.find(group[0].level)!.color.darker(),
                  onTap: () => setState(
                          () => _expanded[groupIndex] = !_expanded[groupIndex]),
                  child: fm.Padding(
                    padding: const fm.EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: fm.Row(
                      children: [
                        // Group checkbox (indeterminate handled via icon)
                        fm.Checkbox(
                          value: isIndeterminate ? null : isGroupChecked,
                          tristate: true,
                          onChanged: (val) {
                            // Tristate cycles: null → true; treat null as toggling to all-on if mixed
                            final newVal = (val == null || val == true)
                                ? !isGroupChecked
                                : val;
                            _toggleGroup(groupIndex, newVal);
                          },
                        ),
                        fm.Text(
                          LevelData.find(group[0].level).toString(),
                          style: const fm.TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const fm.Spacer(),
                        fm.Text(
                          '${group.length} items',
                          style: fm.TextStyle(color: fm.Colors.grey[600], fontSize: 13),
                        ),
                        const fm.SizedBox(width: 8),
                        fm.Icon(isExpanded
                            ? fm.Icons.expand_less
                            : fm.Icons.expand_more),
                      ],
                    ),
                  ),
                )
              ),
              // Items
              if (isExpanded)
                ...List.generate(group.length, (itemIndex) {
                  return fm.Column(
                    children: [
                      const fm.Divider(height: 1),
                      fm.CheckboxListTile(
                        tileColor: LevelData.find(group[itemIndex].level)!.color,
                        dense: true,
                        contentPadding:
                        const fm.EdgeInsets.only(left: 32, right: 16),
                        title: fm.Text(group[itemIndex].title),
                        value: _checked[groupIndex][itemIndex],
                        onChanged: (val) =>
                            _toggleItem(groupIndex, itemIndex, val),
                        controlAffinity: fm.ListTileControlAffinity.leading,
                      ),
                    ],
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}