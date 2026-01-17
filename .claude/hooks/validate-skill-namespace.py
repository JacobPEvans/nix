#!/usr/bin/env python3
"""
Validate skill namespace format: namespace:skill-name

This hook runs before Skill tool invocations. It ensures that skill references
use the correct format (namespace:skill-name) and warns about common mistakes
like assuming pr-review-toolkit for unknown skills.

Exit codes:
  0 = allow the command (format is correct or close enough)
  2 = block the command (format is clearly wrong)

Input: JSON from stdin with tool_input.skill containing the skill reference
Output: Exit code determines whether invocation proceeds
"""

import json
import sys


def validate_skill_format(skill_ref):
    """
    Validate skill reference format.
    Returns: (is_valid, message)
    """
    if not skill_ref or not isinstance(skill_ref, str):
        return False, "Skill reference must be a non-empty string"

    # Check if it contains a colon
    if ":" not in skill_ref:
        return (
            False,
            f"❌ Invalid format: '{skill_ref}'\n"
            f"   Expected: 'namespace:skill-name'\n"
            f"   Example: 'code-simplifier:code-simplifier'\n"
            f"           'pr-review-toolkit:code-reviewer'\n"
            f"   \n"
            f"   💡 TIP: If you got an error listing available skills,\n"
            f"       copy the EXACT string from that list.\n"
            f"       DO NOT assume a namespace!",
        )

    parts = skill_ref.split(":")
    if len(parts) != 2:
        return (
            False,
            f"❌ Invalid format: '{skill_ref}'\n"
            f"   Found {len(parts)} colon-separated parts (expected 2)\n"
            f"   Correct format: 'namespace:skill-name'",
        )

    namespace, skill_name = parts
    if not namespace or not skill_name:
        return (
            False,
            f"❌ Invalid format: '{skill_ref}'\n"
            f"   Both namespace and skill-name must be non-empty",
        )

    # Warn about common mistakes
    if namespace == "pr-review-toolkit" and skill_name not in [
        "code-reviewer",
        "silent-failure-hunter",
        "code-simplifier",
        "comment-analyzer",
        "pr-test-analyzer",
        "type-design-analyzer",
    ]:
        return (
            True,
            f"⚠️  Warning: Using pr-review-toolkit for '{skill_name}'\n"
            f"    This might be incorrect. If you got an error listing\n"
            f"    available skills, double-check the exact namespace.\n"
            f"    Don't assume pr-review-toolkit for unknown skills!\n"
            f"    Proceeding anyway...",
        )

    return True, None


def main():
    """Main hook logic."""
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        # No valid input, allow
        return 0

    skill_ref = hook_input.get("tool_input", {}).get("skill", "")

    is_valid, message = validate_skill_format(skill_ref)

    if message:
        print("\n" + "═" * 70, flush=True)
        if is_valid:
            print(message, flush=True)
            print("═" * 70 + "\n", flush=True)
            return 0
        else:
            print(message, file=sys.stderr, flush=True)
            print("═" * 70 + "\n", file=sys.stderr, flush=True)
            return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
