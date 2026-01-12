import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class Global {
  String clientID = '';
  String url = 'http://127.0.0.1:8609';
  MacroNotification notification = MacroNotification();
  Function(String, NotificationType, bool?) updateNotification = (_, _, _) {};

  Global() {
    clientID = '${DateTime.timestamp()}';
  }
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum NotificationType { success, error, information, warning }

class MacroNotification {
  String value = '';
  bool serverConnected = false;
  NotificationType notificationType = NotificationType.information;
}

class RequestInterface {
  String id = '';

  RequestInterface();

  Map<String, dynamic> toJSON() {
    return {};
  }
}

mixin ResponseInterface {
  bool ok = false;
  String message = "";

  void fromJSON(Map<String, dynamic> jsonData) {}
}

class ValueRequest extends RequestInterface {
  String parameterName = '';

  ValueRequest();

  @override
  Map<String, dynamic> toJSON() {
    return {"ID": id, "Param": parameterName};
  }
}

class ValueResponse with ResponseInterface {
  String value = '';

  ValueResponse();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    value = jsonData['Value'] as String;
    message = jsonData['Message'] as String;
    ok = jsonData['OK'] as bool;
  }
}

class MultipleValueResponse with ResponseInterface {
  List<String> values = [];

  MultipleValueResponse();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    var val = jsonData['Values'] as List;
    for (var value in val) {
      var item = value as String;
      values.add(item);
    }
    message = jsonData['Message'] as String;
    ok = jsonData['OK'] as bool;
  }
}

class SetRequest extends RequestInterface {
  String parameterName = '';
  String parameterValue = '';

  SetRequest();

  @override
  Map<String, dynamic> toJSON() {
    return {
      "ID": id,
      "ParameterName": parameterName,
      "ParameterValue": parameterValue,
    };
  }
}

class SetMultiParameterRequest extends RequestInterface {
  String parameterName = '';
  List<String> parameterValues = [];

  SetMultiParameterRequest();

  @override
  Map<String, dynamic> toJSON() {
    return {
      "ID": id,
      "ParameterName": parameterName,
      "ParameterValues": parameterValues,
    };
  }
}

class Acknowledgement with ResponseInterface {
  Acknowledgement();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    message = jsonData['Message'] as String;
    ok = jsonData['OK'] as bool;
  }
}

class EmptyRequest extends RequestInterface {
  EmptyRequest();

  @override
  Map<String, dynamic> toJSON() {
    return {"ID": id};
  }
}

class FileResponse with ResponseInterface {
  String filename = '';
  String fileContent = '';

  FileResponse();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    filename = jsonData['Filename'] as String;
    fileContent = jsonData['FileContent'] as String;
    ok = jsonData['OK'] as bool;
    message = jsonData['Message'] as String;
  }
}

class LoadCSVFile extends RequestInterface {
  String id = '';
  String type = '';
  String data = '';

  LoadCSVFile();

  @override
  Map<String, dynamic> toJSON() {
    return {"ID": id, "FileType": type, "FileData": data};
  }
}



class SaveMacroCommand extends RequestInterface with ResponseInterface {
  String mnemonicOrCode = "Mnemonic";
  String cmdMnemonic = '';
  String cmdCode = '';
  bool dataFromDS = false;
  bool timeFromDS = false;
  int time = 0;

  SaveMacroCommand();

  @override
  Map<String, dynamic> toJSON() {
    return {
      "MnemonicOrCode": mnemonicOrCode,
      "CommandMnemonic": cmdMnemonic,
      "CommandCode": cmdCode,
      "DataFromDS": dataFromDS,
      "TimeFromDS": timeFromDS,
      "Time": time,
    };
  }

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    mnemonicOrCode = jsonData['MnemonicOrCode'] as String;
    cmdMnemonic = jsonData['CommandMnemonic'] as String;
    cmdCode = jsonData['CommandCode'] as String;
    dataFromDS = jsonData['DataFromDS'] as bool;
    timeFromDS = jsonData['TimeFromDS'] as bool;
    time = jsonData['Time'] as int;
  }
}

class SaveMacroDetails extends RequestInterface {
  int macroNo = 0;
  int noOfCommands = 0;
  List<SaveMacroCommand> commands = [];

  SaveMacroDetails();

  @override
  Map<String, dynamic> toJSON() {
    List<Map<String, dynamic>> cmds = [];
    for (SaveMacroCommand c in commands) {
      cmds.add(c.toJSON());
    }
    return {
      "ID": id,
      "Macro": {
        "MacroNo": macroNo,
        "NoOfCommands": noOfCommands,
        "Commands": cmds,
      },
    };
  }
}

class GetMacroDetails with ResponseInterface {
  int macroNo = 0;
  int noOfCommands = 0;
  List<SaveMacroCommand> savedCommands = [];

  GetMacroDetails();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    Map<String, dynamic> macro = jsonData['Macro'] as Map<String, dynamic>;
    macroNo = macro['MacroNo'] as int;
    noOfCommands = macro['NoOfCommands'] as int;
    List<dynamic> cmds =
        macro['Commands'] as List< dynamic>;
    for (Map<String, dynamic> c in cmds) {
      SaveMacroCommand command = SaveMacroCommand();
      command.fromJSON(c);
      savedCommands.add(command);
    }
    ok = jsonData['OK'] as bool;
    message = jsonData['Message'] as String;
  }
}


class SaveDatasetCommand extends RequestInterface with ResponseInterface {
  List<bool> executions = [];
  List<String> data = [];
  List<int> times = [];

  SaveDatasetCommand();

  @override
  Map<String, dynamic> toJSON() {
    return {
      "Executions": executions,
      "Data": data,
      "Times": times,
    };
  }

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    executions = jsonData['Executions'] as List<bool>;
    data = jsonData['Data'] as List<String>;
    times = jsonData['Times'] as List<int>;
  }
}

class SaveDatasetDetails extends RequestInterface {
  int datasetNo = 0;
  List<bool> executions = [];
  List<String> data = [];
  List<int> times = [];

  int linkedMacro = 0;
  String description = '';

  SaveDatasetDetails();

  @override
  Map<String, dynamic> toJSON() {

    return {
      "ID": id,
      "Dataset": {
        "DatasetNo": datasetNo,
        "Executions": executions,
        "Data": data,
        "Times": times,
      },
      "LinkedMacro": linkedMacro,
      "Description": description,
    };
  }
}

class GetDatasetDetails with ResponseInterface {
  int datasetNo = 0;
  List<bool> executions = [];
  List<String> data = [];
  List<int> times = [];
  bool ok = false;
  String message = "";

  GetDatasetDetails();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    Map<String, dynamic> ds = jsonData['Dataset'] as Map<String, dynamic>;
    datasetNo = ds['DatasetNo'] as int;
    var list = ds['Executions'] as List;
    executions = list.map((e) => e as bool).toList();
    list = ds['Data'] as List;
    data = list.map((e) => e as String).toList();
    list = ds['Times'] as List;
    times = list.map((e) => e as int).toList();
    ok = jsonData['OK'] as bool;
    message = jsonData['Message'] as String;
  }
}

class CompletedMacros with ResponseInterface {
  List<CompletedMacro> macros = [];
  String message = '';
  bool ok = false;

  CompletedMacros();
  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    var tempMacros = jsonData["Macros"] as List;
    macros = tempMacros.map((e) {
      CompletedMacro m = CompletedMacro();
      m.fromJSON(e);
      return m;
    }).toList();

    ok = jsonData['OK'] as bool;
    message = jsonData['Message'] as String;
  }
}

class CompletedMacro {
  int macroNo = 0;
  int datasetNo = 0;
  String description = '';

  CompletedMacro();

  void fromJSON(Map<String, dynamic> jsonData) {
    macroNo= jsonData["MacroNo"] as int;
    datasetNo= jsonData["DatasetNo"] as int;
    description= jsonData["Description"] as String;
  }
}

class InspectedCommand {
  int index = 0;
  String commandMnemonic = '';
  String commandCode = '';
  String data = '';
  int time = 0;
  bool executed = false;

  InspectedCommand();

  void fromJSON(Map<String, dynamic> jsonData) {
    index = jsonData['Index'] as int;
    commandMnemonic = jsonData['CommandMnemonic'] as String;
    commandCode = jsonData['CommandCode'] as String;
    data = jsonData['Data'] as String;
    time = jsonData['Time'] as int;
    executed = jsonData['Executed'] as bool;
  }
}

class InspectionItem {
  int macroNo = 0;
  int datasetNo = 0;
  String description = '';
  List<InspectedCommand> commands = [];

  InspectionItem();

  void fromJSON(Map<String, dynamic> jsonData) {
    macroNo = jsonData['MacroNo'] as int;
    datasetNo = jsonData['DatasetNo'] as int;
    description = jsonData['Description'] as String;
    
    if (jsonData['Commands'] != null) {
      commands = (jsonData['Commands'] as List)
          .map((cmd) {
            InspectedCommand command = InspectedCommand();
            command.fromJSON(cmd as Map<String, dynamic>);
            return command;
          })
          .toList();
    }
  }
}

class InspectionResponse with ResponseInterface {
  List<InspectionItem> items = [];
  bool ok = false;
  String message = '';

  InspectionResponse();

  @override
  void fromJSON(Map<String, dynamic> jsonData) {
    ok = jsonData['OK'] as bool;
    message = jsonData['Message'] as String;
    
    if (jsonData['Items'] != null) {
      items = (jsonData['Items'] as List)
          .map((item) {
            InspectionItem inspectionItem = InspectionItem();
            inspectionItem.fromJSON(item as Map<String, dynamic>);
            return inspectionItem;
          })
          .toList();
    }
  }
}
