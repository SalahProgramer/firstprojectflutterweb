import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/departments_controller.dart';

mixin DepartmentViewMixin<T extends StatefulWidget> on State<T> {
  /// Get the departments controller from context
  DepartmentsController get departmentsController => 
      context.watch<DepartmentsController>();

  /// Read the departments controller without watching
  DepartmentsController readDepartmentsController() => 
      context.read<DepartmentsController>();
  Future<void> navigateToDepartment({
    required String title,
    required String sizes,
    required bool showIconSizes,
  }) async {
    // This is a template method that should be overridden
    // or used by specific department views
  }
}


abstract class BaseDepartmentView extends StatefulWidget {
  const BaseDepartmentView({super.key});
}

