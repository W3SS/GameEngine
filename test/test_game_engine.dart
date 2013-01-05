import 'package:card_game/game_engine_service.dart' as gameEngine;
import 'package:card_game/card_utils.dart' as cards;
import 'package:card_game/view.dart' as presenter;
import 'package:card_game/game_connection.dart';
import 'dart:isolate';
import 'dart:io';
import 'dart:json';
String currentPlayer;
String firstToPlay;
String firstToBid;
ReceivePort _applicationPort;
void main(){
  _applicationPort = new ReceivePort();
  //var env = Platform.environment;
  //print(Platform.runtimeType);
  //env.forEach((k, v) => print("Key=$k Value=$v"));
  print('testing game engine...');
  gameEngine.initialize();
  GameConnection gameConnection = new LocalGameConnection(gameEngine.service.port);
  //gameConnection.send('humanPlayer','registering player', type:'register');
  //gameConnection.
  //presenter.initialize();
  //gameEngine.register(presenter.service);
  //presenter.register(gameEngine.service);
  List cardDeck = cards.createDeck();
  gameConnection.send('humanPlayer',JSON.stringify({'gameName':'Tarabish'}));
  gameConnection.send('humanPlayer',JSON.stringify({'numberOfPlayers':'4'}));
  gameConnection.send('humanPlayer',JSON.stringify({'status':'game started'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'north'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'east'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'south'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'west'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'north'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'east'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'south'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'pass','from':'west'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'hearts','from':'north'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'hearts','from':'east'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'hearts','from':'south'}));
  gameConnection.send('humanPlayer',JSON.stringify({'bid':'hearts','from':'west'}));

  print(cardDeck.length);
  cardDeck = cards.shuffle(cardDeck);
  currentPlayer = firstToPlay;
  for(int i = 0; i < cardDeck.length; i++){
    cardDeck[i].flip();
    gameConnection.send('humanPlayer',JSON.stringify({'name':(cardDeck[i].toString()), 'player':currentPlayer}));
    advanceCurrentPlayer(currentPlayer);
  }
  cardDeck = cards.shuffle(cardDeck);
  for(int i = 0; i < cardDeck.length; i++){
    gameConnection.send('humanPlayer',JSON.stringify({'name':(cardDeck[i].toString()), 'player':currentPlayer}));
    advanceCurrentPlayer(currentPlayer);
  }
  cardDeck = cards.shuffle(cardDeck);
  for(int i = 0; i < cardDeck.length; i++){
    gameConnection.send('humanPlayer',JSON.stringify({'name':(cardDeck[i].toString()), 'player':currentPlayer}));
    advanceCurrentPlayer(currentPlayer);
  }
}

void advanceCurrentPlayer(_currentPlayer) {
  int currentPlayerPosition = cards.positions.indexOf(_currentPlayer);
  currentPlayer = cards.positions[(currentPlayerPosition + 1) % 4];
}