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

import 'package:Medito/utils/stats_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test longerThanOneDayAgo', () {
    var b = longerThanOneDayAgo(
        DateTime.parse('2020-06-26 18:15:00'), DateTime.now());
    expect(b, true);
  });
  test('test not longerThanOneDayAgo', () {
    var b = longerThanOneDayAgo(DateTime.parse('2020-06-26 18:15:00'),
        DateTime.parse('2020-06-26 19:15:00'));
    expect(b, false);
  });

  test('test is same day', () {
    var b = isSameDay(DateTime.parse('2020-06-27 18:15:00'),
        DateTime.parse('2020-06-27 00:15:00'));
    expect(b, true);
  });

  test('test not is same day 2', () {
    var b = isSameDay(DateTime.parse('2020-06-01 18:15:00'),
        DateTime.parse('2021-06-01 11:15:00'));
    expect(b, false);
  });

  test('test not is same day', () {
    var b = isSameDay(DateTime.parse('2020-06-27 18:15:00'),
        DateTime.parse('2021-06-27 00:15:00'));
    expect(b, false);
  });

  test("test increment counter by 1", () async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setInt('streakCount', 0);

    incrementStreakCounter(0);

    Future<String> future2 = getCurrentStreak();
    expect(future2, completion("1"));
  });

  test("test updateStreak and check longest", () async {
    updateStreak(streak: '5');

    Future<String> future2 = getCurrentStreak();
    expect(future2, completion("5"));

    updateStreak(streak: '2');

    Future<String> future1 = getLongestStreak();
    expect(future1, completion("5"));
  });
}