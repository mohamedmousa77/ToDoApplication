import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/db/db_helper.dart';
import 'package:todoapp/moduls/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;

  addTask({Task? task}) {
    return DBHelper.insert(task);
  }

  Future<void> getTask() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((element) => Task.fromJson(element)).toList());
  }

  void deleteTask(Task task) async {
    await DBHelper.delete(task);
    getTask();
  }
  void deleteAllTask() async {
    await DBHelper.deleteAll();
    getTask();
  }

  void markTaskAsCompleted(int id) async {
    await DBHelper.update(id);
    getTask();
  }
}
