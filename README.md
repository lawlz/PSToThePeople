# PowerShell to the People!

Working Repo for my Preso called, 'PowerShell to the People'  

## PowerShell Lessons Learned from an InfoSec Guy

### Abstract

0-60 course over PowerShell and how I use it for every day tasks in InfoSec.  I plan to go over high level topics that would have helped me in the beginning and then take everyone for a ride into what this shell has to offer.

## Presentation Outline

1. Basics I wish I knew early on
    * Verb-noun wat?!  Syntax caveats and ways around
    * man for windows? Yeah, finally! 
    * Get-member - and why I tend to run this at least once a day.
    * format outputs - cuz you can
    * what tha $_,?,%, $?,"`n" etc
2. PowerShell Profiles
    * What they are
    * How to use and my use cases
    * Walk through mine
3. Never open ADUC again!  ADTools to the rescue!
    * How many active user objects
    * How many domain admins
        * admincount=1 caveats
    * compare some user to group memberships
    * stale passwords or no password needed for [ADObjects](https://blogs.technet.microsoft.com/russellt/2016/05/26/passwd_notreqd/)
4. Automate IR
    * Tickle outlook, use case, code, and demo
5. Show the Power of the Shell  <--time permitting
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
            * What are the property values
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
          * New PSCore profile path:  
            `$home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`  
        * Must Change Execution Policy to Work - I use RemoteSigned
          `set-executionpolicy remotesigned` 
          * PSCore already was set to this..  
    * Lets go through the profile setting
        * Set Alias's you like  
        * color that console
        * update paths

3. PS AD Tools - **tested only on 2016 functional domain**
    * Why use a GUI when all the power of ADUC is in PS ADTools
        * It scales and is quicker to get results.
    * Find the functional level of the domain with one commandlet!  
        * `get-adrootDSE` or like this `(Get-ADRootDSE).domainFunctionality`
    * Who has a password to never expire in your domain?  
        * `get-aduser -Filter "PasswordNeverExpires -eq 'True'"`
        * Or even if they do not require a [password](https://blogs.technet.microsoft.com/russellt/2016/05/26/passwd_notreqd/)!
            * `Get-ADUser -Filter 'useraccountcontrol -band 32' -properties * | ft samaccountname,enabled,lastlogindate,PasswordLastSet`
            * Or like this now: `Get-ADUser -Filter 'PasswordNotRequired -eq $True'`
        * What about those stale passwords?  Checks if older than 180 days:
            * `get-aduser -Filter "enabled -eq 'True'" -properties * | where {$_.passwordlastset -le (get-date).adddays(-180)}`
    * Get the number of service accounts, if you have a naming standard that requires svc- at the first of the name
        * `(get-aduser -filter "samaccountname -like 'svc-*'").count`

4. Ticklin' the .Nets - Incident Response Use Case
    * Situation, had to manually update .msg file to send a phishing/malware removal request
        * too cumbersome and the perfect job for PowerShell
    * send-malwareMail to the rescue!
        * sadly no adoption because could not validate the email template before sending
        * even dumping the message to standard out didn't help, wants GUI...
    * enter, tickling the Outlook API!!
        * Pops open an outlook message allowing to modify via GUI before sending
        * more easily adopted and accepted by others in IR

5. Advanced Ops
    * Are you so attached to your C# you can't give it up?
    * Wanna add that DLL?
    * Run solely in memory?  

6. Questions
    * Code and references found in this repo.
    ~~~
    IEX (New-Object Net.Webclient).DownloadString(“https://raw.githubusercontent.com/lawlz/PSToThePeople/master/getStuff.txt”)
    ~~~

## References

Automatic variables to call - [good ol' built-ins](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-6)  

More information about the [powershell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1).

Great resource on converting C/C++ types (generally the way MS shows you in their dev docs) to [.net types powershell can use](http://www.pinvoke.net/).  

Great profile information with additional PS Profile links at the bottom of [page](https://blogs.technet.microsoft.com/askpfeplat/2018/06/25/powershell-profiles-processing-illustrated/)  

### BlueTeam Misc Resources  
* A SANS maintained repo of PS commands that are good to [know](https://github.com/sans-blue-team/blue-team-wiki/blob/gh-pages/Tools/PowerShell.md)  
* I stumbled across this repo of nice scripts.  From API to AD tickling, this has a robust set to start [playing with](https://github.com/WiredPulse/PowerShell)  


# Ignore?

These last sections are mainly used as information for CFP input and can be ignored.

## Overview

The goal of this presentation is to share knowledge about PowerShell that would be valuable for anyone that wants to learn more, no matter what level of PowerShell foo you are at.  The ultimate hope is that everyone walks away with use cases and tools they could use today.  

First I will walk through some tips, tricks and how to's, mainly things I wish I knew when I started using PowerShell.  Then I will go over some automation use cases of where you could save time using PowerShell for incident response or even just to quickly gather AD configuration data.  It is all possible in this shell.

## Outline

1. get-help - we all need it..
2. PS has a .profile?!  And how I use it.
3. Never use ADUC again - Powershell AD Tools and the cool things therein
4. send-malwareMail.ps1 <– IR Automation Use Case
5. You like your C# code that much, lets add-type   <-- Time permitting

## Reference

[Github repo link to follow along](https://github.com/lawlz/PSToThePeople)

## Bio

Passionate and paranoid information technology professional, who also loves to serve the community.  Been in IT for over 15 years, with almost 10 years of that in Information Security. I have been fortunate enough to have had the opportunity to work on just about everything there is to do in InfoSec, with some deep knowledge in SIEM and reverse/forward web proxy technologies. My current focus is on infrastructure and endpoint automation mostly for hardening and resiliency purposes.

Passionate and paranoid infosec professional, who loves to serve the community.  Worked in IT Ops for over 15 years, 10 of that in InfoSec.