/// Sortable materials in Sprint 1 (plastic / metal / paper).
enum WasteMaterial {
  plastic,
  metal,
  paper,
  mixed;

  String get label => switch (this) {
    WasteMaterial.plastic => 'Plastic',
    WasteMaterial.metal => 'Metal',
    WasteMaterial.paper => 'Paper',
    WasteMaterial.mixed => 'Mixed',
  };
}

/// One dump-pile item for drag-sort.
class SortItemData {
  const SortItemData({required this.id, required this.material});

  final String id;
  final WasteMaterial material;
}

/// Build a mixed truckload cycling plastic → metal → paper.
List<SortItemData> buildTruckload(int count, {String prefix = 'item'}) {
  const cycle = [
    WasteMaterial.plastic,
    WasteMaterial.metal,
    WasteMaterial.paper,
  ];
  return List.generate(
    count,
    (i) => SortItemData(id: '$prefix-$i', material: cycle[i % cycle.length]),
  );
}
