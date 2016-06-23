// Copyright (c) 2016, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:corsac_startd/corsac_startd.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceInstance: ', () {
    test('we can start a simple service', () async {
      var service =
          await ServiceInstance.spawn('/simple-service/1', simpleService);
      sleep(new Duration(milliseconds: 100));
      expect(service.status, completion(ServiceStatus.started));
      service.kill();
    });
  });
}

simpleService(id) {
  // I'm running...
}
