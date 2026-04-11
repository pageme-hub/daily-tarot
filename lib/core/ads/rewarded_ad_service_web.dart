/// RewardedAdService 웹 스텁 — 웹에서는 리워드 즉시 지급
class RewardedAdService {
  RewardedAdService._();
  static final RewardedAdService instance = RewardedAdService._();

  Future<void> loadAd() async {}

  Future<bool> showAd({
    required void Function() onRewarded,
    void Function()? onAdDismissed,
  }) async {
    onRewarded();
    return false;
  }

  void dispose() {}
}
