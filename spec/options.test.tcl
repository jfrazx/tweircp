package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

test systemDefaults_DetermineSysDefaults {
  Test: Show script defaults
} -body {
  ::tweircp::setOptions {}
} -result {silent 0 clean 1 syntax {} target {} chan {} nick {} empty_error 0 syntax_on_empty 0 unknown_error 1 before_return {} usage {--- %bind% Options ---------------}}

set opts [list silent 1 clean 0 syntax "command opt1 --switch -opt=what" target "#somechannel" empty_error 1 syntax_on_empty 1 unknown_error 0 usage "--- %command% Help Options ---------------"]

test systemDefaults_changeSysDefaults {
  Test: Change the script defaults
} -body {
  tweircp::setOptions [list silent 1 clean 0 syntax "command opt1 --switch -opt=what" target #somechannel empty_error 1 syntax_on_empty 1 unknown_error 0 usage "--- %command% Help Options ---------------"]
} -result {silent 1 clean 0 syntax {command opt1 --switch -opt=what} target #somechannel chan {} nick {} empty_error 1 syntax_on_empty 1 unknown_error 0 before_return {} usage {--- %command% Help Options ---------------}}

cleanupTests

