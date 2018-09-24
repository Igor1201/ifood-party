import 'dart:io';
import 'dart:convert';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart/model.dart';
import 'package:http/http.dart' as http;
import 'package:ifood_party_bot/data/json_data.dart';
import 'package:ifood_party_bot/data/restaurant.dart';
import 'package:ifood_party_bot/data/dish.dart';
import 'package:ifood_party_bot/data/garnish.dart';

InlineKeyboardMarkup restaurantMarkup(Restaurant restaurant) {
  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant
      .sections
      .map((s) => [InlineKeyboardButton(text: s.name, url: '', callback_data: fromSection(s.id).toString())])
      .toList()
      ..add([InlineKeyboardButton(text: '❌ CANCEL', url: '', callback_data: cancel().toString())]);

  return InlineKeyboardMarkup(inline_keyboard: inlineKeyboard);
}

JSONData fromSection(String sectionId) {
  return JSONData(
    type: 'S',
    sectionId: sectionId,
  );
}

InlineKeyboardMarkup sectionMarkup(Restaurant restaurant, JSONData data) {
  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant
      .sections
      .firstWhere((s) => s.id == data.sectionId)
      .dishes
      .map((d) => [InlineKeyboardButton(text: '${d.name} R\$${d.price}', url: '', callback_data: fromDish(restaurant, data.sectionId, d.id).toString())])
      .toList()
      ..add([InlineKeyboardButton(text: '❌ CANCEL', url: '', callback_data: cancel().toString())]);

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
  if (data.garnishIndex + 1 >= data.garnishLength) {
    return JSONData.clone(data)
      ..type = 'B';
  }
  return JSONData.clone(data)
    ..garnishIndex = data.garnishIndex + 1;
}

JSONData cancel() {
  return JSONData(
    type: 'C',
  );
}

JSONData fromDish(Restaurant restaurant, String sectionId, String dishId) {
  Dish dish = restaurant
      .sections
      .firstWhere((s) => s.id == sectionId)
      .dishes
      .firstWhere((d) => d.id == dishId);

  int garnishLength = dish.garnishes == null ? 0 : dish.garnishes.length;

  return JSONData(
    type: 'G',
    sectionId: sectionId,
    dishId: dishId,
    garnishIndex: 0,
    garnishLength: garnishLength,
    selectedOptions: List.filled(garnishLength, 0),
  );
}

InlineKeyboardMarkup dishMarkup(Restaurant restaurant, JSONData data) {
  List<InlineKeyboardButton> bottomButtons = [
    InlineKeyboardButton(text: '❌ CANCEL', url: '', callback_data: cancel().toString()),
    InlineKeyboardButton(text: data.garnishIndex + 1 >= data.garnishLength ? '🛒 ADD TO CART' : '➡️ NEXT', url: '', callback_data: nextGarnish(data).toString()),
  ];

  if (data.garnishLength == 0) {
    return InlineKeyboardMarkup(
      inline_keyboard: [bottomButtons],
    );
  }
  
  List<List<InlineKeyboardButton>> inlineKeyboard = restaurant
      .sections
      .firstWhere((s) => s.id == data.sectionId)
      .dishes
      .firstWhere((d) => d.id == data.dishId)
      .garnishes
      .elementAt(data.garnishIndex)
      .options
      .asMap()
      .entries
      .map((o) => [InlineKeyboardButton(text: '${(data.selectedOptions[data.garnishIndex] & (1 << o.key) != 0) ? '☑️' : '🔲'} ${o.value.name} R\$${o.value.price}', url: '', callback_data: toggleSelectedOption(data, o.key).toString())])
      .toList()
      ..add(bottomButtons);

  return InlineKeyboardMarkup(inline_keyboard: inlineKeyboard);
}

String jsonToAddToCart(Restaurant restaurant, JSONData data) {
  Dish dish = restaurant
      .sections
      .firstWhere((s) => s.id == data.sectionId)
      .dishes
      .firstWhere((d) => d.id == data.dishId);

  double amount = dish.price + 2.0;

  data.selectedOptions
      .asMap()
      .entries
      .forEach((MapEntry<int, int> option) {
        dish.garnishes
            .elementAt(option.key)
            .options
            .asMap()
            .entries
            .forEach((o) {
              bool selected = option.value & (1 << o.key) != 0;
              o.value.isSelected = selected;
              if (selected) {
                amount += o.value.price;
              }
            });
      });

  List<List<String>> stringGarnishes = [];
  if (dish.garnishes != null) {
    stringGarnishes = dish
        .garnishes
        .map((Garnish g) {
          return g.options
              .where((o) => o.isSelected)
              .map((o) => o.id)
              .toList();
        })
        .toList();
  }

  return json.encode({
    'dishId': data.dishId,
    'garnishes': stringGarnishes,
    'amount': amount,
  });
}

void run() async {
  Restaurant restaurant = await http.get('http://localhost:3000/')
      .then((response) => Restaurant.fromJson(json.decode(response.body)));
  TeleDart teledart = TeleDart(Telegram(Platform.environment['TELEGRAM_TOKEN']), Event());

  teledart.startFetching();

  // JSONData data = JSONData.fromString('B_P35X_43893224_3/4_[352,0,0,2]');
  // String entry = jsonToAddToCart(restaurant, data);
  // await http.post('http://localhost:3000/cart', body: entry, headers: {'Content-type' : 'application/json'});
  // exit(0);

  List<JSONData> receivedData = [];

  teledart
    .onCommand('start')
    .listen((message) {
      print('Received command: ${message.message_id} from ${message.from.username}');
      teledart.replyMessage(message,
          'Welcome to *${restaurant.name}*!\nPlease select a section.',
          reply_markup: restaurantMarkup(restaurant),
          parse_mode: 'markdown');
    });

  // teledart
  //   .onMessage(keyword: '\/b_[0-9]+')
  //   .listen((message) {
  //     print('Received text: ${message.text}');
  //   });

  teledart
    .onCallbackQuery()
    .listen((query) async {
      print('Received callback: ${query.from.username} ${query.data}');

      JSONData data = JSONData.fromString(query.data);
      receivedData.add(data);

      try {
        if (data.type == 'S') {
          // section
          await teledart.editMessageText(query.data,
              chat_id: query.message.chat.id,
              message_id: query.message.message_id,
              reply_markup: sectionMarkup(restaurant, data));
        } else if (data.type == 'G') {
          // garnish
          await teledart.editMessageText(query.data,
              chat_id: query.message.chat.id,
              message_id: query.message.message_id,
              reply_markup: dishMarkup(restaurant, data));
        } else if (data.type == 'B') {
          // buy
          print('!! CART: ${query.from.id} ${query.from.username} ${query.data}');

          String entry = jsonToAddToCart(restaurant, data);
          http.Response response = await http.post('http://localhost:3000/cart', body: entry, headers: {'Content-type' : 'application/json'});
          String url = json.decode(response.body)['url'];

          await teledart.editMessageText('Item was successfully added to cart!\n${url}',
              chat_id: query.message.chat.id,
              message_id: query.message.message_id);
        } else if (data.type == 'C') {
          // cancel
          await teledart.editMessageText('Cancelled.',
              chat_id: query.message.chat.id,
              message_id: query.message.message_id);
        }
        await teledart.answerCallbackQuery(query);
      } catch (e) {
        print('Error: ${e}');
      }

    });
}
