# Setup Notes

This file attempts to go over the PowerShell environment setup.  It includes gotchas, configurations, and more.   

## RSAT Install
Install RSAT, now a 'Feature On Demand' but the GUI sucks and never really installs for me...
[I had to use DISM to do it](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-capabilities-package-servicing-command-line-options).  

* First get the list of capabilities online.  
  * `dism /online /get-capabilities`  
* Then copy the name and add it to the capability.  Here is the Active Directory Tools:   
  * `dism /add-capability /online /CapabilitYName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`  
* Add some remote management tools as well, may not be needed:  
  * `dism /add-capability /online /CapabilitYName:Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0`  
* Server Manager Install:  
  * `dism /add-capability /online /CapabilitYName:Rsat.ServerManager.Tools~~~~0.0.1.0`  
  
## Local AD Environment Setup  

### WinRM setup  

#### Configurations on the domain controller side  
I had to use [winrm quickconfig](https://4sysops.com/wiki/enable-powershell-remoting/) to get it setup in the DC.  
* This link will help create the [HTTPS listener](https://www.visualstudiogeeks.com/devops/how-to-configure-winrm-for-https-manually) for WinRM.  
  * The directions will show you how to generate a cert for HTTPS connection. If on corporate env, you may already have PKI setup with a cert to use.  Below is how to create from scratch for this talk.  
* Take note of the cert thumbprint when creating the cert using the instructions in the link above and add to your local client trust store.  Steps to add:  
  * `$cert = gci Cert:\LocalMachine\My\$CertThumbprint`  
  * `Export-Certificate -Cert $cert -FilePath "C:\Users\Administrator\Documents\newCert" -Type cert`  
* I shared my local C:\ with the VM guest to copy over the cert. 
  * Once copied local, I double-clicked to add via GUI...  
* if you want to remove the HTTP listener once the HTTPS listener is setup and tested:
  * `winrm delete winrm/config/Listener?Address=*+Transport=HTTP` 

#### Configurations On the client side
* If you don't have DNS working, set a static resolver in your 'hosts' file to point to the IP address of the DC.  In an elevated PS:  
  * `notepad C:\windows\system32\drivers\etc\hosts`  
  * Example:, **Change the fully_qual.hostname** to one appropriate for your env.  
    * `192.168.253.201	fully_qual.hostname`
    * That is a 'tab' between the IP and hostname  
  * Make sure the hostname matches the CN attribute of the certificate created on the DC above.  
* Once completed, setup WINRM to connect to it and trust it:  
    * `winrm set winrm/config/client '@{TrustedHosts="fully_qual.hostname"}'`  
    * `winrm set winrm/config/client/Auth '@{Kerberos="false";Basic="false";Certificate="false";Digest="false"}'`  
* If your local computer is not part of your test domain, you need to run as a domain user.  
  * First grab those creds in a secure manner:  
    * `$creds = get-credential -username domain\administrator`  
  * With those creds, use SSL to connect and select negotiate:  
    * `enter-pssession $DCHostName -Authentication negotiate -Credential $creds -UseSSL`   
* Setting this, should also allow you to run server manager to manage your domain controller.  


## PowerShell Profile - Colorization Fix and More
Due to the issues below, I moved to PSCore from PowerShell 5.1...  [More Info Here](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-6) on how to install PSCore.  This is the cross platform PowerShell and everyone should look to start moving this direction as well.    
* Install the MSI, I suggest to use PS Core 7+, since it is based on .net core 3.0 and said to support [90% PS modules now](https://www.petri.com/what-you-need-to-know-about-powershell-7)...
  * I didn't check the psremoting box during install.  I am thinking it may be more allowing than I like..  Not sure yet, to be continued..  
  * **Update** - So far so good, didn't need to enable psremoting on client to remote to server.  
* New profile path for PowerShell core:  
  * `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`  
* By default It was not there...  Run these two commands:  
  * `new-item -path ~\Documents\ -name PowerShell -ItemType Directory`  
  * `copy-item C:\<pathTo>\Microsoft.PowerShell_profile.ps1 -Destination ~\Documents\PowerShell`  
    * now restart the PS Session.  

### !! Deprecated Notes Below !!
The following is working with PSReadline, which had issues noted below.  Use PSCore instead to fix the colorization.  Or if stuck with PS 5.1, cuz corp, then these commands may work, but had issues again after upgrading to 1909, and the reason I finally moved to Core...  

**PSReadLine Profile Colorization Issues, even with new install of 1903**  

* The first one is to add the PSGallery, not trusted by default.  
  * I chose to trust 'ad hoc' or as needed, since anyone pretty much can commit to this repo, or at least it felt like it...  
  * `Install-Module PowerShellGet –Repository PSGallery –Force`  
* This command will then install the latest PSReadline from the gallery.  
  * `Install-Module -Name PSReadLine -AllowPrerelease -verbose -scope AllUsers -force`  
* Validate all is installed with the latest PSReadline, mine is version "2.0.0-rc2".  
  * `Get-InstalledModule psreadline | fl *`

Best source found on this, to me it helps explain why I am having troubles with this, plainly... https://devblogs.microsoft.com/commandline/new-experimental-console-features/   
Other references to some newer issues submitted, mostly blaming PSReadline as the place to fix:  
[1]: https://github.com/PowerShell/PowerShell/issues/7812    
[2]: https://github.com/PowerShell/PowerShell/issues/7037   
This feature may be something to look into, since I believe this is related to the 'newer' API as opposed to the old API I am using in the profile wrapping `$host.ui.rawui`.  
Feature link to look into: https://github.com/microsoft/terminal/issues/1796   
I don't like to download additional tools, but I keep seeing a reference to ColorTools for PS:  
https://devblogs.microsoft.com/commandline/introducing-the-windows-console-colortool/  
Repo:  https://github.com/microsoft/terminal/tree/master/src/tools/ColorTool  

***Previous PSReadLine troubleshooting notes***  
You only need to do the above steps mentioned in the PowerShell Profile section above.    
* doing a remove module fixes my colorizations:
  * `remove-module psreadline`  
  * However, you do lose all the great things in PSReadline, like copy/paste, history, etc.  
* They have patched this in Beta2.0.0.4 for me.  I tried the RC2 and it is giving me a weird colorization error:  
![error](./img/weirdUI_color.png)
* Its a very odd behavior but after running this command you could once again pass strings to the version param as opposed to creating "system.Version" type using  `[system.version]::new()`  
  * `Install-Module PowerShellGet –Repository PSGallery –Force`  
  * Then restart restart your PS session.  Maybe reboot, TODO - Update me!
It was stating that the module was not in a valid module path, which it was in two places.  
List the contents of each currently loaded PSModulePath in $env:  
`($env:PSModulePath).split(";") |foreach { gci -Verbose $_}`
It also had an error that I need to run as admin, when I was indeed doing that.  Reboot definitely fixed this one...
* Now you can run these commands to get the beta version working:  
  * `Install-Module -Name PSReadLine -AllowPrerelease -verbose -scope AllUsers -force`  
  Maybe delete this next one:
  * `import-module -Name psreadline -MinimumVersion 2.0.0 -Force`  
* References to this issue, and still fighting it in 1903:  
    [1]: https://github.com/MicrosoftDocs/PowerShell-Docs/issues/2688  
    [2]: https://github.com/lzybkr/PSReadLine/issues/818  
    [3]: https://github.com/lzybkr/PSReadLine/issues/774  
    [4]: https://github.com/Microsoft/console/issues/276  
    [5]: https://github.com/microsoft/terminal/issues/372  
* Another issue on the latest referencing RawUI is the old API... Need to get with the new?  
    [6]: https://github.com/PowerShell/PSReadLine/issues/1110