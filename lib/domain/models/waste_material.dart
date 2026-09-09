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
