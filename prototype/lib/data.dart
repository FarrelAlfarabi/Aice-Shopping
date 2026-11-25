import 'config.dart';

/// Sample catalog. All names, prices, stores and addresses are made up but
/// look real. The DEMO strip on every screen and the About screen say so, so
/// labels do not carry "(contoh)".

/// A brand that sells through the app. Only brands in [enabledBrands] show.
class Brand {
  final String id;
  final String name;
  const Brand(this.id, this.name);
}

const brands = <Brand>[
  Brand('aice', 'Aice'),
  // Everyday goods the store sells next to Aice (sayur, sembako, snack).
  Brand('toko', 'Produk toko'),
];

class Product {
  final String id;
  final String name;

  /// Kind of product: cone, tub, stick, mochi, icecup, cup (yogurt), drink,
  /// bundle, frozen, veg, staple, snack. Pricing rules key on this.
  final String category;
  final String size;
  final int price;
  final int? oldPrice;
  final String? ribbon;
  final bool soldOut;
  final String? photo; // file name under assets/products, optional
  final int rank; // lower = more popular
  final String brandId;
  final bool sample; // sample data, shown as "Contoh"
  /// 'frozen' (-18 °C), 'chilled' (2-6 °C), 'fresh' (sayur, kulkas) or
  /// 'room' (suhu ruang). Only frozen and chilled get a cold-chain tag.
  final String storage;
  final int? shelfLifeDays; // sample shelf life for chilled products

  /// Shelf (one of [categories]) when it differs from the kind's usual one.
  final String? shelf;

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
    this.storage = 'frozen',
    this.shelfLifeDays,
    this.shelf,
  });

  bool get chilled => storage == 'chilled';
  bool get coldChain => storage == 'chilled' || storage == 'frozen';

  /// The top-level category this product is listed under.
  String get group => shelf ?? kindGroup[category]!;
  bool get multiBuy => category == 'cone';
  int? get percentOff => oldPrice == null
      ? null
      : (((oldPrice! - price) * 100) / oldPrice!).round();
}

/// The 7 shelves a shopper sees, in this order.
const categories = <String, String>{
  'yogurt': 'Yogurt',
  'frozen': 'Frozen Food',
  'icecream': 'Es Krim',
  'sayur': 'Sayur',
  'sembako': 'Sembako',
  'drink': 'Minuman',
  'snack': 'Snack',
};

/// Short names for each kind, used as filters inside Es Krim.
const kinds = <String, String>{
  'cone': 'Cone',
  'stick': 'Stik',
  'icecup': 'Cup',
  'tub': 'Tub',
  'mochi': 'Mochi',
  'bundle': 'Paket',
};

/// Which shelf each kind sits on.
const kindGroup = <String, String>{
  'cone': 'icecream',
  'tub': 'icecream',
  'stick': 'icecream',
  'mochi': 'icecream',
  'icecup': 'icecream',
  'bundle': 'icecream',
  'cup': 'yogurt',
  'frozen': 'frozen',
  'drink': 'drink',
  'veg': 'sayur',
  'staple': 'sembako',
  'snack': 'snack',
};

/// Every sample product, for all brands.
const allProducts = <Product>[
  // Cone
  Product(
    'cone-vanila',
    'Cone Vanila Stroberi',
    'cone',
    '80 ml',
    5000,
    ribbon: 'Best Seller',
    photo: 'cone-vanila.webp',
    rank: 1,
  ),
  Product(
    'cone-cokelat',
    'Cone Cokelat Crunch',
    'cone',
    '80 ml',
    6000,
    ribbon: 'New',
    photo: 'cone-cokelat.webp',
    rank: 4,
  ),
  Product(
    'cone-matcha',
    'Cone Matcha Susu',
    'cone',
    '80 ml',
    6500,
    photo: 'cone-matcha.webp',
    rank: 6,
  ),
  Product(
    'cone-taro',
    'Cone Taro Swirl',
    'cone',
    '80 ml',
    6000,
    ribbon: 'New',
    photo: 'cone-taro.webp',
    rank: 14,
  ),
  Product(
    'cone-mangga',
    'Cone Mangga Susu',
    'cone',
    '80 ml',
    5500,
    photo: 'cone-mangga.webp',
    rank: 16,
  ),
  Product(
    'cone-mint',
    'Cone Mint Segar',
    'cone',
    '80 ml',
    5500,
    photo: 'cone-mint.webp',
    rank: 20,
  ),
  Product(
    'cone-mocha',
    'Cone Mocha',
    'cone',
    '80 ml',
    5500,
    photo: 'cone-mocha.webp',
    rank: 8,
  ),
  Product(
    'cone-stroberi',
    'Cone Stroberi',
    'cone',
    '80 ml',
    5000,
    ribbon: 'Habis',
    soldOut: true,
    rank: 9,
  ),
  // Stik
  Product(
    'stik-cokelat',
    'Stik Cokelat Almond',
    'stick',
    '65 ml',
    7000,
    oldPrice: 8000,
    photo: 'stik-cokelat.webp',
    rank: 2,
  ),
  Product(
    'stik-dark',
    'Stik Dark Cokelat',
    'stick',
    '65 ml',
    7500,
    ribbon: 'New',
    photo: 'stik-dark.webp',
    rank: 15,
  ),
  Product(
    'stik-stroberi',
    'Stik Stroberi Crunch',
    'stick',
    '65 ml',
    6500,
    oldPrice: 7500,
    photo: 'stik-stroberi.webp',
    rank: 12,
  ),
  Product('stik-vanila', 'Stik Vanila Choco', 'stick', '65 ml', 6000, rank: 7),
  // Tub
  Product(
    'tub-stroberi',
    'Tub Stroberi',
    'tub',
    '700 ml',
    32000,
    ribbon: 'Beli 2 Disc.',
    photo: 'tub-stroberi.webp',
    rank: 3,
  ),
  Product(
    'tub-mangga',
    'Tub Mangga',
    'tub',
    '700 ml',
    32000,
    photo: 'tub-mangga.webp',
    rank: 17,
  ),
  Product(
    'tub-taro',
    'Tub Taro',
    'tub',
    '700 ml',
    34000,
    ribbon: 'New',
    photo: 'tub-taro.webp',
    rank: 19,
  ),
  Product(
    'tub-mint',
    'Tub Mint Choco Chip',
    'tub',
    '700 ml',
    34000,
    oldPrice: 38000,
    photo: 'tub-mint.webp',
    rank: 21,
  ),
  Product(
    'tub-vanila',
    'Tub Vanila',
    'tub',
    '700 ml',
    34000,
    ribbon: 'Habis',
    soldOut: true,
    rank: 10,
  ),
  // Yoghurt
  Product(
    'cup-blueberry',
    'Yoghurt Blueberry',
    'cup',
    '100 ml',
    9000,
    photo: 'cup-blueberry.webp',
    rank: 5,
  ),
  Product(
    'cup-anggur',
    'Yoghurt Anggur',
    'cup',
    '100 ml',
    9000,
    photo: 'cup-stroberi.webp',
    rank: 18,
  ),
  Product(
    'cup-matcha',
    'Yoghurt Matcha',
    'cup',
    '100 ml',
    9500,
    ribbon: 'New',
    photo: 'cup-matcha.webp',
    rank: 22,
  ),
  // Chilled yogurt (sample). Kept cold, not frozen.
  Product(
    'cup-original',
    'Yogurt Original 100ml',
    'cup',
    '100 ml',
    6500,
    photo: 'cup-original.webp',
    rank: 30,
    storage: 'chilled',
    shelfLifeDays: 28,
  ),
  // Minuman
  Product(
    'drink-cokelat',
    'Susu Cokelat Dingin',
    'drink',
    '200 ml',
    8000,
    photo: 'drink-cokelat.webp',
    rank: 11,
  ),
  Product(
    'drink-stroberi',
    'Susu Stroberi Dingin',
    'drink',
    '200 ml',
    8000,
    ribbon: 'Best Seller',
    photo: 'drink-stroberi.webp',
    rank: 13,
  ),
  Product(
    'drink-matcha',
    'Matcha Latte Dingin',
    'drink',
    '200 ml',
    9500,
    photo: 'drink-matcha.webp',
    rank: 23,
  ),
  Product(
    'drink-taro',
    'Susu Taro Dingin',
    'drink',
    '200 ml',
    9000,
    oldPrice: 10000,
    photo: 'drink-taro.webp',
    rank: 24,
  ),
  // Makanan beku (sample). Store at -18 °C.
  Product(
    'frozen-naget',
    'Naget Ayam 250g',
    'frozen',
    '250 g',
    28000,
    photo: 'frozen-naget.webp',
    rank: 31,
  ),
  Product(
    'frozen-tahu',
    'Tahu Ikan Beku 400g',
    'frozen',
    '400 g',
    24000,
    photo: 'frozen-tahu.webp',
    rank: 32,
  ),
  Product(
    'frozen-sosis',
    'Sosis Ayam Beku 300g',
    'frozen',
    '300 g',
    26000,
    photo: 'frozen-sosis.webp',
    rank: 33,
  ),
  // Paket
  Product(
    'bundle-keluarga',
    'Paket Keluarga (6 cone)',
    'bundle',
    '6 x 80 ml',
    28500,
    oldPrice: 30000,
    ribbon: 'Gratis hadiah',
    photo: 'bundle-keluarga.webp',
    rank: 25,
  ),
  Product(
    'bundle-pesta',
    'Paket Pesta (12 stik)',
    'bundle',
    '12 x 65 ml',
    72000,
    oldPrice: 78000,
    ribbon: 'Hemat',
    photo: 'paket-stik.webp',
    rank: 26,
  ),
  Product(
    'bundle-cone-trio',
    'Paket Cone 3 Rasa',
    'bundle',
    '3 x 80 ml',
    15000,
    oldPrice: 16500,
    photo: 'paket-cone.webp',
    rank: 27,
  ),
  Product(
    'bundle-tub-duo',
    'Paket Tub Berdua',
    'bundle',
    '2 x 700 ml',
    60000,
    oldPrice: 64000,
    ribbon: 'Hemat',
    photo: 'paket-tub.webp',
    rank: 28,
  ),
  Product(
    'bundle-yoghurt',
    'Paket Yoghurt 3 Rasa',
    'bundle',
    '3 x 100 ml',
    25000,
    oldPrice: 27500,
    photo: 'paket-yoghurt.webp',
    rank: 29,
    shelf: 'yogurt',
  ),
  // Es krim: mochi and cups
  Product(
    'mochi-vanila',
    'Mochi Es Krim Vanila',
    'mochi',
    '3 x 35 g',
    15000,
    photo: 'mochi-vanila.webp',
    rank: 34,
  ),
  Product(
    'mochi-stroberi',
    'Mochi Es Krim Stroberi',
    'mochi',
    '3 x 35 g',
    15000,
    ribbon: 'New',
    photo: 'mochi-stroberi.webp',
    rank: 35,
  ),
  Product(
    'mochi-matcha',
    'Mochi Es Krim Matcha',
    'mochi',
    '3 x 35 g',
    16000,
    photo: 'mochi-matcha.webp',
    rank: 36,
  ),
  Product(
    'icup-cokelat',
    'Es Krim Cup Cokelat',
    'icecup',
    '120 ml',
    8000,
    photo: 'icup-cokelat.webp',
    rank: 37,
  ),
  Product(
    'icup-vanila',
    'Es Krim Cup Vanila Kacang',
    'icecup',
    '120 ml',
    8000,
    photo: 'icup-vanila.webp',
    rank: 38,
  ),
  // Yogurt, kept cold
  Product(
    'yog-drink-stroberi',
    'Yogurt Minum Stroberi 200ml',
    'cup',
    '200 ml',
    8500,
    photo: 'yog-drink.webp',
    rank: 39,
    storage: 'chilled',
    shelfLifeDays: 21,
  ),
  Product(
    'yog-greek',
    'Greek Yogurt Plain 500g',
    'cup',
    '500 g',
    32000,
    photo: 'yog-greek.webp',
    rank: 40,
    storage: 'chilled',
    shelfLifeDays: 21,
  ),
  // Frozen food
  Product(
    'frozen-dimsum',
    'Dimsum Ayam Udang isi 12',
    'frozen',
    '360 g',
    32000,
    photo: 'frozen-dimsum.webp',
    rank: 41,
  ),
  Product(
    'frozen-kentang',
    'Kentang Goreng Beku 1kg',
    'frozen',
    '1 kg',
    38000,
    oldPrice: 42000,
    photo: 'frozen-kentang.webp',
    rank: 42,
  ),
  Product(
    'frozen-bakso',
    'Bakso Sapi Beku 500g',
    'frozen',
    '500 g',
    42000,
    photo: 'frozen-bakso.webp',
    rank: 43,
  ),
  // Minuman
  Product(
    'drink-teh',
    'Teh Melati Botol 350ml',
    'drink',
    '350 ml',
    5000,
    photo: 'drink-teh.webp',
    rank: 44,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'drink-air',
    'Air Mineral 600ml',
    'drink',
    '600 ml',
    3500,
    photo: 'drink-air.webp',
    rank: 45,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'drink-kopi',
    'Kopi Susu Gula Aren 250ml',
    'drink',
    '250 ml',
    15000,
    ribbon: 'New',
    photo: 'drink-kopi.webp',
    rank: 46,
    brandId: 'toko',
    storage: 'chilled',
    shelfLifeDays: 5,
  ),
  // Sayur, fresh
  Product(
    'veg-bayam',
    'Bayam Hijau 250g',
    'veg',
    '250 g',
    6000,
    photo: 'veg-bayam.webp',
    rank: 47,
    brandId: 'toko',
    storage: 'fresh',
  ),
  Product(
    'veg-kangkung',
    'Kangkung 250g',
    'veg',
    '250 g',
    5000,
    photo: 'veg-kangkung.webp',
    rank: 48,
    brandId: 'toko',
    storage: 'fresh',
  ),
  Product(
    'veg-wortel',
    'Wortel 500g',
    'veg',
    '500 g',
    9000,
    photo: 'veg-wortel.webp',
    rank: 49,
    brandId: 'toko',
    storage: 'fresh',
  ),
  Product(
    'veg-tomat',
    'Tomat Merah 500g',
    'veg',
    '500 g',
    11000,
    photo: 'veg-tomat.webp',
    rank: 50,
    brandId: 'toko',
    storage: 'fresh',
  ),
  Product(
    'veg-brokoli',
    'Brokoli 300g',
    'veg',
    '300 g',
    16000,
    photo: 'veg-brokoli.webp',
    rank: 51,
    brandId: 'toko',
    storage: 'fresh',
  ),
  // Sembako
  Product(
    'staple-beras',
    'Beras Pulen 5kg',
    'staple',
    '5 kg',
    74000,
    oldPrice: 78000,
    photo: 'staple-beras.webp',
    rank: 52,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'staple-gula',
    'Gula Pasir 1kg',
    'staple',
    '1 kg',
    17500,
    photo: 'staple-gula.webp',
    rank: 53,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'staple-tepung',
    'Tepung Terigu 1kg',
    'staple',
    '1 kg',
    13500,
    photo: 'staple-tepung.webp',
    rank: 54,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'staple-minyak',
    'Minyak Goreng 2L',
    'staple',
    '2 L',
    38000,
    photo: 'staple-minyak.webp',
    rank: 55,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'staple-telur',
    'Telur Ayam 1kg',
    'staple',
    '1 kg',
    29000,
    photo: 'staple-telur.webp',
    rank: 56,
    brandId: 'toko',
    storage: 'room',
  ),
  // Snack
  Product(
    'snack-keripik',
    'Keripik Singkong Balado 150g',
    'snack',
    '150 g',
    12000,
    photo: 'snack-keripik.webp',
    rank: 57,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'snack-mete',
    'Kacang Mete Panggang 100g',
    'snack',
    '100 g',
    26000,
    photo: 'snack-mete.webp',
    rank: 58,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'snack-wafer',
    'Wafer Cokelat 140g',
    'snack',
    '140 g',
    9500,
    ribbon: 'Best Seller',
    photo: 'snack-wafer.webp',
    rank: 59,
    brandId: 'toko',
    storage: 'room',
  ),
  Product(
    'snack-biskuit',
    'Biskuit Kelapa 200g',
    'snack',
    '200 g',
    11000,
    photo: 'snack-biskuit.webp',
    rank: 60,
    brandId: 'toko',
    storage: 'room',
  ),
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
  final String area; // kecamatan or neighbourhood
  final String distance;
  final String hours;
  final Set<String> brandIds;
  final bool sample;
  const Store(
    this.name,
    this.area,
    this.distance,
    this.hours, {
    this.brandIds = const {'aice', 'toko'},
    this.sample = sampleData,
  });
}

/// Made-up stores with real-sounding names in Jakarta Barat. None of them is
/// a real business.
const stores = <Store>[
  Store('Es Krim Sejahtera', 'Kebon Jeruk', '0,8 km', 'Buka 08.00 - 22.00'),
  Store('Toko Beku Makmur', 'Palmerah', '1,6 km', 'Buka 08.00 - 22.00'),
  Store(
    'Dingin Berkah Frozen',
    'Tanjung Duren',
    '2,4 km',
    'Buka 09.00 - 21.00',
  ),
];

/// Made-up addresses on real-sounding streets, with real kecamatan and postal
/// codes of Jakarta Barat. House numbers are invented.
const savedAddresses = <String>[
  'Jl. Kemanggisan Utama No. 27, Palmerah, Jakarta Barat 11480',
  'Apartemen Griya Kencana Tower B Lt. 12, Kembangan, Jakarta Barat 11610',
  'Kantor, Jl. Arjuna Selatan No. 9, Kebon Jeruk, Jakarta Barat 11530',
];

const popularSearches = <String>['cone', 'yogurt', 'naget', 'beras', 'sayur'];
