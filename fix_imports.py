
file_path = 'frontend/apps/management_org/lib/fees.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the damaged import
content = content.replace("import 'package:flutter/dart';", "import 'package:flutter/material.dart';")
# In case it appears twice (as seen in cat output)
content = content.replace("import 'package:flutter/dart';", "import 'package:flutter/material.dart';")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed imports in fees.dart")
