import os
import re

lib_dir = 'lib'
imports_to_add = "import 'package:sumarg/utils/toast_service.dart';"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # If file contains Fluttertoast.showToast
    if 'Fluttertoast.showToast' in content:
        # replace the method call
        new_content = re.sub(r'Fluttertoast\.showToast', 'ToastService.showToast', content)
        
        # Add import if missing
        if "toast_service.dart" not in new_content:
            # find first import
            import_match = re.search(r'^import .*;', new_content, re.MULTILINE)
            if import_match:
                index = import_match.start()
                new_content = new_content[:index] + imports_to_add + "\n" + new_content[index:]
        
        # Write back
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'toast_service.dart':
            process_file(os.path.join(root, file))

print("Toast migration complete.")
