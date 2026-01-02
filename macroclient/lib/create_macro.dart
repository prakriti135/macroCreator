import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:macroclient/structures.dart';

import 'communication_functions.dart';
import 'helperfunctions.dart' as helperfunctions;

class CreateMacro extends StatefulWidget {
  final Global global;

  const CreateMacro(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateCreateMacro();
}

class _StateCreateMacro extends State<CreateMacro> {
  List<String> _macroTypes = [];
  String _macroTypeSelected = '';
  List<String> _macroNumbers = [];
  List<String> _savedMacroNumbers = [];
  String _selectedMacroNumber = '';
  int _noOfCommands = 0;
  bool _showCommands = false;
  List<SaveMacroCommand> _commands = [];

  @override
  void initState() {
    super.initState();
    _macroNumbers.clear();
    _getMacroTypes();
    _getSavedMacroNumbers();
  }

  void _saveMacroInfo() {
    Acknowledgement ack = Acknowledgement();
    saveMacros(
      widget.global,
      int.parse(_selectedMacroNumber),
      _noOfCommands,
      _commands,
      ack,
      () {
        if (!ack.ok) {
          return;
        }
        widget.global.updateNotification(
          "Commands Updated",
          NotificationType.success,
          null,
        );
      },
    );
  }

  void _getMacroInfo() {
    GetMacroDetails response = GetMacroDetails();
    getMacros(widget.global, _selectedMacroNumber, response, () {
      if (!response.ok) {
        widget.global.updateNotification(
          "Not able to fetch macro $_selectedMacroNumber",
          NotificationType.error,
          null,
        );
        return;
      }
      widget.global.updateNotification(
        "Commands Fetched",
        NotificationType.success,
        null,
      );
      _commands = [];
      for (int i = 0; i < response.noOfCommands; i++) {
        _commands.add(response.savedCommands[i]);
      }
      _noOfCommands = response.noOfCommands;
      setState(() {});
    });
  }

  void _getMacroTypes() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "macroTypes", response, () {
      if (!response.ok) {
        return;
      }
      _macroTypes.addAll(response.values);
      _macroTypeSelected = (_macroTypes.isEmpty) ? "" : _macroTypes.first;
      _setMacroType();

      setState(() {});
    });
  }

  void _setMacroType() {
    Acknowledgement ack = Acknowledgement();
    setParameter(
      widget.global,
      "SelectedMacroType",
      _macroTypeSelected,
      ack,
      () {
        if (!ack.ok) {
          return;
        }
      },
    );
    _getMacroNumbers();
  }

  void _getMacroNumbers() {
    _macroNumbers.clear();
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "macroNumbers", response, () {
      if (!response.ok) {
        return;
      }
      _macroNumbers.addAll(response.values);
      _selectedMacroNumber = (_macroNumbers.isEmpty) ? "" : _macroNumbers.first;
      setState(() {});
    });
  }

  void _getSavedMacroNumbers() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "savedMacroNumbers", response, () {
      if (!response.ok) {
        return;
      }
      _savedMacroNumbers.addAll(response.values);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _getNavigationBar(),
        Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(children: _getCommandCards()),
          ),
        ),
        Divider(),
        _getBottomBar(),
      ],
    );
  }

  List<Widget> _getCommandCards() {
    List<Widget> children = [];
    if (_showCommands) {
      for (int i = 0; i < _noOfCommands; i++) {
        children.add(
          MacroCommandCard(
            widget.global,
            _commands[i],
            i,
            key: Key('$_selectedMacroNumber-$i'),
          ),
        );
      }
    }
    return children;
  }

  Widget _getBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: (_showCommands)
              ? () {
                  setState(() {
                    _saveMacroInfo();
                  });
                }
              : null,
          icon: Icon(Icons.save),
          label: Text('Save'),
        ),
      ],
    );
  }

  Widget _getNavigationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 80,
      children: [
        _getMacroTypeDD(),
        _getMacroNumberDD(),
        SizedBox(
          width: 200,
          child: SpinBox(
            min: 0,
            max: 32,
            value: _noOfCommands.toDouble(),
            onChanged: (value) {
              _noOfCommands = value.toInt();
              if (_noOfCommands > _commands.length) {
                for (int i = _commands.length; i < _noOfCommands; i++) {
                  _commands.add(SaveMacroCommand());
                }
              }
              setState(() {});
            },
            decoration: InputDecoration(labelText: 'No of Commands'),
          ),
        ),
        IconButton(
          onPressed: () {
            _showCommands = true;
            if (_savedMacroNumbers.contains(_selectedMacroNumber)) {
              _getMacroInfo();
              setState(() {

              });
            } else {
              _commands = [];
              for (int i = 0; i < _noOfCommands; i++) {
                _commands.add(SaveMacroCommand());
              }

              setState(() {

              });
            }
          },
          icon: Icon(Icons.check_circle),
          tooltip: 'Submit',
        ),
      ],
    );
  }

  Widget _getMacroTypeDD() {
    List<DropdownMenuEntry<String>> items = [];

    items = _macroTypes
        .map((e) => DropdownMenuEntry(value: e, label: e))
        .toList();

    return DropdownMenu(
      dropdownMenuEntries: items,
      initialSelection: _macroTypeSelected,
      enableSearch: false,
      enableFilter: true,
      onSelected: (value) {
        _macroTypeSelected = value ?? _macroTypes.first;
        setState(() {
          _setMacroType();
        });
      },
      label: Text("Macro Type"),
    );
  }

  Widget _getMacroNumberDD() {
    List<DropdownMenuEntry<String>> items = [];
    items = _macroNumbers
        .map((e) => DropdownMenuEntry(value: e, label: e))
        .toList();

    return DropdownMenu(
      dropdownMenuEntries: items,
      initialSelection: _selectedMacroNumber,
      enableSearch: false,
      enableFilter: true,
      onSelected: (value) {
        _selectedMacroNumber = value ?? _macroNumbers.first;
        _showCommands = false;
        setState(() {});
      },
      label: Text('Macro Number'),
      helperText: _macroTypeSelected.isEmpty
      ? 'Select Macro Type first' : null,
    );
  }
}

class MacroCommandCard extends StatefulWidget {
  final Global global;
  final SaveMacroCommand cmd;
  final int index;

  const MacroCommandCard(this.global, this.cmd, this.index, {super.key});

  @override
  State<MacroCommandCard> createState() => _StateMacroCommandCard();
}

class _StateMacroCommandCard extends State<MacroCommandCard> {
  String _codeOrMnemonic = 'Mnemonic';
  final TextEditingController _codeController = TextEditingController();
  final List<String> _commands = [];
  String _selectedCommand = '';
  bool _dataFromDS = false;
  bool _timeFromDS = false;
  String _commandType = '';

  final TextEditingController _timeController = TextEditingController(
    text: '0',
  );

  @override
  void initState() {
    super.initState();
    _getAllTCMnemonics();
    _codeOrMnemonic = widget.cmd.mnemonicOrCode;
    _codeController.text = widget.cmd.cmdCode;
    _selectedCommand = widget.cmd.cmdMnemonic;
    _dataFromDS = widget.cmd.dataFromDS;
    _timeFromDS = widget.cmd.timeFromDS;
    _timeController.text = widget.cmd.time.toString();
  }

  void _getAllTCMnemonics() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "tcMnemonics", response, () {
      if (!response.ok) {
        return;
      }
      _commands.addAll(response.values);
      if (_selectedCommand.isEmpty) {
        _selectedCommand = (_commands.isEmpty) ? "" : _commands.first;
      }
      setState(() {});
    });
  }

  void _getCommandType() {
    _setCommandMnemonic();
    ValueResponse response = ValueResponse();
    getParameterValue(widget.global, "cmdType", response, () {
      if (!response.ok) {
        return;
      }
      _commandType = response.value;
      debugPrint(_commandType);
      if (_commandType.toLowerCase() == "data") {
        _dataFromDS = true;
      }
      setState(() {});
    });
  }

  void _setCommandMnemonic() {
    Acknowledgement ack = Acknowledgement();
    setParameter(widget.global, "SelectedMnemonic", _selectedCommand, ack, () {
      if (!ack.ok) {
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 350,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Command ${widget.index + 1}',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Divider(),
              Row(
                children: [
                  Flexible(
                    child: RadioListTile(
                      value: "Mnemonic",
                      groupValue: _codeOrMnemonic,
                      onChanged: (value) {
                        _codeOrMnemonic = value ?? "Mnemonic";
                        widget.cmd.mnemonicOrCode = _codeOrMnemonic;
                        setState(() {});
                      },
                      title: Text("Mnemonic"),
                    ),
                  ),
                  Flexible(
                    child: RadioListTile(
                      value: "Code",
                      groupValue: _codeOrMnemonic,
                      onChanged: (value) {
                        _codeOrMnemonic = value ?? "Mnemonic";
                        widget.cmd.mnemonicOrCode = _codeOrMnemonic;
                        setState(() {});
                      },
                      title: Text("Code"),
                    ),
                  ),
                ],
              ),
              _getMnemonicOrCode(),
              CheckboxListTile(
                value: _dataFromDS,
                onChanged: (value) {
                  _dataFromDS = value ?? false;
                  widget.cmd.dataFromDS = _dataFromDS;
                  setState(() {});
                },
                title: Text('Data from Dataset'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: _timeFromDS,
                onChanged: (value) {
                  _timeFromDS = value ?? false;
                  widget.cmd.timeFromDS = _timeFromDS;
                  setState(() {});
                },
                title: Text('Time from Dataset'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: "Time"),
                onChanged: (value) {
                  try {
                    widget.cmd.time = int.parse(_timeController.text);
                  } catch (_) {}
                },
                enabled: !_timeFromDS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMnemonicOrCode() {
    if (_codeOrMnemonic == "Code") {
      return TextFormField(
        controller: _codeController,
        decoration: InputDecoration(labelText: "Code (48 bit)"),
        onChanged: (value) {
          widget.cmd.cmdCode = _codeController.text;
        },
      );
    } else {
      return DropdownSearch<String>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          showSelectedItems: true,
          searchDelay: Duration(milliseconds: 200),
        ),
        selectedItem: _selectedCommand,
        items: (_, _) => _commands,
        filterFn: (item, filter) =>
            item.toLowerCase().contains(filter.toLowerCase()),
        onChanged: (value) {
          _selectedCommand = value ?? _commands.first;
          widget.cmd.cmdMnemonic = _selectedCommand;
          setState(() {
            _getCommandType();
          });
        },
      );
    }
  }
}
