import 'dart:io';
import 'dart:convert';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart/model.dart';
import 'package:http/http.dart' as http;
import 'package:ifood_party_bot/data/json_data.dart';
import 'package:ifood_party_bot/data/restaurant.dart';
import 'package:ifood_party_bot/data/section.dart';
import 'package:ifood_party_bot/data/dish.dart';
import 'package:ifood_party_bot/data/garnish.dart';

InlineKeyboardButton a(String t) => InlineKeyboardButton(text: t, url: '', callback_data: 'data${t}');

InlineKeyboardMarkup sectionsMarkup(Restaurant restaurant) {
  Function makeData = (Section section) => json.encode({
    'type': 'section',
    'sectionId': section.id,
  });

  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant.sections
      .map((s) => [InlineKeyboardButton(text: s.name, url: '', callback_data: makeData(s))])
      .toList();
  
  return InlineKeyboardMarkup(inline_keyboard: inlineKeyboard);
}

InlineKeyboardMarkup dishesMarkup(Restaurant restaurant, String sectionId) {
  Function makeData = (Dish dish) => json.encode({
    'type': 'garnish',
    'sectionId': sectionId,
    'dishId': dish.id,
    'garnishId': dish.garnishes.isEmpty ? null : dish.garnishes[0].id,
    'selectedOptions': [],
  });

  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant.sections
      .firstWhere((s) => s.id == sectionId)
      .dishes
      .map((d) {
        return [InlineKeyboardButton(text: '${d.name} R\$${d.price}', url: '', callback_data: makeData(d))];
      })
      .toList();
  
  return InlineKeyboardMarkup(inline_keyboard: inlineKeyboard);
}

JSONData toggleSelectedOption(JSONData data, String option) {
  List<String> newOptions = data.selectedOptions.contains(option) ?
      data.selectedOptions.where((o) => o != option).toList() :
      data.selectedOptions.followedBy([option]).toList();

  return JSONData(
    type: data.type,
    sectionId: data.sectionId,
    dishId: data.dishId,
    garnishId: data.garnishId,
    selectedOptions: newOptions,
  );
}

JSONData sampleGarnish() {
  return JSONData.fromString('G_HL46_38178309_459I4_');
}

JSONData secondSampleGarnish() {
  return JSONData.fromString('G_HL46_38178309_459I5_');
}

InlineKeyboardMarkup garnishMarkup(Restaurant restaurant, JSONData data) {
  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant.sections
      .firstWhere((s) => s.id == data.sectionId)
      .dishes
      .firstWhere((d) => d.id == data.dishId)
      .garnishes
      .firstWhere((g) => g.id == data.garnishId)
      .options
      .asMap()
      .entries
      .map((o) => [InlineKeyboardButton(text: '${data.selectedOptions.contains(o.key.toString()) ? '[x]' : '[ ]'} ${o.value.name}', url: '', callback_data: toggleSelectedOption(data, o.key.toString()).toString())])
      // .map((o) => [InlineKeyboardButton(text: '${data.selectedOptions.contains(o.id) ? '[x]' : '[ ]'} ${o.name}', url: '', callback_data: toggleSelectedOption(data, o.id).toString())])
      .toList()
      ..add([InlineKeyboardButton(text: 'NEXT >', url: '', callback_data: JSONData(type: 'NG').toString())]);
  
  return InlineKeyboardMarkup(inline_keyboard: inlineKeyboard);
}

void run() async {
  Restaurant restaurant = await http.get('http://localhost:3000/')
      .then((response) => Restaurant.fromJson(json.decode(response.body)));
  TeleDart teledart = TeleDart(Telegram(Platform.environment['TELEGRAM_TOKEN']), Event());

  teledart.startFetching();

  print(restaurant.name);

  teledart
    .onCommand('a')
    .listen((message) {
      print('Received command: ${message.message_id}');
      print(sampleGarnish());
      teledart.replyMessage(message, 'Choose garnish options:', reply_markup: garnishMarkup(restaurant, sampleGarnish()));
    });

  teledart
    .onMessage(keyword: '\/b_[0-9]+')
    .listen((message) {
      print('Received text: ${message.text}');
    });

  teledart
    .onCallbackQuery()
    .listen((query) async {
      print('Received callback: ${query.id} ${query.data}');

      JSONData data = JSONData.fromString(query.data);

      if (data.type == 'section') {
        await teledart.editMessageText('Chose a dish:',
            chat_id: query.message.chat.id,
            message_id: query.message.message_id, 
            reply_markup: dishesMarkup(restaurant, data.sectionId));
      } else if (data.type == 'dish') {
        await teledart.editMessageText('Chose a dish:',
            chat_id: query.message.chat.id,
            message_id: query.message.message_id, 
            reply_markup: dishesMarkup(restaurant, data.dishId));
      } else if (data.type == 'G') {
        await teledart.editMessageText('blah',
            chat_id: query.message.chat.id,
            message_id: query.message.message_id, 
            reply_markup: garnishMarkup(restaurant, data));
      } else if (data.type == 'NG') {
        await teledart.editMessageText('novo garnish',
            chat_id: query.message.chat.id,
            message_id: query.message.message_id, 
            reply_markup: garnishMarkup(restaurant, secondSampleGarnish()));
      }

      await teledart.answerCallbackQuery(query, text: 'Done!');
    });
}
