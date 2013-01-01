library game_connector;
import 'dart:isolate';

abstract class GameConnector{
  void send(String from, String message, {String type:'general'});
}

class LocalGameConnector implements GameConnector{
  SendPort _targetPort;
  LocalGameConnector(this._targetPort);
  
  void send(String from, String message, {String type:'general'}){
    Map messageMap = {'from':'${from}','message':'${message}'};
    if(?type){
      messageMap['type'] = type;
    }
  }
}