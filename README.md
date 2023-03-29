# PowerShell to the People!

## Working Repo for me Preso    

Use and abuse freely and currently 'Bounded' within the Unlinense lawyer jargon [stuffs](https://github.com/lawlz/PSToThePeople/blob/master/LICENSE).  

Setup Information can be found
 [here](https://github.com/lawlz/PSToThePeople/blob/master/SETUP.md), if curious.  

## Abstract

0-60 course over PowerShell and how I use it for every day tasks in InfoSec.  I plan to go over high level topics that would have helped me in the beginning and then take everyone for a ride into what this shell has to offer.

## Presentation Outline

1. Basics I wish I knew early on
    * Verb-noun wat?!  Syntax caveats and ways around
    * man for windows? Yeah, finally! 
    * Hands don't have to leave the keyboard to copy and paste anymore!!!
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

1. **Basics**  
* Use PS version 6+ (7 is out now too, but at least 6)
    * Least amount of bugs and seems the developer/Microsoft focus now
    * Uses .net core, but still exposes .net framework as well as the runtime engine
    * Also, cross platform, can run on *nix and Mac!
* cmdlet naming convention
    * Does seem bloated at first, but can become more natural feeling  
    * verb-noun.ps1 construct
        * approved verb list (get-verb - seriously will list approved verbs...)
        * You don't have to conform - use case
            * All the internal PS scripts for my internal compX usages starts like this:
                `CompXGet-Computer.ps1`
            * That way tab completion worked for internal commands, your IDE will get mad.  Linters and their verb standards...
* get-help - man for Windows
    * man is the built in alias now for get-help, especially with PSCore
    * search for name of cmdlet, function, script, or workflow in the first parameter 
        * If you explicity state it, it goes to it
        * If not, it searches help topic titles
            * if not found then show topics that include that word
* Getting around in the terminal
    * Your hands don't have to leave the keyboard to copy/paste!
    * Have you ever seen a terminal with a built-in editor?  ctrl+shift+<-
* get-member - exploring objects
    * I use this extensively to see what methods are available for an object
        * What is the type of the object
        * What are the property values
* format output options
    * the many ways, from csv, xml, windows form type, list, table, etc
        * convertto-csv, convertto-xml, out-gridview, format-list, format-table, out-host

2. **PowerShell Profiles**
* Like in Bash, but PS has it too!
    * some configuration required - depedning on how you are accessing PS
        * VSCode, ISE, PowerShell, PSCore, all have a different profile location...
    * Common default path, for current user in PowerShell:
        `$home\Documents\WindowsPowerShell\profile.ps1` 
        * New PSCore profile common default path:  
        `$home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`  
    * Must Change Execution Policy to Work - I use RemoteSigned
        `set-executionpolicy remotesigned` 
        * PSCore already was set to this..  
* Lets go through the profile setting
    * Set Alias's you like  
    * color that console
    * update paths  
  

3. **PS AD Tools** - **tested only on 2016 functional domain**  
* Why use a GUI when all the power of ADUC is in PS ADTools
    * It scales and is quicker to get results.
    * It takes time at first, but try and force yourself into it.  

There is a big caveat here.  Core has not ported the activedirectory module yet, but you still have options!  
* Query AD with pscore, using [.net methods](https://adsecurity.org/?p=113).  
    * Or even better, [import AD module from pssession!](https://www.itprotoday.com/powershell/import-powershell-module-remote-machine)
    * You can even prefix the noun in the command
    ```
    $cred = Get-Credential
    $sess = New-PSSession -ComputerName PRD-DC1.lawlz.us -Credential $cred -Authentication negotiate -UseSSL  
    Import-Module -PSSession $sess -Name ActiveDirectory -prefix fromExt
    ```

* Find the functional level of the domain with one commandlet!  
    * `get-adrootDSE` or like this `(Get-ADRootDSE).domainFunctionality`
* Dump dang near all object properties of a user account in AD
    * `get-aduser -Identity adm-jimmy -Properties *`
* Who has a password to never expire in your domain?  
    * `get-aduser -Filter "PasswordNeverExpires -eq 'True'"`
    * Or even if they do not require a [password](https://blogs.technet.microsoft.com/russellt/2016/05/26/passwd_notreqd/)!
        * `Get-ADUser -Filter 'useraccountcontrol -band 32' -properties * | ft samaccountname,enabled,lastlogindate,PasswordLastSet`
        * Or like this now: `Get-ADUser -Filter 'PasswordNotRequired -eq $True'`
    * What about those stale passwords?  Checks if older than 180 days:
        * `get-aduser -Filter "enabled -eq 'True'" -properties * | where {$_.passwordlastset -le (get-date).adddays(-180)}`
* Get the number of service accounts, if you have a naming standard that requires svc- at the first of the name
    * `(get-aduser -filter "samaccountname -like 'svc-*'").count`

4. **Ticklin' the .Nets - Incident Response Use Case**
    * Situation, had to manually update .msg file to send a phishing/malware removal request
        * too cumbersome and the perfect job for PowerShell
    * send-malwareMail to the rescue!
        * sadly no adoption because could not validate the email template before sending
        * even dumping the message to standard out didn't help, wants GUI...
    * enter, tickling the Outlook API!!
        * Pops open an outlook message allowing to modify via GUI before sending
        * more easily adopted and accepted by others in IR

5. **Advanced Ops**
    * Are you so attached to your C# or even VBScript you can't give it up?
        * Try this:  

```
$testcode = @"
using System;

namespace testfun
{
    public static class hello
    {
        public static void get()
        {
            Console.WriteLine("Hello World!");
        }
    }
}
"@
```

* Wanna add that DLL?
* Run solely in memory?  

6. **Questions**
* Code and references found in this repo.
* Fun Command to run, of course understand before running...
    * `IEX (New-Object Net.Webclient).DownloadString(“https://raw.githubusercontent.com/lawlz/PSToThePeople/master/getStuff.txt”)`

## References

Automatic variables to call - [good ol' built-ins](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-6)  

More information about the [powershell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-5.1).  
Great profile information with additional PS Profile links at the bottom of [this page](https://blogs.technet.microsoft.com/askpfeplat/2018/06/25/powershell-profiles-processing-illustrated/)  

Great resource on converting C#/VB types (generally the way MS shows you in their dev docs) to [.net constructs that powershell can use](http://www.pinvoke.net/).  


### BlueTeam Misc Resources  
* A SANS maintained repo of PS commands that are good to [know](https://github.com/sans-blue-team/blue-team-wiki/blob/gh-pages/Tools/PowerShell.md)  
* I stumbled across this repo of nice scripts.  From API to AD tickling, this has a robust set to start [playing with here](https://github.com/WiredPulse/PowerShell)   

