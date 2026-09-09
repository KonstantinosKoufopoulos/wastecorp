import 'package:flutter_test/flutter_test.dart';

import 'package:waste_corp/domain/economy/economy.dart';
import 'package:waste_corp/domain/contracts/contracts.dart';

void main() {
  test('tutorial economy constants are set', () {
    expect(kPlasticPressPayout, greaterThan(0));
    expect(kWorkerHireCost, lessThanOrEqualTo(kPlasticPressPayout));
  });

  test('tutorial contract has three loads', () {
    expect(kTutorialContract.loadsRequired, 3);
    expect(kTutorialContract.districtName, isNotEmpty);
  });
}
