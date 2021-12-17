import 'package:flutter/material.dart';


class ButtonCustomer extends StatelessWidget {
  const ButtonCustomer(this.label, this.onTap,{Key? key}) : super(key: key);

  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:const Color(0xFF4e5ae8)
        ),
        width: 100,
        height: 45,
        child: Text(
          label,
          style: const TextStyle(color: Colors.black,),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
