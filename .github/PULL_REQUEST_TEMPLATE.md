<!--
Rules in one line each:
- One paragraph per section, no hard-wrap (GitHub flows the text).
- Explain the shipped outcome, not every file — the diff already shows it.
- No design rationale narration here.
- No file-by-file changelog and no asset inventory (use the diff).
- No mechanical CI-shaped checks — CI runs scripts/validate-assets.sh itself.
- Every Verify-locally command is copy-pasteable and states its expected
  outcome when a bare exit code does not disambiguate pass from fail.
- Drop the headings you do not need. "Behavior changes" is only when it adds
  signal beyond "What ships". "Not included" is only when scope boundaries or
  deferred work are useful to call out.
-->

## Summary

<One paragraph answering: what is this pull request for? Name the assets or
tooling change, who benefits, and where the assets live in the repository.
Keep this short.>

## What ships

- <The new or changed logo assets, described as outcomes (which design round,
  which formats), not as a file list.>
- <Any tooling or documentation change contributors can rely on.>

## Behavior changes

<Drop this section when it would only repeat "What ships". Keep it when CI
validation, supported file types, or repository structure changes.>

- <Existing behavior that changes>

## Not included

<Scope boundaries and deferred work so reviewers know what is intentionally
out of scope. Drop this section entirely when nothing meaningful is excluded.>

- <Out-of-scope work or deferred follow-up>

## Verify locally

### Checkout

```sh
gh pr checkout <PR_NUMBER>
```

### Asset validation

<This is the repository's only gate: CI runs scripts/validate-assets.sh, which
decodes every tracked asset (ImageMagick, rsvg-convert, ghostscript, pdfinfo)
and lint-checks shell, YAML, and text files. Expected output on success is the
final line `Validated <N> tracked files, including <M> artwork assets.`>

```sh
scripts/validate-assets.sh
```
