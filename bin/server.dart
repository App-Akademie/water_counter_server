import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'drink.dart';
import 'drink_repository.dart';

void main() async {
  final repository = DrinkRepository('drinks.json');

  final router = Router();

  router.get('/drinks', (Request request) async {
    final List<Map<String, dynamic>> drinkList = [];
    for (final drink in await repository.getAllDrinks()) {
      drinkList.add(drink.toJson());
    }
    return Response.ok(
      jsonEncode(drinkList),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/drinks', (Request request) async {
    final Drink newDrink = await repository.addDrink();
    return Response.ok(jsonEncode(newDrink),
        headers: {'Content-Type': 'application/json'});
  });

  router.delete('/drinks/', (Request request) async {
    repository.removeAllDrinks();
    return Response.ok('Drink deleted successfully');
  });

  // router.delete('/drinks/<id|[0-9]+>', (Request request, String id) async {
  //   final drinkId = int.tryParse(id);
  //   if (drinkId == null) {
  //     return Response(400, body: 'Invalid ID');
  //   }

  //   final success = repository.removeDrinkById(drinkId);
  //   if (success) {
  //     await repository.saveDrinks();
  //     return Response.ok('Drink deleted successfully');
  //   } else {
  //     return Response(404, body: 'Drink not found');
  //   }
  // });

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  final server = await io.serve(handler, 'localhost', 8080);

  print('Server listening on http://${server.address.host}:${server.port}');
}
