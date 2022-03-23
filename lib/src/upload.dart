import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:ndt_7_dart/src/util.dart';
import 'package:web_socket_channel/io.dart';

import 'constants.dart';

class UploadTest {
  int _totalBytes = 0;
  late DateTime _start;
  final String _url;
  bool _done = false;

  //TODO handle canceling the test
  final StreamController<TestStatus> _outputStream = StreamController();

  Stream<TestStatus> get outputStream => _outputStream.stream;

  UploadTest(this._url);

  //TODO return future that returns final results when test is done
  Future<TestStatus> startTest() async {
    //create the message to send
    var rng = Random();
    Uint8List data = Uint8List.fromList(
        List.generate(BulkMessageSize, (index) => rng.nextInt(256)));

    _start = DateTime.now();

    var channel = IOWebSocketChannel.connect(Uri.parse(_url),
        headers: {"Sec-WebSocket-Protocol": "net.measurementlab.ndt.v7"});

    var outputTimer = Timer.periodic(UpdateInterval, (t) {
      _outputStream.add(TestStatus.fromRaw(_totalBytes, _start));
    });

    final sink = channel.sink;

    //make sure we don't go over test duration
    sink.done.timeout(UploadTimeout, onTimeout: () {
      _done = true;
      outputTimer.cancel();
      var doneMessage = TestStatus.fromRaw(_totalBytes, _start, done: true);
      _outputStream.add(doneMessage);
      return doneMessage;
    }).whenComplete(() {
      _done = true;
      outputTimer.cancel();
    });

    return Future(() async {
      while (!_done) {
        await Future.delayed(Duration(microseconds: 1));
        sink.add(data);//TODO this doesn't block if buffer is full so we can't get an accurate measurement
        _totalBytes += data.length;
      }
      outputTimer.cancel();
      return TestStatus.fromRaw(_totalBytes, _start, done: true);
    });
  }
}
