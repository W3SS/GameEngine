import '../bin/GameEngine.dart';
void main(){
  print('testing game engine...');
  GameEngine ge = new GameEngine();
  List cards = ge.createDeck();
  //ge.init();
  ge.ports['cardGame'].send({'gameName':'Tarabish'});
  ge.ports['numberOfPlayers'].send({'numberOfPlayers':'4'});
  ge.ports['startGame'].send({'status':'game started'});
  ge.ports['bid'].send({'bid':'pass','from':'north'});
  ge.ports['bid'].send({'bid':'pass','from':'east'});
  ge.ports['bid'].send({'bid':'pass','from':'south'});
  ge.ports['bid'].send({'bid':'pass','from':'west'});
  ge.ports['bid'].send({'bid':'hearts','from':'north'});
  ge.ports['bid'].send({'bid':'hearts','from':'east'});
  ge.ports['bid'].send({'bid':'hearts','from':'south'});
  ge.ports['bid'].send({'bid':'hearts','from':'west'});
  print(cards.length);
  for(int i = 0; i < cards.length; i++){
    //print(cards[i].toString());
    cards[i].flip();
    ge.ports['playCard'].send({'name':(cards[i].toString())},null);
  }
  for(int i = 0; i < cards.length; i++){
    //print(cards[i].toString());
    cards[i].flip();
    ge.ports['playCard'].send({'name':(cards[i].toString())},null);
  }
  for(int i = 0; i < cards.length; i++){
    //print(cards[i].toString());
    cards[i].flip();
    ge.ports['playCard'].send({'name':(cards[i].toString())},null);
  }
  //ge.ports['playCard'].send({'name':'unknown'}, null);
}