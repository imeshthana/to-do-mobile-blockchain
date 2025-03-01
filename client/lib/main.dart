import 'package:client/contracts/contract.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ChangeNotifierProvider(
        create: (context) => Contract(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo-Dapp',
      home: const MyHomePage(title: 'ToDo Dapp'),
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
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Create New Task"),
            content: TextField(
              controller: _taskController,
              decoration:
                  const InputDecoration(hintText: "Enter task description"),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _taskController.clear();
                  },
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  if (_taskController.text.isNotEmpty) {
                    Provider.of<Contract>(context, listen: false)
                        .addTask(_taskController.text);
                    Navigator.pop(context);
                    _taskController.clear();
                  }
                },
                child: const Text('Add'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final contractProvider = Provider.of<Contract>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 134, 115, 255),
        title: Center(
            child: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        )),
      ),
      body: contractProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : contractProvider.tasks.isEmpty
              ? const Center(
                  child: Text('No tasks yet. Add a task to get started!'))
              : Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                      itemCount: contractProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = contractProvider.tasks[index];
                        return ListTile(
                          title: Text(task.description,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              )),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (bool? value) {
                              if (!task.isCompleted) {
                                contractProvider.updateTasks(index);
                              }
                            },
                          ),
                          trailing: task.isCompleted
                              ? const Chip(
                                  label: Text('Completed'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                )
                              : const Chip(
                                  label: Text('Pending'),
                                  backgroundColor: Colors.orange,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                        );
                      }),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Color.fromARGB(255, 134, 115, 255),
        tooltip: "Add Task",
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
