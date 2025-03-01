import 'dart:convert';
import 'package:client/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Task {
  final String description;
  final bool isCompleted;

  Task({required this.description, required this.isCompleted});
}

class Contract with ChangeNotifier {
  final String rpcUrl = "http://127.0.0.1:8545";
  final String privateKey =
      "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
  bool isLoading = true;
  late Web3Client web3client;
  late String abi;
  late EthereumAddress ethereumAddress;
  late Credentials credentials;
  late DeployedContract deployedContract;
  late ContractFunction addTaskFunction;
  late ContractFunction updateStatusFunction;
  late ContractFunction getAllTasksFunction;
  late ContractFunction getTaskFunction;

  List<Task> tasks = [];

  Contract() {
    initialContract();
  }

  Future initialContract() async {
    web3client = Web3Client(rpcUrl, Client());
    await getAbi();
    await getCredentials();
    await getDeployedContract();
    await getTasks();

    isLoading = false;
    notifyListeners();
  }

  Future getAbi() async {
    String abiFile = await rootBundle.loadString('assets/ToDo.json');
    final jsonAbi = jsonDecode(abiFile);
    abi = jsonEncode(jsonAbi['abi']);
    ethereumAddress = EthereumAddress.fromHex(address);
  }

  Future getCredentials() async {
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future getDeployedContract() async {
    deployedContract =
        DeployedContract(ContractAbi.fromJson(abi, 'ToDo'), ethereumAddress);

    addTaskFunction = deployedContract.function('addTask');
    updateStatusFunction = deployedContract.function('updateStatus');
    getAllTasksFunction = deployedContract.function('getAllTasks');
    getTaskFunction = deployedContract.function('getTask');
  }

  Future getTasks() async {
    try {
      final result = await web3client.call(
          contract: deployedContract,
          function: getAllTasksFunction,
          params: []);

      if (result.isNotEmpty && result[0] is List) {
        List<dynamic> taskList = result[0];
        tasks = [];

        for (var i = 0; i < taskList.length; i++) {
          var taskResult = await web3client.call(
            contract: deployedContract,
            function: getTaskFunction,
            params: [BigInt.from(i)],
          );

          String description = taskResult[0];
          BigInt status = taskResult[1];

          tasks.add(Task(
            description: description,
            isCompleted: status == BigInt.from(1),
          ));
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error getting tasks: $e");
    }
  }

  Future<void> addTask(String description) async {
    isLoading = true;
    notifyListeners();

    try {
      await web3client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: deployedContract,
              function: addTaskFunction,
              parameters: [description]),
          chainId: null,
          fetchChainIdFromNetworkId: true);
      await getTasks();
    } catch (e) {
      print("Error adding task: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTasks(int taskId) async {
    isLoading = true;
    notifyListeners();

    try {
      await web3client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: deployedContract,
              function: updateStatusFunction,
              parameters: [BigInt.from(taskId)]),
          chainId: null,
          fetchChainIdFromNetworkId: true);
      await getTasks();
    } catch (e) {
      print("Error updating task: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
