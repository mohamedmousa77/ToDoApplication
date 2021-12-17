import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/controllers/task_controller.dart';
import 'package:todoapp/moduls/task.dart';
import 'package:todoapp/widgets/button.dart';
import 'package:todoapp/widgets/input_field.dart';
import 'package:todoapp/widgets/theme.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();
  int _selectedRemaind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectRepeat = 'None';
  final List<String> _repitList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int _selectdColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _customAppbar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Add task', style: headingStyle),
              InputField(
                  hint: 'Enter title here',
                  title: 'Title',
                  controller: _titleController),
              InputField(
                  hint: 'Enter note here',
                  title: 'Note',
                  controller: _noteController),
              InputField(
                title: 'Date',
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () => _getDateFromUser(),
                  color: Colors.grey,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: 'start Time',
                      hint: _startTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_rounded),
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InputField(
                      title: 'end Time',
                      hint: _endTime,
                      widget: IconButton(
                        icon: const Icon(Icons.access_time_rounded),
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
              InputField(
                title: 'Remind',
                hint: '$_selectedRemaind minutes early',
                widget: Row(
                  children: [
                    DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.blueGrey,
                      items: remindList
                          .map<DropdownMenuItem<String>>(
                              (int value) =>
                              DropdownMenuItem<String>(
                                  value: value.toString(),
                                  child: Text(
                                    '$value',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  )))
                          .toList(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey),
                      iconSize: 32,
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemaind = int.parse(newValue!);
                        });
                      },
                    ),
                    const SizedBox(width: 6)
                  ],
                ),
              ),
              InputField(
                title: 'Repeat',
                hint: _selectRepeat,
                widget: Row(
                  children: [
                    DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: Colors.blueGrey,
                      items: _repitList
                          .map<DropdownMenuItem<String>>(
                              (String value) =>
                              DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  )))
                          .toList(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey),
                      iconSize: 32,
                      underline: Container(height: 0),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectRepeat = newValue!;
                        });
                      },
                    ),
                    const SizedBox(width: 6)
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPallet(),
                  ButtonCustomer('Create task', () {
                    _validateDate();
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar _customAppbar() {
    return AppBar(
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, size: 25, color: primaryClr)),
      backgroundColor: context.theme.backgroundColor,
      elevation: 0,
      actions: const [
        CircleAvatar(
          backgroundColor: primaryClr,
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Column _colorPallet() {
    return Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children: [
        Text('Color', style: titleStyle),
        Wrap(
          children: List.generate(
              3,
                  (index) =>
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectdColor = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        child: _selectdColor == index
                            ? const Icon(
                          Icons.done,
                          size: 14,
                          color: white,
                        )
                            : null,
                        backgroundColor: index == 0
                            ? primaryClr
                            : index == 1
                            ? pinkClr
                            : orangeClr,
                        radius: 14,
                      ),
                    ),
                  )),
        )
      ],
    );
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isNotEmpty ||
        _noteController.text.isNotEmpty) {
      Get.snackbar('required', 'All fields are required!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: white,
          colorText: pinkClr,
          icon: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
          ));
    } else {
      debugPrint('############  SOMETHING BAD HAPPENED ############');
    }
  }

  _addTaskToDb() async {
    int value = await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        note: _noteController.text,
        isCompleted: 0,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        color: _selectdColor,
        remind: _selectedRemaind,
        repeat: _selectRepeat,
      ),
    );
    debugPrint('$value');
  }

  _getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
    );
    if (_pickedDate != null) {
      setState(() => _selectedDate = _pickedDate);
    } else {
      debugPrint('It\'s null or something is wrong');
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? _pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
          DateTime.now().add(const Duration(minutes: 15))),
    );
    String _formattedTime = _pickedTime!.format(context);
    if (isStartTime) {
      setState(() => _startTime = _formattedTime);
    }
  else  if (!isStartTime) {
      setState(() => _endTime = _formattedTime);
    } else {
      debugPrint('Time canceled or something is wrong');
    }
  }
}
