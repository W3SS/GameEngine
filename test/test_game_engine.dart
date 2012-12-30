//import 'file:/D:/Users/al/dart-dev/game_engine/GameEngine/lib/game_engine_service.dart';
import 'package:card_game/game_engine_service.dart' as gameEngine;
import 'package:card_game/card_utils.dart' as cards;
import 'package:card_game/view.dart' as presenter;
import 'dart:isolate';
gameEngine.GameEngineService ges;
String currentPlayer;
String firstToPlay;
String firstToBid;
void main(){
  print('testing game engine...');
  gameEngine.initialize();
  presenter.initialize();
  gameEngine.register(presenter.service);
  presenter.register(gameEngine.service);
  ges = gameEngine.service;
//  ReceivePort presenterPort = new ReceivePort();
//  presenterPort.receive((msg,_){
//    if(msg['firstToPlay'] != null){
//      firstToPlay = msg['firstToPlay'];
//    }
//    if(msg['firstToBid'] != null){
//      firstToBid = msg['firstToBid'];
//    }
//    print(msg['message']);
//  });
  List cardDeck = cards.createDeck();
  //ge.init();
  //ges.ports['register'].send({'port':'presenter'}, presenterPort.toSendPort());
  presenter.ports['gameEngine'].send({'gameName':'Tarabish'});
  presenter.ports['gameEngine'].send({'numberOfPlayers':'4'});
  //ges.ports['cardGame'].send({'gameName':'Tarabish'});
  //ges.ports['numberOfPlayers'].send({'numberOfPlayers':'4'});

  
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
  
//  ges.ports['startGame'].send({'status':'game started'});
//  ges.ports['bid'].send({'bid':'pass','from':'north'});
//  ges.ports['bid'].send({'bid':'pass','from':'east'});
//  ges.ports['bid'].send({'bid':'pass','from':'south'});
//  ges.ports['bid'].send({'bid':'pass','from':'west'});
//  ges.ports['bid'].send({'bid':'pass','from':'north'});
//  ges.ports['bid'].send({'bid':'pass','from':'east'});
//  ges.ports['bid'].send({'bid':'pass','from':'south'});
//  ges.ports['bid'].send({'bid':'pass','from':'west'});
//  ges.ports['bid'].send({'bid':'hearts','from':'north'});
//  ges.ports['bid'].send({'bid':'hearts','from':'east'});
//  ges.ports['bid'].send({'bid':'hearts','from':'south'});
//  ges.ports['bid'].send({'bid':'hearts','from':'west'});
  print(cardDeck.length);
  cardDeck = cards.shuffle(cardDeck);
  currentPlayer = firstToPlay;
  for(int i = 0; i < cardDeck.length; i++){
    //print(cards[i].toString());
    cardDeck[i].flip();
    presenter.ports['gameEngine'].send({'name':(cardDeck[i].toString()), 'player':currentPlayer},null);
    advanceCurrentPlayer(currentPlayer);
  }
  cardDeck = cards.shuffle(cardDeck);
  for(int i = 0; i < cardDeck.length; i++){
    //print(cards[i].toString());
    //cards[i].flip();
    presenter.ports['gameEngine'].send({'name':(cardDeck[i].toString()), 'player':currentPlayer},null);
    advanceCurrentPlayer(currentPlayer);
  }
  cardDeck = cards.shuffle(cardDeck);
  for(int i = 0; i < cardDeck.length; i++){
    //print(cards[i].toString());
    //cards[i].flip();
    presenter.ports['gameEngine'].send({'name':(cardDeck[i].toString()), 'player':currentPlayer},null);
    advanceCurrentPlayer(currentPlayer);
  }
  //presenter.ports['gameEngine'].close();
  //ge.ports['playCard'].send({'name':'unknown'}, null);
}

void advanceCurrentPlayer(_currentPlayer) {
  int currentPlayerPosition = ges.positions.indexOf(_currentPlayer);
  currentPlayer = ges.positions[(currentPlayerPosition + 1) % 4];
}