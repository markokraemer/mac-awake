# mac-awake

Minimal macOS helper to keep a Mac awake — forever or on a timer — including lid closed.

## One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/markokraemer/mac-awake/main/install.sh | bash
```

Open a new shell, then:

```bash
awake-on
awake-on 30      # stay awake for 30 minutes, then auto-sleep
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
git clone https://github.com/markokraemer/mac-awake.git
cd mac-awake
./install.sh
```

## Commands

```bash
awake-on            # stay awake forever (until awake-off)
awake-on 30         # stay awake for 30 minutes, then auto-sleep
awake-off
awake-status
```

What it does:

- `pmset -a disablesleep 1`
- runs `/usr/bin/caffeinate -dimsu`
- verifies with `pmset -g live` (`SleepDisabled 1`)
- auto-configures passwordless sudo for only the two `pmset disablesleep` commands

### Timer (`awake-on <minutes>`)

Pass a number of minutes to `awake-on` to keep the Mac awake for just that long,
then automatically restore normal sleep:

```bash
awake-on 30         # awake for 30 minutes
awake-status        # shows: auto-off in 29m 54s
awake-off           # cancel early at any time
```

A lightweight background watcher counts down and runs `awake-off` when the timer
expires. Running `awake-on` again (with or without a timer) replaces any pending
timer, and `awake-off` cancels it. The minute value must be a positive whole number.

`awake-off` restores normal sleep with `pmset -a disablesleep 0`, kills the background
`caffeinate`, and cancels any pending auto-off timer.
