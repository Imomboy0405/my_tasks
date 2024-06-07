import 'package:intl/intl.dart';
import 'package:my_tasks/Data/Services/lang_service.dart';

class LogicService {

  static String difference({required DateTime endDate}) {
  int day = endDate.difference(DateTime.now()).inDays;
  int hour = endDate.difference(DateTime.now()).inHours % 24;
  int minute = endDate.difference(DateTime.now()).inMinutes % 60;
  return '${day > 0 ? " $day ${'day'.tr()}" : ''} ${hour > 0 ? "$hour ${'hour'.tr()}" : ''} ${minute > 0 ? "$minute ${'minute'.tr()}" : ''}';
}

  static bool compareStatus({
    required bool filterInProcess,
    required bool filterIQ,
    required bool filterPaid,
    required bool filterPayme,
    required String status,
  }) {
    switch (status) {
      case ('Paid'): if (filterPaid) {
        return true;
      } else {
        break;
      }
      case ('In process'): if (filterInProcess) {
        return true;
      } else {
        break;
      }
      case ('Rejected by IQ'): if (filterIQ) {
        return true;
      } else {
        break;
      }
      case ('Rejected by Payme'): if (filterPayme) {
        return true;
      } else {
        break;
      }
    }
    return false;
  }


  static String weekDayName({required int day, required int month, required int year}) {
    DateTime date = DateTime(year, month, day);
    return DateFormat('EEEE').format(date).substring(0,2);
  }
}