import 'config.dart';

/// Demo-only accounts. There is no real sign-in: no password is checked and no
/// real OTP is sent (guidebook: no login, no real accounts). Every account is
/// sample data, shown as "Contoh".
class Customer {
  final String id;
  final String name;
  final String phone;
  final bool vip; // gets the member price
  final bool sample;
  const Customer(this.id, this.name, this.phone,
      {this.vip = false, this.sample = sampleData});
}

/// The person browsing before they sign in. Orders placed as a guest belong
/// to this customer.
const guestCustomer = Customer('guest', 'Tamu (contoh)', '');

/// Chips on the sign-in sheet that fill the form. Fake numbers (the 800 prefix
/// is not a real Indonesian mobile prefix).
const demoAccounts = <Customer>[
  Customer('c-jaya', 'Toko Es Contoh Jaya', '+62 800-1111-0001', vip: true),
  Customer('c-kios', 'Kios Dingin Contoh', '+62 800-1111-0002'),
  Customer('c-rina', 'Ibu Rina Contoh', '+62 800-1111-0003', vip: true),
];

/// Sample invite code that makes a new demo account VIP.
const inviteCodeVip = 'VIP-CONTOH';

/// Any 4+ digit code works as the demo OTP.
const demoOtpLength = 4;

/// Link to the salesperson. Only a link: nothing is sent from the app and the
/// number is not real.
const salespersonWhatsApp =
    'https://wa.me/628000000000?text=Halo%2C%20saya%20mau%20tanya%20pesanan%20(demo%20contoh)';

/// Fake bank details shown on the transfer step.
const sampleBankAccount = '0000-000-000 a.n. Toko Contoh (contoh)';

String digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
