library game_engine;
import 'dart:isolate';
import 'dart:math';
part 'card.dart';
part 'suit.dart';
part 'rank.dart';
class GameEngine{
  List acceptableBids = ['hearts', 'diamonds', 'clubs', 'spades', 'pass'];
  List positions = ['north', 'east', 'south', 'west'];
  Map<String,SendPort> ports;
  ReceivePort _playGameReceiver;
  ReceivePort _selectCardGameReceiver;
  ReceivePort _selectNumberOfPlayersReceiver;
  ReceivePort _selectStartGameReceiver;
  ReceivePort _playCardReceivePort;
  ReceivePort _bidReceivePort;
  Function isBiddingRound;
  Function notBiddingRound;
  
  GameEngine(){
    init();
  }

  void init() {
    print("Lets play a game of cards!");
    ports = new Map<String,SendPort>();
    _selectCardGameReceiver = new ReceivePort();
    ports['cardGame'] = _selectCardGameReceiver.toSendPort();
    _selectNumberOfPlayersReceiver = new ReceivePort();
    ports['numberOfPlayers'] = _selectNumberOfPlayersReceiver.toSendPort();
    _selectStartGameReceiver = new ReceivePort();
    ports['startGame'] = _selectStartGameReceiver.toSendPort();
    _playCardReceivePort = new ReceivePort();
    ports['playCard'] = _playCardReceivePort.toSendPort();
    _bidReceivePort = new ReceivePort();
    ports['bid'] = _bidReceivePort.toSendPort();
    notBiddingRound = (msg, _) {
      print('not accepting bids at this time');
    };
    _bidReceivePort.receive(notBiddingRound);
    
    selectCardGame()
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
    Future biddingRoundResults = biddingRound(game);
    //followed by playing a round, repeating until game is over
    biddingRoundResults.chain((value) => playRound(value))
    .then((value){
      c.complete(value);
    });
    return c.future;
  }

  Future bidCards(game) {
    Completer c = new Completer();
    _bidReceivePort.receive((msg, _) {
      String nextToBidName = game['bidderPosition'];
      print('bidding cards...next  to bid is ${nextToBidName}');
      String bidFrom = msg['from'];
      String bid = msg['bid'];
      if(bidFrom == nextToBidName && bid != null){
        if(acceptableBids.contains(bid)){
          print('bid from ${bidFrom} of ${bid}');
          if( bid != 'pass'){
            game['winningBid'] = bid;
            game['winningBidder'] = bidFrom;
            _bidReceivePort.receive(notBiddingRound);
            print(game['bids']);
            c.complete(game);
            return;
          }
          if(game['bids'].length == 4 && game['winningBid'] == null){
            print('you are forced to bid if you are the dealer...');
            return;
          }
          game['bids'][bidFrom] = msg['bid'];
          advanceBidder(game);
        }
      }
      else{
        //game['bids'][msg['from']] = msg['bid'];
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
    game['bidderPosition'] = game['dealer'];
    advanceBidder(game);
    game['bids'] = {};
    Future result;// = new Future.immediate(game);
    //game['cards'] = [];
//    Map currentGame;
    //for(int i = 0 ; i < 4 ; i++){
//    while(game['winningBid'] == null){
//      print('in while loop...');
      result = bidCards(game);
//      if(currentGame['winningBid'] != null){
//        //_bidReceivePort.receive((msg, _) {
//          print('bidding round complete!');
//        //} );
//
//        break;
//      }
    //}
    //_bidReceivePort.close();
      
    return result;
  }
  String selectDealer() {
    String result = 'south';//default
    Random randomDealer = new Random();
    int nextRandomInt = randomDealer.nextInt(4);
    result = positions[nextRandomInt];
    return result;
  }

  Future<Map> playRound(game) {
    Future result = new Future.immediate(game);
    game['cards'] = [];
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
    //print('waiting for card to be played...');
    //Future result = new Future.immediate(game);
    //game['cards'].add('a card');
//    String currentPositionToPlay = game['dealer'];
    Completer c = new Completer();
    //_playCardReceivePort = new ReceivePort();
    _playCardReceivePort.receive((msg, _) {
      game['cards'].add(msg['name']);
      c.complete(game);
    } );
    return c.future;
//  return result;
  }
  Future<Map> selectStartGame(Map game){
    print('waiting for card game to be started...');
    Map result = game;
    Completer c = new Completer();
    _selectStartGameReceiver.receive((message, _){
      print(message['status']);
      result['status'] = message['status'];
      c.complete(result);
    });
    //send selectStartGameReceiver to UI and wait for event
    return c.future;
  }
  Future<Map> selectCardGame(){
    Map result = {};
    print('waiting for card game to be selected...');
    Completer c = new Completer();
    _selectCardGameReceiver.receive((message, _){
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
    _selectNumberOfPlayersReceiver.receive((message, _){
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
    _selectCardGameReceiver.close();
    _selectNumberOfPlayersReceiver.close();
    _selectStartGameReceiver.close();
    _playCardReceivePort.close();
    _bidReceivePort.close();
    print(gameMap);
  }
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

}