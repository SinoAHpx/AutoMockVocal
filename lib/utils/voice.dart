import 'package:auto_mock_vocal/utils/data.dart';

Voice getVoiceByShortName(String shortName) {
  return DataBus.azureVoices
      .firstWhere((element) => element.shortName == shortName);
}
