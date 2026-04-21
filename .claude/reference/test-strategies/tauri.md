# Test Strategy: Tauri Desktop App

## Project Type Identifier
`tauri` — Tauri 1.x / 2.x desktop apps (Rust backend + WebView frontend)

### Detection Signals
| File | Signal |
|------|---------|
| `src-tauri/Cargo.toml` | Tauri dependency present |
| `src-tauri/tauri.conf.json` | Tauri config file |
| `src-tauri/src/main.rs` | Rust entry point |

---

## Smoke Test Checklist

- [ ] `cargo tauri dev` starts without compile errors or panics
- [ ] Main window is visible, no blank screen
- [ ] Overlay window (if any) is visible
- [ ] At least one IPC command succeeds (`invoke` returns non-error)
- [ ] Global hotkey registers (no `failed to register shortcut` in logs)
- [ ] Closing the app does not crash

---

## Business Workflow Verification

Use **Tauri IPC direct calls + state snapshots** (no UI automation required):

```typescript
// Call invoke from the frontend dev console or a test page
import { invoke } from "@tauri-apps/api/core";

// 1. Trigger core operation
const result = await invoke("start_recording");

// 2. Wait for state transition
await new Promise(r => setTimeout(r, 500));
const state = await invoke("get_app_state");

// 3. Assert
assert(state.isRecording === true);

// 4. Complete operation
await invoke("stop_recording");
const recording = await invoke("get_latest_recording");
assert(recording.duration_ms > 0);
```

### Typical Journey Template
```
Step 1: invoke("get_settings") → no error, returns valid config object
Step 2: invoke("start_recording") → isRecording = true
Step 3: wait 1s → invoke("stop_recording") → returns recording_id
Step 4: invoke("get_recording", {id}) → duration_ms > 0, file_path exists
Step 5: invoke("summarize_recording", {id}) → summary is non-empty string
```

---

## Unit Test Focus

| Layer | Test Subject | Approach |
|----|---------|---------|
| Rust business logic | DB ops, audio processing, STT/LLM calls | `#[cfg(test)]` inline or `tests/` integration tests |
| IPC serialization | `#[serde(rename_all = "camelCase")]` structs | serde round-trip tests |
| Frontend Store | Zustand store actions | Vitest + `@tauri-apps/api/mocks` |
| Frontend components | React component rendering | Vitest + RTL |

---

## Mock Strategy

| External Dependency | Mock Approach |
|---------|---------|
| STT API (Whisper/cloud) | `MockSTTProvider` trait impl returning fixed text |
| LLM API (OpenAI/Qwen) | `MockLLMProvider` trait impl returning fixed summary |
| cpal audio device | `silence_generator` test fixture producing silent PCM data |
| SQLite | `:memory:` database, isolated per test |
| Tauri IPC (frontend unit tests) | `@tauri-apps/api/mocks` + `mockIPC()` |

---

## Tauri 2.0 Specific Notes

- `cpal::Stream` is `!Send` on macOS → requires `SendStream` type-erasure wrapper
- `Channel<T>` constructor requires a callback: `Channel::new(|_| Ok(()))`
- Window management API: `get_webview_window()` (not the old `get_webview_label()`)
- Global hotkeys: macOS uses `Cmd`, Windows/Linux uses `Ctrl` (`#[cfg(target_os)]`)

---

## Evidence Requirements

- Smoke Test: `cargo tauri dev` terminal output screenshot + main window screenshot
- Business workflow: DevTools Console `invoke` call result screenshot
- State verification: `get_app_state` return value JSON screenshot
