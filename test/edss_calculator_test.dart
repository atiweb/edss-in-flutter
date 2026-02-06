import 'package:edss/edss.dart';
import 'package:test/test.dart';

void main() {
  late EdssCalculator calculator;

  setUp(() {
    calculator = EdssCalculator();
  });

  // ─── Visual Score Conversion ─────────────────────────────────

  test('Visual score conversion 0-6 to 0-4', () {
    // 0 → 0, 1 → 1, 2-3 → 2, 4-5 → 3, 6 → 4
    expect(EdssCalculator.convertVisualScore(0), 0);
    expect(EdssCalculator.convertVisualScore(1), 1);
    expect(EdssCalculator.convertVisualScore(2), 2);
    expect(EdssCalculator.convertVisualScore(3), 2);
    expect(EdssCalculator.convertVisualScore(4), 3);
    expect(EdssCalculator.convertVisualScore(5), 3);
    expect(EdssCalculator.convertVisualScore(6), 4);
  });

  // ─── Bowel & Bladder Score Conversion ────────────────────────

  test('Bowel and Bladder score conversion 0-6 to 0-5', () {
    // 0 → 0, 1 → 1, 2 → 2, 3-4 → 3, 5 → 4, 6 → 5
    expect(EdssCalculator.convertBowelAndBladderScore(0), 0);
    expect(EdssCalculator.convertBowelAndBladderScore(1), 1);
    expect(EdssCalculator.convertBowelAndBladderScore(2), 2);
    expect(EdssCalculator.convertBowelAndBladderScore(3), 3);
    expect(EdssCalculator.convertBowelAndBladderScore(4), 3);
    expect(EdssCalculator.convertBowelAndBladderScore(5), 4);
    expect(EdssCalculator.convertBowelAndBladderScore(6), 5);
  });

  // ─── Helper Functions ────────────────────────────────────────

  test('findMaxAndCount returns correct max and count', () {
    expect(EdssCalculator.findMaxAndCount([1, 3, 2, 3, 0]), (3, 2));
    expect(EdssCalculator.findMaxAndCount([1, 5, 2, 3, 0]), (5, 1));
    expect(EdssCalculator.findMaxAndCount([0, 0, 0, 0, 0, 0, 0]), (0, 7));
  });

  test('findSecondMaxAndCount returns correct second max and count', () {
    expect(EdssCalculator.findSecondMaxAndCount([1, 3, 2, 3, 0], 3), (2, 1));
    expect(EdssCalculator.findSecondMaxAndCount([1, 5, 3, 3, 0], 5), (3, 2));
    expect(EdssCalculator.findSecondMaxAndCount([3, 3, 3], 3), (0, 0));
  });

  // ─── calculateFromMap ────────────────────────────────────────

  test('calculateFromMap returns null on empty data', () {
    expect(calculator.calculateFromMap({}), isNull);
  });

  test('calculateFromMap returns null on incomplete data', () {
    expect(
      calculator.calculateFromMap({
        'visual_functions_score': '0',
        'brainstem_functions_score': '0',
      }),
      isNull,
    );
  });

  test('calculateFromMap with default English fields', () {
    final data = {
      'visual_functions_score': '1',
      'brainstem_functions_score': '2',
      'pyramidal_functions_score': '1',
      'cerebellar_functions_score': '3',
      'sensory_functions_score': '1',
      'bowel_and_bladder_functions_score': '4',
      'cerebral_functions_score': '2',
      'ambulation_score': '1',
    };
    expect(calculator.calculateFromMap(data), '4');
  });

  test('calculateFromMap with REDCap Portuguese fields', () {
    final data = {
      'edss_func_visuais': '1',
      'edss_cap_func_tronco_cereb': '2',
      'edss_cap_func_pirad': '1',
      'edss_cap_func_cereb': '3',
      'edss_cap_func_sensitivas': '1',
      'edss_func_vesicais_e_instestinais': '4',
      'edss_func_cerebrais': '2',
      'edss_func_demabulacao_incapacidade': '1',
    };
    expect(
      calculator.calculateFromMap(data,
          fieldMap: EdssCalculator.fieldsRedcapPt),
      '4',
    );
  });

  test('calculateFromMap with suffix', () {
    final data = {
      'visual_functions_score_long': '0',
      'brainstem_functions_score_long': '0',
      'pyramidal_functions_score_long': '0',
      'cerebellar_functions_score_long': '0',
      'sensory_functions_score_long': '0',
      'bowel_and_bladder_functions_score_long': '0',
      'cerebral_functions_score_long': '0',
      'ambulation_score_long': '0',
    };
    expect(calculator.calculateFromMap(data, suffix: '_long'), '0');
  });

  test('calculateFromMap with REDCap suffix', () {
    final data = {
      'edss_func_visuais_long': '0',
      'edss_cap_func_tronco_cereb_long': '0',
      'edss_cap_func_pirad_long': '0',
      'edss_cap_func_cereb_long': '0',
      'edss_cap_func_sensitivas_long': '0',
      'edss_func_vesicais_e_instestinais_long': '0',
      'edss_func_cerebrais_long': '0',
      'edss_func_demabulacao_incapacidade_long': '0',
    };
    expect(
      calculator.calculateFromMap(data,
          fieldMap: EdssCalculator.fieldsRedcapPt, suffix: '_long'),
      '0',
    );
  });

  test('calculateFromMap with custom field mapping', () {
    final customFields = {
      'visual': 'fs_visual',
      'brainstem': 'fs_brainstem',
      'pyramidal': 'fs_pyramidal',
      'cerebellar': 'fs_cerebellar',
      'sensory': 'fs_sensory',
      'bowelBladder': 'fs_bowel_bladder',
      'cerebral': 'fs_cerebral',
      'ambulation': 'fs_ambulation',
    };
    final data = {
      'fs_visual': '0',
      'fs_brainstem': '0',
      'fs_pyramidal': '2',
      'fs_cerebellar': '0',
      'fs_sensory': '0',
      'fs_bowel_bladder': '0',
      'fs_cerebral': '2',
      'fs_ambulation': '0',
    };
    expect(calculator.calculateFromMap(data, fieldMap: customFields), '2.5');
  });

  // ─── EDSS Calculation (parameterized) ────────────────────────

  // Format: [Visual(raw), Brainstem, Pyramidal, Cerebellar, Sensory, BowelBladder(raw), Cerebral, Ambulation, Expected]
  final edssTestCases = <String, List<dynamic>>{
    // ── EDSS 0 ──
    'All zeros → 0': [0, 0, 0, 0, 0, 0, 0, 0, '0'],

    // ── EDSS 1.0 ──
    'One FS=1 (Pyramidal) → 1': [0, 0, 1, 0, 0, 0, 0, 0, '1'],
    'One FS=1 (BB raw=1) → 1': [0, 0, 0, 0, 0, 1, 0, 0, '1'],
    'One FS=1 (Cerebellar) → 1': [0, 0, 0, 1, 0, 0, 0, 0, '1'],
    'Visual raw=1 → conv=1 → 1': [1, 0, 0, 0, 0, 0, 0, 0, '1'],

    // ── EDSS 1.5 ──
    'Two FS=1 → 1.5': [0, 1, 1, 0, 0, 0, 0, 0, '1.5'],
    'Seven FS=1 → 1.5': [1, 1, 1, 1, 1, 1, 1, 0, '1.5'],

    // ── EDSS 2.0 ──
    'One FS=2 → 2': [0, 0, 2, 0, 0, 0, 0, 0, '2'],
    'Amb=1 all FS≤1 → 2': [0, 0, 0, 0, 0, 0, 0, 1, '2'],
    'Amb=1 seven FS=1 → 2': [1, 1, 1, 1, 1, 1, 1, 1, '2'],
    'Visual raw=2 → conv=2 → 2': [2, 0, 0, 0, 0, 0, 0, 0, '2'],
    'Visual raw=3 → conv=2 → 2': [3, 0, 0, 0, 0, 0, 0, 0, '2'],
    'BB raw=2 → conv=2 → 2': [0, 0, 0, 0, 0, 2, 0, 0, '2'],

    // ── EDSS 2.5 ──
    'Two FS=2 → 2.5': [0, 0, 2, 2, 0, 0, 0, 0, '2.5'],
    'Vis raw=2 + BS=2 → 2.5': [2, 2, 0, 0, 0, 0, 0, 0, '2.5'],

    // ── EDSS 3.0 ──
    'Three FS=2 → 3': [0, 0, 2, 2, 2, 0, 0, 0, '3'],
    'Four FS=2 → 3': [0, 0, 2, 2, 2, 2, 0, 0, '3'],
    'One FS=3 → 3': [0, 3, 0, 0, 0, 0, 0, 0, '3'],
    'One FS=3 rest=1 → 3': [1, 3, 1, 1, 1, 1, 1, 0, '3'],
    'BB raw=3 → conv=3 → 3': [0, 0, 0, 0, 0, 3, 0, 0, '3'],
    'BB raw=4 → conv=3 → 3': [0, 0, 0, 0, 0, 4, 0, 0, '3'],
    'Visual raw=4 → conv=3 → 3': [4, 0, 0, 0, 0, 0, 0, 0, '3'],
    'Visual raw=5 → conv=3 → 3': [5, 0, 0, 0, 0, 0, 0, 0, '3'],

    // ── EDSS 3.5 ──
    'Five FS=2 → 3.5': [2, 2, 2, 2, 2, 0, 0, 0, '3.5'],
    '1×FS=3 + 1×FS=2 → 3.5': [0, 0, 3, 2, 0, 0, 0, 0, '3.5'],
    '1×FS=3 + Vis raw=2 → 3.5': [2, 0, 0, 0, 0, 0, 3, 0, '3.5'],
    '2×FS=3 secondMax≤1 → 3.5': [0, 0, 0, 3, 0, 0, 3, 0, '3.5'],
    '2×FS=3 + 1×FS=1 → 3.5': [0, 0, 0, 3, 1, 0, 3, 0, '3.5'],

    // ── EDSS 4.0 ──
    'Six FS=2 → 4': [2, 2, 2, 2, 2, 2, 0, 0, '4'],
    'Seven FS=2 → 4': [2, 2, 2, 2, 2, 2, 2, 0, '4'],
    '1×FS=4 rest=0 → 4': [0, 0, 4, 0, 0, 0, 0, 0, '4'],
    '1×FS=4 rest=1 → 4': [1, 1, 1, 1, 1, 1, 4, 0, '4'],
    '2×FS=3 + 2×FS=2 → 4': [0, 0, 0, 3, 2, 0, 3, 0, '4'],
    '4×FS=3 → 4': [2, 3, 3, 3, 2, 2, 3, 0, '4'],
    '1×FS=3 + 3×FS=2 → 4': [2, 2, 2, 0, 0, 0, 3, 0, '4'],
    'Visual raw=6 → conv=4 → 4': [6, 0, 0, 0, 0, 0, 0, 0, '4'],
    'BB raw=5 → conv=4 → 4': [0, 0, 0, 0, 0, 5, 0, 0, '4'],

    // ── EDSS 4.5 ──
    'Amb=2 → 4.5': [0, 0, 0, 0, 0, 0, 0, 2, '4.5'],
    '1×FS=4 + 1×FS=3 → 4.5': [0, 0, 4, 3, 0, 0, 0, 0, '4.5'],
    '1×FS=4 + 1×FS=2 → 4.5': [0, 2, 0, 0, 0, 0, 4, 0, '4.5'],
    '1×FS=4 + 2×FS=3 → 4.5': [0, 4, 3, 3, 0, 0, 0, 0, '4.5'],
    '5×FS=3 → 4.5': [1, 3, 3, 3, 3, 1, 3, 0, '4.5'],
    'Vis raw=5 conv=3 Amb=2 → 4.5': [5, 1, 1, 1, 1, 1, 1, 2, '4.5'],
    '1×FS=4 Amb=2 → 4.5': [0, 0, 0, 0, 0, 0, 4, 2, '4.5'],

    // ── EDSS 5.0 ──
    'Amb=3 → 5': [0, 0, 0, 0, 0, 0, 0, 3, '5'],
    '2×FS=4 → 5': [0, 0, 4, 4, 0, 0, 0, 0, '5'],
    'BS=5 → 5': [0, 5, 0, 0, 0, 0, 0, 0, '5'],
    'Pyr=5 → 5': [0, 0, 5, 0, 0, 0, 0, 0, '5'],
    'Sen=5 → 5': [0, 0, 0, 0, 5, 0, 0, 0, '5'],
    'BB raw=6 → conv=5 → 5': [0, 0, 0, 0, 0, 6, 0, 0, '5'],
    '6×FS=3 → 5': [4, 3, 3, 3, 3, 3, 3, 0, '5'],
    '1×FS=4 + 3×FS=3 → 5': [1, 4, 3, 3, 3, 1, 1, 0, '5'],

    // ── EDSS 5.5 ──
    'Amb=4 → 5.5': [0, 0, 0, 0, 0, 0, 0, 4, '5.5'],

    // ── EDSS 6.0 ──
    'Amb=5 → 6': [0, 0, 0, 0, 0, 0, 0, 5, '6'],
    'Amb=6 → 6': [0, 0, 0, 0, 0, 0, 0, 6, '6'],
    'Amb=7 → 6': [0, 0, 0, 0, 0, 0, 0, 7, '6'],

    // ── EDSS 6.5 ──
    'Amb=8 → 6.5': [0, 0, 0, 0, 0, 0, 0, 8, '6.5'],
    'Amb=9 → 6.5': [0, 0, 0, 0, 0, 0, 0, 9, '6.5'],

    // ── EDSS 7.0 – 10.0 ──
    'Amb=10 → 7': [0, 0, 0, 0, 0, 0, 0, 10, '7'],
    'Amb=11 → 7.5': [0, 0, 0, 0, 0, 0, 0, 11, '7.5'],
    'Amb=12 → 8': [0, 0, 0, 0, 0, 0, 0, 12, '8'],
    'Amb=13 → 8.5': [0, 0, 0, 0, 0, 0, 0, 13, '8.5'],
    'Amb=14 → 9': [0, 0, 0, 0, 0, 0, 0, 14, '9'],
    'Amb=15 → 9.5': [0, 0, 0, 0, 0, 0, 0, 15, '9.5'],
    'Amb=16 → 10': [0, 0, 0, 0, 0, 0, 0, 16, '10'],

    // ── Reference example from JS repo ──
    'Ref: calculateEDSS(1,2,1,3,1,4,2,1) → 4': [1, 2, 1, 3, 1, 4, 2, 1, '4'],
  };

  for (final entry in edssTestCases.entries) {
    test('EDSS: ${entry.key}', () {
      final c = entry.value;
      final result = calculator.calculate(
        visualFunctionsScore: c[0] as int,
        brainstemFunctionsScore: c[1] as int,
        pyramidalFunctionsScore: c[2] as int,
        cerebellarFunctionsScore: c[3] as int,
        sensoryFunctionsScore: c[4] as int,
        bowelAndBladderFunctionsScore: c[5] as int,
        cerebralFunctionsScore: c[6] as int,
        ambulationScore: c[7] as int,
      );
      expect(
        result,
        c[8] as String,
        reason:
            'EDSS mismatch for Visual=${c[0]} Brainstem=${c[1]} Pyramidal=${c[2]} '
            'Cerebellar=${c[3]} Sensory=${c[4]} BowelBladder=${c[5]} '
            'Cerebral=${c[6]} Ambulation=${c[7]}: expected ${c[8]}, got $result',
      );
    });
  }
}
