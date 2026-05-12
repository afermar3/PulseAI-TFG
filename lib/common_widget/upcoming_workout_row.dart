import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/material.dart';

class UpcomingWorkoutRow extends StatefulWidget {
  final Map wObj;

  const UpcomingWorkoutRow({
    super.key,
    required this.wObj,
  });

  @override
  State<UpcomingWorkoutRow> createState() => _UpcomingWorkoutRowState();
}

class _UpcomingWorkoutRowState extends State<UpcomingWorkoutRow> {
  bool positive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              widget.wObj["image"].toString(),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wObj["title"].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  widget.wObj["time"].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 34,
            child: Transform.scale(
              scale: 0.75,
              child: Switch(
                value: positive,
                activeColor: TColor.white,
                activeTrackColor: TColor.secondaryColor1,
                inactiveThumbColor: TColor.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (value) {
                  setState(() {
                    positive = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}