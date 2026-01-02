
import os

# 1. Read the "Good Part" of fees_clean.dart
try:
    with open('frontend/apps/management_org/lib/fees_clean.dart', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        # Keep up to line 2436 (inclusive, which is the closing brace of _NavItem)
        # Note: list is 0-indexed, so line 2436 is index 2435.
        # Let's verify context. Line 2436 is '}' of _NavItem.
        # Line 2437 is 'class _StatsOverview ...' (Duplicate).
        base_content = "".join(lines[:2436])
except Exception as e:
    print(f"Error reading fees_clean.dart: {e}")
    exit(1)

# 2. Define Missing Classes Stubs/Impls

add_fee_section_impl = """

// --- Added Missing Classes ---

class _AddFeeSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController studentIdController;
  final TextEditingController studentNameController;
  final TextEditingController classController;
  final String? selectedGrade;
  final ValueChanged<String?> onGradeChanged;
  final TextEditingController totalAmountController;
  final TextEditingController lateFeeController;
  final TextEditingController descriptionController;
  final VoidCallback onStudentIdChanged;
  final String? feeType;
  final ValueChanged<String?> onFeeTypeChanged;
  final String? frequency;
  final ValueChanged<String?> onFrequencyChanged;
  final DateTime? dueDate;
  final VoidCallback onPickDueDate;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const _AddFeeSection({
    required this.formKey,
    required this.studentIdController,
    required this.studentNameController,
    required this.classController,
    this.selectedGrade,
    required this.onGradeChanged,
    required this.totalAmountController,
    required this.lateFeeController,
    required this.descriptionController,
    required this.onStudentIdChanged,
    this.feeType,
    required this.onFeeTypeChanged,
    this.frequency,
    required this.onFrequencyChanged,
    this.dueDate,
    required this.onPickDueDate,
    required this.onSubmit,
    required this.isSubmitting,
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
          const Text(
            'Add New Fee',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  onChanged: (_) => onStudentIdChanged(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                   controller: studentNameController,
                   decoration: const InputDecoration(labelText: 'Student Name'),
                   readOnly: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: totalAmountController,
                  decoration: const InputDecoration(labelText: 'Total Amount'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                    ),
                    child: isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Fee Record'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""

search_filter_section_impl = """
class _SearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<FeeRecord> fees;
  final void Function(FeeRecord) onMarkPaid;
  final Map<String, dynamic>? studentFeeSummary;
  final Set<int> expandedFeeTypes;
  final ValueChanged<int> onToggleFeeType;
  final ValueChanged<int> onMarkAsPaid;

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
                  trailing: Text('Rs.${fee.totalAmount}'),
                );
              },
            ),
        ],
      ),
    );
  }
}
"""

table_cell_impl = """
class _TableCell extends StatelessWidget {
  final String text;
  final bool isLink;
  final String? receiptPath;
  final String? receiptNumber;
  final Color? statusColor;

  const _TableCell(
    this.text, {
    this.isLink = false,
    this.receiptPath,
    this.receiptNumber,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLink && receiptPath != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () {
            // Show receipt dialog logic here or simplified
          },
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: statusColor ?? Colors.black87,
          fontWeight: statusColor != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
"""

glass_container_impl = """
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool drawRightBorder;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.drawRightBorder = false,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final radius = drawRightBorder
        ? BorderRadius.zero
        : BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: radius,
              border: Border(
                right: drawRightBorder
                    ? BorderSide(color: Colors.white.withOpacity(0.2))
                    : BorderSide.none,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(2, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
"""

# 3. Assemble
final_content = base_content + "\n" + add_fee_section_impl + "\n" + search_filter_section_impl + "\n" + table_cell_impl + "\n" + glass_container_impl

with open('frontend/apps/management_org/lib/fees_final.dart', 'w', encoding='utf-8') as f:
    f.write(final_content)

print("Created fees_final.dart")
