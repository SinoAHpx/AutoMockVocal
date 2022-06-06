import 'dart:typed_data';

import 'package:auto_mock_vocal/models/exceptions.dart';
import 'package:auto_mock_vocal/utils/data.dart';
import 'package:http/http.dart' as http;

extension HttpExtensions on String {
  Future<String> get({Map<String, String>? headers}) async {
    headers ??= {"Ocp-Apim-Subscription-Key": DataBus.subscriptionKey!};
    var uri = Uri.parse(this);
    var response = await http.get(uri, headers: headers);

    return response.body;
  }
}

Future<Uint8List> requestAudio() async {
  if (DataBus.selectedRegion == null) {
    throw IncompleteConfigException(message: "Please select a region");
  }
  if (DataBus.subscriptionKey == null) {
    throw IncompleteConfigException(message: "Missing subscription key");
  }
  if (DataBus.selectedFormat == null) {
    throw IncompleteConfigException(message: "Please select a format");
  }
  if (DataBus.voiceRate == 0) {
    throw IncompleteConfigException(message: "Voice rate cannot be 0");
  }
  if (DataBus.productPath == null) {
    throw IncompleteConfigException(
        message: "Please set your own product path");
  }
  if (DataBus.selectedVoice == null) {
    throw IncompleteConfigException(message: "You didn't even select a voice");
  }
  if (DataBus.speakingContent == null) {
    throw IncompleteConfigException(
        message: "You didn't even set what you want to say");
  }

  var voice = DataBus.selectedVoice!;
  var content = DataBus.selectedStyle == null
      ? DataBus.speakingContent!
      : """
        <mstts:express-as style="${DataBus.selectedStyle}">
          ${DataBus.speakingContent}
        </mstts:express-as>
        """;

  var url = Uri.parse(
      "https://${DataBus.selectedRegion}.tts.speech.microsoft.com/cognitiveservices/v1");
  var response = await http.post(url, headers: {
    "Content-Type": "application/ssml+xml",
    "User-Agent": "AutoMockVocal/1.0",
    "X-Microsoft-OutputFormat": DataBus.selectedFormat!,
    "Ocp-Apim-Subscription-Key": DataBus.subscriptionKey!
  }, body: """

    <speak version='1.0' xml:lang='${voice.locale}' xmlns='http://www.w3.org/2001/10/synthesis'
       xmlns:mstts='https://www.w3.org/2001/mstts'>
      <voice xml:lang='${voice.locale}' xml:gender='${voice.gender}' name='${voice.shortName}'>
          $content
      </voice>
    </speak>
    """);

  return response.bodyBytes;
}
