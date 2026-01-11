import 'package:flutter/material.dart';
import 'package:macroclient/create_dataset.dart';
import 'package:macroclient/create_macro.dart';
import 'package:macroclient/error_status.dart';
import 'package:macroclient/export.dart';
import 'package:macroclient/information.dart';
import 'package:macroclient/inputs.dart';
import 'package:macroclient/inspect.dart';
import 'package:macroclient/notification_bar.dart';
import 'package:macroclient/structures.dart';

import 'communication_functions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Macro Creator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: const MyHomePage(title: 'Macro Creator'),
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
  String _option = 'createMacro';
  int _selectedIndex = 0;
  Global _global = Global();

  void _updateNotification(
    String value,
    NotificationType nType,
    bool? serverStatus,
  ) {
    _global.notification.value = value;
    _global.notification.notificationType = nType;
    if (serverStatus != null) {
      _global.notification.serverConnected = serverStatus;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _global.updateNotification = _updateNotification;
    _initializeParameters();
  }

  void _initializeParameters() async {
    Acknowledgement ack = Acknowledgement();
    debugPrint(_global.clientID);
    registerClient(_global, ack, () {
      if (!ack.ok) {
        _option = 'error';
        _updateNotification(
          "Server Not Present",
          NotificationType.error,
          false,
        );
      } else {
        _option = 'createMacro';
        _updateNotification(
          "Waiting for User",
          NotificationType.information,
          true,
        );
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                switch (index) {
                  case 0:
                    _option = 'createMacro';
                  case 1:
                    _option = 'createDataset';
                  case 2:
                    _option = 'export';
                  case 3:
                    _option = 'inspect';
                  case 4:
                    _option = 'inputs';
                  case 5:
                    _option = 'information';
                }
              });
            },
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.data_object_outlined),
                selectedIcon: Icon(Icons.data_object),
                label: Text('Macro'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dynamic_feed_outlined),
                selectedIcon: Icon(Icons.dynamic_feed),
                label: Text('Dataset'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.file_download_outlined),
                selectedIcon: Icon(Icons.file_download),
                label: Text('Export'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.lightbulb_outline),
                selectedIcon: Icon(Icons.lightbulb),
                label: Text('Inspect'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.keyboard_outlined),
                selectedIcon: Icon(Icons.keyboard),
                label: Text('Inputs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: Text('Info'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                actions: [
                   Padding(
                     padding: const EdgeInsets.only(right: 16.0),
                     child: _getNotificationIcon(),
                   ),
                ],
              ),
              body: _getChild(),
              bottomNavigationBar: BottomAppBar(
                 height: 48,
                 child: NotificationBar(
                    notification: _global.notification,
                    updateNotification: _updateNotification,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _getNotificationChildren(),
                    ),
                 ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getChild() {
    Widget child = Text('Child comes here');
    switch (_option) {
      case 'createMacro':
        child = CreateMacro(_global);
      case 'createDataset':
        child = CreateDataset(_global);
      case 'export':
        child = Export(_global);
      case 'inspect':
        child = Inspect(_global);
      case 'inputs':
        child = Inputs(_global);
      case 'information':
        child = Information(_global);
      case 'error':
        child = ErrorStatus(_global, reInit);
    }
    return Padding(padding: EdgeInsets.all(16.0), child: child);
  }

  void reInit() {
    _initializeParameters();
  }

  List<Widget> _getNotificationChildren() {
    List<Widget> children = [];
    children
      ..add(const SizedBox(width: 8))
      ..add(Text(_global.notification.value))
      ..add(Spacer());
    if (_global.notification.serverConnected) {
      children
        ..add(Text('Server Connected'))
        ..add(SizedBox(width: 8))
        ..add(Icon(Icons.cloud_done_outlined, color: Colors.green));
    } else {
      children
        ..add(Text('Server Not Connected'))
        ..add(SizedBox(width: 8))
        ..add(Icon(Icons.cloud_off, color: Colors.red));
    }
    children.add(
      IconButton(
        onPressed: () {
          reInit();
        },
        icon: Icon(Icons.sync),
        tooltip: "Reconnect",
      ),
    );
    return children;
  }

  Widget _getNotificationIcon() {
    switch (_global.notification.notificationType) {
      case NotificationType.success:
        return Icon(Icons.check_circle, color: Colors.green);
      case NotificationType.warning:
        return Icon(Icons.warning_amber, color: Colors.orange);
      case NotificationType.error:
        return Icon(Icons.error, color: Colors.red);
      case NotificationType.information:
        return Icon(Icons.info, color: Colors.blue);
    }
  }
}
