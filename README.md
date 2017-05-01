# TWEIRCP

This is TWEIRCP, pronounced Twerp (the 'C' is silent), or Twerk (the 'P' is silent?)... or perhaps neither of those. Either way, this is most assuredly    
**T**he **W**orst **E**ver **IRC** **P**arser, or possibly **T**he **W**orst **E**ver **I**RC **R**eadline **C**ommand **P**arser? No matter, it is certainly the worst. EVER!   
Modeled, in part, after cmdline and for use with Eggdrop IRC bots, Twerp makes option parsing so easy you'll want to Twerk!   

Should be considered ALPHA quality, not all features implemented. Improvements and docs to come...


## Basic Usage 

```tcl 

package require tweircp

# Some proc 
# arg = "myThing"
proc doStuff { nick uhost hand chan arg } {
  if { [catch { set result [::tweircp::parse arg [list \
      {"opt" "1" "this is an option with a default value"}\
      {"o.alias" "opt" "alias for opt"}\
      {"thing.first" "this must be first"}\
    ]]] } err] } {

    return [puthelp "PRIVMSG $chan : There was an error processing your request: $err"]
  }

  set thing [dict get $result thing]

  if { [dict get $result opt] && $thing eq "myThing" } {
    # do something
  } else {
    # do something else
  }
```
