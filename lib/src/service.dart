part of corsac_startd;

class ServiceInstance {
  static const int _INIT = 100;
  static const int _PING = 101;

  final id;
  final ReceivePort pingPort;
  SendPort _commandPort;
  final Isolate isolate;
  final StartService startService;

  Completer _commandPortCompleter = new Completer();

  ServiceInstance(this.id, this.isolate, this.pingPort, this.startService) {
    pingPort.listen(_pingHandler);
  }

  void _pingHandler(List command) {
    switch (command[0]) {
      case _INIT:
        _logger.info(
            'ServiceInstance(${id}) received command port. Starting the service...');
        _commandPort = command[1];
        _commandPortCompleter.complete(_commandPort);
        _commandPort
            .send(list3(ServiceInstanceRemote._START, startService, id));
        return;
      case _PING:
        _logger.fine('Recieved ping from instance ${id}');
        return;
    }
  }

  static Future<ServiceInstance> spawn(id, StartService start) async {
    var pingPort = new ReceivePort();
    var exitPort = new ReceivePort();
    Isolate isolate = await Isolate.spawn(
        ServiceInstanceRemote.create, pingPort.sendPort,
        onExit: exitPort.sendPort);
    exitPort.listen((a) {
      _logger.info('Service instance exited.');
    });

    var service = new ServiceInstance(id, isolate, pingPort, start);
    await service._commandPortCompleter.future;

    return service;
  }

  Future<ServiceStatus> get status {
    var channel = new SingleResponseChannel();
    _commandPort.send(list2(ServiceInstanceRemote._STATUS, channel.port));

    return channel.result;
  }

  void kill() {
    isolate.kill(priority: Isolate.IMMEDIATE);
  }
}

enum ServiceStatus { created, started, stopped, failed }

class ServiceInstanceRemote {
  static const int _START = 1;
  static const int _STATUS = 2;

  final SendPort _pingPort;
  final RawReceivePort _commandPort = new RawReceivePort();
  ServiceStatus _status;

  SendPort get commandPort => _commandPort.sendPort;

  ServiceInstanceRemote(this._pingPort) {
    _commandPort.handler = _handleCommand;
    _pingPort.send([ServiceInstance._INIT, commandPort]);
    _status = ServiceStatus.created;
    new Timer.periodic(new Duration(seconds: 3), (timer) {
      _pingPort.send([ServiceInstance._PING]);
    });
  }

  void _handleCommand(List command) {
    switch (command[0]) {
      case _START:
        _logger.info('Received start command. Executing.');
        Function function = command[1];
        var id = command[2];
        _status = ServiceStatus.started;
        function(id); // TODO: handle service errors
        // SendPort responsePort = command[3];
        // sendFutureResult(new Future.sync(() => function(id)),
        //  responsePort);
        return;
      case _STATUS:
        SendPort responsePort = command[1];
        responsePort.send(_status);
        return;
    }
  }

  static void create(SendPort pingPort) {
    new ServiceInstanceRemote(pingPort);
  }
}

typedef Future StartService(id);
