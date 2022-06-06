import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:auto_mock_vocal/models/exceptions.dart';
import 'package:auto_mock_vocal/utils/data.dart';
import 'package:auto_mock_vocal/utils/network.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:input_slider/input_slider.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'components/setting_components.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (await DataBus.configFile.exists()) {
      await readConfig();
    } else {
      await writeConfig();
    }
  } catch (e) {
    await FlutterPlatformAlert.playAlertSound();

    var action = await FlutterPlatformAlert.showAlert(
        windowTitle: "Oops!",
        text:
            "error: ${e.toString()}, maybe delete config file could help, would you? yes: delete it, no: bring me to it(you may have to restart the app manually)",
        alertStyle: AlertButtonStyle.yesNo);
    //yesButton and noButton
    if (action.name == "yesButton") {
      await DataBus.configFile.delete();
      await writeConfig();
      await readConfig();
    } else {
      launchUrlString(DataBus.configFile.path);
    }
  }

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AutoMockVocal(),
  ));

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await DesktopWindow.setWindowSize(const Size(810, 510));
  }
}

class AutoMockVocal extends StatefulWidget {
  const AutoMockVocal({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AutoMockVocalState();
  }
}

class AutoMockVocalState extends State<AutoMockVocal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Auto mock vocal"),
          actions: [
            IconButton(
                onPressed: () {
                  launchUrl(
                      Uri.parse("https://github.com/SinoAHpx/AutoMockVocal"));
                },
                icon: const Icon(FontAwesome5.github))
          ],
        ),
        body: Center(
          child: Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    SubscriptionSettings(),
                    VocalSettings(),
                    PersistenceSettings(),
                    ContentSettings()
                  ],
                ),
              )),
        ));
  }
}

class SubscriptionSettings extends StatefulWidget {
  const SubscriptionSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SubscriptionSettingsState();
}

class SubscriptionSettingsState extends State<SubscriptionSettings> {
  TextEditingController subscriptionKeyController =
      TextEditingController(text: DataBus.subscriptionKey);

  @override
  Widget build(BuildContext context) {
    return SettingExpander(
        header: "Subscription",
        hint: "Subscription information",
        content: [
          SettingItem(
            input: SettingField(
              icon: Icons.key_sharp,
              labelText: "Subscription key",
              hintText: "Your azure subscription key",
              controller: subscriptionKeyController,
              onChanged: (s) {
                setState(() {
                  DataBus.subscriptionKey = s;
                });
              },
            ),
          ),
          SettingItem(
              input: SettingDropdown<String>(
            labelText: "Region",
            hintText: "Region of your azure resource",
            value: DataBus.selectedRegion,
            icon: Icons.location_on,
            items: DataBus.azureRegions.entries
                .map((e) => DropdownMenuItem<String>(
                    value: e.key, child: Text("${e.value}(${e.key})")))
                .toList(),
            onChanged: (e) => {DataBus.selectedRegion = e},
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text("Keep subscription and region settings?")
                ],
              ),
              Switch(
                  value: DataBus.keepSubscriptionSettings,
                  onChanged: (e) => {
                        setState(
                          () {
                            DataBus.keepSubscriptionSettings = e;
                          },
                        )
                      })
            ],
          )
        ]);
  }
}

class VocalSettings extends StatefulWidget {
  const VocalSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VocalSettingsState();
}

class VocalSettingsState extends State<VocalSettings> {
  bool isStyledVoice() {
    return DataBus.selectedVoice != null &&
        DataBus.styledVoices.keys
            .any((element) => element == DataBus.selectedVoice?.shortName);
  }

  @override
  Widget build(BuildContext context) {
    return SettingExpander(
        header: "Vocal",
        hint: "See how's your voice will be generate",
        content: [
          SettingItem(
              input: SettingDropdown<Voice>(
            icon: Icons.mic,
            value: DataBus.selectedVoice,
            labelText: "Voice",
            hintText: "The voice you heard",
            items: DataBus.azureVoices
                .map((e) => DropdownMenuItem<Voice>(
                      value: e,
                      child: Text(
                          "${e.displayName}(${e.localName}, ${e.localeName}"),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() {
                DataBus.selectedVoice = v;

                if (isStyledVoice()) {
                  var styles = DataBus.styledVoices[v?.shortName]!;
                  if (DataBus.selectedStyle != null &&
                      !styles
                          .any((element) => element == DataBus.selectedStyle)) {
                    DataBus.selectedStyle = styles[0];
                  }
                } else {
                  DataBus.selectedStyle = null;
                }
              });
            },
          )),
          if (isStyledVoice())
            SettingItem(
                input: SettingDropdown<String>(
              icon: Icons.style,
              labelText: "Style",
              value: DataBus.selectedStyle,
              hintText: "The available styles for selected voice",
              items: DataBus.styledVoices[DataBus.selectedVoice?.shortName]!
                  .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                  .toList(),
              onChanged: (s) {
                setState(() {
                  DataBus.selectedStyle = s;
                });
              },
            )),
          Center(
            child: Tooltip(
              message: "The speaking speed",
              child: InputSlider(
                  max: 3,
                  min: 0,
                  decimalPlaces: 1,
                  onChange: (v) {
                    setState(() {
                      DataBus.voiceRate = v;
                    });
                  },
                  defaultValue: DataBus.voiceRate,
                  leading: const Icon(
                    Icons.volume_down,
                    color: Color.fromARGB(255, 135, 135, 135),
                  )),
            ),
          )
        ]);
  }
}

class PersistenceSettings extends StatefulWidget {
  const PersistenceSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PersistenceSettingsState();
}

class PersistenceSettingsState extends State<PersistenceSettings> {
  TextEditingController pathController =
      TextEditingController(text: DataBus.productPath);

  @override
  Widget build(BuildContext context) {
    return SettingExpander(
        header: "Persistence",
        hint: "How do you want to save your products?",
        content: [
          SettingItem(
              input: SettingDropdown<String>(
                  hintText: "Product format",
                  labelText: "Format",
                  icon: Icons.audio_file,
                  onChanged: (e) {
                    setState(() {
                      DataBus.selectedFormat = e;
                    });
                  },
                  items: DataBus.azureFormats
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  value: DataBus.selectedFormat)),
          SettingItem(
              input: SettingField(
                  icon: Icons.folder,
                  labelText: "Write to",
                  hintText: "The absolute path of your product",
                  controller: pathController,
                  onChanged: (s) {
                    setState(() {
                      DataBus.productPath = s;
                    });
                  })),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      var file = await FilePicker.platform.saveFile(
                        dialogTitle: "Where do you want to save your product?",
                        type: FileType.any,
                      );

                      if (file != null && file.isNotEmpty) {
                        pathController.text = file;
                        DataBus.productPath = file;
                      }
                    },
                    child: const Text("Browse"))
              ],
            ),
          )
        ]);
  }
}

class ContentSettings extends StatefulWidget {
  const ContentSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ContentSettingsState();
}

class ContentSettingsState extends State<ContentSettings> {
  bool isProcessing = false;

  setProcessing(bool value) {
    setState(() {
      isProcessing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingExpander(
        header: "Content",
        hint: "What do you want to say?",
        content: [
          SettingItem(
              input: TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Text",
                hintText: "Speaking text"),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onChanged: (s) {
              setState(() {
                DataBus.speakingContent = s;
              });
            },
          )),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: isProcessing
                ? const LinearProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              setProcessing(true);
                              var bytes = await requestAudio();
                              await File(DataBus.productPath!)
                                  .writeAsBytes(bytes);
                              setProcessing(false);
                            } catch (e) {
                              var message = e.toString();
                              if (e is IncompleteConfigException) {
                                message = e.message;
                              }
                              showDialog(
                                  context: context,
                                  builder: (builder) => AlertDialog(
                                        title: const Text(
                                            "Oops: something goes to wrong!"),
                                        content: Text(message),
                                      ));
                              setProcessing(false);
                            }
                          },
                          child: const Text("Generate"))
                    ],
                  ),
          )
        ]);
  }
}
