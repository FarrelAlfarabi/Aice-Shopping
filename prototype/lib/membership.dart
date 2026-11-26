import 'package:flutter/material.dart' hide Text;
import 'format.dart';
import 'i18n.dart';
import 'pricing.dart';
import 'consumer_extras.dart';
import 'state.dart';
import 'ui.dart';

/// Membership and points (sample rules, all numbers in lib/pricing.dart).
/// Points are added only when the admin confirms the transfer. Points used at
/// checkout are taken off at once.

String tierName(MemberTier t) => switch (t.key) {
  'silver' => 'Silver',
  'gold' => 'Gold',
  _ => 'Reguler',
};

String tierBenefit(MemberTier t) => switch (t.key) {
  'silver' => 'Gratis ongkir semua pesanan',
  'gold' => 'Harga VIP + gratis ongkir',
  _ => 'Kumpulkan poin tiap belanja',
};

Color tierColor(MemberTier t) => switch (t.key) {
  'silver' => const Color(0xFF6B7280),
  'gold' => const Color(0xFF8A5A00),
  _ => C.pri,
};

void openMember(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (_) => const MemberScreen()));

/// One line on Beranda. Signed in: balance and tier, tap opens the Member
/// card. Guest: a short sign-in prompt.
class PointsChip extends StatelessWidget {
  const PointsChip({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.tier;
    return Material(
      color: C.tint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const ValueKey('points-chip'),
        borderRadius: BorderRadius.circular(14),
        onTap: s.signedIn
            ? () => openMember(context)
            : () => showSignIn(context),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: Sp.m),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: s.signedIn ? tierColor(t) : C.pri,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: s.signedIn
                    ? Text(
                        '${pts(s.balance)} Poin · ${tierName(t)}',
                        style: tBody.copyWith(fontWeight: FontWeight.w600),
                      )
                    : const Text('Poin dan harga member', style: tBody),
              ),
              if (!s.signedIn)
                const Text(
                  'Masuk',
                  style: TextStyle(color: C.pri, fontWeight: FontWeight.w600),
                ),
              const Icon(Icons.chevron_right, color: C.pri),
            ],
          ),
        ),
      ),
    );
  }
}

class MemberScreen extends StatelessWidget {
  const MemberScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.tier;
    final next = nextTier(s.lifetime);
    final acc = s.accountOf(s.customer);
    final progress = next == null
        ? 1.0
        : ((s.lifetime - t.minPoints) / (next.minPoints - t.minPoints)).clamp(
            0.0,
            1.0,
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Kartu Member')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            key: const ValueKey('member-card'),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.pri, C.priDark]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Kartu Member',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        tierName(t),
                        style: TextStyle(
                          color: tierColor(t),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  s.customer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'No. member ${s.customer.memberNo}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Text(
                  '${pts(s.balance)} Poin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Setara ${rp(s.balance * pointValueRp)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    key: const ValueKey('tier-progress'),
                    value: progress,
                    minHeight: 8,
                    backgroundColor: C.tint,
                    color: C.pri,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  next == null
                      ? 'Tingkat tertinggi sudah tercapai'
                      : '${pts(next.minPoints - s.lifetime)} poin lagi ke ${tierName(next)}',
                  style: tBold,
                ),
                const SizedBox(height: 8),
                for (final m in memberTiers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          m.key == t.key
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 18,
                          color: m.key == t.key ? C.good : C.muted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${tierName(m)} (${pts(m.minPoints)}+): ${tierBenefit(m)}',
                            style: tMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '1 poin tiap ${rp(pointsEarnRp)}. 100 poin = ${rp(100 * pointValueRp)}. '
                  'Tukar maksimal $maxRedeemPercent% dari subtotal. '
                  'Poin ditambahkan setelah transfer dikonfirmasi (aturan contoh).',
                  style: tMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: Sp.s),
          ListGroup(
            title: 'Riwayat poin',
            indent: Sp.l,
            children: [
              if (acc.history.isEmpty)
                const ListRow(title: 'Belum ada riwayat poin.'),
              for (final e in acc.history)
                ListRow(
                  title: switch (e.kind) {
                    PointKind.earn => 'Poin pesanan ${e.ref}',
                    PointKind.redeem => 'Tukar poin untuk ${e.ref}',
                    PointKind.bonus => 'Bonus bergabung',
                  },
                  subtitle: '${e.at.day}/${e.at.month}/${e.at.year}',
                  trailing: Text(
                    '${e.points > 0 ? '+' : ''}${pts(e.points)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: e.points > 0 ? C.good : C.danger,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Tukar poin" block on the cart: pick how many points to use.
class RedeemPanel extends StatelessWidget {
  const RedeemPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    if (!s.signedIn) return const SizedBox.shrink();
    final max = s.maxRedeem;
    final step = 100;
    return Panel(
      key: const ValueKey('redeem-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tukar poin', style: tH3),
          const SizedBox(height: 4),
          Text(
            'Saldo ${pts(s.balance)} poin. Bisa dipakai sampai ${pts(max)} poin '
            '(${rp(max * pointValueRp)}).',
            style: tMuted,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: tr('Kurangi poin'),
                onPressed: s.redeem > 0
                    ? () => s.setRedeem(s.redeem - step)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${pts(s.redeem)} poin',
                    key: const ValueKey('redeem-value'),
                    style: tBold,
                  ),
                ),
              ),
              IconButton(
                tooltip: tr('Tambah poin'),
                onPressed: s.redeem < max
                    ? () => s.setRedeem(s.redeem + step)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              TextButton(
                key: const ValueKey('redeem-max'),
                onPressed: max > 0 ? () => s.setRedeem(max) : null,
                child: const Text('Pakai semua'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Admin: members per tier, points outstanding and the sample member list.
class MembersAdminCard extends StatelessWidget {
  final AppState s;
  const MembersAdminCard(this.s, {super.key});
  @override
  Widget build(BuildContext context) => Panel(
    key: const ValueKey('members-card'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Member & Poin', style: tH3),
        const SizedBox(height: 4),
        Text(
          'Poin beredar: ${pts(s.pointsOutstanding)} (${rp(s.pointsOutstanding * pointValueRp)})',
          style: tMuted,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final m in memberTiers)
              Chip(label: Text('${tierName(m)}: ${s.tierCount(m.key)}')),
          ],
        ),
        const SizedBox(height: 6),
        const Text('Member contoh', style: tBold),
        for (final c in s.customers)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(child: Text('${c.name} · ${tierName(s.tierOf(c))}')),
                Text('${pts(s.accountOf(c).balance)} poin', style: tBold),
              ],
            ),
          ),
      ],
    ),
  );
}

/// Compact Member card for Profil: number, tier progress, tap for the full card.
class MemberCardTile extends StatelessWidget {
  const MemberCardTile({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = s.tier;
    final next = nextTier(s.lifetime);
    final progress = next == null
        ? 1.0
        : ((s.lifetime - t.minPoints) / (next.minPoints - t.minPoints)).clamp(
            0.0,
            1.0,
          );
    return InkWell(
      key: const ValueKey('member-tile'),
      borderRadius: BorderRadius.circular(14),
      onTap: () => openMember(context),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: tierColor(t)),
                const SizedBox(width: 8),
                const Expanded(child: Text('Kartu Member', style: tBold)),
                Text(s.customer.memberNo, style: tMuted),
                const Icon(Icons.chevron_right, color: C.muted),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: C.tint,
                color: C.pri,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              next == null
                  ? 'Tingkat tertinggi sudah tercapai'
                  : '${pts(next.minPoints - s.lifetime)} poin lagi ke ${tierName(next)}',
              style: tMuted,
            ),
          ],
        ),
      ),
    );
  }
}
