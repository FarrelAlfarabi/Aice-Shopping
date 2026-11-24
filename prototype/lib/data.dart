/// Sample catalog. All names, prices and stores are made up and shown as "contoh".
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

const catalog = <Product>[
  Product('cone-vanila', 'Cone Vanila Susu', 'cone', '80 ml', 5000,
      ribbon: 'Best Seller', photo: 'cone-vanila.webp', rank: 1),
  Product('cone-cokelat', 'Cone Cokelat Crunch', 'cone', '80 ml', 6000,
      ribbon: 'New', photo: 'cone-cokelat.webp', rank: 4),
  Product('cone-matcha', 'Cone Matcha Susu', 'cone', '80 ml', 6500,
      photo: 'cone-matcha.webp', rank: 6),
  Product('cone-stroberi', 'Cone Stroberi', 'cone', '80 ml', 5000,
      ribbon: 'Habis', soldOut: true, rank: 9),
  Product('cone-mocha', 'Cone Mocha', 'cone', '80 ml', 5500, rank: 8),
  Product('stik-cokelat', 'Stik Cokelat Almond', 'stick', '65 ml', 7000,
      oldPrice: 8000, photo: 'stik-cokelat.webp', rank: 2),
  Product('stik-vanila', 'Stik Vanila Choco', 'stick', '65 ml', 6000, rank: 7),
  Product('tub-stroberi', 'Tub Stroberi', 'tub', '700 ml', 32000,
      ribbon: 'Beli 2 Disc.', photo: 'tub-stroberi.webp', rank: 3),
  Product('tub-vanila', 'Tub Vanila', 'tub', '700 ml', 34000, rank: 10),
  Product('cup-blueberry', 'Yoghurt Blueberry', 'cup', '100 ml', 9000,
      photo: 'cup-blueberry.webp', rank: 5),
  Product('drink-cokelat', 'Susu Cokelat Dingin', 'drink', '200 ml', 8000,
      photo: 'drink-cokelat.webp', rank: 11),
  Product('bundle-keluarga', 'Paket Keluarga (6 cone)', 'bundle', '6 x 80 ml',
      28500,
      oldPrice: 30000,
      ribbon: 'Gratis hadiah',
      photo: 'bundle-keluarga.webp',
      rank: 12),
  Product('bundle-pesta', 'Paket Pesta (12 stik)', 'bundle', '12 x 65 ml', 72000,
      oldPrice: 78000, ribbon: 'Hemat', rank: 13),
];

Product productById(String id) => catalog.firstWhere((p) => p.id == id);

class Store {
  final String name;
  final String distance;
  final String hours;
  const Store(this.name, this.distance, this.hours);
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
