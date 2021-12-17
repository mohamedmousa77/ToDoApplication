import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final String payload;

  NotificationScreen(this.payload);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _payload = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              color: Get.isDarkMode ? Colors.white : Colors.white,
              icon: const Icon(Icons.arrow_back)),
          backgroundColor: Get.isDarkMode ? Colors.white : Colors.black,
          title: Text(_payload.toString().split('|')[0],
              style: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.white,
              ))),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                Text('Hello , Mohamed',
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      color: Get.isDarkMode
                          ? Colors.white
                          : const Color(0xFF121212),
                    )),
                Text('You have a new reminder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Get.isDarkMode
                          ? Colors.grey[100]
                          : const Color(0xFF121212),
                    ))
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF4e5ae8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(
                        Icons.text_format,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('Title',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const SizedBox(width: 10),
                      Text(_payload.toString().split('|')[0],
                          style: const TextStyle(
                            color: Colors.white,
                          ))
                    ]),
                    const SizedBox(height: 10),
                    Row(children: const [
                      Icon(
                        Icons.description,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const SizedBox(width: 10),
                      Text(
                        _payload.toString().split('|')[1],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      )
                    ]),
                    const SizedBox(height: 10),
                    Row(children: const [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      const SizedBox(width: 10),
                      Text(
                        _payload.toString().split('|')[2],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      )
                    ]),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
