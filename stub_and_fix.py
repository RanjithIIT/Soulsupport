import re

file_path = 'frontend/apps/management_org/lib/fees_clean.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace Row and SizedBox with flutter_material prefix
content = re.sub(r'\bRow\(', 'flutter_material.Row(', content)
content = re.sub(r'\bSizedBox\(', 'flutter_material.SizedBox(', content)

# 2. Append _AddFeeSection stub (using flutter_material)
stub = """
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
  });

  @override
  Widget build(BuildContext context) {
    return flutter_material.Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: const flutter_material.Text('Add Fee Section Placeholder'),
    );
  }
}
"""

if 'class _AddFeeSection' not in content:
    content += stub

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed fees_clean.dart with flutter_material alias")
