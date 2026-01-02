
import re

file_path = 'frontend/apps/management_org/lib/fees_final.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix Imports: Remove alias
content = content.replace("import 'package:flutter/material.dart' as flutter_material;", "import 'package:flutter/material.dart';")

# 2. Fix Prefixes: Remove material. and flutter_material.
# Handle double prefix first
content = content.replace("material.flutter_material.", "")
content = content.replace("flutter_material.", "")
content = content.replace("material.", "")

# 3. Fix Type Mismatch
# Change Set<int> _expandedFeeTypes to Map<int, bool> _expandedFeeTypes
content = content.replace("Set<int> _expandedFeeTypes = {};", "Map<int, bool> _expandedFeeTypes = {};")

# Also fix the usage in _SearchFilterSection signature if needed?
# In assemble_fees.py, I defined _SearchFilterSection stub with Set<int>. I need to check if I need to update that signature.
# The stub I wrote has: final Set<int> expandedFeeTypes;
# I should change that to Map<int, bool> too.
content = content.replace("final Set<int> expandedFeeTypes;", "final Map<int, bool> expandedFeeTypes;")

with open('frontend/apps/management_org/lib/fees.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Cleaned fees.dart generated")
