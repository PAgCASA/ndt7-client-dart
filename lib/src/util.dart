
import 'dart:collection';

HashMap<String,String> toStringMap(Map<String, dynamic> data){
  HashMap<String,String> result = HashMap();

  data.forEach((key, value) {
    result[key] = value as String;
  });

  return result;
}

class TestStatus {
  bool done; //done with test
  int bps; //bytes per second

  TestStatus({this.done = false, required this.bps});

  factory TestStatus.fromRaw(int totalBytes, DateTime start, {bool done = false}) {
      var decimalBPS =
          totalBytes / ((DateTime.now().difference(start).inMilliseconds) / 1000);
      return TestStatus(bps: decimalBPS.truncate(), done: done);
  }

  @override
  String toString() {
    return "$bps-$done";
  }
}