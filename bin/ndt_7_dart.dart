import 'dart:io';

import 'package:ndt_7_dart/src/download.dart';
import 'package:ndt_7_dart/src/locator.dart';
import 'package:ndt_7_dart/src/upload.dart';

Future<void> main(List<String> arguments) async {
  print('Test program for NDT-7 Dart implementation!');
  var c = Client.newClient("ndt7-dart");
  var targets = await c.nearest("ndt/ndt7");

  var downloadLocation = targets[0].URLs['ws:///ndt/v7/download'] ?? "";
  var dc = DownloadTest(downloadLocation);

  dc.outputStream.forEach((element) {
    print("download-${element.bps * 8 / 1000 / 1000}mbps-${element.done}");
  });

  print("Starting download test");
  await dc.startTest();

  await Future.delayed(Duration(milliseconds: 500));
  print("Moving on to upload test");

  var upload = UploadTest(targets[0].URLs['ws:///ndt/v7/upload'] ?? "");
  upload.outputStream.forEach((element) {
    print("upload-${element.bps * 8 / 1000 / 1000}mbps-${element.done}");
  });
  await upload.startTest();
  print("Done testing!");
  exit(0);
}
