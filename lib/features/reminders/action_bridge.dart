import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

/// Lets the background isolate tell the running app that a notification
/// action changed the database, since the two use separate connections and
/// the app's streams would otherwise not notice.
const _portName = 'wellbeing_reminder_action_done';

/// In the app: listen for "an action finished". Returns a disposer.
void Function() listenForActionResults(void Function() onDone) {
  IsolateNameServer.removePortNameMapping(_portName);
  final port = ReceivePort();
  IsolateNameServer.registerPortWithName(port.sendPort, _portName);
  final sub = port.listen((_) => onDone());
  return () {
    sub.cancel();
    IsolateNameServer.removePortNameMapping(_portName);
    port.close();
  };
}

/// In the background isolate: report that an action finished.
void notifyActionDone() =>
    IsolateNameServer.lookupPortByName(_portName)?.send(null);
