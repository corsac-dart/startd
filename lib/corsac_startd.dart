// Copyright (c) 2016, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Support for doing something awesome with isolates.
library corsac_startd;

import 'dart:async';
import 'dart:isolate';

import 'package:isolate/ports.dart';
import 'package:logging/logging.dart';
import 'src/lists.dart';

part 'src/service.dart';

Logger _logger = new Logger('StartD');
