import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableCartWidget extends StatefulWidget {
  final Widget card;
  final int index;
  final void Function()? onPressed;

  const SlidableCartWidget(
      {super.key,
      required this.card,
      required this.index,
      required this.onPressed});

  @override
  State<SlidableCartWidget> createState() => _SlidableCartWidgetState();
}

class _SlidableCartWidgetState extends State<SlidableCartWidget> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: ((((widget.index) * 4) + 100))),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(value * 200 - 100, 0),
        child: child,
      ),
      tween: Tween(begin: -1, end: 0.5),
      child: Container(
        margin: EdgeInsets.all(4.w),
        child: Slidable(
          dragStartBehavior: DragStartBehavior.start,
          startActionPane: ActionPane(
            motion: ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SizedBox(
                width: 80.w,
                child: FloatingActionButton(
                    elevation: 0.5,
                    // isExtended: true,
                    shape: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.r)),
                    backgroundColor: Colors.red,
                    onPressed: widget.onPressed ?? () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.delete,
                          color: Colors.white,
                        ),
                        Text(
                          "حذف",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
              )
            ],
          ),
          child: widget.card,
        ),
      ),
    );
  }
}
