// Switches and demo settings in one place (guidebook 2.3 and Aice 5.3).
// Tests in test/guard_test.dart pin these values.

/// Every product, store, price and promo in this demo is sample data
/// ("Contoh"). Nothing is a real Aice catalog.
const bool sampleData = true;

/// Brands shown in the app. Brand and Store are separate concepts so other
/// brands can be added later. 'toko' is the store's own everyday goods
/// (sayur, sembako, snack, some drinks), which the client asked for.
const Set<String> enabledBrands = {'aice', 'toko'};
