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
        James Lawler
        DATE:11/20/2014
      
      .EXAMPLE
      
      . $env:UserProfile\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1

      Dot sourcing the profile, but if you have it in this locatino it should source by default. Maybe you changed it?

#>

#For this first part I am pretty much just following this page:
#http://www.howtogeek.com/50236/customizing-your-powershell-profile/

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
  # here i attempted to modify the current shell to have some defaults that I prefer.
  # I tried to base it off the current screen size to position to and all that.  Epic Fail...
  # $shell = $host.ui.RawUI
  # # now get the shell size
  # $maxHeight = $shell.MaxPhysicalWindowSize.Height
  # $maxWidth = $shell.MaxPhysicalWindowSize.Width
  # # now get the buffer settings, we want lotso scroll
  # $myBuffer = $shell.buffersize
  # # now getting the active windowsize interface to modify
  # $myWindow = $shell.Windowsize
  # # modify stuffs
  # $MyWindow.Height = ($MaxHeight)
  # $MyWindow.Width = ($Maxwidth-2)
  # $MyBuffer.Height = (9999)
  # $MyBuffer.Width = ($Maxwidth-2)
  # $shell.set_bufferSize($MyBuffer)
  # $shell.set_windowSize($MyWindow)
  #there is this weird initial positioning that keeps screwing this up. 
  # .net option to tickle: System.Management.Automation.Host.Coordinates  -- nope...
  # You can use the process namespace, first get current pid - Already Done!  $pid var...
  # Determined that I don't really care.  I can hotkey to the position I want...

  # now check if you are admin or not, so you know not to screw around.
  #http://superuser.com/questions/237902/how-can-one-show-the-current-directory-in-powershell
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
  if ($isAdmin) {
    # modifying the prompt variable, one for admin and the other for reg user.
    function prompt {
      # we want to see if the last result ($?) ran successfully
      $(if ($?) {
        write-host ":) " -ForegroundColor "Green" -NoNewline
      }
      else {
        write-host ":( " -ForegroundColor "Red" -NoNewline
      }) + $(write-host "$(get-location)" -foregroundcolor "darkred" -NoNewline) +
      ">"
    }
    # set admin window settings
    # custom mods of the terminal shell:
    $Shell = $Host.UI.RawUI
    $size = $Shell.BufferSize
    $size.width=240
    $size.height=9999
    $shell.BackgroundColor = "Black"
    $shell.ForegroundColor = "DarkRed"
    $shell.windowtitle = "You are PowerShell'n as an Administrator!"
  }
  else {
    # regular user prompt modify
    function prompt {
      # we want to see if the last result ($?) ran successfully
      # based on that result color the face and make frown or smile.
      $(if ($?) {
        write-host ":) " -ForegroundColor "Green" -NoNewline
      }
      else {
        write-host ":( " -ForegroundColor "Red" -NoNewline
      }) + $(write-host "$(get-location)" -foregroundcolor "green" -NoNewline) +
      ">"
    }
    # custom mods of the shell:
    $Shell = $Host.UI.RawUI
    $size = $Shell.BufferSize
    $size.width=240
    $size.height=9999
    $shell.BackgroundColor = "Black"
    $shell.ForegroundColor = "Green"
    $shell.windowtitle = "You are PowerShell'n as a normal user."
  }
}
else 
{
  write-host "For some reason you don't have the $host var set."
  $shell = $host
  if ($shell){
    write-host "Yay you got the host var, now do while?"
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
  # we have to break up each path with a semicolon
  $allPaths = $allpaths + ";" + $location
}
# now add those valid paths to env path
$env:Path = $env:Path + $allPaths

#good ol' . ("dot") sourcing in powershell
# if you have a custom functions you want to load, like internal corp functions, use this.
if (test-path "$userRootDir\Documents\repo\scripts\powershell\functions.ps1") {
  . $userRootDir\Documents\repo\scripts\powershell\functions.ps1
}

#variables, to make it easier to cd into
$pygit = "$userRootDir\Documents\repo\git\projects\Scripts\Python"
$pymods = "$userRootDir\Documents\analyst\tools\DidierStevensSuite"

# by default $home is the root of your profile, who stores stuff there
# you can still cd $home and get to the root of profile..., but I want docs.
$goToNewHome = $userRootDir + "\Documents"
set-location $goToNewHome
# Set the "~" shortcut value for the FileSystem provider
# it doesn't go to the root of your profile like *nix, but docs, which is where I want to be usually in PowerShell
(get-psprovider 'FileSystem').Home = $goToNewHome



Function Global:draw-figure
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

