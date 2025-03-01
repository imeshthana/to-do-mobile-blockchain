// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ToDoList {
    address owner;

    enum TaskStatus {
        Pending, Finished
    }    

    struct Task {
        string des;
        TaskStatus status;
    }

    Task[] public tasks;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function addTask(string memory _des) public onlyOwner {
        tasks.push(Task(_des, TaskStatus.Pending));
    }

    function updateStatus(uint256 _id) public  onlyOwner {
        require(_id < tasks.length, "Task not available");
        tasks[_id].status = TaskStatus.Finished;
    }

    function getAllTasks() public view returns (Task[] memory){
        return tasks;
    }

    function getTask(uint256 _id) public view returns (string memory, TaskStatus){
        require(_id < tasks.length, "Task not available");
        return(tasks[_id].des, tasks[_id].status);

    }
}