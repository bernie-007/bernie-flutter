import 'package:http/http.dart' as http;

class Api {

  final String _url = 'http://68.183.93.26/dating-server/apis/';

  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
      fullUrl,
      body: data
    );
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.get(
      fullUrl,
      headers: _setHeaders()
    );
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'appilcation/json',
  };

}