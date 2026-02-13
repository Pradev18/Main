import 'package:shared_preferences/shared_preferences.dart';

import '../../api_confige.dart';

class   Constants {
  static String login =
      '${ApiConfige.BASE_URL}/parent_login.php';
  static String loginlog =
      '${ApiConfige.BASE_URL}/parent_login_log.php';
  static String logout =
      '${ApiConfige.BASE_URL}/parent_logout.php';
  static String alternate_add =
      '${ApiConfige.BASE_URL}/add_update_parent_alternate_person.php';
  static String editparent = '${ApiConfige.BASE_URL}/parent_update_details.php';
  static String editchild = '${ApiConfige.BASE_URL}/child_update_details.php';
  static String Formurl = '${ApiConfige.BASE_URL}/raise_ticket.php';
  static String Attendant = 'https://s3-alpha-sig.figma.com/img/35fd/14cd/bf0423c850b8bdb50bf8e9dd4e00ecd9?Expires=1705276800&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=nwCQ13m2jvAfl8vWWMrmyBidwBTbmvxpVLqFUEDthbL0BjanfR242CyMI~5f~bp18NsjyRcAW8iflIrO8TTe8uCtrR7yXAgX1uA0qVV4w0JhncvjmdHHZVYnMS1QEC6TPUfB6wt6FQPjvu4p1DSguiKu4vVzBO71xYnX6FvjVyjrMcWPsARapXVZQ-dif2vd4YRG0nuQm4S~ckkjKOQM2HZQuf4gdA4xq5DaBQMFUGlSrOEtE~RcB-V3-kfv~p8QWusnRvCgtoMilVRHnqnydStsxQCJpfcUnAvrHtxZEFydXichgUS9y-id3xNc0bUC~L8HgqHSrzh2xzYZ~BJQRg__';
  static String device_token = '1212121212122121212';
  static String parentId = '';
  static String alternateId = ' ';
  static String? setalternate = '';
  static String? fcmToken = '';
  static String? latitude = '';
  static String? longitude = '';
  static String? IpAddress = '';
  static String? firebaseid = '';


  static Future<void> initSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    parentId = prefs.getString('parentId') ?? '';
    alternateId = prefs.getString('alternateId') ?? '';
    fcmToken = prefs.getString('fcmToken');
    latitude = prefs.getString('latitude');
    longitude = prefs.getString('longitude');
    IpAddress = prefs.getString('ipAddress');
    firebaseid = prefs.getString('firebaseid');
  }

  // Save data to SharedPreferences
  static Future<void> saveToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('parentId', parentId);
    prefs.setString('alternateId', alternateId);
    prefs.setString('fcmToken', fcmToken ?? '');
    prefs.setString('latitude', latitude ?? '');
    prefs.setString('longitude', longitude ?? '');
    prefs.setString('ipAddress', IpAddress ?? '');
    prefs.setString('firebaseid', firebaseid ?? '');
  }

  // Clear data
  static Future<void> clearData() async {
    parentId = '';
    alternateId = '';
    // fcmToken = '';
    latitude = '';
    longitude = '';
    IpAddress = '';
    firebaseid = '';

    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
