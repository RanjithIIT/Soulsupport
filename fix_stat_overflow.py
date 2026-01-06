import re

# Read the file
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the _StatCard widget and fix the overflow by adding Flexible/Expanded wrappers
# The issue is likely in the Column children not being constrained properly

# Fix 1: Wrap Text widgets in Flexible
content = re.sub(
    r"(child: Column\(\s*mainAxisAlignment: MainAxisAlignment\.center,\s*crossAxisAlignment: CrossAxisAlignment\.center,\s*children: \[\s*Icon\([^)]+\),\s*const SizedBox\(height: 8\),\s*)(Text\(\s*count\.toString\(\),)",
    r"\1Flexible(child: \2),",
    content
)

# Fix 2: Wrap the label Text in Flexible as well
content = re.sub(
    r"(const SizedBox\(height: 4\),\s*)(Text\(\s*label,\s*style: TextStyle\(\s*color: Colors\.white70,)",
    r"\1Flexible(child: \2),",
    content
)

# Fix 3: Add constraints to the stat card container
content = re.sub(
    r"(Widget _buildStatCard\(\{[^}]+\}\) \{\s*return Container\(\s*padding: const EdgeInsets\.all\(20\),)",
    r"\1\n      constraints: const BoxConstraints(minHeight: 120),",
    content
)

# Write back
with open(r'C:\Users\d-it\Desktop\sushil code\frontend\apps\management_org\lib\events.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed stat card overflow issues")
