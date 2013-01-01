library card_utils;
import 'dart:math';

//import 'package:card_game/game_engine_service.dart';
part 'card.dart';
part 'suit.dart';
part 'rank.dart';

List positions = ['north', 'east', 'south', 'west'];

List createDeck() {
  List<Card> result = new List<Card>();
  Card currentCard;
  //String deckName;
  //int counter = 0;
  for (final currentRank in ranks){
    if(['5','4','3','2'].indexOf(currentRank.letter) != -1){
      continue;
    }
    for(final currentSuit in suits){
      if(currentSuit.letter == 'W'){
        continue;
      }
      currentCard = new Card(currentRank, currentSuit);
      result.add(currentCard);
    }
  }
  return result;
}
List shuffle(List myArray) {
  var m = myArray.length - 1, t, i, random;
  random = new Random();
  // While there remain elements to shuffle…
  //print('_____');
  while (m > 0) {
    // Pick a remaining element…
    i = random.nextInt(m);
    //print('i is $i');
    // And swap it with the current element.
    t = myArray[m];
    myArray[m] = myArray[i];
    myArray[i] = t;
    //print(
    m--;
    //);
  }

  return myArray;
}
