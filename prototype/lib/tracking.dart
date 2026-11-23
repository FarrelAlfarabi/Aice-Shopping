/// Fake order tracking. The whole trip is squeezed into [demoSeconds] so it can
/// be shown in a meeting. The shown ETA is a sample 15 minutes.
enum Phase { received, preparing, onTheWay, arrived }

const sampleEtaMinutes = 15;
const lateGraceMinutes = 10;

class TrackState {
  final Phase phase;
  final double minutesLeft; // >= 0 while on time
  final double minutesLate; // > 0 once the ETA has passed
  const TrackState(this.phase, this.minutesLeft, this.minutesLate);

  bool get isLate => minutesLate > 0;
  bool get guarantee => minutesLate > lateGraceMinutes;
  bool get delivered => phase == Phase.arrived;
}

/// [elapsed] is real seconds since the order was placed.
/// When [forceLate] is set, the courier never arrives on time and the late
/// minutes grow 1 minute per 1.5 seconds, so the guarantee shows within a
/// short wait.
TrackState trackAt(double elapsed, int demoSeconds, {bool forceLate = false}) {
  final f = elapsed / demoSeconds;
  if (forceLate && f >= 1) {
    final late = (elapsed - demoSeconds) / 1.5;
    // The courier finally arrives once the order is 20 minutes late.
    if (late >= 20) return TrackState(Phase.arrived, 0, late);
    return TrackState(Phase.onTheWay, 0, late <= 0 ? 0.01 : late);
  }
  final left = sampleEtaMinutes * (1 - f);
  if (f >= 1) return const TrackState(Phase.arrived, 0, 0);
  if (f < 0.15) return TrackState(Phase.received, left, 0);
  if (f < 0.4) return TrackState(Phase.preparing, left, 0);
  return TrackState(Phase.onTheWay, left, 0);
}

/// The sample rule: fee refunded when more than 10 minutes late.
bool lateGuarantee(double minutesLate) => minutesLate > lateGraceMinutes;

String clock(double minutes) {
  final total = (minutes * 60).round().clamp(0, 99 * 60);
  final m = total ~/ 60;
  final s = total % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
