/// EDSS (Expanded Disability Status Scale) Calculator.
///
/// Calculates the EDSS score based on 7 Functional System (FS) scores and an
/// Ambulation score, following the scoring table by Ludwig Kappos, MD
/// (University Hospital Basel) and the Neurostatus-EDSS™ standard
/// (Kurtzke, 1983).
///
/// Functional Systems (in Neurostatus-EDSS™ standard order):
///   1. Visual (Optic)         — raw 0-6, converted to 0-4 for EDSS calculation
///   2. Brainstem              — 0-5
///   3. Pyramidal              — 0-6
///   4. Cerebellar             — 0-5
///   5. Sensory                — 0-6
///   6. Bowel & Bladder        — raw 0-6, converted to 0-5 for EDSS calculation
///   7. Cerebral (Mental)      — 0-5
///   8. Ambulation             — 0-16 (determines EDSS ≥ 5.0 directly)
///
/// See also:
/// - [JavaScript reference implementation](https://github.com/atiweb/edss)
/// - [Neurostatus-EDSS™](https://www.neurostatus.net/)
class EdssCalculator {
  /// Default English field names for [calculateFromMap].
  ///
  /// These match the parameter names used in the JS reference implementation.
  static const Map<String, String> fieldsDefault = {
    'visual': 'visual_functions_score',
    'brainstem': 'brainstem_functions_score',
    'pyramidal': 'pyramidal_functions_score',
    'cerebellar': 'cerebellar_functions_score',
    'sensory': 'sensory_functions_score',
    'bowelBladder': 'bowel_and_bladder_functions_score',
    'cerebral': 'cerebral_functions_score',
    'ambulation': 'ambulation_score',
  };

  /// REDCap/REDONE.br Portuguese field names (legacy).
  ///
  /// Maps the Portuguese field names used in REDCap projects to the
  /// standard Functional System identifiers.
  static const Map<String, String> fieldsRedcapPt = {
    'visual': 'edss_func_visuais',
    'brainstem': 'edss_cap_func_tronco_cereb',
    'pyramidal': 'edss_cap_func_pirad',
    'cerebellar': 'edss_cap_func_cereb',
    'sensory': 'edss_cap_func_sensitivas',
    'bowelBladder': 'edss_func_vesicais_e_instestinais',
    'cerebral': 'edss_func_cerebrais',
    'ambulation': 'edss_func_demabulacao_incapacidade',
  };

  /// Calculate the EDSS score from individual Functional System scores.
  ///
  /// Parameter names match the JS reference: calculateEDSS(visualFunctionsScore,
  /// brainstemFunctionsScore, pyramidalFunctionsScore, cerebellarFunctionsScore,
  /// sensoryFunctionsScore, bowelAndBladderFunctionsScore, cerebralFunctionsScore,
  /// ambulationScore)
  ///
  /// Returns the calculated EDSS score as a String (e.g., '0', '1.5', '4', '6.5', '10').
  String calculate({
    required int visualFunctionsScore,
    required int brainstemFunctionsScore,
    required int pyramidalFunctionsScore,
    required int cerebellarFunctionsScore,
    required int sensoryFunctionsScore,
    required int bowelAndBladderFunctionsScore,
    required int cerebralFunctionsScore,
    required int ambulationScore,
  }) {
    // ─── Phase 1: Ambulation-driven EDSS (≥ 5.0) ───
    final ambulationEdss = _getAmbulationEdss(ambulationScore);
    if (ambulationEdss != null) return ambulationEdss;

    // ─── Phase 2: FS-driven EDSS (0 – 5.0) ───
    final convertedVisual = convertVisualScore(visualFunctionsScore);
    final convertedBowelBladder =
        convertBowelAndBladderScore(bowelAndBladderFunctionsScore);

    final functionalSystems = [
      convertedVisual,
      brainstemFunctionsScore,
      pyramidalFunctionsScore,
      cerebellarFunctionsScore,
      sensoryFunctionsScore,
      convertedBowelBladder,
      cerebralFunctionsScore,
    ];

    final maxResult = findMaxAndCount(functionalSystems);

    return _calculateFromFunctionalSystems(
      functionalSystems,
      maxResult.$1,
      maxResult.$2,
      ambulationScore,
    );
  }

  /// Calculate EDSS from a map using custom field mapping.
  ///
  /// By default uses English field names ([fieldsDefault]). You can pass
  /// [fieldsRedcapPt] for Portuguese REDCap field names, or your own mapping.
  ///
  /// [data] is a map with FS score values (values as strings or ints).
  /// [fieldMap] is the field name mapping (default: [fieldsDefault]).
  /// [suffix] is an optional suffix appended to field names (e.g., '_long').
  ///
  /// Returns the calculated EDSS score, or null if data is incomplete.
  String? calculateFromMap(
    Map<String, dynamic> data, {
    Map<String, String> fieldMap = fieldsDefault,
    String suffix = '',
  }) {
    final fields = {
      'visual': '${fieldMap['visual']}$suffix',
      'brainstem': '${fieldMap['brainstem']}$suffix',
      'pyramidal': '${fieldMap['pyramidal']}$suffix',
      'cerebellar': '${fieldMap['cerebellar']}$suffix',
      'sensory': '${fieldMap['sensory']}$suffix',
      'bowelBladder': '${fieldMap['bowelBladder']}$suffix',
      'cerebral': '${fieldMap['cerebral']}$suffix',
      'ambulation': '${fieldMap['ambulation']}$suffix',
    };

    final values = <String, int>{};
    for (final entry in fields.entries) {
      final rawValue = data[entry.value]?.toString() ?? '';
      if (rawValue.isEmpty) return null; // Incomplete data
      values[entry.key] = int.parse(rawValue);
    }

    return calculate(
      visualFunctionsScore: values['visual']!,
      brainstemFunctionsScore: values['brainstem']!,
      pyramidalFunctionsScore: values['pyramidal']!,
      cerebellarFunctionsScore: values['cerebellar']!,
      sensoryFunctionsScore: values['sensory']!,
      bowelAndBladderFunctionsScore: values['bowelBladder']!,
      cerebralFunctionsScore: values['cerebral']!,
      ambulationScore: values['ambulation']!,
    );
  }

  /// Convert the raw Visual (Optic) FS score to its adjusted value for EDSS.
  ///
  /// The Visual FS uses a 0-6 scale but is compressed for EDSS calculation:
  ///   0 → 0, 1 → 1, 2-3 → 2, 4-5 → 3, 6 → 4
  static int convertVisualScore(int rawScore) {
    if (rawScore == 6) return 4;
    if (rawScore >= 4) return 3;
    if (rawScore >= 2) return 2;
    return rawScore; // 0 or 1
  }

  /// Convert the raw Bowel & Bladder FS score to its adjusted value for EDSS.
  ///
  /// The Bowel & Bladder FS uses a 0-6 scale but is compressed for EDSS calculation:
  ///   0 → 0, 1 → 1, 2 → 2, 3-4 → 3, 5 → 4, 6 → 5
  static int convertBowelAndBladderScore(int rawScore) {
    if (rawScore == 6) return 5;
    if (rawScore == 5) return 4;
    if (rawScore >= 3) return 3;
    return rawScore; // 0, 1, or 2
  }

  /// Find the maximum value in a list and how many times it appears.
  ///
  /// Returns a record of (maxValue, count).
  static (int, int) findMaxAndCount(List<int> scores) {
    final max = scores.reduce((a, b) => a > b ? a : b);
    final count = scores.where((v) => v >= max).length;
    return (max, count);
  }

  /// Find the second-largest value in a list and how many times it appears.
  ///
  /// [max] is the maximum value to exclude.
  /// Returns a record of (secondMaxValue, count).
  static (int, int) findSecondMaxAndCount(List<int> scores, int max) {
    final filtered = scores.where((v) => v < max).toList();
    if (filtered.isEmpty) return (0, 0);

    final secondMax = filtered.reduce((a, b) => a > b ? a : b);
    final count = filtered.where((v) => v >= secondMax).length;
    return (secondMax, count);
  }

  /// Get the EDSS score determined directly by ambulation (for ambulationScore ≥ 3).
  ///
  /// Returns the EDSS score, or null if ambulation doesn't directly determine it.
  String? _getAmbulationEdss(int ambulationScore) {
    return switch (ambulationScore) {
      16 => '10',    // Death due to MS
      15 => '9.5',   // Totally helpless bed patient
      14 => '9',     // Helpless bed patient; can communicate and eat
      13 => '8.5',   // Restricted to bed; some use of arm(s)
      12 => '8',     // Restricted to bed/chair, out of bed most of day
      11 => '7.5',   // Wheelchair with help
      10 => '7',     // Wheelchair without help
      9 || 8 => '6.5',   // Bilateral assistance or limited walking
      7 || 6 || 5 => '6', // Unilateral/bilateral assistance ≥120m
      4 => '5.5',    // Walks 100-200m without help
      3 => '5',      // Walks 200-300m without help
      _ => null,     // FS-driven EDSS (ambulationScore 0-2)
    };
  }

  /// Calculate EDSS from FS scores when ambulation is 0-2 (Phase 2).
  String _calculateFromFunctionalSystems(
    List<int> functionalSystems,
    int maxValue,
    int maxCount,
    int ambulationScore,
  ) {
    // ── EDSS 5.0: FS-based ──
    if (maxValue >= 5) return '5';

    if (maxValue == 4 && maxCount >= 2) return '5';

    if (maxValue == 4 && maxCount == 1) {
      final (secondMax, secondCount) =
          findSecondMaxAndCount(functionalSystems, maxValue);

      if (secondMax == 3 && secondCount > 2) return '5';
      if (secondMax == 3 || secondMax == 2) return '4.5';
      if (ambulationScore < 2 && secondMax < 2) return '4';
    }

    // Check here because of ambulation score — the only case where it could go to 5
    if (maxValue == 3 && maxCount >= 6) return '5';

    // ── EDSS 4.5: Ambulation = 2 ──
    if (ambulationScore == 2) return '4.5';

    // ── EDSS 3.0 – 4.5: maxValue = 3 ──
    if (maxValue == 3) {
      if (maxCount == 5) return '4.5';

      if (maxCount >= 2) {
        if (maxCount == 2) {
          final (secondMax, _) =
              findSecondMaxAndCount(functionalSystems, maxValue);
          if (secondMax <= 1) return '3.5';
        }
        return '4';
      }

      // maxCount is 1
      final (secondMax, secondCount) =
          findSecondMaxAndCount(functionalSystems, maxValue);

      if (secondMax == 2) {
        if (secondCount >= 3) return '4';
        return '3.5';
      }

      // Second max is 0 or 1
      return '3';
    }

    // ── EDSS 2.0 – 4.0: maxValue = 2 ──
    if (maxValue == 2) {
      if (maxCount >= 6) return '4';
      if (maxCount == 5) return '3.5';
      if (maxCount == 3 || maxCount == 4) return '3';
      if (maxCount == 2) return '2.5';
      return '2';
    }

    // ── EDSS 2.0: Ambulation = 1 ──
    if (ambulationScore == 1) return '2';

    // ── EDSS 1.0 – 1.5: maxValue = 1 ──
    if (maxValue == 1) {
      if (maxCount >= 2) return '1.5';
      return '1';
    }

    // ── EDSS 0.0: All scores are 0 ──
    return '0';
  }
}
