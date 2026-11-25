import 'config.dart';

/// Demo-only accounts. There is no real sign-in: no password is checked and no
/// real OTP is sent (guidebook: no login, no real accounts). Every account is
/// sample data, shown as "Contoh".
class Customer {
  final String id;
  final String name;
  final String phone;
  final String memberNo;
  final int startBalance; // points the member can spend at the start
  final int startLifetime; // points ever earned: decides the tier
  final bool sample;
  const Customer(
    this.id,
    this.name,
    this.phone, {
    this.memberNo = '',
    this.startBalance = 0,
    this.startLifetime = 0,
    this.sample = sampleData,
  });
}

/// The person browsing before they sign in. Orders placed as a guest belong
/// to this customer.
const guestCustomer = Customer('guest', 'Tamu (contoh)', '');

/// Chips on the sign-in sheet that fill the form. Fake numbers (the 800 prefix
/// is not a real Indonesian mobile prefix).
const demoAccounts = <Customer>[
  Customer(
    'c-jaya',
    'Toko Maju Jaya',
    '+62 821-3333-4403',
    memberNo: 'ICE-0001',
    startBalance: 1320,
    startLifetime: 1820,
  ),
  Customer(
    'c-kios',
    'Sari Mart Indah',
    '+62 822-8888-9908',
    memberNo: 'ICE-0002',
    startBalance: 760,
    startLifetime: 760,
  ),
  Customer(
    'c-rina',
    'Ibu Sari Wijaya',
    '+62 812-1111-2201',
    memberNo: 'ICE-0003',
    startBalance: 210,
    startLifetime: 210,
  ),
];

/// Sample invite code that starts a new demo account at the top tier.
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
