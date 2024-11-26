import 'dart:convert';
import 'dart:io';

import 'drink.dart';

class DrinkRepository {
  final String _filePath;
  final List<Drink> _drinks = [];
  int _nextId = 0;

  DrinkRepository(this._filePath);

  Future<List<Drink>> getAllDrinks() async {
    await _loadDrinksFromFile();
    return _drinks;
  }

  Future<Drink> addDrink(DateTime newDrinkTime) async {
    await _loadDrinksFromFile();
    final newId = _nextId++;
    final newDrink = Drink(id: newId, timeOfDrink: newDrinkTime);
    _drinks.add(newDrink);
    // Wir müssen hierauf nicht unbedingt warten.
    _saveDrinksToFile();

    return newDrink;
  }

  Drink? findDrinkById(int id) {
    _loadDrinksFromFile();
    for (final drink in _drinks) {
      if (drink.id == id) {
        return drink;
      }
    }
    return null;
  }

  void removeAllDrinks() {
    _loadDrinksFromFile();
    _drinks.clear();
    _saveDrinksToFile();
  }

  bool removeDrinkById(int id) {
    _loadDrinksFromFile();
    for (int i = 0; i < _drinks.length; i++) {
      if (_drinks[i].id == id) {
        _drinks.removeAt(i);
        _saveDrinksToFile();
        return true;
      }
    }
    return false;
  }

  Future<void> _loadDrinksFromFile() async {
    _drinks.clear();
    if (await File(_filePath).exists()) {
      final content = await File(_filePath).readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      for (final json in jsonList) {
        final drink = Drink.fromJson(json);
        _drinks.add(drink);
        if (drink.id >= _nextId) {
          _nextId = drink.id + 1;
        }
      }
    }
  }

  Future<void> _saveDrinksToFile() async {
    final List<Map<String, dynamic>> jsonList = [];
    for (final drink in _drinks) {
      jsonList.add(drink.toJson());
    }
    final content = jsonEncode(jsonList);
    await File(_filePath).writeAsString(content);
  }
}
