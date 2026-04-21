# Test Strategy: CLI Tool

## Project Type Identifier
`cli` — Command-line tools (Rust/Clap, Python/Click, Node.js/Commander, Go/Cobra, etc.)

### Detection Signals
| File | Signal |
|------|---------|
| `Cargo.toml` + `clap` dep | Rust CLI |
| `pyproject.toml` + `click`/`typer` | Python CLI |
| `package.json` + `commander`/`yargs` + `bin` field | Node.js CLI |
| `go.mod` + `cobra` | Go CLI |
| `src/main.*` with no HTTP listener | Non-server entry point |

---

## Smoke Test Checklist

- [ ] `{binary} --version` outputs version, exit code 0
- [ ] `{binary} --help` outputs usage text, exit code 0
- [ ] Core command runs successfully with minimal args (exit code 0)
- [ ] Invalid args return a meaningful error message, exit code non-0
- [ ] `{binary} {core-command} < /dev/null` does not hang (handles empty input)

---

## Business Workflow Verification

Use **CLI integration tests** (capture stdout/stderr + exit code):

### Typical Journey Template

```bash
# Step 1: Initialize (create config/workspace)
{binary} init --output /tmp/test-workspace
# Assert: directory exists, config file generated

# Step 2: Core operation
{binary} process --input fixture.txt --output /tmp/result.txt
# Assert: exit code 0, output file exists

# Step 3: Verify output content
diff /tmp/result.txt expected/result.txt
# Assert: content matches

# Step 4: Error handling
{binary} process --input nonexistent.txt
# Assert: exit code 1, stderr contains meaningful error message
```

### Test Framework Templates

```rust
// Rust: assert_cmd crate
use assert_cmd::Command;
use predicates::str::contains;

#[test]
fn test_core_workflow() {
    Command::cargo_bin("myapp")
        .unwrap()
        .arg("process")
        .arg("--input")
        .arg("tests/fixtures/input.txt")
        .assert()
        .success()
        .stdout(contains("Done"));
}
```

```python
# Python: subprocess + pytest
import subprocess, pytest

def test_core_workflow(tmp_path):
    result = subprocess.run(
        ["myapp", "process", "--input", "tests/fixtures/input.txt",
         "--output", str(tmp_path / "result.txt")],
        capture_output=True, text=True
    )
    assert result.returncode == 0
    assert (tmp_path / "result.txt").exists()
```

---

## Unit Test Focus

| Layer | Test Subject | Assertions |
|----|---------|------|
| Arg parsing | CLI arg struct | Valid and invalid arg combinations |
| Core logic | Business processing functions | Pure functions, no CLI context dependency |
| Output formatting | stdout format functions | String matching |
| Error mapping | Error → exit code | Each error type maps to correct code |
| Config file I/O | Config parse / serialize | TOML/YAML round-trip |

---

## Mock Strategy

| External Dependency | Mock Approach |
|---------|---------|
| File system | `tempdir` / `tmp_path` (pytest) creates temp directories |
| Network requests | `httpmock` / `respx` / `nock` |
| stdin | `echo "input" | {binary}` or `Command::write_stdin()` |
| System clock | Inject fake time or fix `SOURCE_DATE_EPOCH` env var |
| Interactive prompts | Non-interactive flag (`--no-interactive` / `--yes`) |

---

## Evidence Requirements

- Smoke Test: `--version` and `--help` terminal output screenshot
- Business workflow: Full command sequence terminal screenshot (with `echo $?` exit codes)
- Output verification: `diff` result screenshot (no differences)
- Error handling: Non-zero exit code + stderr screenshot
