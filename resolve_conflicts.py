import re
import sys

def resolve_conflicts(file_path):
    """Resolve all git merge conflicts by keeping the 'theirs' (sairam) version"""
    content = ""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeError:
        try:
            with open(file_path, 'r', encoding='utf-16') as f:
                content = f.read()
        except UnicodeError:
            with open(file_path, 'r') as f: # Default system encoding
                content = f.read()
    
    # Pattern to match conflict blocks
    pattern = r'<<<<<<< HEAD\n(.*?)\n=======\n(.*?)\n>>>>>>> sairam\n'
    
    # Replace with the 'theirs' version (sairam)
    resolved = re.sub(pattern, r'\2\n', content, flags=re.DOTALL)
    
    # Also handle Windows line endings
    pattern_crlf = r'<<<<<<< HEAD\r\n(.*?)\r\n=======\r\n(.*?)\r\n>>>>>>> sairam\r\n'
    resolved = re.sub(pattern_crlf, r'\2\r\n', resolved, flags=re.DOTALL)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(resolved)
    
    print(f"Resolved conflicts in {file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python resolve_conflicts.py <file_path>")
        sys.exit(1)
    
    resolve_conflicts(sys.argv[1])
