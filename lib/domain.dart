import 'dart:convert';
import 'package:http/http.dart' as http;

class Domain {
  static var url = 'https://b2conlinestore.com.my';
  static var domain = 'https://www.app.emenu.com.my/';

  static Uri notification = Uri.parse(domain + 'notification/index.php');
  static Uri loading = Uri.parse(domain + 'loading/index.php');

  /*
  * register device token
  * */
  registerDeviceToken(token) async {
    var response = await http.post(Domain.notification, body: {'register_token': '1', 'token': token, 'merchant_id': '761'});
    return jsonDecode(response.body);
  }

  /*
  * loading
  * */
  launchCheck() async {
    var response = await http.post(Domain.loading, body: {'launch_check': '1', 'merchant_id': '761'});
    return jsonDecode(response.body);
  }
}
