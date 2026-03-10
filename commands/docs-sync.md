---
name: docs-sync
description: Sync documentation with current code
disable-model-invocation: true
---

# Documentation Sync

Read `CLAUDE.md` to learn the project's stack and structure.

## Steps

1. **Identify recent changes**: Detect source code files modified in the last month:
   ```
   git log --since="1 month ago" --name-only --pretty=format:"" -- "*.ts" "*.tsx" "*.js" "*.jsx" "*.py" "*.go" "*.rs" "*.java" "*.rb" | sort -u
   ```
   Adapt the extensions to the project's stack.

2. **Locate related documentation**: For each modified file, search for:
   - READMEs in the same directory or parent directories
   - `.md` files that reference the module/component
   - JSDoc comments/docstrings describing public APIs
   - API documentation (OpenAPI, GraphQL schema docs)

3. **Verify consistency**: For each code-documentation pair:
   - Are the code examples in the documentation still valid?
   - Do documented function/API signatures match the code?
   - Are there new features without documentation?
   - Is there documentation for features that no longer exist?

4. **Fix only real errors**: Update documentation only where there are verifiable inconsistencies. Do not:
   - Add documentation where none existed before
   - Change the style or format of existing docs
   - Generate changelogs

5. **Report**:
   ```
   ## Documentation Updated
   - [file] — [what was fixed]

   ## No Changes Needed
   - [file] — documentation is up to date

   ## Summary
   - X doc files reviewed
   - X corrections made
   ```
