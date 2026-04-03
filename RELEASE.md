# RELEASE GUIDE

This document defines the lightweight release flow for this repository.

## Scope

- Repository: `will-siklls`
- Main branch: `main`
- Artifacts: skill folders and documentation files

## Versioning

Use Semantic Versioning for published skill states:

- Patch: `0.1.1 -> 0.1.2` (docs, small fixes, non-breaking tweaks)
- Minor: `0.1.1 -> 0.2.0` (new capability or notable behavior enhancement)
- Major: `0.x.y -> 1.0.0` (breaking contract changes)

## Release Checklist

1. Ensure working tree is clean.
2. Update `CHANGELOG.md`:
   - Move items from `Unreleased` into a new version section.
   - Add release date (`YYYY-MM-DD`).
3. Commit release changes.
4. Create annotated tag.
5. Push `main` and tags.
6. Verify GitHub shows the new tag.

## Commands

```bash
git status --short
git add .
git commit -m "chore: release vX.Y.Z"
git tag -a vX.Y.Z -m "release: vX.Y.Z"
git push origin main
git push origin vX.Y.Z
```

## Example

```bash
git commit -m "chore: release v0.1.2"
git tag -a v0.1.2 -m "release: v0.1.2"
git push origin main
git push origin v0.1.2
```

## Hotfix Flow

1. Branch from `main`.
2. Apply minimal fix.
3. Update `CHANGELOG.md` patch section.
4. Merge back to `main`.
5. Release a new patch tag (`vX.Y.(Z+1)`).

## Rollback Note

If a release must be reverted, create a new patch version with corrective commits instead of deleting published tags.

## Maintainer Note

Keep release commits focused: avoid mixing large feature edits with release metadata updates.
