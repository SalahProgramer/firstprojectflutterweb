import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../controllers/departments_controller.dart';
import '../../utilities/style/text_style.dart';

class TotalItemsDepartment extends StatelessWidget {
  const TotalItemsDepartment({super.key});

  @override
  Widget build(BuildContext context) {
    DepartmentsController departmentsController =
        context.watch<DepartmentsController>();
    return AnimatedOpacity(
      opacity: (departmentsController.totalItems == 0) ? 0 : 1,
      duration: Duration(milliseconds: 1300),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: AnimatedOpacity(
                opacity: (departmentsController.totalItems == 0) ? 0 : 1,
                duration: Duration(milliseconds: 600),
                child: Text(
                  "عدد الكمية المتوفرة: ${departmentsController.totalItems}",
                  style: CustomTextStyle()
                      .heading1L
                      .copyWith(color: Colors.black, fontSize: 12.sp),
                ),
              ),
            ),
            Spacer(),
            Expanded(
              child: AnimatedOpacity(
                opacity: ((departmentsController.numberPage) <= 0) ? 0 : 1,
                duration: Duration(milliseconds: 600),
                child: Text(
                  "الصفحة: ${departmentsController.numberPage}",
                  textAlign: TextAlign.end,
                  style: CustomTextStyle()
                      .heading1L
                      .copyWith(color: Colors.black, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
