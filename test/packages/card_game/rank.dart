part of card_utils;

List ranks = [
              new Rank(0),
              new Rank(1),
              new Rank(2),
              new Rank(3),
              new Rank(4),
              new Rank(5),
              new Rank(6),
              new Rank(7),
              new Rank(8),
              new Rank(9),
              new Rank(10),
              new Rank(11),
              new Rank(12),
              ];
class Rank {
  var rankValue;
  Rank(this.rankValue){
    letter = rankValue == 9 ? '10' :'A23456789TJQK'[rankValue];
  }
  
  var letter;
  var nextLower;
  var nextHigher;
 
  
}
