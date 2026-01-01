import 'package:flutter/material.dart';
import 'package:macro_creator/structures.dart';

class ErrorStatus extends StatefulWidget {
  final Global global;
  final VoidCallback callback;

  const ErrorStatus(this.global, this.callback, {super.key});

  @override
  State<ErrorStatus> createState() => StateErrorStatus();
}

class StateErrorStatus extends State<ErrorStatus> {
  final TextEditingController _serverIP = TextEditingController();

  @override
  void initState() {
    _serverIP.text = widget.global.url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var msg = "Server Not Available";

    return Center(
      child: Form(
        child: SizedBox(
          height: 250,
          width: 450,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(msg, style: Theme.of(context).textTheme.titleLarge),
                Divider(),
                TextFormField(
                  controller: _serverIP,
                  decoration: InputDecoration(helperText: "Server IP"),
                ),
                const Divider(),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.global.url = _serverIP.text;
                    widget.callback();
                  },
                  label: const Text("Try Again"),
                  icon: const Icon(Icons.private_connectivity_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
