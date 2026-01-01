import 'package:flutter/material.dart';
import 'package:macro_creator/create_dataset.dart';
import 'package:macro_creator/create_macro.dart';
import 'package:macro_creator/error_status.dart';
import 'package:macro_creator/export.dart';
import 'package:macro_creator/information.dart';
import 'package:macro_creator/inputs.dart';
import 'package:macro_creator/inspect.dart';
import 'package:macro_creator/notification_bar.dart';
import 'package:macro_creator/structures.dart';

import 'communication_functions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Macro Creator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
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
  String _option = '';
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: _getDrawer(context),
      body: _getChild(),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        child: NotificationBar(
          notification: _global.notification,
          updateNotification: _updateNotification,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _getNotificationChildren(),
          ),
        ),
      ),
    );
  }

  Widget _getDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Text(
              'Choose Option',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.data_object),
            title: const Text('Create Macro'),
            onTap: () {
              Navigator.pop(context);
              _option = 'createMacro';
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.dynamic_feed),
            title: const Text('Create Dataset'),
            onTap: () {
              Navigator.pop(context);
              _option = 'createDataset';
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export'),
            onTap: () {
              Navigator.pop(context);
              _option = 'export';
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: const Text('Inspect'),
            onTap: () {
              Navigator.pop(context);
              _option = 'inspect';
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.keyboard),
            title: const Text('Inputs'),
            onTap: () {
              Navigator.pop(context);
              _option = 'inputs';
              setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Information'),
            onTap: () {
              Navigator.pop(context);
              _option = 'information';
              setState(() {});
            },
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
    return Padding(padding: EdgeInsets.all(8.0), child: child);
  }

  void reInit() {
    _initializeParameters();
  }

  List<Widget> _getNotificationChildren() {
    List<Widget> children = [];
    children
      ..add(_getNotificationIcon())
      ..add(Text(_global.notification.value))
      ..add(Spacer());
    if (_global.notification.serverConnected) {
      children
        ..add(Text('Server Connected'))
        ..add(Icon(Icons.cloud_done_outlined, color: Colors.greenAccent));
    } else {
      children
        ..add(Text('Server Not Connected'))
        ..add(Icon(Icons.cloud_off, color: Colors.redAccent));
    }
    children.add(
      IconButton.filledTonal(
        onPressed: () {
          reInit();
        },
        icon: Icon(Icons.sync, color: Colors.blueAccent),
        tooltip: "Reconnect",
      ),
    );
    return children;
  }

  Widget _getNotificationIcon() {
    switch (_global.notification.notificationType) {
      case NotificationType.success:
        return Icon(Icons.done_all_outlined, color: Colors.greenAccent);
      case NotificationType.warning:
        return Icon(Icons.warning_amber_outlined, color: Colors.amberAccent);
      case NotificationType.error:
        return Icon(Icons.error_outline_outlined, color: Colors.redAccent);
      case NotificationType.information:
        return Icon(Icons.info_outline, color: Colors.blueAccent);
    }
  }
}
