import 'dart:convert';

import 'package:gala_travels_app/menu_pages/constants/constants.dart';
import 'package:gala_travels_app/model/parent_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api_confige.dart';

class Apicontroller extends GetxController {
  List<parentmodel>? apimodel = <parentmodel>[].obs;
  var isloding = false.obs;
  List<dynamic>? data;

  @override
  Future<void> onInit() async {
    super.onInit();
    Fetchdata();
  }

 Fetchdata() async {
    try {
      isloding(true);

      http.Response response = await http.get(Uri.parse(
          '${ApiConfige.BASE_URL}/parent_dashboard.php?parent_id=${Constants.parentId}'));
      print("response: =-----------${response.body}");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        var newData = parentmodel.fromJson(result);
        print("result data: =-----------$result");

        // Assigning the new data to the apimodel
        print("dasborde data: =-----------$newData");
        apimodel = [newData];
      } else {
        print('Error fetching data');
      }
    } catch (e) {
      print('Error while getting data: $e');
    } finally {
      isloding(false);
      // print('Finally: $apimodel');
    }
  }
}
