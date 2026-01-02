
import re

file_path = 'frontend/apps/management_org/lib/fees.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import 'dart:typed_data';
if "import 'dart:typed_data';" not in content:
    content = content.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'dart:typed_data';")

# 2. Fix _expandedFeeTypes type definition
# Was changed to Map<int, bool> in cleanup, but needs to be Map<String, bool> because feeType is String
content = content.replace("Map<int, bool> _expandedFeeTypes = {};", "Map<String, bool> _expandedFeeTypes = {};")
content = content.replace("final Map<int, bool> expandedFeeTypes;", "final Map<String, bool> expandedFeeTypes;")

# 3. Replace _SearchFilterSection Stub with updated one accepting new parameters
old_stub_start = "class _SearchFilterSection extends StatelessWidget {"
# We'll use a regex or string match to find the block. 
# Since I pasted it at the end, I can replace the whole class definition.

new_search_filter_stub = """
class _SearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<FeeRecord> fees;
  final void Function(FeeRecord) onMarkPaid;
  final Map<String, dynamic>? studentFeeSummary;
  final Map<String, bool> expandedFeeTypes;
  final ValueChanged<String> onToggleFeeType;
  final ValueChanged<int> onMarkAsPaid;
  // Added omitted parameters
  final Function(int)? onUploadReceipt;
  final bool isLoadingSummary;
  final Function(dynamic)? onFeeUpdated;
  final bool isLoading;

  const _SearchFilterSection({
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.fees,
    required this.onMarkPaid,
    this.studentFeeSummary,
    required this.expandedFeeTypes,
    required this.onToggleFeeType,
    required this.onMarkAsPaid,
    this.onUploadReceipt,
    this.isLoadingSummary = false,
    this.onFeeUpdated,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading) const LinearProgressIndicator(), 
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          if (fees.isEmpty)
             const Center(child: Text('No fees found'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fees.length,
              itemBuilder: (context, index) {
                final fee = fees[index];
                return ListTile(
                  title: Text(fee.studentName),
                  subtitle: Text(fee.typeLabel),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rs.${fee.totalAmount}'),
                      IconButton(
                        icon: const Icon(Icons.upload_file),
                        onPressed: onUploadReceipt != null ? () => onUploadReceipt!(fee.id) : null,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
"""

# I need to match the existing class block.
# Since it was appended at the end, I can try specific replace if I know the exact string.
# But indentation might vary or I might have edited it.
# Simpler: Use regex to replace "class _SearchFilterSection ... }"
# But ensuring I capture the full body is hard with regex dotall.
# Since I know I wrote it in assemble_fees.py, I know the exact content I wrote there.
# Let's try to identify it by the fields I defined previously.

# Previous fields in assemble_fees.py:
# final Set<int> expandedFeeTypes; -> I changed it to Map<int, bool> in cleanup_fees.py (wait, cleanup_fees.py replace failed? No it worked for prefixes)
# wait, cleanup_fees.py DID replacements. So content has Map<int, bool>.
# I need to be careful.

# Strategy: Delete the old usage and append the new one?
# No, `_SearchFilterSection` is in the middle of other stubs potentially.
# In assemble_fees.py order: _AddFeeSection, _SearchFilterSection, _TableCell, GlassContainer.
# So _SearchFilterSection is sandwiched.

# I will regex replace the class definition.
pattern = r"class _SearchFilterSection extends StatelessWidget \{.*?\n\}"
# This won't work because of nested braces in build method.

# Fallback: Identify the start and end of _SearchFilterSection.
# Start: class _SearchFilterSection extends StatelessWidget {
# End: class _TableCell ... (Next class)

# Find start index
start_idx = content.find("class _SearchFilterSection extends StatelessWidget {")
if start_idx == -1:
    print("Could not find _SearchFilterSection class definition")
    exit(1)

# Find end index (start of next class or end of file)
# Next class is _TableCell
end_idx = content.find("class _TableCell extends StatelessWidget {", start_idx)
if end_idx == -1:
   # Maybe it's the last one? No GlassContainer is after.
   # Check assemble_fees.py order: Add, Search, Table, Glass.
   # So TableCell follows Search.
   print("Could not find start of _TableCell to delimit _SearchFilterSection")
   exit(1)

# Replace the block
content = content[:start_idx] + new_search_filter_stub + "\n\n" + content[end_idx:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Applied final semantic fixes to fees.dart")
