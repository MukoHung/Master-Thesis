Invoke-WebRequest -Uri 'https://aka.ms/vs/16/release/vs_buildtools.exe' -OutFile '~/Downloads/vs_buildtools.exe'
~/Downloads/vs_buildtools.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64
Invoke-WebRequest -Uri 'https://win.rustup.rs/x86_64' -OutFile '~/Downloads/rustup-init.exe'
~/Downloads/rustup-init.exe -y