import '../../../service/department_service.dart';

/// Helper class for department views to extract common logic
/// Following MVC pattern: Views use helpers, not business logic
class DepartmentViewHelpers {
  /// Extract selected sizes from loading states (MVC: View helper)
  static String extractSelectedSizes(Map<String, bool>? loadingStates) {
    return DepartmentService.extractSizesFromLoadingStates(loadingStates);
  }
}

