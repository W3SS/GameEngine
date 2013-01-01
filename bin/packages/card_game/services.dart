library services;
import 'dart:isolate';
part 'service_helper.dart';

class Service {
  String _name;
  ReceivePort _port;
  String get name{
    return _name;
  }
  SendPort get port{
    return _port.toSendPort(); 
  }
  Service(this._name){
    _port = new ReceivePort();
    _port.receive((msg,_){
//      if(msg['firstToPlay'] != null){
//        firstToPlay = msg['firstToPlay'];
//      }
//      if(msg['firstToBid'] != null){
//        firstToBid = msg['firstToBid'];
//      }
      print(msg);
      if(msg['close'] != null){
        _port.close();
      }
    });
  }
}

class Producer{
  
}

class Consumer{
  
}
