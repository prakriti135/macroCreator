import 'package:flutter/material.dart';
import 'package:macroclient/communication_functions.dart';
import 'package:macroclient/structures.dart';

class Inspect extends StatefulWidget {
  final Global global;

  const Inspect(this.global, {super.key});

  @override
  State<StatefulWidget> createState() => _StateInspect();
}

class _StateInspect extends State<Inspect> {
  List<InspectionItem> _items = [];
  InspectionItem? _selectedItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInspectionData();
  }

  void _fetchInspectionData() {
    InspectionResponse response = InspectionResponse();
    getInspectionData(widget.global, response, () {
      if (response.ok) {
        setState(() {
          _items = response.items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        widget.global.updateNotification(
          "Failed to fetch inspection data",
          NotificationType.error,
          null,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Macros/Datasets to Inspect',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left Panel: List of Datasets
        Expanded(
          flex: 2,
          child: _buildDatasetList(),
        ),
        VerticalDivider(width: 1, thickness: 1),
        // Right Panel: Command Details
        Expanded(
          flex: 3,
          child: _selectedItem == null
              ? _buildPlaceholder()
              : _buildCommandDetails(),
        ),
      ],
    );
  }

  Widget _buildDatasetList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Saved Macros & Datasets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final isSelected = _selectedItem == item;
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: isSelected ? 6 : 2,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${item.macroNo}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Macro ${item.macroNo} / Dataset ${item.datasetNo}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item.description.isEmpty 
                        ? 'No description' 
                        : item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedItem = item;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Select a Macro/Dataset to inspect',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandDetails() {
    final item = _selectedItem!;
    
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Row(
            children: [
              Icon(Icons.info_outline, 
                color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Macro ${item.macroNo} / Dataset ${item.datasetNo}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.description.isNotEmpty)
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
        
        // Commands Table
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primaryContainer,
                  ),
                  columns: const [
                    DataColumn(label: Text('#', 
                      style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Command', 
                      style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Data', 
                      style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Time (ms)', 
                      style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Execute', 
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: item.commands.map((cmd) {
                    return DataRow(
                      cells: [
                        DataCell(Text('${cmd.index}')),
                        DataCell(
                          Text(
                            cmd.commandMnemonic.isNotEmpty 
                                ? cmd.commandMnemonic 
                                : cmd.commandCode,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text(cmd.data.isEmpty ? '--' : cmd.data)),
                        DataCell(Text('${cmd.time}')),
                        DataCell(
                          Icon(
                            cmd.executed 
                                ? Icons.check_circle 
                                : Icons.cancel,
                            color: cmd.executed ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
