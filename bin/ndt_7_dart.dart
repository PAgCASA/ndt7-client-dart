import 'package:ndt_7_dart/src/download.dart';
import 'package:ndt_7_dart/src/locator.dart';

Future<void> main(List<String> arguments) async {
  print('Hello world!');
  var c = Client.newClient("ndt7-dart");
  var targets = await c.nearest("ndt/ndt7");
  var downloadLocation = targets[0].URLs['ws:///ndt/v7/download'] ?? "";

  var dc = DownloadTest(downloadLocation);

  dc.outputStream.forEach((element) {
    print("${element.bps*8/1000/1000}mbps-${element.done}");
  });

  dc.startTest();
}
