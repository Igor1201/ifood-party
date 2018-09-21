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

JSONData toggleSelectedOption(JSONData data, int optionIndex) {
  int currentOptions = data.selectedOptions[data.garnishIndex];
  // toggling optionIndex
  currentOptions ^= 1 << optionIndex;

  List<int> newOptions = List.from(data.selectedOptions)
      ..setAll(data.garnishIndex, [currentOptions]);

  return JSONData.clone(data)
    ..selectedOptions = newOptions;
}

JSONData nextGarnish(JSONData data) {
  if (data.garnishIndex + 1 == data.garnishLength) {
    return JSONData.clone(data)
      ..type = 'B';
  }
  return JSONData.clone(data)
    ..garnishIndex = data.garnishIndex + 1;
}

JSONData fromDish(Restaurant restaurant, String sectionId, String dishId) {
  Dish dish = restaurant.sections
      .firstWhere((s) => s.id == sectionId)
      .dishes
      .firstWhere((d) => d.id == dishId);

  return JSONData(
    type: 'G',
    sectionId: sectionId,
    dishId: dishId,
    garnishIndex: 0,
    garnishLength: dish.garnishes.length,
    selectedOptions: List.filled(dish.garnishes.length, 0),
  );
}

InlineKeyboardMarkup dishMarkup(Restaurant restaurant, JSONData data) {
  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant.sections
      .firstWhere((s) => s.id == data.sectionId)
      .dishes
      .firstWhere((d) => d.id == data.dishId)
      .garnishes
      .elementAt(data.garnishIndex)
      .options
      .asMap()
      .entries
      .map((o) => [InlineKeyboardButton(text: '${(data.selectedOptions[data.garnishIndex] & (1 << o.key) != 0) ? '☑️' : '🔲'} ${o.value.name}', url: '', callback_data: toggleSelectedOption(data, o.key).toString())])
      .toList()
      ..add([InlineKeyboardButton(text: 'NEXT >', url: '', callback_data: nextGarnish(data).toString())]);

  return InlineKeyboardMarkup(inline_keyboard: inlineKeyboard);
}

void run() async {
  Restaurant restaurant = await http.get('http://localhost:3000/')
      .then((response) => Restaurant.fromJson(json.decode(response.body)));
  TeleDart teledart = TeleDart(Telegram(Platform.environment['TELEGRAM_TOKEN']), Event());

  teledart.startFetching();

  List<JSONData> receivedData = [];

  teledart
    .onCommand('a')
    .listen((message) {
      print('Received command: ${message.message_id}');
      teledart.replyMessage(message, 'Choose garnish options:', reply_markup: dishMarkup(restaurant, fromDish(restaurant, 'HL46', '38178309')));
    });

  teledart
    .onCommand('show')
    .listen((message) {
      print(receivedData);
    });

  teledart
    .onMessage(keyword: '\/b_[0-9]+')
    .listen((message) {
      print('Received text: ${message.text}');
    });

  teledart
    .onCallbackQuery()
    .listen((query) async {
      print('Received callback: ${query.data}');

      JSONData data = JSONData.fromString(query.data);
      receivedData.add(data);

      try {
        if (data.type == 'G') {
          await teledart.editMessageText(query.data,
              chat_id: query.message.chat.id,
              message_id: query.message.message_id,
              reply_markup: dishMarkup(restaurant, data));
        } else if (data.type == 'B') {
          print('!! CART: ${query.from.id} ${query.from.username} ${query.data}');
          await teledart.editMessageText('Item was added to cart.',
              chat_id: query.message.chat.id,
              message_id: query.message.message_id);
        }
        await teledart.answerCallbackQuery(query, text: 'Done!');
      } catch (e) {
        print('Error: ${e}');
      }

    });
}
