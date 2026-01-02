import 'package:flutter/material.dart';
import 'package:macroclient/structures.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'communication_functions.dart';
import 'helperfunctions.dart' as HelperFunctions;

class Inputs extends StatefulWidget {
  final Global global;

  const Inputs(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateInputs();
}

class _StateInputs extends State<Inputs> {
  String _selected = '';
  final TextEditingController _macroAddress = TextEditingController();
  final TextEditingController _datasetAddress = TextEditingController();
  final TextEditingController _serverIP = TextEditingController();
  final TextEditingController _scName = TextEditingController();
  String _tcMode = 'fetch';
  final TextEditingController _tcFile = TextEditingController();
  String _macroUpdateTC = '';
  String _macroEnableTC = '';
  String _macroInitTC = '';
  String _datasetUpdateTC = '';
  String _masterMacroEnable = '';
  String _selectedCmd = '';
  String _macrofilename = '';
  String _macrofileData = '';
  String _dsfilename = '';
  String _dsfileData = '';
  String _tcfilename = '';
  String _tcfileData = '';
  final TextEditingController _filter = TextEditingController();
  List<String> filteredTC = [];
  List<String> _tcMnemonics = [];
  List<String> _mappedTCs = [];
  String _selectedTC = '';
  List<String> _macroCmds = [];
  List<String> _totalMacros = [];
  List<String> _totalDatasets = [];
  int noOfMacros = 0;
  int noOfDatasets = 0;
  int noOfCmds = 0;

  @override
  void initState() {
    super.initState();
    _getAllMacros();
    _getAllDatasets();
    _getAllTCMnemonics();
    _getAllMappedTCs();
    _filter.addListener(_onSearchChanged);
  }

  void _getMappedCmdAsSubTitles() {
    if (_mappedTCs.length == 0) {
      _macroUpdateTC = "ToBeSelected";
      _datasetUpdateTC = "ToBeSelected";
      _macroInitTC = "ToBeSelected";
      _macroEnableTC = "ToBeSelected";
      _masterMacroEnable = "ToBeSelected";
    } else {
      _macroUpdateTC = _mappedTCs[0];
      _macroEnableTC = _mappedTCs[2];
      _macroInitTC = _mappedTCs[3];
      _datasetUpdateTC = _mappedTCs[1];
      _masterMacroEnable = _mappedTCs[4];
    }
  }

  void _onSearchChanged() {
    setState(() {
      if (_filter.text.isEmpty) {
        filteredTC = _tcMnemonics;
      } else {
        filteredTC = _tcMnemonics
            .where(
              (_tcMnemonics) => _tcMnemonics.toLowerCase().contains(
                _filter.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _pickFile(String file) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null) {
      PlatformFile pFile = result.files.single;
      if (file == "macro") {
        _macrofilename = result.files.single.name;
        if (!_macrofilename.toLowerCase().endsWith('csv')) {
          HelperFunctions.showMessage("Only CSV Files Supported", true);
          return;
        }
        var data = pFile.bytes ?? Uint8List(0);
        _macrofileData = String.fromCharCodes(data);
        _macroAddress.text = _macrofilename;
      }

      if (file == "dataset") {
        _dsfilename = result.files.single.name;
        if (!_dsfilename.toLowerCase().endsWith('csv')) {
          HelperFunctions.showMessage("Only CSV Files Supported", true);
          return;
        }
        var data = pFile.bytes ?? Uint8List(0);
        _dsfileData = String.fromCharCodes(data);
        _datasetAddress.text = _dsfilename;
      }

      if (file == "tc") {
        _tcfilename = result.files.single.name;
        if (!_tcfilename.toLowerCase().endsWith('xlsx')) {
          HelperFunctions.showMessage("Only XLSX Files Supported", true);
          return;
        }
        var data = pFile.bytes ?? Uint8List(0);
        _tcfileData = base64Encode(data);
        _tcFile.text = _tcfilename;
      }
    }
  }

  void _getAllTCMnemonics() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "tcMnemonics", response, () {
      if (!response.ok) {
        return;
      }
      _tcMnemonics.addAll(response.values);
      _selectedTC = (_tcMnemonics.isEmpty) ? "" : _tcMnemonics.first;
      noOfCmds = _tcMnemonics.length;
      setState(() {});
    });
  }

  void _getAllMappedTCs() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "mappedTC", response, () {
      if (!response.ok) {
        return;
      }
      _mappedTCs.addAll(response.values);
      debugPrint("Mapped TCs: ${_mappedTCs.length}");
      _getMappedCmdAsSubTitles();
      setState(() {});
    });
  }

  void _getAllMacros() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "totalMacros", response, () {
      if (!response.ok) {
        return;
      }
      _totalMacros.addAll(response.values);
      noOfMacros = _totalMacros.length;
      setState(() {});
    });
  }

  void _getAllDatasets() {
    MultipleValueResponse response = MultipleValueResponse();
    getMultipleValues(widget.global, "totalDatasets", response, () {
      if (!response.ok) {
        return;
      }
      _totalDatasets.addAll(response.values);
      noOfDatasets = _totalDatasets.length;
      setState(() {});
    });
  }

  void _readTCDB() {
    Acknowledgement ack = Acknowledgement();
    setParameter(widget.global, "SCCMainIP", _serverIP.text, ack, () {
      if (!ack.ok) {
        return;
      }
      Acknowledgement scNameAck = Acknowledgement();
      setParameter(widget.global, "SCName", _scName.text, scNameAck, () {
        if (!scNameAck.ok) {
          return;
        }
        Acknowledgement tcAck = Acknowledgement();
        populateTCDatabase(widget.global, tcAck, () {
          if (!tcAck.ok) {
            return;
          }
        });
      });
    });
  }

  void _saveSpecificCommands(List<String> cmdMnemonic) {
    Acknowledgement ack = Acknowledgement();
    setMultipleParameters(widget.global, "macroCommands", cmdMnemonic, ack, () {
      if (!ack.ok) {
        return;
      }
      widget.global.updateNotification(
        "Macro Commands Mapped in database",
        NotificationType.success,
        null,
      );
    });
  }

  void _saveMacroAndDSCSV(String macroContent, String datasetContent) {
    Acknowledgement ack = Acknowledgement();
    loadCSVFiles(widget.global, macroContent, "macro", ack, () {
      if (!ack.ok) {
        return;
      }
      Acknowledgement ack2 = Acknowledgement();
      loadCSVFiles(widget.global, datasetContent, "dataset", ack2, () {
        if (!ack2.ok) {
          return;
        }
        widget.global.updateNotification(
          "CSV Files Updated",
          NotificationType.success,
          null,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _getChildCard()),
        _getNavigationBar(),
      ],
    );
  }

  Widget _getChildCard() {
    switch (_selected) {
      case 'address':
        return _getAddressCard();
      case 'tc':
        return _getTelecommandCard();
      case 'mapping':
        return _getMappingCard();
    }
    return _getInformationCard();
  }

  Widget _getInformationCard() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.4,
        heightFactor: 0.6,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
                Text('No Of Macros: $noOfMacros'),
                Text('No Of Datasets: $noOfDatasets'),
                Text('No Of Telecommands: $noOfCmds'),
                Text(
                  'Macro Update Command: ${_mappedTCs.isNotEmpty ? _mappedTCs[0] : "Fetching"}',
                ),
                Text(
                  'Macro Enable Command:  ${_mappedTCs.isNotEmpty ? _mappedTCs[2] : "Fetching"}',
                ),
                Text(
                  'Macro Init Command:  ${_mappedTCs.isNotEmpty ? _mappedTCs[3] : "Fetching"}',
                ),
                Text(
                  'Dataset Update Command: ${_mappedTCs.isNotEmpty ? _mappedTCs[1] : "Fetching"}',
                ),
                Text(
                  'Master Macro Update Command:  ${_mappedTCs.isNotEmpty ? _mappedTCs[4] : "Fetching"}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getAddressCard() {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.4,
        heightFactor: 0.6,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Select Address CSVs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _macroAddress,
                          decoration: InputDecoration(
                            labelText: "Path of Macro Address file",
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _pickFile("macro");
                        },
                        label: Text("Browse"),
                        icon: Icon(Icons.open_in_browser),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _datasetAddress,
                          decoration: InputDecoration(
                            labelText: "Path of Dataset Address file",
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _pickFile("dataset");
                        },
                        label: Text("Browse"),
                        icon: Icon(Icons.open_in_browser),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        label: Text('Download Sample'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _saveMacroAndDSCSV(_macrofileData, _dsfileData);
                        },
                        label: Text('Submit'),
                        icon: Icon(Icons.check_circle),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      "Number of Macros    : ${noOfMacros != 0 ? noOfMacros : "No Macro Addresses"}\n"
                      "Number of Datasets : ${noOfDatasets != 0 ? noOfDatasets : "No Dataset Addresses"}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTelecommandCard() {
    List<Widget> children = [];
    children.add(
      Text(
        'Select Telecommands',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    children.add(Divider());
    children.add(
      Flexible(
        child: Row(
          children: [
            Flexible(
              child: RadioListTile(
                title: Text("Fetch"),
                value: 'fetch',
                groupValue: _tcMode,
                onChanged: (value) {
                  _tcMode = value ?? 'fetch';
                  setState(() {});
                },
              ),
            ),
            Flexible(
              child: RadioListTile(
                title: Text("CDB File"),
                value: 'cdb',
                groupValue: _tcMode,
                onChanged: (value) {
                  _tcMode = value ?? 'fetch';
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (_tcMode == 'fetch') {
      children.add(
        TextFormField(
          controller: _serverIP,
          decoration: InputDecoration(labelText: 'Server IP'),
        ),
      );
      children.add(
        TextFormField(
          controller: _scName,
          decoration: InputDecoration(labelText: 'Spacecraft Name'),
        ),
      );
    } else {
      children.add(
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: TextFormField(
                  controller: _tcFile,
                  decoration: InputDecoration(labelText: "Path of CDB TC file"),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _pickFile("tc");
                },
                label: Text("Browse"),
                icon: Icon(Icons.open_in_browser),
              ),
            ],
          ),
        ),
      );
    }

    children.add(Spacer());
    children.add(
      ElevatedButton.icon(
        onPressed: () {
          _readTCDB();
        },
        label: Text('Submit'),
        icon: Icon(Icons.check_circle),
      ),
    );
    children.add(Divider());
    children.add(Text(style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        "Number of Telecommands: ${noOfCmds != 0 ? noOfCmds : "No TC in Database"}\n"));

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.4,
        heightFactor: 0.6,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: children),
          ),
        ),
      ),
    );
  }

  Widget _getMappingCard() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Select TC Mapping',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('Macro Update'),
                      subtitle: Text(_macroUpdateTC),
                      selectedTileColor: Colors.green,
                      selected: _selectedCmd == 'MacroUpdate',
                      onTap: () {
                        _selectedCmd = 'MacroUpdate';
                        setState(() {});
                      },
                    ),

                    ListTile(
                      title: Text('Macro Enable'),
                      subtitle: Text(_macroEnableTC),
                      selectedTileColor: Colors.green,
                      selected: _selectedCmd == 'MacroEnable',
                      onTap: () {
                        _selectedCmd = 'MacroEnable';
                        setState(() {});
                      },
                    ),
                    ListTile(
                      title: Text('Macro Init'),
                      subtitle: Text(_macroInitTC),
                      selectedTileColor: Colors.green,
                      selected: _selectedCmd == 'MacroInit',
                      onTap: () {
                        _selectedCmd = 'MacroInit';
                        setState(() {});
                      },
                    ),
                    ListTile(
                      title: Text('Dataset Update'),
                      subtitle: Text(_datasetUpdateTC),
                      selectedTileColor: Colors.green,
                      selected: _selectedCmd == 'DatasetUpdate',
                      onTap: () {
                        _selectedCmd = 'DatasetUpdate';
                        setState(() {});
                      },
                    ),
                    ListTile(
                      title: Text('Master Macro Enable'),
                      subtitle: Text(_masterMacroEnable),
                      selectedTileColor: Colors.green,
                      selected: _selectedCmd == 'MasterMacroEnable',
                      onTap: () {
                        _selectedCmd = 'MasterMacroEnable';
                        setState(() {});
                      },
                    ),

                    Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        _macroCmds.clear();
                        _macroCmds.addAll([
                          _macroUpdateTC,
                          _macroEnableTC,
                          _macroInitTC,
                          _datasetUpdateTC,
                          _masterMacroEnable,
                        ]);
                        _saveSpecificCommands(_macroCmds);
                      },
                      label: Text('Submit'),
                      icon: Icon(Icons.check_circle),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _getCommandSelector(),
        ],
      ),
    );
  }

  Widget _getCommandSelector() {
    if (_selectedCmd == '') {
      return SizedBox.shrink();
    }

    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Select TC', style: TextStyle(fontWeight: FontWeight.bold)),
              Divider(),
              TextFormField(
                controller: _filter,
                decoration: InputDecoration(labelText: 'Filter'),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index >= filteredTC.length) {
                      return null;
                    }
                    return ListTile(
                      title: Text(filteredTC[index]),
                      onTap: () {
                        switch (_selectedCmd) {
                          case 'MacroUpdate':
                            _macroUpdateTC = filteredTC[index];
                          case 'MacroEnable':
                            _macroEnableTC = filteredTC[index];
                          case 'MacroInit':
                            _macroInitTC = filteredTC[index];
                          case 'DatasetUpdate':
                            _datasetUpdateTC = filteredTC[index];
                          case 'MasterMacroEnable':
                            _masterMacroEnable = filteredTC[index];
                        }
                        _selectedCmd = '';
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNavigationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _selected = "address";
            setState(() {});
          },
          label: Text('Address'),
          icon: Icon(Icons.location_searching_outlined),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _selected = 'tc';
            setState(() {});
          },
          label: Text('Telecommand'),
          icon: Icon(Icons.code),
        ),
        ElevatedButton.icon(
          onPressed: () {
            _selected = 'mapping';
            setState(() {
            });
          },
          label: Text('Command Mapping'),
          icon: Icon(Icons.compare_arrows),
        ),
      ],
    );
  }
}
