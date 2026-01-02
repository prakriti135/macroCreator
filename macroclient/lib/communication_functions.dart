import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:macroclient/structures.dart';
import 'package:macroclient/helperfunctions.dart';

void communicate(String url, RequestInterface request,
    ResponseInterface response, VoidCallback callback) {
  http
      .post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(request.toJSON()),
  )
      .then(
        (resp) {
      getResponse(resp, response);
      callback();
    },
    onError: (e) {
      showMessage("Server not Available", true);
      response.ok = false;
      callback();
    },
  );
}

void getResponse(http.Response resp, ResponseInterface response) {
  if (resp.statusCode == 200) {
    response.fromJSON(jsonDecode(resp.body));
    if (!response.ok) {
      showMessage(response.message, true);
    }
  } else {
    showMessage("Server returned negative acknowledgement", true);
    response.ok = false;
  }
}

void registerClient(Global global, Acknowledgement response, VoidCallback callback) {
  EmptyRequest emptyRequest = EmptyRequest();
  emptyRequest.id = global.clientID;
  debugPrint(emptyRequest.id);

  communicate('${global.url}/register', emptyRequest, response, callback);
}

void getParameterValue(Global global, String paramName, ValueResponse response,
    VoidCallback callback) {
  ValueRequest valueRequest = ValueRequest();
  valueRequest.id = global.clientID;
  valueRequest.parameterName = paramName;

  communicate('${global.url}/getValue', valueRequest, response, callback);
}

void setParameter(Global global, String parameterName, String value,
    Acknowledgement ack, VoidCallback callback) {
  SetRequest request = SetRequest();
  request.id = global.clientID;
  request.parameterName = parameterName;
  request.parameterValue = value;

  communicate('${global.url}/saveParameterValue', request, ack, callback);
}

void populateTCDatabase(Global global, Acknowledgement response, VoidCallback callback) {
  EmptyRequest emptyRequest = EmptyRequest();
  emptyRequest.id = global.clientID;

  communicate('${global.url}/getTCDatabase', emptyRequest, response, callback);
}

void setMultipleParameters(Global global, String paramName, List<String> values,
    Acknowledgement ack, VoidCallback callback) {
  SetMultiParameterRequest request = SetMultiParameterRequest();
  request.id = global.clientID;
  request.parameterName = paramName;
  request.parameterValues = [];
  request.parameterValues.addAll(values);

  communicate('${global.url}/saveParameterValues', request, ack, callback);
}

void loadCSVFiles(Global global, String fileData, fileType, Acknowledgement ack, VoidCallback callback){
  LoadCSVFile request = LoadCSVFile();
  request.id = global.clientID;
  request.type = fileType;
  request.data = fileData;

  communicate('${global.url}/saveCSVFiles', request, ack, callback);
}

void getMultipleValues(Global global, String param, MultipleValueResponse response, VoidCallback callback){
  ValueRequest request = ValueRequest();
  request.id = global.clientID;
  request.parameterName = param;

  communicate('${global.url}/getMultipleValues', request, response, callback);
}

void saveMacros(Global global, int macNo, int cmdNos, List<SaveMacroCommand> cmds,
    Acknowledgement ack, VoidCallback callback){
  SaveMacroDetails request = SaveMacroDetails();
  request.id = global.clientID;
  request.macroNo = macNo;
  request.noOfCommands = cmdNos;
  request.commands = cmds;
  communicate('${global.url}/saveMacros', request, ack, callback);
}

void getMacros(Global global, String macNo, GetMacroDetails response, VoidCallback callback) {
  ValueRequest request = ValueRequest();
  request.id = global.clientID;
  request.parameterName = macNo;
  communicate('${global.url}/getMacros', request, response, callback);
}

void saveDatasets(Global global, int datasetNo, List<bool> executions,
List<String> data, List<int> times, int linkedMacro, String description, Acknowledgement ack, VoidCallback callback) {
  SaveDatasetDetails request = SaveDatasetDetails();
  request.id = global.clientID;
  request.datasetNo = datasetNo;
  request.executions = executions;
  request.data = data;
  request.times = times;
  request.linkedMacro = linkedMacro;
  request.description = description;

  communicate('${global.url}/saveDatasetDetails', request, ack, callback);
}

void getDatasets(Global global, String dsNo, GetDatasetDetails response, VoidCallback callback) {
  ValueRequest request = ValueRequest();
  request.id = global.clientID;
  request.parameterName = dsNo;
  communicate('${global.url}/getDatasets', request, response, callback);
}

void getCompletedMacros(Global global, CompletedMacros response, VoidCallback callback) {
  EmptyRequest request = EmptyRequest();
  request.id = global.clientID;
  communicate('${global.url}/getCompletedMacros', request, response, callback);
}







