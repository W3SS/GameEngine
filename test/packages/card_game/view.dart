library view;
import 'package:card_game/services.dart';

Service presentationService;
Map ports;
void initialize(){
  //initialize presentationService;
  ports = new Map();
  presentationService = new Service('presentation');
}

void register(Service targetService){
  ports[targetService.name] = targetService.port;
}


Service get service{
  return presentationService;
}

