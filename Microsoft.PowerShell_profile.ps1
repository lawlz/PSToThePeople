<#
      .Synopsis
          This is my local PS profile settings.
      .DESCRIPTION
          This is a starter profile or helper profile.
          
          There are some alias's that are created.
          It checks if you are admin or not makes the words red if admin or green if not.
          It adds some paths to your global script/cmdlet search path - easier to run commands like tshark and others.


      .Dependencies
          Powershell 5+
      
      Resources:


      .AUTHOR
        Jimmy James
        DATE:11/20/2014
      
      .EXAMPLE
      
      . $env:UserProfile\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1

      Dot sourcing the profile, but if you have it in this locatino it should source by default. Maybe you changed it?

#>

#One of the first resources I used to find help on this topic
#http://www.howtogeek.com/50236/customizing-your-powershell-profile/
#### I have not had to do this on newer(1703+) Windows 10 to get profile working ######
#before you profile do this:
# Test-Path $profile
#If nothing found then do this command:
# if (test-path $profile) {
#    New-Item -path $profile -type file –force
# }
#you should see a popup, just say OK

#alias's
set-alias ll get-childitem
set-alias wc measure-object
set-alias ifconfig ipconfig
# way to set an alias via function <-- not really alias then...
function md5sum {get-filehash -algorithm md5}
# do a man on them and see, one shows the alias's commands help
# the other shows nothing and expects those help attribs to be in the function.

# change up the terminal window
# I had some help on this one. 
# https://gallery.technet.microsoft.com/scriptcenter/Set-the-PowerShell-Console-bd8b2ad1
if ($host) {
  $Shell = $Host.UI.RawUI
  $size = $Shell.BufferSize
  $size.width=240
  $size.height=9999
  # This is goofy, but check if last ran correct and then set the prompt.
  function check-run {
    if ($?) {
        return $(write-host ":) " -ForegroundColor "Green" -NoNewline)
      }
      else {
        return $(write-host ":( " -ForegroundColor "Red" -NoNewline)
      }
  }
  # first check if in a remote pssession or not
  if ($executionContext.host.name -eq "ServerRemoteHost") {
    # I had to make a custom function to pass as one string to get the computer name to stay at the front of the prompt...
    # the remote computer name went to the end of the prompt, I had to use parts of the default prompt to make this work: Get-Item Function:\prompt
    function prompt {"PS $(check-run)$($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";}
  }
  else {
    function prompt {"$(check-run)$(get-location)> ";}
  }
  # modifying the prompt function, one for admin and the other for reg user.
  # now check if you are admin or not, so you know not to screw around.
  #http://superuser.com/questions/237902/how-can-one-show-the-current-directory-in-powershell
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
  if ($isAdmin) {
    # set admin window settings
    $shell.BackgroundColor = "Black"
    $shell.ForegroundColor = "DarkRed"
    $shell.windowtitle = "You are PowerShell'n as an Administrator!"
  }
  else {
    # running as a regular user colors
    $shell.BackgroundColor = "Black"
    $shell.ForegroundColor = "Green"
    $shell.windowtitle = "You are PowerShell'n as a normal user."
  }
}
else 
{
  # you should never see this...
  write-host "For some reason you don't have the $host var set."
  if ($shell){
    write-host "$shell is set?!, something wrong happened?"
  }
}

#since moving around a profile, may not have all the paths there in the new env
# we don't want to add paths for tab completion when not valid, this attempts that
function check-path{
  param(
    [parameter(mandatory=$true,position=0,valuefrompipelinebypropertyname=$true)]$path
  )
  if(test-path $path){
    return $path
  }
}

# create dynamic entry point, based on current env
$userRootDir = $env:USERPROFILE
# create array to add valid paths to
$paths = @()
# this may not be the best way to add a path
# just paste the valid path string in one of these, and it should do the rest.
$paths += check-path "$userRootDir\Documents\repo\tools\android-tools"
$paths += check-path "C:\Program Files (x86)\Nmap"
$paths += check-path "C:\Program Files\Git\bin"
$paths += check-path "$userRootDir\Documents\repo\scripts\powershell"
$paths += check-path "$userRootDir\Documents\repo\Tools\SysinternalsSuite"
$paths += check-path "$userRootDir\Documents\GitHub\DidierStevensSuite"
$paths += check-path "C:\Program Files\nodejs"
$paths += check-path "C:\Program Files\Python37"
$paths += check-path "$userRootDir\Documents\repo\scripts\python"
# now to create a string var to append to
[string]$allPaths = ""
foreach ($location in $paths) {
  # we have to break up each path with a semicolon, starting with a semicolon
  $allPaths = $allpaths + ";" + $location
}
# now add those valid paths to env path
$env:Path = $env:Path + $allPaths

#good ol' . ("dot") sourcing in powershell
# if you have a custom functions you want to load, like internal corp functions, use this.
if (test-path "$userRootDir\Documents\repo\scripts\powershell\functions.ps1") {
  . $userRootDir\Documents\repo\scripts\powershell\functions.ps1
}

#variables, to make it easier to cd into or run a command from:
# python3 $pygit\run.py
$pygit = "$userRootDir\Documents\repo\git\projects\Scripts\Python"
$pymods = "$userRootDir\Documents\analyst\tools\DidierStevensSuite"

# by default $home is the root of your profile, who stores stuff there
# you can still cd $home and get to the root of profile..., but I want docs.
$goToNewHome = $userRootDir + "\Documents"
set-location $goToNewHome
# Set the "~" shortcut value for the FileSystem provider
# it doesn't go to the root of your profile like *nix, but docs, which is where I want to be usually in PowerShell
(get-psprovider 'FileSystem').Home = $goToNewHome


# potentially remove, no valid use case.
Function draw-figure
{
Write-Host -ForegroundColor green @"                                            
                                            ';'                  
                                          '+;:;'#@+.             
                                         @;';::::::@@          
                                        @:;::;:::::;;@         
                                       .#::::;::::::::@          
                                       @::::::::::::::;@
                                      ,+;;::::::::::::;''        
                                      #:::::::::::::::::@        
                                      @;::::::::::::::::;;       
                                     `;::::::::::::::::::@       
                                     +:;::;;:::::;:::::::@.      
                                     @:#@++#';:::;'@;:@;:'@      
                      `              @@......::::;+:....+:;@      
        :+;+.       ,  :             @........@::;'.......':@      
        +  ,+       .. ,             #++......@::',......`@:@      
        :   #      .. `,             #,;......@;:+.#......@:@      
        :   +      ;..`              #.......`';:+;#.....;@:@      
        +.:;+     .,#@               @#......`@;:;@......@@:@      
        +,.;+     ,`+`               @@:....+@:::@@+...:@@':@      
    `   +...+    ;`...               @;@@;#@@+:::#@@@@@@:;@#     
  @@@@, +:;,+    .,..                +'#@@@@#';:::@@@@+::+@##:   
 ;@++@@ `...    ,`,`,                `@:;;;:'::::;'::';::@####.  
 :@#++@ `..,     ,..                  @;:::::::::::::;:::@#####  
  #++#@ .,..    .:..                  ;@:::::;::;;:::::::@#####
  :#@@` @;;;.   ::`                    @:;:::;:::::;::;:@######' 
   ;#@,  ''     #:`                    #'::+'#';;+'':;::@####### 
   ,;''  ;;     #:`                     @+:@@+:.,;@++::@######## 
   `;;;  `:'    +::                     ,#'#,;@@@@+,:;@@######## 
    ';;   ;:    +:+                   `  :@+;#+:@,';#@@######### 
    ''''  :;'   ;:;                        `#@#+++@@############ 
    #';'  `::+  `::'                          ;################# 
    ,''+   ;:;#  ;:'                          ;################# 
     `;::   +:;; #:;                          ;################# 
   `   :::`  ;::+.:;'                         ;################# 
       .::'`  #;:;+;:`                        #+################ 
      ` `:;:+# @;+;:###'`                    ,+################+ 
         `;:::;:'+;;#+####'                  +#################+ 
           ;:;;;;:::#+######'               :##################; 
             ,+;:;:;:#######+##,            ###################: 
                ....  .####+#####'        `+###################, 
                        `#######+###.     `####################, 
                          .#++++#+#++#'   +#+#++++++++++++++++#. 
                             ;+''++++++++.+++++++++++++++++++++;
                               :'';'''''';';;;;'''''''''''''''; 
                                 `:::::::::::,:::::::::::::::::  
                                    `......`. .................
"@
} 

Set-Alias wat draw-figure -Scope Global

