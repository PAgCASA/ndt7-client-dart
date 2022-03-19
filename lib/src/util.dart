
import 'dart:collection';

HashMap<String,String> toStringMap(Map<String, dynamic> data){
  HashMap<String,String> result = HashMap();

  data.forEach((key, value) {
    result[key] = value as String;
  });

  return result;
}