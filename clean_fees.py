import os

def clean_file(src, dst):
    with open(src, 'rb') as f:
        content = f.read()
    
    # Check for BOM
    if content.startswith(b'\xef\xbb\xbf'):
        content = content[3:]
    
    with open(dst, 'wb') as f:
        f.write(content)

clean_file('frontend/apps/management_org/lib/fees.dart', 'frontend/apps/management_org/lib/fees_clean.dart')
