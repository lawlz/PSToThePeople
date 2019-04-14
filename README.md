# Overview

This is the working directory of the presentation 'Powershell to the People'


## Outline

* Basics I wish I knew early on
    * Verb-noun wat?!
    * Help Get-Help -showwindow
    * Get-member
    * format outputs
    * whatif | confirm
    * what tha $_,?,%, $?,"`n" etc
* PowerShell Profiles
    * How you can get one
    * What I use mine for
        * Looky at mine
* Never open ADUC again!
    * How many active users
    * How many passwords never set on enabled users
    * How many people in a group
        * compare some groups
* Tickle Outlook to send mail
    * IR example and use case
* Show the Power of the Shell
    * add-type to add custom types  
        * dll load and call
        * You like your C# so much, run in PS!




## Rundown

1. Basics
    * cmdlet naming convention
        * Does seem bloated at first, but can become more natural feeling  
        * verb-noun.ps1 construct
            * approved verb list (get-verb - seriously will list approved verbs...)
            * You don't have to conform - use case
                * All the internal PS scripts for my internal compX usages starts like this:
                    `CompXGet-Computer.ps1`
                * That way tab completion worked for internal commands, your IDE will get mad..
    * get-help - man for Windows
        * man seems to be a built in alias now for get-help...
        * search for name of cmdlet, function, script, or workflow in the first parameter 
            * If you explicity state it, it goes to it
            * If not, it searches help topic titles
                * if not found then show topics that include that word
    * get-member - exploring objects
        * I use this extensively to see what methods are available for an object
            * What is the type of the object
    * format output options
        * the many ways, from csv, xml, windows form type, list, table, etc
            * convertto-csv, convertto-xml, out-gridview, format-list, format-table, out-host

2. PowerShell Profiles
    * Like in Bash, but PS has it too!
        * some configuration required - depedning on how you are accessing PS
            * VSCode has a path
            * ISE has a path
            * PS Terminal has a path..
        * Luckily there is a common default path, for current user:
            `$home\Documents\WindowsPowerShell\profile.ps1`  
        **Must Change Execution Policy to Work** 
    * Lets go through mine
        * Found some issues with coloring the command line... 
            * It has something to do with PSReadLine... See here:   
                [1]: https://github.com/MicrosoftDocs/PowerShell-Docs/issues/2688  
                [2]: https://github.com/lzybkr/PSReadLine/issues/818  
                [3]: https://github.com/lzybkr/PSReadLine/issues/774  
                [4]: https://github.com/Microsoft/console/issues/276  
                * doing a remove module fixes my colorizations, and I still get features of this module somehow...  
                `remove-module psreadline`  
                * They say however, PSReadline is the new way of setting colours is better and the way forward... I guess I will conform.  
        * Set Alias's you like  


3. PS AD Tools
    * Why use a GUI when all the power of ADUC is in PS ADTools
        * It scales and is much quicker to get results.
    * find the functional level of the domain with one commandlet!  
        * `get-adrootDSE` or like this `(Get-ADRootDSE).domainFunctionality`
    * Who has a password to never expire in your domain?  
        * `get-aduser -Filter "PasswordNeverExpires -eq 'True'"`
    * Find out who are all members of Domain Admins Group

4. Send some mails
    * Situation, had to update .msg file to send a phishing removel/malware endpoint events
        * too cumbersome and the perfect opp to flex some powershell skills
    * send-mailMessage to the rescue!
        * sadly no adoption because could not validate the email template
        * even dumping the message didn't help
    * enter, tickling the Outlook API!!
        * Pops open an outlook message with all the stuffs
        * more easily adopted and accepted by others in IR

5. Add Your Type Right Here
    * Are you so attached to your C# you can't give it up?



## Code


#TODO
#figure this out
#IEX (New-Object Net.Webclient).DownloadString(“https://github.com/lawlz/PSToThePeople/blob/7705c7ef36942185ffbaae93d1497ec7c6fe1100/getStuff.txt”)



## References

Automatic variables to call - [good ol' built-ins](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-6)  
More information about the [powershell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1  )

Weird command cannot be found then hit enter again and sure enough, [its there..](https://social.msdn.microsoft.com/Forums/en-US/2c40c928-ce5e-460d-a1ef-30c5ef494846/why-does-it-say-command-cannot-be-found?forum=WindowsIoT)  
I believe the problem is, PS is searching the client machine and not the remote session.  Which is definitely the case, installed activedirectory module on local machine and it fixed that weird error.    

Great resource on converting C/C++ types (generally the way MS shows you in their dev docs) to [.net types powershell can use](http://www.pinvoke.net/)  

Great profile information with additional PS Profile links at the bottom of [page](https://blogs.technet.microsoft.com/askpfeplat/2018/06/25/powershell-profiles-processing-illustrated/)  

WinRM can be difficult to setup.  Had to enable the [winrm quickconfig](https://4sysops.com/wiki/enable-powershell-remoting/)  
This link help create the [HTTPS listener](https://www.visualstudiogeeks.com/devops/how-to-configure-winrm-for-https-manually)  
Once you configure the cert, you can run the export-certificate cmdlet like so:  
    `$cert = gci Cert:\LocalMachine\My\CertThumbprint`  
    `Export-Certificate -Cert $cert -FilePath "C:\Users\Administrator\Documents\newCert" -Type cert`  
I then mounted the C$ share and copied down the cert that I exported above.  
Finally the fix, run PS with *elevated* creds from client [side Powershell](https://serverfault.com/questions/337905/enabling-powershell-remoting-access-is-denied/568228#568228)  
I was able to remote from a non-domain joined machine.  


BlueTeam Resources:  
[Some common commands to know](https://github.com/sans-blue-team/blue-team-wiki/blob/gh-pages/Tools/PowerShell.md)  
[Nice little repo of scripts.](https://github.com/WiredPulse/PowerShell)


Install RSAT, now a 'Feature On Demand' but the GUI sucks and never really installs..
[I had to use DISM to do it](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-capabilities-package-servicing-command-line-options)  
First get the list of capabilities online.  
`dism /online /get-capabilities`  
Then copy the name and add it to the capabilityName param  
`dism /add-capability /online /CapabilitYName:"Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"`