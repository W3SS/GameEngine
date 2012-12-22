part of game_engine;

class Card {
  Card.foundation() {
    _id = 100;
    isFaceUp = true;
    _isPlayable = false;
    leftPosition = 140;
    topPosition = 100;
  }

  int _id;
  Rank _rank;
  Suit _suit;
  bool isFaceUp;
  bool _isPlayable;
  int index;
  int leftPosition;
  int topPosition;
  static int nextId = 0;
  Card(this._rank, this._suit){
    _id = nextId++;
    isFaceUp = false;
    _isPlayable = false;
    leftPosition = -140;
    topPosition = 100;
    //cardStyles = new Map<String,String>();
    //print(backgroundPosition);
  }
  int get id{
    int result = -1;
    if(isFaceUp){
      return _id;
    }
    return result;
  }
  Rank get rank{
    Rank result = null;
    if(isFaceUp){
      return _rank;
    }
    return result;
  }
  Suit get suit{
    Suit result = null;
    if(isFaceUp){
      return _suit;
    }
    return result;
  }
  List<String> classList = ['card', 'deck', 'back'];
  //Deck container;
  Function clickCardListener;
  String deck = '';
  //Map<String,String> cardStyles;
  void flip(){
    isFaceUp = !isFaceUp;
  }
  String toString(){
    if(!isFaceUp){
      return 'Unknown';
    }
    return '${_rank.letter} of ${_suit.name}';
  }
//  String get backgroundPosition{
//    if(!_isFaceUp && deck != 'south'){
//      return '-158px -492px';
//    }
//    int currentRank = -(_rank.rankValue * 79);
//    int currentSuit = -(_suit.suitValue * 123);
//    return '${currentRank}px ${currentSuit}px';
//  }
  Map toMap() {
    Map map = new Map();
    map["id"] = id;
    //map["rank"] = _rank.letter;
    //map["suit"] = _suit.name;
    map["isFaceUp"] = isFaceUp;
    map["isPlayable"] = _isPlayable;
    return map;
  }
}