import 'config.dart';

/// Demo-only accounts. There is no real sign-in: no password is checked and no
/// real OTP is sent (guidebook: no login, no real accounts). Every account is
/// sample data; the DEMO strip says so.
class Customer {
  final String id;
  final String name;
  final String phone;
  final String memberNo;
  final int startBalance; // points the member can spend at the start
  final int startLifetime; // points ever earned: decides the tier
  final String address; // made-up delivery address for admin sample orders
  final bool sample;
  const Customer(
    this.id,
    this.name,
    this.phone, {
    this.memberNo = '',
    this.startBalance = 0,
    this.startLifetime = 0,
    this.address = '',
    this.sample = sampleData,
  });
}

/// The person browsing before they sign in. Orders placed as a guest belong
/// to this customer.
const guestCustomer = Customer('guest', 'Tamu', '');

/// Chips on the sign-in sheet that fill the form. Made-up people and shops.
/// Phone numbers use the real 0812 format with 0000 in the middle so they do
/// not reach a real person.
const demoAccounts = <Customer>[
  Customer(
    'c-jaya',
    'Toko Maju Jaya',
    '+62 812-0000-4403',
    memberNo: 'ICE-0001',
    startBalance: 1320,
    startLifetime: 1820,
    address: 'Jl. Kedoya Raya No. 41, Kebon Jeruk, Jakarta Barat 11520',
  ),
  Customer(
    'c-kios',
    'Sari Mart Indah',
    '+62 813-0000-9908',
    memberNo: 'ICE-0002',
    startBalance: 760,
    startLifetime: 760,
    address:
        'Jl. Anggrek Cendrawasih Blok K No. 3, Palmerah, Jakarta Barat 11480',
  ),
  Customer(
    'c-rina',
    'Rina Wulandari',
    '+62 857-0000-2201',
    memberNo: 'ICE-0003',
    startBalance: 210,
    startLifetime: 210,
    address: 'Jl. Duri Kepa Raya No. 18, Kebon Jeruk, Jakarta Barat 11510',
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
const sampleBankAccount = '123-0045-678 a.n. Es Krim Sejahtera';

String digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
