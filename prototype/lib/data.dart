import 'config.dart';

/// Sample catalog. All names, prices and stores are made up and shown as "contoh".

/// A brand that sells through the app. Only brands in [enabledBrands] show.
class Brand {
  final String id;
  final String name;
  const Brand(this.id, this.name);
}

const brands = <Brand>[Brand('aice', 'Aice')];
class Product {
  final String id;
  final String name;
  final String category; // cone, tub, stick, cup, drink, bundle
  final String size;
  final int price;
  final int? oldPrice;
  final String? ribbon;
  final bool soldOut;
  final String? photo; // file name under assets/products, optional
  final int rank; // lower = more popular
  final String brandId;
  final bool sample; // sample data, shown as "Contoh"

  const Product(
    this.id,
    this.name,
    this.category,
    this.size,
    this.price, {
    this.oldPrice,
    this.ribbon,
    this.soldOut = false,
    this.photo,
    this.rank = 99,
    this.brandId = 'aice',
    this.sample = sampleData,
  });

  bool get multiBuy => category == 'cone';
  int? get percentOff =>
      oldPrice == null ? null : (((oldPrice! - price) * 100) / oldPrice!).round();
}

const categories = <String, String>{
  'cone': 'Cone',
  'tub': 'Tub',
  'stick': 'Stik',
  'cup': 'Yoghurt',
  'drink': 'Minuman',
  'bundle': 'Paket',
};

/// Every sample product, for all brands.
const allProducts = <Product>[
  // Cone
  Product('cone-vanila', 'Cone Vanila Stroberi', 'cone', '80 ml', 5000,
      ribbon: 'Best Seller', photo: 'cone-vanila.webp', rank: 1),
  Product('cone-cokelat', 'Cone Cokelat Crunch', 'cone', '80 ml', 6000,
      ribbon: 'New', photo: 'cone-cokelat.webp', rank: 4),
  Product('cone-matcha', 'Cone Matcha Susu', 'cone', '80 ml', 6500,
      photo: 'cone-matcha.webp', rank: 6),
  Product('cone-taro', 'Cone Taro Swirl', 'cone', '80 ml', 6000,
      ribbon: 'New', photo: 'cone-taro.webp', rank: 14),
  Product('cone-mangga', 'Cone Mangga Susu', 'cone', '80 ml', 5500,
      photo: 'cone-mangga.webp', rank: 16),
  Product('cone-mint', 'Cone Mint Segar', 'cone', '80 ml', 5500,
      photo: 'cone-mint.webp', rank: 20),
  Product('cone-mocha', 'Cone Mocha', 'cone', '80 ml', 5500,
      photo: 'cone-mocha.webp', rank: 8),
  Product('cone-stroberi', 'Cone Stroberi', 'cone', '80 ml', 5000,
      ribbon: 'Habis', soldOut: true, rank: 9),
  // Stik
  Product('stik-cokelat', 'Stik Cokelat Almond', 'stick', '65 ml', 7000,
      oldPrice: 8000, photo: 'stik-cokelat.webp', rank: 2),
  Product('stik-dark', 'Stik Dark Cokelat', 'stick', '65 ml', 7500,
      ribbon: 'New', photo: 'stik-dark.webp', rank: 15),
  Product('stik-stroberi', 'Stik Stroberi Crunch', 'stick', '65 ml', 6500,
      oldPrice: 7500, photo: 'stik-stroberi.webp', rank: 12),
  Product('stik-vanila', 'Stik Vanila Choco', 'stick', '65 ml', 6000, rank: 7),
  // Tub
  Product('tub-stroberi', 'Tub Stroberi', 'tub', '700 ml', 32000,
      ribbon: 'Beli 2 Disc.', photo: 'tub-stroberi.webp', rank: 3),
  Product('tub-mangga', 'Tub Mangga', 'tub', '700 ml', 32000,
      photo: 'tub-mangga.webp', rank: 17),
  Product('tub-taro', 'Tub Taro', 'tub', '700 ml', 34000,
      ribbon: 'New', photo: 'tub-taro.webp', rank: 19),
  Product('tub-mint', 'Tub Mint Choco Chip', 'tub', '700 ml', 34000,
      oldPrice: 38000, photo: 'tub-mint.webp', rank: 21),
  Product('tub-vanila', 'Tub Vanila', 'tub', '700 ml', 34000,
      ribbon: 'Habis', soldOut: true, rank: 10),
  // Yoghurt
  Product('cup-blueberry', 'Yoghurt Blueberry', 'cup', '100 ml', 9000,
      photo: 'cup-blueberry.webp', rank: 5),
  Product('cup-anggur', 'Yoghurt Anggur', 'cup', '100 ml', 9000,
      photo: 'cup-stroberi.webp', rank: 18),
  Product('cup-matcha', 'Yoghurt Matcha', 'cup', '100 ml', 9500,
      ribbon: 'New', photo: 'cup-matcha.webp', rank: 22),
  // Minuman
  Product('drink-cokelat', 'Susu Cokelat Dingin', 'drink', '200 ml', 8000,
      photo: 'drink-cokelat.webp', rank: 11),
  Product('drink-stroberi', 'Susu Stroberi Dingin', 'drink', '200 ml', 8000,
      ribbon: 'Best Seller', photo: 'drink-stroberi.webp', rank: 13),
  Product('drink-matcha', 'Matcha Latte Dingin', 'drink', '200 ml', 9500,
      photo: 'drink-matcha.webp', rank: 23),
  Product('drink-taro', 'Susu Taro Dingin', 'drink', '200 ml', 9000,
      oldPrice: 10000, photo: 'drink-taro.webp', rank: 24),
  // Paket
  Product('bundle-keluarga', 'Paket Keluarga (6 cone)', 'bundle', '6 x 80 ml',
      28500,
      oldPrice: 30000,
      ribbon: 'Gratis hadiah',
      photo: 'bundle-keluarga.webp',
      rank: 25),
  Product('bundle-pesta', 'Paket Pesta (12 stik)', 'bundle', '12 x 65 ml', 72000,
      oldPrice: 78000, ribbon: 'Hemat', photo: 'paket-stik.webp', rank: 26),
  Product('bundle-cone-trio', 'Paket Cone 3 Rasa', 'bundle', '3 x 80 ml', 15000,
      oldPrice: 16500, photo: 'paket-cone.webp', rank: 27),
  Product('bundle-tub-duo', 'Paket Tub Berdua', 'bundle', '2 x 700 ml', 60000,
      oldPrice: 64000, ribbon: 'Hemat', photo: 'paket-tub.webp', rank: 28),
  Product('bundle-yoghurt', 'Paket Yoghurt 3 Rasa', 'bundle', '3 x 100 ml',
      25000,
      oldPrice: 27500, photo: 'paket-yoghurt.webp', rank: 29),
];

/// Products the app shows: only brands that are switched on.
final List<Product> catalog = [
  for (final p in allProducts)
    if (enabledBrands.contains(p.brandId)) p,
];

Product productById(String id) => catalog.firstWhere((p) => p.id == id);

/// A store (outlet). Separate from [Brand]: a store sells products of the
/// brands it lists.
class Store {
  final String name;
  final String distance;
  final String hours;
  final Set<String> brandIds;
  final bool sample;
  const Store(this.name, this.distance, this.hours,
      {this.brandIds = const {'aice'}, this.sample = sampleData});
}

const stores = <Store>[
  Store('Toko Contoh 1', '0,8 km', 'Buka 08.00 - 22.00'),
  Store('Toko Contoh 2', '1,6 km', 'Buka 08.00 - 22.00'),
  Store('Toko Contoh 3', '2,4 km', 'Buka 09.00 - 21.00'),
];

const savedAddresses = <String>[
  'Jl. Contoh No. 12, Kota Contoh',
  'Apartemen Contoh Tower B, Kota Contoh',
  'Kantor Contoh, Jl. Sampel No. 7',
];

const popularSearches = <String>[
  'cone',
  'stik cokelat',
  'paket pesta',
  'yoghurt',
  'tub 700 ml',
];
