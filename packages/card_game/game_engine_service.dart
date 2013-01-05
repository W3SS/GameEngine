library game_engine;
import 'dart:isolate';
import 'dart:math';
import 'dart:json';
import 'package:card_game/services.dart';
import 'package:card_game/card_utils.dart';

SendPort _gamePort;
GameEngineService ges;
ReceivePort gameServer;

//Completer _completer;

Future<String> send(String message) {
  _gamePort.send(message);
}

void register(Service targetService){
  ges.ports[targetService.name] = targetService.port;
}

void initialize(){
  gameServer = new ReceivePort();
  
//  ges = new GameEngineService();
//  ges.init;
}

Service get service{
  return ges;
}

String advanceBidder(game) {
  int bidderPosition = positions.indexOf(game['bidderPosition']);
  int nextToBidPosition = (bidderPosition + 1) % 4;
  String nextToBidName = positions[nextToBidPosition];
  game['bidderPosition'] = nextToBidName;
  return nextToBidName;
}
List acceptableBids = ['hearts', 'diamonds', 'clubs', 'spades', 'pass'];
List positions = ['north', 'east', 'south', 'west'];


class GameEngineService implements Service{
  Map<String,SendPort> ports;
  ReceivePort _registerReceivePort;
  SendPort _presenter;
  Function isBiddingRound;
  Function notBiddingRound;
  String _name;
  ReceivePort _port;
  String get name{
    return _name;
  }
  SendPort get port{
    return _port.toSendPort(); 
  }

  GameEngineService(){
    init();
    
  }

  void init() {
    _name = 'gameEngine';
    print("Lets play a game of cards!");
    ports = new Map<String,SendPort>();
//    _registerReceivePort = new ReceivePort();
//    ports['register'] = _registerReceivePort.toSendPort();
//    _registerReceivePort.receive((msg,sendPort){
//      if(msg['port'] == 'presenter'){
//        _presenter = sendPort;
//      }
//    });
    //ports['presenter'] = _presenter;
    //define the default behavior when a bid is made when it is not a bidding round
//    notBiddingRound = (msg, _) {
//      print('not accepting bids at this time');
//    };
    //set the default behavior when receiving a bid
    //_bidReceivePort.receive(notBiddingRound);
    _port = new ReceivePort();
    _port.receive(new DefaultHandler().receive);
//    _port.receive((msg,_){
//      if(msg['gameName'] != null){
//        print('gameName is not null...');
//        ports['cardGame'].send(msg, _);
//      }
//      print(msg );
//    });
    
    _selectCardGame()
    .chain((gameMap) => selectNumberOfPlayers(gameMap))
    .chain((gameMap) => selectStartGame(gameMap))
    .chain((gameMap) => playGame(gameMap))
    .then((gameMap) => end(gameMap));
  }
  
  Future<Map> playGame(Map game){
    //Map result = game;
    Completer c = new Completer();
//  randomly choose dealer
    game['dealer'] = selectDealer();
    print('dealer is ${game['dealer']}');
    
//  retrieve card deck
    print('retrieving card deck');
//  shuffle cards 
    print('shuffling cards');
//  deal cards
    print('dealing cards');
    //have a round of bidding
    game['northSouthScore'] = 0;
    game['eastWestScore'] = 0;
    Future playRoundResults = biddingRound(game);
    //followed by playing a round, repeating until game is over
    game['roundIndex'] = 0;
    game['rounds'] = {};
    playRoundsUntilWinner(playRoundResults, c, game);
    
    return c.future;
  }

  void playRoundsUntilWinner(Future playRoundResults, Completer c, Map game) {
    game['roundIndex'] = game['roundIndex'] + 1;
    String currentRound = game['currentRound'] = 'Round ${game['roundIndex']}';
    game['rounds'][currentRound] = {};
     playRoundResults.chain((value) => playRound(value))
      .then((value){
        //print('in then clause');
        if(value['northSouthScore'] >= 500 || value['eastWestScore'] >= 500){
          print(value['northSouthScore'] );
          _port.receive(new DefaultHandler().receive);

          c.complete(game);
        }else {
          //recursively call playRound, using chain for maintaining order
          playRoundsUntilWinner(playRoundResults, c, game);
        }
      });
  }

  Future bidCards(game) {
    Completer c = new Completer();
    _port.receive(new BidCardsHandler(c,game).receive);
    
    return c.future;
  }


  Future<Map> biddingRound(game) {
    print('waiting for bids...');
    //start with the dealer position
    game['bidderPosition'] = game['dealer'];
    //dealer always deals to their left
    advanceBidder(game);
    game['bids'] = {};
    return bidCards(game);
  }
  String selectDealer() {
    String result = 'south';//default
    Random randomDealer = new Random();
    int nextRandomInt = randomDealer.nextInt(4);
    result = positions[nextRandomInt];
    return result;
  }

  Future<Map> playRound(game) {
    game['northSouthScore'] = game['northSouthScore'] + 200;
    Future result = new Future.immediate(game);
    game['rounds'][game['currentRound']]['cards'] = [];
    for(int i = 0 ; i < 9 ; i++){
      result = result.chain((value) => playHand(value));
    }    
    return result;
  }

  Future<Map> playHand(game){
    Future result = new Future.immediate(game);
    for(int i = 0 ; i < 4 ; i++){
      result = result.chain((value) => playCard(value));
    }
    return result;
  }
  Future<Map> playCard(game){
    Completer c = new Completer();
    _port.receive(new PlayCardHandler(c,game).receive);
    return c.future;
  }
  Future<Map> selectStartGame(Map game){
    print('waiting for card game to be started...');
    Map result = game;
    Completer c = new Completer();
    _port.receive(new SelectStartGameHandler(c, result).receive);
    //send selectStartGameReceiver to UI and wait for event
    return c.future;
  }
  Future<Map> _selectCardGame(){
    Map result = {};
    print('waiting for card game to be selected...');
    Completer c = new Completer();
    _port.receive(new SelectCardGameHandler(c,result).receive);
//    ((message, _){
//      print('in _selectCardGameReceiver...');
//
//      result['gameName'] = message['gameName'];
//      c.complete(result);//todo - hardcoded - change this to game selected
//    });
    //send selectCardGameReceiver to UI and wait for event
    return c.future;
  }


  Future<Map> selectNumberOfPlayers(Map game){
    print('waiting for number of players to be selected...');
    Map result = game;
    Completer c = new Completer();
    _port.receive(new SelectNumberOfPlayersHandler(c, result).receive);
    //send selectNumberOfPlayers to UI and wait for event
    return c.future;
  }

  end(Map gameMap) {
    _port.close();
//    _registerReceivePort.close();
    //ports['presentation'].send({'close':'true'}, null);
    print(gameMap);
  }

}
class SelectCardGameHandler{
  Completer _completer;
  Map _gameMap;
  //Function receive;
  SelectCardGameHandler(this._completer, this._gameMap);
  
  receive(msg,SendPort _){
    Map message = JSON.parse(msg);
    Map messageMap = JSON.parse(message['message']);

    print('in _selectCardGameReceiver...port is ${_}');
    
    _gameMap['gameName'] = messageMap['gameName'];
    _completer.complete(_gameMap);
    
  }

}

class BidCardsHandler{
  Completer _completer;
  Map _gameMap;
  //Function receive;
  BidCardsHandler(this._completer, this._gameMap);
  
  receive(message, _) {
    Map msg = JSON.parse(message);
    print(msg);
    String nextToBidName = _gameMap['bidderPosition'];
    print('bidding cards...next  to bid is ${nextToBidName}');
    Map messageMap = JSON.parse(msg['message']);
    String bidFrom = messageMap['from'];
    String bid = messageMap['bid'];
    if(bidFrom == nextToBidName && bid != null){
      if(acceptableBids.contains(bid)){
        print('bid from ${bidFrom} of ${bid}');
        _gameMap['bids'][bidFrom] = bid;
        if( bid != 'pass'){
          _gameMap['winningBid'] = bid;
          _gameMap['winningBidder'] = bidFrom;
          //_bidReceivePort.receive(notBiddingRound);
          print(_gameMap['bids']);
          _completer.complete(_gameMap);
          return;
        }
        if(_gameMap['bids'].length == 4 && _gameMap['winningBid'] == null){
          print('you are forced to bid if you are the dealer...');
          return;
        }
        advanceBidder(_gameMap);
      }
    }
    else{
      print('not a valid bid!');
    }
  } 

}
class SelectNumberOfPlayersHandler{
  Completer _completer;
  Map _gameMap;
  //Function receive;
  SelectNumberOfPlayersHandler(this._completer, this._gameMap);
  
  receive(msg, _){
    Map message = JSON.parse(msg);
    Map messageMap = JSON.parse(message['message']);
    _gameMap['numberOfPlayers'] = messageMap['numberOfPlayers'];//todo - hardcoded - change to message info
    _completer.complete(_gameMap);
  }

}
class SelectStartGameHandler{
  Completer _completer;
  Map _gameMap;
  //Function receive;
  SelectStartGameHandler(this._completer, this._gameMap);
  
  receive(msg, _){
    Map message = JSON.parse(msg);
    Map messageMap = JSON.parse(message['message']);
    print(messageMap['status']);
    _gameMap['status'] = messageMap['status'];
    _completer.complete(_gameMap);
  }

}

class PlayCardHandler{
  Completer _completer;
  Map _gameMap;
  //Function receive;
  PlayCardHandler(this._completer, this._gameMap);
  
  receive(msg, _) {
    Map message = JSON.parse(msg);
    Map messageMap = JSON.parse(message['message']);

    _gameMap['rounds'][_gameMap['currentRound']]['cards'].add('${messageMap['name']} from ${messageMap['player']}');
    _completer.complete(_gameMap);
  }

}

class DefaultHandler{
  Completer _completer;
  Map _gameMap;
  //Function receive;
  DefaultHandler();
  
  receive(message, _){
    print('nothing to do in this state....');
  }

}

class GamesServerDefaultHandler{
  GameEngineService currentGameEngineService;
  Set<GameEngineService> games;
  GamesServerDefaultHandler(){
    games = new Set<GameEngineService>();
  }
  receive(message, _){
    currentGameEngineService = new GameEngineService();
    currentGameEngineService.init();
    //add incoming sendport _ to currentGameEngineService as owner of game 
    games.add(currentGameEngineService);
  }
}