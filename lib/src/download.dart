import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ndt_7_dart/src/util.dart';
import 'package:web_socket_channel/io.dart';

import 'constants.dart';

class DownloadTest {
  int _totalBytes = 0;
  late DateTime _start;
  final String _url;

  //TODO handle canceling the test
  final StreamController<TestStatus> _outputStream = StreamController();

  Stream<TestStatus> get outputStream => _outputStream.stream;

  DownloadTest(this._url);

  Future<TestStatus> startTest() async {
    _start = DateTime.now();

    var channel = IOWebSocketChannel.connect(Uri.parse(_url),
        headers: {"Sec-WebSocket-Protocol": "net.measurementlab.ndt.v7"});

    var outputTimer = Timer.periodic(UpdateInterval, (t) {
      _outputStream.add(TestStatus.fromRaw(_totalBytes, _start));
    });

    channel.stream.listen((event) {
      switch (event.runtimeType) {
        case String:
          //print(event.toString());
          //TODO deal with the debug info strings later
          _totalBytes += utf8.encode(event.toString()).length;
          break;
        default:
          _totalBytes += (event as Uint8List).length;
      }
    }, onDone: () {
      outputTimer.cancel();
      _outputStream.add(TestStatus.fromRaw(_totalBytes, _start, done: true));
      channel.sink.close();
    }, onError: (e) {
      outputTimer.cancel();
      _outputStream.addError(e);
      channel.sink.close();
    });

    return Future(() async {
      await channel.sink.done; //wait for socket to close
      return TestStatus.fromRaw(_totalBytes, _start, done: true);
    });
  }
}
