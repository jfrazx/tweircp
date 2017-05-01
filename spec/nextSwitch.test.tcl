package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set parameters "skipped -S something --wat false wicked this way --comes true"

test nextSwitch_shouldGetIndexOfSwitchedArguments {
  Test: tweircp::nextSwitch "skipped -S something --wat false" == 1
} -body {
  tweircp::nextSwitch $parameters
} -result 1

test nextSwitch_shouldGetIndexOfSwitchedArgumentsStaringAtIndex {
  Test: tweircp::nextSwitch "skipped -S something --wat false" 2 == 3
} -body {
  tweircp::nextSwitch $parameters 2
} -result 3

test nextSwitch_shouldGetIndexOfSwitchedArgumentsStaringAtIndex {
  Test: tweircp::nextSwitch "skipped -S something --wat false wicked this way --comes true" 3 == 8
} -body {
  tweircp::nextSwitch $parameters 3
} -result 8


cleanupTests
