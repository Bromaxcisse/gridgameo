import 'package:flutter_test/flutter_test.dart';
import 'package:the_oxygen_grid/models/sector_factory.dart';
import 'package:the_oxygen_grid/the_oxygen_grid.dart';

void main() {
  test('TheOxygenGrid can be instantiated', () {
    final game = TheOxygenGrid(sectorData: SectorFactory.getSector(1));
    expect(game, isNotNull);
  });

  test('All sectors can be created', () {
    for (int i = 1; i <= SectorFactory.totalSectors; i++) {
      final sector = SectorFactory.getSector(i);
      expect(sector.sector, i);
      expect(sector.grid.length, sector.rows);
      expect(sector.grid.first.length, sector.columns);
    }
  });
}
