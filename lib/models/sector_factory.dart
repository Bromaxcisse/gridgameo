import '../core/app_constants.dart';
import 'sector_data.dart';

// Shorthand aliases for grid readability.
const _ = GridEntity.empty;
const W = GridEntity.wall;
const D = GridEntity.droneStart;
const E = GridEntity.extractionPoint;
const S = GridEntity.sentryNode;
const C = GridEntity.corrosiveTile;
const X = GridEntity.decayingWall;

abstract final class SectorFactory {
  static SectorData getSector(int sector) {
    assert(sector >= 1 && sector <= totalSectors, 'Sector $sector not defined');
    return _sectors[sector - 1];
  }

  static int get totalSectors => _sectors.length;

  // ──────────────────────────────────────────────
  //  Sectors 1–5 : 5×5, 30 O2, Static Walls only
  // ──────────────────────────────────────────────

  static const _sectors = <SectorData>[
    // Sector 1 — Trivially simple (2 walls)
    SectorData(
      sector: 1,
      columns: 5,
      rows: 5,
      startingO2: 30,
      grid: [
        [_, _, _, _, E],
        [_, _, _, _, _],
        [_, _, W, _, _],
        [_, _, _, W, _],
        [D, _, _, _, _],
      ],
    ),

    // Sector 2 — A few more walls force a detour
    SectorData(
      sector: 2,
      columns: 5,
      rows: 5,
      startingO2: 30,
      grid: [
        [_, _, _, _, E],
        [_, W, _, _, _],
        [_, W, _, W, _],
        [_, _, _, W, _],
        [D, _, _, _, _],
      ],
    ),

    // Sector 3 — Vertical wall corridor
    SectorData(
      sector: 3,
      columns: 5,
      rows: 5,
      startingO2: 30,
      grid: [
        [_, _, W, _, E],
        [_, _, W, _, _],
        [_, _, _, _, W],
        [_, W, _, _, _],
        [D, _, W, _, _],
      ],
    ),

    // Sector 4 — Diagonal wall chain
    SectorData(
      sector: 4,
      columns: 5,
      rows: 5,
      startingO2: 30,
      grid: [
        [D, _, W, _, _],
        [_, W, _, _, _],
        [_, _, _, W, _],
        [_, _, W, _, _],
        [_, W, _, _, E],
      ],
    ),

    // Sector 5 — Deliberate path planning required
    SectorData(
      sector: 5,
      columns: 5,
      rows: 5,
      startingO2: 30,
      grid: [
        [D, _, W, _, _],
        [W, _, W, _, W],
        [_, _, _, _, W],
        [W, _, W, _, _],
        [_, _, W, _, E],
      ],
    ),

    // ──────────────────────────────────────────────
    //  Sectors 6–15 : 7×7, 40 O2, Sentry Nodes
    // ──────────────────────────────────────────────

    // Sector 6 — Single sentry in the center
    SectorData(
      sector: 6,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [D, _, _, _, _, _, _],
        [_, _, W, _, _, W, _],
        [_, _, _, _, _, _, _],
        [_, W, _, S, _, W, _],
        [_, _, _, _, _, _, _],
        [_, W, _, _, W, _, _],
        [_, _, _, _, _, _, E],
      ],
    ),

    // Sector 7 — Twin sentries guarding the middle row
    SectorData(
      sector: 7,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [_, _, _, W, _, _, E],
        [_, W, _, _, _, W, _],
        [_, _, _, _, _, _, _],
        [W, _, S, _, S, _, W],
        [_, _, _, _, _, _, _],
        [_, W, _, _, _, W, _],
        [D, _, _, W, _, _, _],
      ],
    ),

    // Sector 8 — Staggered sentries with wall funnels
    SectorData(
      sector: 8,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [D, _, _, _, W, _, _],
        [_, W, _, _, _, _, W],
        [_, _, _, S, _, _, _],
        [_, _, W, _, W, _, _],
        [_, _, _, _, _, S, _],
        [W, _, _, _, _, W, _],
        [_, _, W, _, _, _, E],
      ],
    ),

    // Sector 9 — Sentries with tight corridors
    SectorData(
      sector: 9,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [_, _, W, _, _, _, E],
        [_, _, _, _, W, _, _],
        [W, _, S, _, _, _, W],
        [_, _, _, W, _, _, _],
        [W, _, _, _, S, _, _],
        [_, _, W, _, _, _, W],
        [D, _, _, _, W, _, _],
      ],
    ),

    // Sector 10 — Three sentries, complex navigation
    SectorData(
      sector: 10,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [D, _, _, W, _, W, _],
        [_, W, _, _, _, _, _],
        [_, _, S, _, W, _, _],
        [W, _, _, _, _, S, _],
        [_, _, W, _, _, _, W],
        [_, S, _, _, W, _, _],
        [_, _, _, W, _, _, E],
      ],
    ),

    // Sector 11 — Sentry corridor gauntlet
    SectorData(
      sector: 11,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [D, _, _, W, _, _, _],
        [_, W, _, _, _, _, W],
        [_, _, S, _, _, _, _],
        [_, W, _, _, W, _, _],
        [_, _, _, _, S, _, _],
        [_, _, W, _, _, _, _],
        [W, _, _, _, _, W, E],
      ],
    ),

    // Sector 12 — Sentries flanking a narrow passage
    SectorData(
      sector: 12,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [_, _, W, _, W, _, E],
        [_, _, _, _, _, _, _],
        [W, _, _, S, _, _, W],
        [_, _, W, _, W, _, _],
        [_, _, _, _, _, _, _],
        [W, _, S, _, _, _, W],
        [D, _, _, _, W, _, _],
      ],
    ),

    // Sector 13 — Three sentries in zigzag
    SectorData(
      sector: 13,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [D, _, W, _, _, _, _],
        [_, _, _, _, W, _, _],
        [_, S, _, _, _, _, W],
        [_, _, _, W, _, _, _],
        [W, _, _, _, _, S, _],
        [_, _, W, _, _, _, _],
        [_, _, _, S, _, _, E],
      ],
    ),

    // Sector 14 — Four sentries, tight grid
    SectorData(
      sector: 14,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [_, _, _, _, _, _, E],
        [_, W, _, S, _, W, _],
        [_, _, _, _, _, _, _],
        [_, S, _, W, _, S, _],
        [_, _, _, _, _, _, _],
        [_, W, _, S, _, W, _],
        [D, _, _, _, _, _, _],
      ],
    ),

    // Sector 15 — Dense sentry maze
    SectorData(
      sector: 15,
      columns: 7,
      rows: 7,
      startingO2: 40,
      grid: [
        [D, _, _, W, _, _, _],
        [_, W, _, _, _, S, _],
        [_, _, _, W, _, _, W],
        [W, _, S, _, _, _, _],
        [_, _, _, _, W, _, _],
        [_, S, _, _, _, S, _],
        [_, _, W, _, _, _, E],
      ],
    ),

    // ──────────────────────────────────────────────
    //  Sectors 16–25 : 7×9, 50 O2, Corrosive Tiles
    // ──────────────────────────────────────────────

    // Sector 16 — Introduction to corrosive tiles
    SectorData(
      sector: 16,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [D, _, _, _, _, _, _],
        [_, _, W, _, _, W, _],
        [_, _, _, _, _, _, _],
        [_, W, _, C, _, _, _],
        [_, _, _, _, _, W, _],
        [_, _, C, _, _, _, _],
        [_, W, _, _, W, _, _],
        [_, _, _, _, _, _, _],
        [_, _, _, _, _, _, E],
      ],
    ),

    // Sector 17 — Corrosive shortcut vs safe detour
    SectorData(
      sector: 17,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [_, _, _, _, W, _, E],
        [_, _, W, _, _, _, _],
        [_, _, _, _, _, W, _],
        [_, W, C, C, _, _, _],
        [_, _, _, _, _, _, W],
        [_, _, _, W, _, _, _],
        [W, _, _, _, _, W, _],
        [_, _, W, _, _, _, _],
        [D, _, _, _, _, _, _],
      ],
    ),

    // Sector 18 — Corrosive field with wall channels
    SectorData(
      sector: 18,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [D, _, _, W, _, _, _],
        [_, W, _, _, _, _, W],
        [_, _, C, _, C, _, _],
        [_, _, _, W, _, _, _],
        [W, _, _, _, _, _, W],
        [_, _, C, _, _, _, _],
        [_, _, _, _, W, _, _],
        [_, W, _, _, _, C, _],
        [_, _, _, W, _, _, E],
      ],
    ),

    // Sector 19 — Sentries and corrosive tiles combined
    SectorData(
      sector: 19,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [_, _, W, _, _, _, E],
        [_, _, _, _, _, W, _],
        [_, S, _, _, _, _, _],
        [_, _, _, W, _, _, _],
        [_, _, C, _, C, _, W],
        [W, _, _, _, _, _, _],
        [_, _, _, S, _, _, _],
        [_, W, _, _, _, _, _],
        [D, _, _, _, W, _, _],
      ],
    ),

    // Sector 20 — Corrosive corridor
    SectorData(
      sector: 20,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [D, _, _, _, _, _, _],
        [_, W, _, _, W, _, _],
        [_, _, C, _, _, _, W],
        [_, _, _, _, _, C, _],
        [W, _, _, W, _, _, _],
        [_, _, C, _, _, _, _],
        [_, _, _, _, W, _, _],
        [_, W, _, C, _, _, _],
        [_, _, _, _, _, W, E],
      ],
    ),

    // Sector 21 — Sentry patrol through corrosive zone
    SectorData(
      sector: 21,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [_, _, _, _, _, _, E],
        [_, _, W, _, _, _, _],
        [_, _, _, S, _, W, _],
        [_, W, _, _, _, _, _],
        [_, _, C, C, C, _, W],
        [_, _, _, _, _, _, _],
        [W, _, S, _, _, _, _],
        [_, _, _, _, W, _, _],
        [D, _, _, _, _, _, _],
      ],
    ),

    // Sector 22 — Dense corrosive with narrow safe path
    SectorData(
      sector: 22,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [D, _, _, W, _, _, _],
        [_, _, C, _, _, _, W],
        [_, _, _, _, C, _, _],
        [W, _, _, _, _, _, _],
        [_, C, _, W, _, C, _],
        [_, _, _, _, _, _, W],
        [_, _, C, _, _, _, _],
        [_, W, _, _, C, _, _],
        [_, _, _, _, _, _, E],
      ],
    ),

    // Sector 23 — Two sentries with corrosive maze
    SectorData(
      sector: 23,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [_, _, W, _, _, _, E],
        [_, _, _, _, C, _, _],
        [_, S, _, W, _, _, _],
        [_, _, _, _, _, C, W],
        [_, _, C, _, _, _, _],
        [W, _, _, _, W, _, _],
        [_, _, _, C, _, S, _],
        [_, _, W, _, _, _, _],
        [D, _, _, _, _, _, _],
      ],
    ),

    // Sector 24 — Heavy corrosive with sentry gauntlet
    SectorData(
      sector: 24,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [D, _, _, _, _, _, _],
        [_, C, _, W, _, _, _],
        [_, _, _, _, _, S, _],
        [_, _, W, _, C, _, W],
        [_, _, _, _, _, _, _],
        [W, _, S, _, _, _, _],
        [_, _, _, C, _, W, _],
        [_, _, _, _, _, _, _],
        [_, _, W, _, C, _, E],
      ],
    ),

    // Sector 25 — Corrosive gauntlet finale
    SectorData(
      sector: 25,
      columns: 7,
      rows: 9,
      startingO2: 50,
      grid: [
        [_, _, _, W, _, _, E],
        [_, C, _, _, _, C, _],
        [_, _, S, _, _, _, W],
        [W, _, _, C, _, _, _],
        [_, _, _, _, W, _, _],
        [_, C, _, _, _, S, _],
        [_, _, W, _, C, _, _],
        [_, _, _, _, _, _, W],
        [D, _, _, _, _, _, _],
      ],
    ),

    // ──────────────────────────────────────────────
    //  Sectors 26–40 : 9×11, 65 O2, Decaying Walls
    // ──────────────────────────────────────────────

    // Sector 26 — Introduction to decaying walls
    SectorData(
      sector: 26,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, W, _, _, _, W, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, W, _, _, X, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, W, _, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, W, _, _, X, _, _, _, _],
        [_, _, _, _, _, _, W, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 27 — Decaying walls blocking the direct path
    SectorData(
      sector: 27,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, X, _, W, _, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, W, _],
        [_, _, _, _, _, X, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, _, _, W, _, _],
        [_, W, _, X, _, _, _, _, _],
        [_, _, _, _, _, _, _, W, _],
        [D, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 28 — Decaying walls with sentries
    SectorData(
      sector: 28,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, _, _],
        [_, _, X, _, _, _, S, _, _],
        [_, _, _, _, W, _, _, _, _],
        [_, W, _, _, _, _, _, W, _],
        [_, _, _, _, X, _, _, _, _],
        [_, _, _, W, _, _, _, _, _],
        [_, _, S, _, _, _, X, _, _],
        [_, _, _, _, _, W, _, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 29 — Timing challenge with decaying corridors
    SectorData(
      sector: 29,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, _, _, W, _, _, _, _],
        [_, _, W, _, _, _, _, W, _],
        [_, _, _, _, _, X, _, _, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, X, _, _, W, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [D, _, _, _, _, _, W, _, _],
      ],
    ),

    // Sector 30 — Decaying walls and corrosive tiles
    SectorData(
      sector: 30,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, _, _],
        [_, _, C, _, _, _, X, _, _],
        [_, _, _, _, W, _, _, _, _],
        [_, W, _, _, _, _, _, C, _],
        [_, _, _, X, _, _, _, _, _],
        [_, _, _, _, _, W, _, _, _],
        [_, _, C, _, _, _, _, _, _],
        [_, _, _, _, _, _, X, _, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 31 — Multi-decaying wall corridor
    SectorData(
      sector: 31,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, W, _, X, _, _, W, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, X, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, W, _],
        [_, _, _, X, _, _, _, _, _],
        [D, _, _, _, _, W, _, _, _],
      ],
    ),

    // Sector 32 — Sentries patrolling near decaying walls
    SectorData(
      sector: 32,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, W, _, _, _],
        [_, _, S, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, W, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, S, _, _],
        [_, _, _, W, _, _, _, _, _],
        [_, _, _, _, _, X, _, _, _],
        [_, _, X, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 33 — Dense decaying wall maze
    SectorData(
      sector: 33,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, _, W, _, _, _, _, _],
        [_, _, X, _, _, _, X, _, _],
        [_, _, _, _, W, _, _, _, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, X, _, X, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, _, _],
        [_, _, _, _, _, _, W, _, _],
        [D, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 34 — All hazards combined
    SectorData(
      sector: 34,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, _, _, W, _, _, _, _],
        [_, _, C, _, _, _, S, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, W, _, X, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, C, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, _, _],
        [_, _, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 35 — Decaying wall timing gauntlet
    SectorData(
      sector: 35,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, W, _, _],
        [_, _, W, _, X, _, _, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, X, _, W, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, X, _, _, _, _, _],
        [_, _, _, _, _, _, W, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, W, _, X, _, _, _, _],
        [D, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 36 — Sentry and decaying wall pinch points
    SectorData(
      sector: 36,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, S, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, X, _, _, _, X, _, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, _, _, S, _, _, _, _],
        [_, _, _, _, _, _, _, W, _],
        [_, _, _, X, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 37 — Corrosive and decaying wall maze
    SectorData(
      sector: 37,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, W, _, _, _],
        [_, _, C, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, W, _],
        [_, W, _, _, _, _, C, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, X, _, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, X, _, _, _, _, W, _],
        [_, _, _, _, C, _, _, _, _],
        [D, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 38 — Triple threat convergence
    SectorData(
      sector: 38,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, _, _],
        [_, _, S, _, _, _, C, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, X, _, _, W, _],
        [_, W, _, _, _, _, _, _, _],
        [_, _, C, _, _, _, S, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, X, _, _, _, _, _],
        [_, _, _, _, _, W, _, _, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 39 — Decaying wall labyrinth
    SectorData(
      sector: 39,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [_, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, _, _, _],
        [_, _, X, _, W, _, X, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, W, _, X, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, X, _, _, _],
        [_, _, W, _, _, _, _, _, _],
        [_, _, _, _, X, _, W, _, _],
        [_, _, _, _, _, _, _, _, _],
        [D, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 40 — Decaying wall finale
    SectorData(
      sector: 40,
      columns: 9,
      rows: 11,
      startingO2: 65,
      grid: [
        [D, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, W, _],
        [_, _, S, _, X, _, _, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, W, _, _, _, X, _, _, _],
        [_, _, _, C, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, X, _, _, _, S, _, _],
        [_, _, _, _, _, _, _, _, _],
        [_, _, _, _, C, _, _, _, _],
        [_, _, _, _, _, _, _, _, E],
      ],
    ),

    // ──────────────────────────────────────────────
    //  Sectors 41–50 : 10×12, 70 O2, Hunter Wakes
    //  (Sentry Nodes with 20% faster patrol speed)
    // ──────────────────────────────────────────────

    // Sector 41 — Hunter introduction
    SectorData(
      sector: 41,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [D, _, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, _, _, _],
        [_, _, _, _, _, _, S, _, _, _],
        [_, _, W, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, W, _, _, _, W, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, W, _, _, _, _, _],
        [_, _, S, _, _, _, _, W, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 42 — Hunters with corrosive zones
    SectorData(
      sector: 42,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [_, _, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, W, _, _, _],
        [_, _, C, _, _, _, _, _, _, _],
        [_, _, _, _, S, _, _, _, W, _],
        [_, W, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, C, _, _, _],
        [_, _, _, W, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [_, _, _, _, _, S, _, _, _, _],
        [_, W, _, _, _, _, _, _, _, _],
        [_, _, _, C, _, _, _, _, _, _],
        [D, _, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 43 — Hunters with decaying walls
    SectorData(
      sector: 43,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [D, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, W, _, _, _, _],
        [_, _, _, X, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, S, _, _],
        [_, W, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, X, _, _, W, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, S, _, _, _, _, _, _, _],
        [_, _, _, _, W, _, _, _, _, _],
        [_, _, _, _, _, _, X, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 44 — Triple hunter patrol
    SectorData(
      sector: 44,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [_, _, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, S, _, _, W, _, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [_, W, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, S, _, _, _],
        [_, _, _, _, W, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, W, _, _],
        [_, _, S, _, _, _, _, _, _, _],
        [_, _, _, _, W, _, _, _, _, _],
        [D, _, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 45 — Hunters and corrosive gauntlet
    SectorData(
      sector: 45,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [D, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, W, _, _, _, _, _],
        [_, _, C, _, _, _, S, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [_, W, _, _, _, _, _, _, _, _],
        [_, _, _, _, C, _, _, _, _, _],
        [_, _, _, _, _, _, _, W, _, _],
        [_, _, S, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, C, _, _, _],
        [_, _, _, W, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 46 — Hunters with decaying wall maze
    SectorData(
      sector: 46,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [_, _, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, _, W, _, _],
        [_, _, _, X, _, _, _, _, _, _],
        [_, _, _, _, _, S, _, _, _, _],
        [_, W, _, _, _, _, _, _, W, _],
        [_, _, _, _, X, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, S, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, X, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _, _],
        [D, _, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 47 — All hazards with hunters
    SectorData(
      sector: 47,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [D, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, C, _, _, W, _, _, _, _],
        [_, _, _, _, _, _, _, S, _, _],
        [_, W, _, _, X, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, C, _, _, _],
        [_, _, _, W, _, _, _, _, _, _],
        [_, _, S, _, _, _, _, X, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, W, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 48 — Hunter convergence zone
    SectorData(
      sector: 48,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [_, _, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, S, _, _, W, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, W, _, _, _, _, _, _, W, _],
        [_, _, _, _, _, S, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, S, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, C, _, _, X, _, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [D, _, _, _, _, _, _, _, _, _],
      ],
    ),

    // Sector 49 — Penultimate challenge
    SectorData(
      sector: 49,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [D, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, W, _, _, _, _],
        [_, _, S, _, _, _, _, C, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, W, _, _, X, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, S, _, _, _],
        [_, _, _, W, _, _, _, _, _, _],
        [_, _, _, _, _, X, _, _, _, _],
        [_, _, C, _, _, _, _, _, W, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, _, _, _, _, _, _, E],
      ],
    ),

    // Sector 50 — Final sector
    SectorData(
      sector: 50,
      columns: 10,
      rows: 12,
      startingO2: 70,
      grid: [
        [_, _, _, _, _, _, _, _, _, E],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, S, _, _, W, _, X, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, W, _, _, C, _, _, _, W, _],
        [_, _, _, _, _, _, S, _, _, _],
        [_, _, _, _, _, _, _, _, _, _],
        [_, _, _, W, _, _, _, _, _, _],
        [_, _, X, _, _, _, _, C, _, _],
        [_, _, _, _, _, S, _, _, _, _],
        [_, _, _, _, _, _, _, _, W, _],
        [D, _, _, _, _, _, _, _, _, _],
      ],
    ),
  ];
}
