class Drink {
  final int id;
  final DateTime timeOfDrink;

  Drink({required this.id, required this.timeOfDrink});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timeOfDrink': timeOfDrink.toIso8601String(),
    };
  }

  Drink.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        timeOfDrink = DateTime.parse(json['timeOfDrink']);
}
