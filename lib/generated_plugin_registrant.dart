import 'package:audioplayer_web/audioplayer_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(PluginRegistry registry) {
  AudioplayerPlugin.registerWith(registry.registrarFor(AudioplayerPlugin));
  registry.registerMessageHandler();
}
