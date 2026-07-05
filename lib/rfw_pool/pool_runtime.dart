import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';

import 'local_widgets.dart';

/// Library names.
const _core = LibraryName(['core', 'widgets']);
const _bonsai = LibraryName(['bonsai', 'widgets']);
const mainLibrary = LibraryName(['main']);
const _main = mainLibrary;

/// Swap the agent's DSL into a live runtime (re-renders the RemoteWidget).
/// Throws if the DSL fails to parse — callers should catch and keep the prior
/// screen (degrade), so a bad agent output never blanks the app.
void applyDsl(Runtime runtime, String dsl) =>
    runtime.update(_main, parseLibraryFile(dsl));

/// Neutral defaults for the UI data blob (the bridge's ui_data() shape).
/// Generated goal dashboards carry their own copy inline; this layer only
/// backs optional data.* bindings, so nothing here may name a domain.
const Map<String, Object?> kMockData = {
  'user': {'headline': 'Welcome to Bonsai'},
  'project': {
    'title': 'Nothing planted yet',
    'subtitle': 'Plant a seed to get started',
    'headline': 'Your garden is ready for its first seed.',
    'status': 'foundation',
    'progress': 0.0,
  },
  'stats': {'active': '0', 'blocked': '0', 'inbox': '0'},
};

/// Builds an rfw [Runtime] with: core layout widgets, the frozen Bonsai pool,
/// and a remote DSL library. Reused by the app and by tests.
Runtime buildRuntime(String dsl) {
  return Runtime()
    ..update(_core, createCoreWidgets())
    ..update(_bonsai, createBonsaiWidgets())
    ..update(_main, parseLibraryFile(dsl));
}
