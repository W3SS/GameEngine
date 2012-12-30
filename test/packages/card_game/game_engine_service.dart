library game_engine;
import 'dart:isolate';
import 'dart:math';
import 'dart:json';
import 'package:card_game/services.dart';
import 'package:card_game/card_utils.dart';
//import 'service.dart';

SendPort _gamePort;
GameEngineService ges;

Future<String> send(String message) {
  _gamePort.send(message);
}

void register(Service targetService){
  ges.ports[targetService.name] = targetService.port;
}

void initialize(){
  ges = new GameEngineService();
  ges.init;
}

Service get service{
  return ges;
}


//part '../bin/player_session.dart';
class GameEngineService implements Service{
  List acceptableBids = ['hearts', 'diamonds', 'clubs', 'spades', 'pass'];
  List positions = ['north', 'east', 'south', 'west'];
  Map<String,SendPort> ports;
//  ReceivePort _playGameReceiver;
//  ReceivePort _selectCardGameReceiver;
//  ReceivePort _selectNumberOfPlayersReceiver;
//  ReceivePort _selectStartGameReceiver;
//  ReceivePort _playCardReceivePort;
//  ReceivePort _bidReceivePort;
  ReceivePort _registerReceivePort;
  SendPort _presenter;
  Function isBiddingRound;
  Function notBiddingRound;
  //PlayerSession _playerSession;
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
//    _selectCardGameReceiver = new ReceivePort();
//    ports['cardGame'] = _selectCardGameReceiver.toSendPort();
//    _selectNumberOfPlayersReceiver = new ReceivePort();
//    ports['numberOfPlayers'] = _selectNumberOfPlayersReceiver.toSendPort();
//    _selectStartGameReceiver = new ReceivePort();
//    ports['startGame'] = _selectStartGameReceiver.toSendPort();
//    _playCardReceivePort = new ReceivePort();
//    ports['playCard'] = _playCardReceivePort.toSendPort();
//    _bidReceivePort = new ReceivePort();
//    ports['bid'] = _bidReceivePort.toSendPort();
    //_bidReceivePort = new ReceivePort();
    _registerReceivePort = new ReceivePort();
    ports['register'] = _registerReceivePort.toSendPort();
    _registerReceivePort.receive((msg,sendPort){
      if(msg['port'] == 'presenter'){
        _presenter = sendPort;
      }
    });
    ports['presenter'] = _presenter;
    //define the default behavior when a bid is made when it is not a bidding round
    notBiddingRound = (msg, _) {
      print('not accepting bids at this time');
    };
    //set the default behavior when receiving a bid
    //_bidReceivePort.receive(notBiddingRound);
    _port = new ReceivePort();
    _port.receive((msg,_){
      if(msg['gameName'] != null){
        print('gameName is not null...');
        ports['cardGame'].send(msg, _);
      }
//      if(msg['firstToBid'] != null){
//        firstToBid = msg['firstToBid'];
//      }
      print(msg );
    });
    
    _selectCardGame()
    .chain((gameMap) => selectNumberOfPlayers(gameMap))
    .chain((gameMap) => selectStartGame(gameMap))
    .chain((gameMap) => playGame(gameMap))
    .then((gameMap) => end(gameMap));
  }
  
//  void set playerSession(session){
//    _playerSession = session;
//  }
    
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
          _port.receive((msg,_){
            if(msg['gameName'] != null){
              print('gameName is not null...');
              ports['cardGame'].send(msg, _);
            }
//      if(msg['firstToBid'] != null){
//        firstToBid = msg['firstToBid'];
//      }
            print(msg );
          });

          c.complete(game);
        }else {
          //recursively call playRound, using chain for maintaining order
          playRoundsUntilWinner(playRoundResults, c, game);
        }
      });
  }

  Future bidCards(game) {
    Completer c = new Completer();
    _port.receive((msg, _) {
      String nextToBidName = game['bidderPosition'];
      print('bidding cards...next  to bid is ${nextToBidName}');
      String bidFrom = msg['from'];
      String bid = msg['bid'];
      if(bidFrom == nextToBidName && bid != null){
        if(acceptableBids.contains(bid)){
          print('bid from ${bidFrom} of ${bid}');
          game['bids'][bidFrom] = msg['bid'];
          if( bid != 'pass'){
            game['winningBid'] = bid;
            game['winningBidder'] = bidFrom;
            //_bidReceivePort.receive(notBiddingRound);
            print(game['bids']);
            c.complete(game);
            return;
          }
          if(game['bids'].length == 4 && game['winningBid'] == null){
            print('you are forced to bid if you are the dealer...');
            return;
          }
          advanceBidder(game);
        }
      }
      else{
        print('not a valid bid!');
      }
    } );
    
    return c.future;
  }

  String advanceBidder(game) {
    int bidderPosition = positions.indexOf(game['bidderPosition']);
    int nextToBidPosition = (bidderPosition + 1) % 4;
    String nextToBidName = positions[nextToBidPosition];
    game['bidderPosition'] = nextToBidName;
    return nextToBidName;
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
    _port.receive((msg, _) {
      game['rounds'][game['currentRound']]['cards'].add('${msg['name']} from ${msg['player']}');
      c.complete(game);
    } );
    return c.future;
  }
  Future<Map> selectStartGame(Map game){
    print('waiting for card game to be started...');
    Map result = game;
    Completer c = new Completer();
    _port.receive((message, _){
      print(message['status']);
      result['status'] = message['status'];
      c.complete(result);
    });
    //send selectStartGameReceiver to UI and wait for event
    return c.future;
  }
  Future<Map> _selectCardGame(){
    Map result = {};
    //PlayerSession playerSession = new PlayerSession();
    print('waiting for card game to be selected...');
    Completer c = new Completer();
    _port.receive((message, _){
      print('in _selectCardGameReceiver...');

      result['gameName'] = message['gameName'];
      c.complete(result);//todo - hardcoded - change this to game selected
    });
    //send selectCardGameReceiver to UI and wait for event
    return c.future;
  }


  Future<Map> selectNumberOfPlayers(Map game){
    print('waiting for number of players to be selected...');
    Map result = game;
    Completer c = new Completer();
    _port.receive((message, _){
      result['numberOfPlayers'] = message['numberOfPlayers'];//todo - hardcoded - change to message info
      c.complete(result);
    });
    //send selectNumberOfPlayers to UI and wait for event
    return c.future;
  }
//Future startSession(){
//  Future result = new Future.immediate(null);
//  return result;
//}
    //start session
  //});
  /*
  start session
  retrieve logger (isolate)
choose card game
  create card game
choose number of players
  create players
choose start game
  start game
  randomly choose dealer
  retrieve card deck
  shuffle cards 
  deal cards
  ...
  start round
    start bidding
    ...
    notify next to bid
bid hand
    ...
    end bidding
    ...
    start hand
      ...
      notify next to play
play card
      ...
    end hand
    ...
  end round
  ...
  end game
   * */
  

  end(Map gameMap) {
//    _selectCardGameReceiver.close();
//    _selectNumberOfPlayersReceiver.close();
//    _selectStartGameReceiver.close();
//    _playCardReceivePort.close();
//    _bidReceivePort.close();
    _port.close();
    _registerReceivePort.close();
    ports['presentation'].send({'close':'true'}, null);
//    ports.forEach((key,value){
//      
//    });
    print(gameMap);
  }
//  List createDeck() {
//    List<Card> result = new List<Card>();
//    Card currentCard;
//    //String deckName;
//    //int counter = 0;
//    for (final currentRank in ranks){
//      if(['5','4','3','2'].indexOf(currentRank.letter) != -1){
//        continue;
//      }
//      for(final currentSuit in suits){
//        if(currentSuit.letter == 'W'){
//          continue;
//        }
//        currentCard = new Card(currentRank, currentSuit);
//        result.add(currentCard);
//      }
//    }
//    return result;
//  }
//  List shuffle(List myArray) {
//    var m = myArray.length - 1, t, i, random;
//    random = new Random();
//    // While there remain elements to shuffle…
//    //print('_____');
//    while (m > 0) {
//      // Pick a remaining element…
//      i = random.nextInt(m);
//      //print('i is $i');
//      // And swap it with the current element.
//      t = myArray[m];
//      myArray[m] = myArray[i];
//      myArray[i] = t;
//      //print(
//      m--;
//      //);
//    }
//
//    return myArray;
//  }

}