import 'package:card_game/game_engine_service.dart' as gameEngine;
import 'package:card_game/card_utils.dart' as cards;
import 'package:card_game/view.dart' as presenter;
import 'dart:isolate';
import 'dart:io';
String currentPlayer;
String firstToPlay;
String firstToBid;
void main(){
  var env = Platform.environment;
  print(Platform.runtimeType);
  //env.forEach((k, v) => print("Key=$k Value=$v"));
  print('testing game engine...');
  gameEngine.initialize();
  presenter.initialize();
  gameEngine.register(presenter.service);
  presenter.register(gameEngine.service);
  List cardDeck = cards.createDeck();
  presenter.ports['gameEngine'].send({'gameName':'Tarabish'});
  presenter.ports['gameEngine'].send({'numberOfPlayers':'4'});
  presenter.ports['gameEngine'].send({'status':'game started'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'north'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'east'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'south'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'west'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'north'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'east'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'south'});
  presenter.ports['gameEngine'].send({'bid':'pass','from':'west'});
  presenter.ports['gameEngine'].send({'bid':'hearts','from':'north'});
  presenter.ports['gameEngine'].send({'bid':'hearts','from':'east'});
  presenter.ports['gameEngine'].send({'bid':'hearts','from':'south'});
  presenter.ports['gameEngine'].send({'bid':'hearts','from':'west'});

  print(cardDeck.length);
  cardDeck = cards.shuffle(cardDeck);
  currentPlayer = firstToPlay;
  for(int i = 0; i < cardDeck.length; i++){
    cardDeck[i].flip();
    presenter.ports['gameEngine'].send({'name':(cardDeck[i].toString()), 'player':currentPlayer},null);
    advanceCurrentPlayer(currentPlayer);
  }
  cardDeck = cards.shuffle(cardDeck);
  for(int i = 0; i < cardDeck.length; i++){
    presenter.ports['gameEngine'].send({'name':(cardDeck[i].toString()), 'player':currentPlayer},null);
    advanceCurrentPlayer(currentPlayer);
  }
  cardDeck = cards.shuffle(cardDeck);
  for(int i = 0; i < cardDeck.length; i++){
    presenter.ports['gameEngine'].send({'name':(cardDeck[i].toString()), 'player':currentPlayer},null);
    advanceCurrentPlayer(currentPlayer);
  }
}

void advanceCurrentPlayer(_currentPlayer) {
  int currentPlayerPosition = cards.positions.indexOf(_currentPlayer);
  currentPlayer = cards.positions[(currentPlayerPosition + 1) % 4];
}