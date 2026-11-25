import 'package:aice_shopping/assistant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String first(String q) => answer(q).text;

  test('main intents work in English', () {
    expect(first('Any promo today?'), contains('Promo contoh'));
    expect(first('How much is delivery?'), contains('Ongkir contoh'));
    expect(first('What are my points?'), contains('poin'));
    expect(first('Where is my order? track it'), contains('tab Pesanan'));
    expect(first('Does it stay frozen?'), contains('tas pendingin'));
    expect(answer('best sellers').productIds, isNotEmpty);
    expect(answer('ice cream for a party').productIds, isNotEmpty);
  });

  test('main intents work in Chinese', () {
    expect(first('今天有什么优惠？'), contains('Promo contoh'));
    expect(first('配送费多少？'), contains('Ongkir contoh'));
    expect(first('我的积分'), contains('poin'));
    expect(first('我的订单在哪里，物流'), contains('tab Pesanan'));
    expect(first('冷冻的吗'), contains('tas pendingin'));
    expect(answer('畅销的是什么').productIds, isNotEmpty);
    expect(answer('派对用什么').productIds, isNotEmpty);
  });

  test('Indonesian questions still work and unknown ones fall back', () {
    expect(first('Ada promo apa hari ini?'), contains('Promo contoh'));
    expect(first('xyz qqq'), contains('Maaf'));
  });
}
