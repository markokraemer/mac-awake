# mac-sleep-forever

Minimal macOS helper to keep a Mac awake forever, including lid closed.

## One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/markokraemer/mac-sleep-forever/main/install.sh | bash
```

Open a new shell, then:

```bash
awake-on
awake-off
awake-status
```

## Clone install

```bash
git clone https://github.com/markokraemer/mac-sleep-forever.git
cd mac-sleep-forever
./install.sh
```

## Commands

```bash
awake-on
awake-off
awake-status
```

What it does:

- `pmset -a disablesleep 1`
- runs `/usr/bin/caffeinate -dimsu`
- verifies with `pmset -g live` (`SleepDisabled 1`)

`awake-off` restores normal sleep with `pmset -a disablesleep 0` and kills the background `caffeinate`.
