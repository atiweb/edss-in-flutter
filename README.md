# EDSS Calculator for Flutter/Dart

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Flutter/Dart implementation of the **Expanded Disability Status Scale (EDSS)** calculator, based on the scoring table by Ludwig Kappos, MD (University Hospital Basel) and the Neurostatus-EDSS™ standard (Kurtzke, 1983).

This library calculates the EDSS score from 7 Functional System (FS) scores and an Ambulation score, used in the clinical assessment of Multiple Sclerosis.

Based on the [JavaScript reference implementation](https://github.com/atiweb/edss) and the [PHP implementation](https://github.com/atiweb/edss-in-php).

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  edss:
    git:
      url: https://github.com/atiweb/edss-in-flutter.git
      ref: main
```

Or if published on pub.dev:

```yaml
dependencies:
  edss: ^1.0.0
```

## Usage

### Direct calculation with individual scores

```dart
import 'package:edss/edss.dart';

final calculator = EdssCalculator();

final edss = calculator.calculate(
  visualFunctionsScore: 1,              // Visual (Optic) — raw 0-6
  brainstemFunctionsScore: 2,           // Brainstem — 0-5
  pyramidalFunctionsScore: 1,           // Pyramidal — 0-6
  cerebellarFunctionsScore: 3,          // Cerebellar — 0-5
  sensoryFunctionsScore: 1,             // Sensory — 0-6
  bowelAndBladderFunctionsScore: 4,     // Bowel & Bladder — raw 0-6
  cerebralFunctionsScore: 2,            // Cerebral (Mental) — 0-5
  ambulationScore: 1,                    // Ambulation — 0-16
);

print(edss); // "4"
```

### From a Map

By default, `calculateFromMap()` expects English field names:

```dart
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

final edss = calculator.calculateFromMap(data);
print(edss); // "4"
```

### With REDCap Portuguese field names

```dart
final redcapData = {
  'edss_func_visuais': '1',
  'edss_cap_func_tronco_cereb': '2',
  'edss_cap_func_pirad': '1',
  'edss_cap_func_cereb': '3',
  'edss_cap_func_sensitivas': '1',
  'edss_func_vesicais_e_instestinais': '4',
  'edss_func_cerebrais': '2',
  'edss_func_demabulacao_incapacidade': '1',
};

final edss = calculator.calculateFromMap(
  redcapData,
  fieldMap: EdssCalculator.fieldsRedcapPt,
);
print(edss); // "4"

// Longitudinal data with suffix
final edssLong = calculator.calculateFromMap(
  longitudinalData,
  fieldMap: EdssCalculator.fieldsRedcapPt,
  suffix: '_long',
);
```

### Custom field mapping

```dart
final myFields = {
  'visual': 'my_visual_field',
  'brainstem': 'my_brainstem_field',
  'pyramidal': 'my_pyramidal_field',
  'cerebellar': 'my_cerebellar_field',
  'sensory': 'my_sensory_field',
  'bowelBladder': 'my_bowel_bladder_field',
  'cerebral': 'my_cerebral_field',
  'ambulation': 'my_ambulation_field',
};

final edss = calculator.calculateFromMap(myData, fieldMap: myFields);
```

### Score conversions

```dart
// Visual: raw 0-6 → converted 0-4
EdssCalculator.convertVisualScore(3);  // 2
EdssCalculator.convertVisualScore(5);  // 3

// Bowel & Bladder: raw 0-6 → converted 0-5
EdssCalculator.convertBowelAndBladderScore(4);  // 3
EdssCalculator.convertBowelAndBladderScore(6);  // 5
```

## Functional Systems

| # | Functional System   | Raw Scale | Converted Scale | Parameter Name |
|---|--------------------|-----------|-----------------|-----------------------|
| 1 | Visual (Optic)     | 0-6       | 0-4             | `visualFunctionsScore` |
| 2 | Brainstem          | 0-5       | —               | `brainstemFunctionsScore` |
| 3 | Pyramidal          | 0-6       | —               | `pyramidalFunctionsScore` |
| 4 | Cerebellar         | 0-5       | —               | `cerebellarFunctionsScore` |
| 5 | Sensory            | 0-6       | —               | `sensoryFunctionsScore` |
| 6 | Bowel & Bladder    | 0-6       | 0-5             | `bowelAndBladderFunctionsScore` |
| 7 | Cerebral (Mental)  | 0-5       | —               | `cerebralFunctionsScore` |
| 8 | Ambulation         | 0-16      | —               | `ambulationScore` |

## Algorithm

The EDSS calculation follows a two-phase approach:

### Phase 1: Ambulation-driven (EDSS ≥ 5.0)
When the Ambulation score is ≥ 3, it directly maps to an EDSS value (5.0 – 10.0).

### Phase 2: FS-driven (EDSS 0 – 5.0)
When Ambulation is 0-2, the EDSS is calculated from the combination of the 7 FS scores based on the Kappos scoring table.

## Other implementations

| Language | Repository |
|----------|------------|
| JavaScript | [atiweb/edss](https://github.com/atiweb/edss) |
| PHP | [atiweb/edss-in-php](https://github.com/atiweb/edss-in-php) |
| Kotlin | [atiweb/edss-in-kotlin](https://github.com/atiweb/edss-in-kotlin) |

## Testing

```bash
dart test
```

The test suite includes 70+ test cases covering all EDSS ranges, score conversions, edge cases, and field mapping support.

## References

- Kurtzke JF. Rating neurologic impairment in multiple sclerosis: an expanded disability status scale (EDSS). *Neurology*. 1983;33(11):1444-1452.
- [Neurostatus-EDSS™](https://www.neurostatus.net/)
- [JavaScript reference implementation](https://github.com/atiweb/edss)

## License

[MIT](LICENSE)
