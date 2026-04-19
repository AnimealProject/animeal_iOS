#!/bin/bash
# Hook: Block amplify commands and require explicit user approval via chat.
# Bypass: add "# approved" to the end of the command after user confirms.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

# Only intercept amplify commands
if ! echo "$COMMAND" | grep -qE "(^|\s|&&|\|;)amplify(\s|$)"; then
    exit 0
fi

# Allow if user explicitly approved in chat
if echo "$COMMAND" | grep -q "# approved"; then
    exit 0
fi

# Block and ask Claude to confirm with user
echo "🛑 Amplify command blocked by amplify-guard." >&2
echo "" >&2
echo "⚠️  You are attempting to run a potentially dangerous operation:" >&2
echo "   $COMMAND" >&2
echo "" >&2
echo "Amplify can modify database schema, overwrite backend resources, or affect" >&2
echo "production data. Make sure this operation is safe before proceeding." >&2
echo "" >&2
echo "Use AskUserQuestion with options Approve / Deny." >&2
echo "If approved — append '# approved' to THIS specific command only." >&2
echo "Each new amplify command requires its own explicit confirmation." >&2
exit 2
