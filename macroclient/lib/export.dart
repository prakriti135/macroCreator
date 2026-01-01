import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:macro_creator/structures.dart';
import 'package:file_saver/file_saver.dart';

import 'communication_functions.dart';

class Export extends StatefulWidget {
  final Global global;

  const Export(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateExport();
}

class _StateExport extends State<Export> {
  List<CompletedMacro> _completedMacros = [];
  List<String> _selectedMacros = [];
  List<CompletedMacro> _filteredMacros = [];
  final TextEditingController _filter = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCompletedMacros();
    _filter.addListener(_onSearchChanged);
  }

  void _getCompletedMacros(){
    CompletedMacros response = CompletedMacros();
    getCompletedMacros(widget.global, response, () {
      if (!response.ok) {
        return;
      }
      _completedMacros.addAll(response.macros);
      setState(() {});
    });
  }

  void _onSearchChanged() {
    setState(() {
      if (_filter.text.isEmpty) {
        _filteredMacros = _completedMacros;
      } else {
        _filteredMacros = _completedMacros
            .where(
              (item) => item.description.toLowerCase().contains(
                _filter.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _exportSelectedMacros() {
    String fileName = "Generated_";
    Acknowledgement ack = Acknowledgement();
    setMultipleParameters(
      widget.global,
      "ExportedMacros",
      _selectedMacros,
      ack,
          () {
        if (!ack.ok) {
          return;
        }else {
          var bytes = Uint8List.fromList(utf8.encode(ack.message));
          for (var i = 0; i < _selectedMacros.length; i++){
                fileName = fileName + _selectedMacros[i];
                fileName = fileName + "_"  ;

          }
          debugPrint(fileName);
          FileSaver.instance.saveFile(
              name: fileName, bytes: bytes, fileExtension: 'tst');
        }
        widget.global.updateNotification(
          "Macros Exported",
          NotificationType.success,
          null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Select Macros',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    TextFormField(
                      controller: _filter,
                      decoration: InputDecoration(
                        labelText: 'Filter Description',
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          if (index >= _filteredMacros.length) {
                            return null;
                          }
                          CompletedMacro m = _filteredMacros[index];
                          return ListTile(
                            title: Text(m.description),
                            subtitle: Text(
                              'Macro: ${m.macroNo}, DS: ${m.datasetNo}',
                            ),
                            selectedTileColor: Colors.green,
                            selected: _selectedMacros.contains(m.description),
                            onTap: () {
                              if (_selectedMacros.contains(m.description)) {
                                _selectedMacros.remove(m.description);
                              } else {
                                _selectedMacros.add(m.description);
                              }
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
          ),
          _getSelectedCommands(),
        ],
      ),
    );
  }

  Widget _getSelectedCommands() {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Selected Macros',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _selectedMacros = [];
                      for (CompletedMacro m in _completedMacros) {
                        _selectedMacros.add(m.description);
                        debugPrint(m.description);
                      }
                      setState(() {});
                    },
                    child: Text("Select All"),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectedMacros = [];
                      setState(() {});
                    },
                    child: Text("Clear All"),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index >= _selectedMacros.length) {
                      return null;
                    }
                    CompletedMacro m = _getMacro(_selectedMacros[index]);
                    return ListTile(
                      title: Text(m.description),
                      subtitle: Text('Macro: ${m.macroNo}, DS: ${m.datasetNo}'),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _exportSelectedMacros();
                },
                label: Text('Export Procedure'),
                icon: Icon(Icons.file_download, color: Colors.greenAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CompletedMacro _getMacro(String description) {
    for (CompletedMacro m in _completedMacros) {
      if (m.description.toLowerCase() == description.toLowerCase()) {
        return m;
      }
    }
    return CompletedMacro();
  }
}
