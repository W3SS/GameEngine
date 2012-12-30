part of card_utils;

List suits = [
              new Suit(0),
              new Suit(1),
              new Suit(2),
              new Suit(3),
              new Suit(4)
              ];
class Suit {
  Suit(this.suitValue){
    letter = 'CDHSW'[suitValue];
    back = 'nbsp';
    color = (letter == 'C' || letter == 'S' ? 'black' : 'red' );
    if(letter == 'C'){
      name = 'clubs';
    }else if(letter == 'D'){
      name = 'diams';
    }else if(letter == 'H'){
      name = 'hearts';
    }else if(letter == 'S'){
      name = 'spades';
    }else{
      name = 'wild';
    }
  }
  String get entityName{
    return '&${name};';
  }
  var suitValue;
  var letter;
  var color;
  var name;
  var back;
}
