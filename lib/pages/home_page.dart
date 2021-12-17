import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/controllers/task_controller.dart';
import 'package:todoapp/db/db_helper.dart';
import 'package:todoapp/moduls/task.dart';
import 'package:todoapp/services/notification_services.dart';

import 'package:todoapp/services/theme_services.dart';
import 'package:todoapp/widgets/button.dart';

import 'package:todoapp/widgets/size_config.dart';
import 'package:todoapp/widgets/task_tile.dart';
import 'package:todoapp/widgets/theme.dart';

import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  late NotifyHelper notifyHepler;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHepler = NotifyHelper();
    notifyHepler.initializeNotification();
    notifyHepler.requestIOSPermissions();
    _taskController.getTask();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // backgroundColor: Get.isDarkMode?Colors.black:Colors.white,
     backgroundColor:context.theme.backgroundColor,
    appBar: _appbar(),
      body: Column(
        children: [
          _addTask(),
          _addDate(),
          const SizedBox(height: 6),
          _showTask()
        ],
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      backgroundColor:context.theme.backgroundColor,
      elevation: 0,
      leading: IconButton(
          onPressed: () {
            ThemeServices().switchTheme();
          },
          icon: Icon(
              Get.isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round_outlined,
              size: 25,
              color: Get.isDarkMode ? Colors.white : primaryClr
          ),
      ),
      actions:  [
        IconButton(
          onPressed: () {
            _taskController.deleteAllTask();
            notifyHepler.cancelAllNotification();
          },
          icon: Icon( Icons.cleaning_services_outlined,
              size: 25,
              color: Get.isDarkMode ? Colors.white : primaryClr
          ),
        ),
        const CircleAvatar(
          backgroundColor: primaryClr,
          backgroundImage: AssetImage('images/person.jpeg'),
          radius: 18,
        ),
       const SizedBox(width: 20),
      ],
    );
  }

  _addTask() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                'Today',
                style: headingStyle,
              )
            ],
          ),
          ButtonCustomer('+ Add Task', () async {
            await Get.to(const AddTaskPage());
            _taskController.getTask();
          })
        ],
      ),
    );
  }

  _addDate() {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 20),
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: _selectedDate,
        dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        width: 70,
        height: 100,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    _taskController.getTask();
  }

  _showTask() {
    return Expanded(
      child: Obx(() {
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemCount: _taskController.taskList.length,
              itemBuilder: (BuildContext context, int index) {
                var task = _taskController.taskList[index];
                var hours = task.startTime.toString().split(':')[0];
                var minutes = task.startTime.toString().split(':')[1];
                debugPrint('My Hour : ' + hours);
                debugPrint('my Minutes' + minutes);
                var date = DateFormat.jm().parse(task.startTime!);
                var myTime = DateFormat('HH:mm').format(date);
                notifyHepler.scheduledNotification(
                    int.parse(myTime.toString().split(':')[0]),
                    int.parse(myTime.toString().split(':')[1]),
                    task);

                if (task.date == DateFormat.yMd().format(_selectedDate) || task.repeat == 'Daily'
                    ||(task.repeat == 'Weekly' && _selectedDate.difference(DateFormat.yMd().parse(task.date!)).inDays %7==0)
                ||(task.repeat == 'Monthly' && _selectedDate.day == DateFormat.yMd().parse(task.date!).day)) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(microseconds: 1333),
                    child: SlideAnimation(
                      horizontalOffset: 300,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () => _showBottomSheet(context, task),
                          child: TaskTile(task),
                        ),
                      ),
                    ),
                  );
                }

                else {
                  return Container();
                }
              },
            ),
          );
        }
      }),
    );
  }

  _noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 5),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(height: 220),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    semanticsLabel: 'Task',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'you do not have any tasks yel! \n Add new task to make your day productive',
                      textAlign: TextAlign.center,
                      style: subTitleStyle,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 120,
                        )
                      : const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          height: (SizeConfig.orientation == Orientation.landscape)
              ? (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.6
                  : SizeConfig.screenHeight * 0.8)
              : (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.30
                  : SizeConfig.screenHeight * 0.39),
          margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          child: Column(
            children: [
              Flexible(
                  child: Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
              )),
              const SizedBox(height: 20),
              task.isCompleted == 1
                  ? Container()
                  : _buildBottomSheet(
                      label: 'Task Completed',
                      clr: primaryClr,
                      onTap: () {
                        notifyHepler.cancelNotification(task);
                        _taskController.markTaskAsCompleted(task.id!);
                        Get.back();
                      },
                    ),
              _buildBottomSheet(
                label: 'delet Completed',
                clr: Colors.red[300]!,
                onTap: () {
                  notifyHepler.cancelNotification(task);
                  _taskController.deleteTask(task);
                  Get.back();
                },
              ),
              Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr),
              _buildBottomSheet(
                label: 'Cancel',
                clr: primaryClr,
                onTap: () {
                  Get.back();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                width: 2,
                color: isClose
                    ? Get.isDarkMode
                        ? Colors.grey[600]!
                        : Colors.grey[300]!
                    : clr),
            color: isClose ? Colors.transparent : clr),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
