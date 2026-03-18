class SectorData {
  final int sector;
  final int columns;
  final int rows;
  final int startingO2;
  final List<List<int>> grid;

  const SectorData({
    required this.sector,
    required this.columns,
    required this.rows,
    required this.startingO2,
    required this.grid,
  });
}
