import 'package:flutter_test/flutter_test.dart';

import 'package:waste_corp/domain/economy/economy.dart';
import 'package:waste_corp/domain/contracts/contracts.dart';
import 'package:waste_corp/domain/models/waste_material.dart';

void main() {
  test('tutorial economy constants match Christos lock', () {
    expect(kPlasticPressPayout, 25);
    expect(kWorkerHireCost, 40);
    expect(kPlasticPressSeconds, 2.0);
    expect(kSortPlasticPayout, 2);
    expect(kSortMetalPayout, 3);
    expect(kSortPaperPayout, 2);
    expect(kS1ItemCount, 8);
    expect(kS4TruckloadItems, 10);
    expect(kSortItemSize, 72);
    expect(kBinHitSize, 120);
    expect(kSnapDistance, 48);
  });

  test('sort payouts wire to materials', () {
    expect(sortPayoutFor(WasteMaterial.plastic), kSortPlasticPayout);
    expect(sortPayoutFor(WasteMaterial.metal), kSortMetalPayout);
    expect(sortPayoutFor(WasteMaterial.paper), kSortPaperPayout);
  });

  test('S1+S2 cash covers hire', () {
    // Worst-case: all \$2 sorts × 8 + press \$25 = \$41 ≥ hire \$40.
    final minSort =
        kS1ItemCount *
        [
          kSortPlasticPayout,
          kSortMetalPayout,
          kSortPaperPayout,
        ].reduce((a, b) => a < b ? a : b);
    expect(
      minSort + kPlasticPressPayout,
      greaterThanOrEqualTo(kWorkerHireCost),
    );
  });

  test('tutorial contract: 3 loads / 90s / \$80 / +1 rep', () {
    expect(kTutorialContract.loadsRequired, 3);
    expect(kTutorialContract.timeLimitSeconds, 90);
    expect(kTutorialContract.rewardCash, 80);
    expect(kTutorialContract.rewardReputation, 1);
    expect(kTutorialContract.districtName, isNotEmpty);
  });

  test('truckload builder cycles materials', () {
    final load = buildTruckload(kS4TruckloadItems, prefix: 't');
    expect(load, hasLength(10));
    expect(load[0].material, WasteMaterial.plastic);
    expect(load[1].material, WasteMaterial.metal);
    expect(load[2].material, WasteMaterial.paper);
  });
}
