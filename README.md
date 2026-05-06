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

The first `awake-on` or `awake-off` may ask for your admin password once. It installs a narrow sudoers rule so future toggles do not prompt:

```text
/usr/bin/pmset -a disablesleep 1
/usr/bin/pmset -a disablesleep 0
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
- auto-configures passwordless sudo for only the two `pmset disablesleep` commands

`awake-off` restores normal sleep with `pmset -a disablesleep 0` and kills the background `caffeinate`.
