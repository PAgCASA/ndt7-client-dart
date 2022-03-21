import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/io.dart';

import 'constants.dart';

class DownloadStatus {
  bool done; //done with test
  int bps; //bytes per second

  DownloadStatus({this.done = false, required this.bps});

  @override
  String toString() {
    return "$bps-$done";
  }
}

class DownloadTest {
  int _totalBytes = 0;
  late DateTime _start;
  final String _url;
  //TODO handle canceling the test
  final StreamController<DownloadStatus> _outputStream = StreamController();

  Stream<DownloadStatus> get outputStream => _outputStream.stream;

  DownloadTest(this._url);

  //TODO return future that returns final results when test is done
  void startTest() {
    _start = DateTime.now();

    var channel = IOWebSocketChannel.connect(Uri.parse(_url),
        headers: {"Sec-WebSocket-Protocol": "net.measurementlab.ndt.v7"});

    var outputTimer = Timer.periodic(UpdateInterval, (t) {
      _outputStream.add(DownloadStatus(bps: _getCurrentBPS()));
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
      _outputStream.add(DownloadStatus(bps: _getCurrentBPS(), done: true));
    }, onError: (e) {
      outputTimer.cancel();
      _outputStream.addError(e);
    });
  }

  int _getCurrentBPS() {
    var decimalBPS =
        _totalBytes / ((DateTime.now().difference(_start).inMilliseconds) / 1000);
    return decimalBPS.truncate();
  }
}
