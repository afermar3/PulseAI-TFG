import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/material.dart';

import '../widgets/common.dart';

class TodaySleepScheduleRow extends StatefulWidget {
  final Map sObj;

  const TodaySleepScheduleRow({
    super.key,
    required this.sObj,
  });

  @override
  State<TodaySleepScheduleRow> createState() => _TodaySleepScheduleRowState();
}

class _TodaySleepScheduleRowState extends State<TodaySleepScheduleRow> {
  bool positive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 10),
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
          const SizedBox(width: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              widget.sObj["image"].toString(),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.sObj["name"].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      ", ${getStringDateToOtherFormate(widget.sObj["time"].toString())}",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  widget.sObj["duration"].toString(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 30,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/img/More_V.png",
                    width: 20,
                    height: 20,
                  ),
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
        ],
      ),
    );
  }
}