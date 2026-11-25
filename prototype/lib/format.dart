/// Rupiah with a dot for thousands and no decimals, for example "Rp5.000".
String rp(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${n < 0 ? '-' : ''}Rp$b';
}

/// A number with a dot for thousands, for example points: "1.320".
String pts(int n) => rp(n).replaceFirst('Rp', '');
