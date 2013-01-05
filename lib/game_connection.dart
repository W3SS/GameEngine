library game_connection;
import 'dart:isolate';
import 'dart:json';

abstract class GameConnection{
  void send(String from, String message, {String type:'sendPort'});
}

class LocalGameConnection implements GameConnection{
  SendPort _targetPort;
  ReceivePort _receivePort;
  LocalGameConnection(this._targetPort){
    _init();
  }
  
  _init(){
    _receivePort = new ReceivePort();
    _receivePort.receive((msg,_){
      _receivedEncodedMessage(msg);
    });
  }
  
  void send(String from, String message, {String type:'sendPort'}){
    bool sendReceivePort = false;
    Map messageMap = {'from':'${from}','message':'${message}'};
    //if(?type){
      messageMap['type'] = type;
      sendReceivePort = (type == 'sendPort' ? true : false);
    //}
    var encoded = JSON.stringify(messageMap);
    if(sendReceivePort){
      //_receivePort = new ReceivePort();
      _sendEncodedMessage(encoded, returnPort:_receivePort.toSendPort());
    }else{
      _sendEncodedMessage(encoded);
    }
  }
  
  _sendEncodedMessage(String encodedMessage, {SendPort returnPort}) {
    if (_targetPort != null) {
      if(?returnPort){
        _targetPort.send(encodedMessage, returnPort);
      }else{
        _targetPort.send(encodedMessage);
      }
    } else {
      print('Game Engine not connected, message $encodedMessage not sent');
    }
  }
  
  _receivedEncodedMessage(String encodedMessage) {
    Map message = JSON.parse(encodedMessage);
    if (message['f'] != null) {
      print('${message['m']} : from ${message['f']}');
      //app.chatWindow.displayMessage(message['f'], message['m']);
    }
  }

  
}