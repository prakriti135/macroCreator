import 'package:flutter/material.dart';
import 'package:macro_creator/helperfunctions.dart';
import 'package:macro_creator/structures.dart';

import 'communication_functions.dart';

class CreateDataset extends StatefulWidget {
  final Global global;

  const CreateDataset(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateCreateDataset();
}

class _StateCreateDataset extends State<CreateDataset> {
  List<String> _savedMacroNumbers = [];
  String _selectedMacroNumber = '';
  List<String> _datasetNumbers = [];
  String _selectedDSNumber = '';
  bool _showCommands = false;
  bool valid = true;

  List<SaveMacroCommand> _macCmds = [];
  SaveDatasetCommand _ds = SaveDatasetCommand();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _datasetNumbers.clear();
    _getSavedMacroNumbers();
  }


  void _getSavedMacroNumbers() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "savedMacroNumbers", response, () {
      if (!response.ok) {
        return;
      }
      _savedMacroNumbers.addAll(response.values);
      _selectedMacroNumber = _savedMacroNumbers.first;
      _getDatasetBasedOnMacroNumber();
      setState(() {});
    });
  }

  void _getDatasetBasedOnMacroNumber() {
    Acknowledgement ack = Acknowledgement();
    setParameter(widget.global, "MacroNumber", _selectedMacroNumber, ack, () {
      if (!ack.ok) {
        debugPrint(ack.message);
        return;
      }
      _getFilteredDSNumbers();
    });
  }

  void _getFilteredDSNumbers() {
    _datasetNumbers.clear();
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "FilteredDSNumbers", response, () {
      if (!response.ok) {
        return;
      }
      _datasetNumbers.addAll(response.values);
      if (_datasetNumbers.isNotEmpty) {
        _selectedDSNumber = _datasetNumbers.first;
      } else {
        _selectedDSNumber = '';
      }
      setState(() {});
    });
  }

  void _getDetails() {
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
      _macCmds = response.savedCommands;
      _getDSInfo();
    });
  }

  void _saveDSInfo() {
    Acknowledgement ack = Acknowledgement();
    saveDatasets(
      widget.global,
      int.parse(_selectedDSNumber),
      _ds.executions,
      _ds.data,
      _ds.times,
      int.parse(_selectedMacroNumber),
      _descriptionController.text,
      ack,
      () {
        if (!ack.ok) {
          return;
        }
        widget.global.updateNotification(
          "Dataset Info Saved",
          NotificationType.success,
          null,
        );
      },
    );
  }

  void _getDSInfo() {
    GetDatasetDetails response = GetDatasetDetails();
    getDatasets(widget.global, _selectedDSNumber, response, () {
      if (!response.ok) {
        widget.global.updateNotification(
          "Not able to fetch dataset $_selectedDSNumber",
          NotificationType.error,
          null,
        );
        return;
      }
      widget.global.updateNotification(
        "Dataset Fetched",
        NotificationType.success,
        null,
      );
      _ds.executions = [];
      _ds.data = [];
      _ds.times = [];
      _ds.message = '';
      _ds.executions.addAll(response.executions);
      _ds.times.addAll(response.times);
      _ds.data.addAll(response.data);
      _ds.message = response.message;
      _descriptionController.text = response.message;
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
      for (int i = 0; i < _ds.executions.length; i++) {
        children.add(
          DatasetCard(
            widget.global,
            _macCmds[i],
            i,
            _ds,
            valid,
            key: Key('$_selectedDSNumber-$i'),
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
        Expanded(
          child: TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: "Macro Description"),
            onChanged: (value) {},
          ),
        ),
        ElevatedButton.icon(
          onPressed: (_showCommands)
              ? () {
                  setState(() {
                    if (!valid){
                      showMessage("Validation Error", true);
                    }
                  });
                }
              : null,
          icon: Icon(Icons.verified_user_sharp),
          label: Text('Validate'),
        ),
        ElevatedButton.icon(
          onPressed: (_showCommands)
              ? () {
                  setState(() {
                    _saveDSInfo();
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
        _getMacroNumberDD(),
        _getDatasetNumberDD(),

        IconButton(
          onPressed: () {
            _showCommands = true;
            _getDetails();
          },
          icon: Icon(Icons.check_circle),
          tooltip: 'Submit',
        ),
      ],
    );
  }

  Widget _getMacroNumberDD() {
    List<DropdownMenuEntry<String>> items = [];
    items = _savedMacroNumbers
        .map((e) => DropdownMenuEntry(value: e, label: e))
        .toList();

    return DropdownMenu(
      dropdownMenuEntries: items,
      initialSelection: _selectedMacroNumber,
      enableSearch: false,
      enableFilter: true,
      onSelected: (value) {
        _selectedMacroNumber = value ?? _savedMacroNumbers.first;
        setState(() {
          _datasetNumbers.clear();
          _getDatasetBasedOnMacroNumber();
        });
      },
      label: Text('Macro Number'),
    );
  }

  Widget _getDatasetNumberDD() {
    List<DropdownMenuEntry<String>> items = [];
    items = _datasetNumbers
        .map((e) => DropdownMenuEntry(value: e, label: e))
        .toList();

    return DropdownMenu(
      dropdownMenuEntries: items,
      initialSelection: _selectedDSNumber,
      enableSearch: false,
      enableFilter: true,
      onSelected: (value) {
        _selectedDSNumber = value ?? _datasetNumbers.first;
        setState(() {});
      },
      label: Text('Dataset Number'),
    );
  }
}

//***********************************************************************************//
class DatasetCard extends StatefulWidget {
  final Global global;
  final SaveMacroCommand cmd;
  final int index;
  final SaveDatasetCommand ds;
  final bool valid;

  const DatasetCard(this.global, this.cmd, this.index, this.ds, this.valid, {super.key});

  @override
  State<DatasetCard> createState() => _StateDatasetCard();
}

class _StateDatasetCard extends State<DatasetCard> {
  String _codeOrMnemonic = 'Mnemonic';
  final TextEditingController _cmdController = TextEditingController();
  final TextEditingController _dataController = TextEditingController(
    text: '0',
  );
  final TextEditingController _timeController = TextEditingController(
    text: '0',
  );

  FocusNode _timeFocusNode = FocusNode();
  FocusNode _dataFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeOrMnemonic = widget.cmd.mnemonicOrCode;
    if (_codeOrMnemonic == "Code") {
      _cmdController.text = widget.cmd.cmdCode;
    } else {
      _cmdController.text = widget.cmd.cmdMnemonic;
    }
    if (widget.cmd.dataFromDS) {
      _dataController.text = widget.ds.data[widget.index];
    } else {
      _dataController.text = "";
    }
    if (widget.cmd.timeFromDS) {
      _timeController.text = widget.ds.times[widget.index].toString();
    } else {
      _timeController.text = "";
    }
    _timeFocusNode.addListener(() {
      if (_timeFocusNode.hasFocus && _timeController.text == "Enter Time") {
        _timeController.clear();
      }
    });

    _dataFocusNode.addListener(() {
      if (_dataFocusNode.hasFocus && _dataController.text == "Enter Data") {
        _dataController.clear();
      }
    });
  }

  bool validate() {
    bool valid = true;
    if (widget.ds.executions[widget.index]) {
      if (widget.cmd.dataFromDS) {
        String dt = _dataController.text;
        if (dt.length != 8) {
          showMessage("Data has to be 8 nibbles", true);
          valid = false;
        }
      }
      if (widget.cmd.timeFromDS) {
        String tm = _timeController.text;
        int time = int.parse(tm);
        if ((time < 0) || (time > 32 * 65536)) {
          showMessage("Time Validation failed", true);
          valid = false;
        }
      }
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 300,
      child: Card(
        color: (widget.ds.executions[widget.index] ? Colors.greenAccent : null),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Command ${widget.index + 1}',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Divider(),
              _getMnemonicOrCode(),

              TextFormField(
                controller: _dataController,
                focusNode: _dataFocusNode,
                decoration: InputDecoration(labelText: "Data"),
                onChanged: (value) {
                  widget.ds.data[widget.index] = _dataController.text;
                },
                enabled: widget.cmd.dataFromDS,
              ),
              TextFormField(
                controller: _timeController,
                focusNode: _timeFocusNode,
                decoration: InputDecoration(labelText: "Time"),
                onChanged: (value) {
                    widget.ds.times[widget.index] = int.parse(
                      _timeController.text,
                    );
                },
                enabled: widget.cmd.timeFromDS,
              ),
              Spacer(),
              CheckboxListTile(
                value: widget.ds.executions[widget.index],
                onChanged: (value) {
                  widget.ds.executions[widget.index] = value ?? false;
                  setState(() {});
                },
                title: Text("Execute"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMnemonicOrCode() {
    return TextFormField(
      controller: _cmdController,
      decoration: InputDecoration(labelText: "Command"),
      onChanged: (value) {},
      enabled: false,
    );
  }
}
