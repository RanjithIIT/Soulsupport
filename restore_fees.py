import os
import codecs

def convert_and_copy(source, dest):
    print(f"Reading {source}...")
    try:
        # Try reading as UTF-16 (PowerShell output default)
        with codecs.open(source, 'r', 'utf-16') as f:
            content = f.read()
            print("Detected UTF-16 encoding")
    except UnicodeError:
        try:
            # Try UTF-8
            with codecs.open(source, 'r', 'utf-8') as f:
                content = f.read()
                print("Detected UTF-8 encoding")
        except UnicodeError:
             # Try CP1252/Default
            with open(source, 'r') as f:
                content = f.read()
                print("Detected default encoding")

    print(f"Writing to {dest} in UTF-8...")
    with codecs.open(dest, 'w', 'utf-8') as f:
        f.write(content)
    print("Done.")

if __name__ == "__main__":
    convert_and_copy("fees_sairam.dart", "frontend/apps/management_org/lib/fees.dart")
