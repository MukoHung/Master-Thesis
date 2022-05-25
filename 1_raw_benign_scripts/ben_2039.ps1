# Invoke-Hyper

A hacky PowerShell script that simulates the [missing multiple profile support](https://github.com/zeit/hyper/issues/1147) using launch-time symlinking of Hyper's preferences file.

## Install

### Prerequisites

- [Hyper](https://github.com/zeit/hyper)
- `hyper` must be on the PATH
- PowerShell's [ExecutionPolicy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6) should be RemoteSigned at least
- Windows (see "Limitations/Known Issues" below for more info)

### Process

1. Create `~\.hyper` and `~\.hyper\launch` directories
2. Put `Invoke-Hyper.ps1` into `~\.hyper\launch`
3. Copy your current `~\.hyper.js` to `~\.hyper\launch\default.hyper.js`
4. Make as many `~\.hyper\launch\<profilename>.hyper.js` (where `<profilename>` is the name of the Hyper profile) files as you need. Each of these files will correspond to a single Hyper profile. Whatever the config format supports is fair game--colors, different startup shells, plugins. Get wild.

## Usage

- Invoke Hyper by calling `~\.hyper\launch\Invoke-Hyper.ps1 <profilename>`. For example, if you've created a settings file `ps.hyper.js` that launches directly into PowerShell (using the `shell` config setting), you'd launch it by calling `~\.hyper\launch\Invoke-Hyper.ps1 ps`. 
- It can be convenient to create Windows Explorer shortcuts to facilitate launching different profiles easily, with command lines similar to `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -File C:\Users\<username>\.hyper\launch\Invoke-Hyper.ps1 ps` (where `<username>` is the name of your Windows user profile). It's probably a good idea to set the shortcut's "Run" setting to "Minimized" if you'd rather not see an ugly Windows Terminal window hang around while you're waiting for Hyper to launch.

## Limitations/Known Issues

- Doing anything that interacts with `~\.hyper.js` (for example, launching Hyper the normal way or opening "Edit-->Preferences...") will operate with the profile of the most recently launched Hyper. So, for example, if you last used `Invoke-Hyper` to start Hyper with your PowerShell profile, and you also happen to previously have a Hyper running a CMD.EXE profile, opening "Edit-->Preferences..." in the CMD.EXE instance of Hyper will open the settings file for the PowerShell profile. This is where the hacky aspect of this scheme starts to rear its ugly head, and it cannot be fixed.
- Hyper takes an appallingly long time to launch. This matters because it's highly likely that, due to the limitation described in the previous bullet, you will find some race conditions if you try to launch a bunch of profiles simultaneously.
- This hack currently only works in Windows (because we're using `cmd.exe`'s built-in `mklink` command). At a guess, a workaround might be to run the script in Powershell Core, and write a conditional that [detects the execution environment](https://stackoverflow.com/questions/44703646/determine-the-os-version-linux-and-windows-from-powershell) and uses `ln` instead of `mklink` on non-Windows systems. I haven't tried this, though. YMMV.