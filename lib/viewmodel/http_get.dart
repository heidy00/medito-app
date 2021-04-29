/*This file is part of Medito App.

Medito App is free software: you can redistribute it and/or modify
it under the terms of the Affero GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Medito App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
Affero GNU General Public License for more details.

You should have received a copy of the Affero GNU General Public License
along with Medito App. If not, see <https://www.gnu.org/licenses/>.*/

import 'dart:convert';
import 'dart:io';

import 'package:Medito/user/user_utils.dart';
import 'package:Medito/utils/utils.dart';
import 'package:Medito/viewmodel/cache.dart';
import 'package:http/http.dart' as http;

//move this to network package later
Future httpGet(String url,
    {bool skipCache = false, String fileNameForCache}) async {
  var cache;

  if (!await checkConnectivity()) {
    skipCache = false;
  }

  if (skipCache) {
    cache = null;
  } else {
    cache = await readJSONFromCache(fileNameForCache ?? url);
  }

  if (cache == null) {
    final response = await http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: await token},
    );

    if (response.statusCode == 200) {
      await writeJSONToCache(response.body, fileNameForCache ?? url);
    }
    return json.decode(response.body);
  }
  return json.decode(cache);
}

Future httpPost(String url, {Map<String, String> body = const <String, String>{}, String token}) async {
  try {
    final response = await http.post(
      url,
      body: encoded(body),
      headers: {
        HttpHeaders.authorizationHeader: token,
        HttpHeaders.contentTypeHeader: 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : true;
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
