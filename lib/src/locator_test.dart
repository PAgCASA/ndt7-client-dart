import 'package:ndt_7_dart/src/locator.dart';
import 'package:test/test.dart';

void main() {
  test("Basic locator test", ()async{
    var locator = Client.newClient("DartClientTesting");
    var response = await locator.nearest("ndt/ndt7");
    expect(response.length, greaterThan(0));
  });
}
