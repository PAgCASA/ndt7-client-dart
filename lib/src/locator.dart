import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ndt_7_dart/src/constants.dart';
import 'package:ndt_7_dart/src/util.dart';

class NearestResult {
  final Error? error;
  final NextRequest? nextRequest;
  final List<Target>? results;

  NearestResult({this.error, this.nextRequest, this.results});

  factory NearestResult.fromJson(Map<String, dynamic> data) {
    Error? e;
    List<Target>? t;
    //TODO implement next request
    final errorData = data['error'] as Map<String, dynamic>?;
    if (errorData != null) {
      e = Error.fromJson(errorData);
    }

    final resultsData = data['results'] as List<dynamic>?;
    if (resultsData != null) {
      t = resultsData.map((v) => Target.fromJson(v)).toList();
    }
    return NearestResult(error: e, results: t);
  }
}

class NextRequest {
  DateTime notBefore;
  DateTime expires;
  Uri URL;

  NextRequest(this.notBefore, this.expires, this.URL);
}

class Target {
  final String machine;
  final Location location;
  final HashMap<String, String> URLs;

  Target({required this.machine, required this.location, required this.URLs});

  factory Target.fromJson(Map<String, dynamic> data) {
    final machine = data['machine'] as String;
    final location = Location.fromJson(data['location']);
    final URLs = toStringMap(data['urls']);
    return Target(machine: machine, location: location, URLs: URLs);
  }

  @override
  String toString() {
    return "$machine-$location-${URLs.toString()}";
  }
}

class Location {
  final String city;
  final String country;

  Location({required this.city, required this.country});

  factory Location.fromJson(Map<String, dynamic> data) {
    final city = data['city'] as String;
    final country = data['country'] as String;
    return Location(city: city, country: country);
  }
  @override
  String toString() {
    return "$city-$country";
  }
}

class Error {
  String type;
  String title;
  String? detail;
  String? instance;
  int status;

  Error(
      {required this.type,
      required this.title,
      this.detail,
      this.instance,
      required this.status});

  factory Error.fromJson(Map<String, dynamic> data) {
    final type = data['type'] as String;
    final title = data['title'] as String;
    final status = data['status'] as int;
    final detail = data['detail'] as String?;
    final instance = data['instance'] as String?;

    return Error(
        type: type,
        title: title,
        status: status,
        detail: detail,
        instance: instance);
  }
}

class Client {
  http.Client client;
  String userAgent;
  String baseURL;

  Client(this.client, this.userAgent, this.baseURL);

  Client.newClient(this.userAgent)
      : client = http.Client(),
        baseURL = "https://locate.measurementlab.net/v2/nearest/";

  Future<List<Target>> nearest(String service) async {
    var url = baseURL + service;
    var response = await client
        .get(Uri.parse(url), headers: Map.of({"User-Agent": userAgent}))
        .timeout(IOTimeout);

    var body = response.body;
    final result = NearestResult.fromJson(jsonDecode(body));

    final targets = result.results;
    if(targets != null){
      return targets;
    }

    final error = result.error;
    if(result.results == null && error != null){
      throw error;
    }

    throw Error(status: -1, title: "SHOULDN'T GET HERE", type: "INVALID");
  }
}
