import 'package:flutter/material.dart';

/// true = dark mode. Intern: Profile ka switch. Admin: header ka button.
final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);

const ColorFilter lightModeFilter = ColorFilter.matrix(<double>[
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
]);

/// Invert + hue-rotate: poori app ko dark bana deta hai, rang kaafi had tak apne jaise rehte hain.
const ColorFilter darkModeFilter = ColorFilter.matrix(<double>[
  0.5166, -1.287, -0.1296, 0, 250,
  -0.3834, -0.387, -0.1296, 0, 250,
  -0.3834, -1.287, 0.7704, 0, 250,
  0, 0, 0, 1, 0,
]);
