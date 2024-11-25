import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process serverProcess;

  setUp(() async {
    // Start the server as a separate process
    serverProcess = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );

    // Wait for the server to start and print to stdout
    await serverProcess.stdout.first;
  });

  tearDown(() async {
    // Kill the server process after each test
    serverProcess.kill();
    await serverProcess.exitCode;
  });

  group('Server Tests:', () {
    test('GET /drinks - Should return an empty list initially', () async {
      final response = await http.get(Uri.parse('$host/drinks'));
      expect(response.statusCode, 200);
      expect(response.body, equals('[]'));
    });

    test('POST /drinks - Should add a drink', () async {
      final response = await http.post(Uri.parse('$host/drinks'));
      expect(response.statusCode, 200);

      final data = response.body;
      expect(data.contains('"id"'), isTrue);
      expect(data.contains('"timeOfDrink"'), isTrue);
    });

    test('GET /drinks - Should return a list with one drink after POST',
        () async {
      await http.post(Uri.parse('$host/drinks'));

      final response = await http.get(Uri.parse('$host/drinks'));
      expect(response.statusCode, 200);

      final drinks = response.body;
      expect(drinks, contains('"id"'));
      expect(drinks, contains('"timeOfDrink"'));
    });

    test('DELETE /drinks/<id> - Should delete a drink', () async {
      final postResponse = await http.post(Uri.parse('$host/drinks'));
      final postBody = postResponse.body;
      final idMatch = RegExp('"id":(\\d+)').firstMatch(postBody);
      final id = idMatch?.group(1);
      expect(id, isNotNull);

      final deleteResponse = await http.delete(Uri.parse('$host/drinks/$id'));
      expect(deleteResponse.statusCode, 200);
      expect(deleteResponse.body, contains('Drink deleted successfully'));

      final getResponse = await http.get(Uri.parse('$host/drinks'));
      expect(getResponse.body, equals('[]'));
    });

    test('DELETE /drinks/<id> - Should return 404 for non-existent drink',
        () async {
      final response = await http.delete(Uri.parse('$host/drinks/999'));
      expect(response.statusCode, 404);
      expect(response.body, contains('Drink not found'));
    });

    test('POST /drinks multiple - Should handle multiple additions', () async {
      await http.post(Uri.parse('$host/drinks'));
      await http.post(Uri.parse('$host/drinks'));

      final response = await http.get(Uri.parse('$host/drinks'));
      expect(response.statusCode, 200);

      final drinks = response.body;
      expect(drinks, contains('"id":1'));
      expect(drinks, contains('"id":2'));
    });

    test('DELETE /drinks/<id> - Should only delete specified drink', () async {
      await http.post(Uri.parse('$host/drinks'));
      final postResponse = await http.post(Uri.parse('$host/drinks'));
      final postBody = postResponse.body;
      final idMatch = RegExp('"id":(\\d+)').firstMatch(postBody);
      final idToDelete = idMatch?.group(1);
      expect(idToDelete, isNotNull);

      await http.delete(Uri.parse('$host/drinks/$idToDelete'));

      final response = await http.get(Uri.parse('$host/drinks'));
      expect(response.statusCode, 200);
      expect(response.body, contains('"id":1'));
      expect(response.body, isNot(contains('"id":$idToDelete')));
    });

    test('404 - Non-existent route', () async {
      final response = await http.get(Uri.parse('$host/unknown-route'));
      expect(response.statusCode, 404);
    });
  });
}
