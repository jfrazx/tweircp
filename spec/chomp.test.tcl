package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set parameters "skipped -S something --wat false wicked this way --comes true"

test chomp_createListOfParamtersAndValues {
  Test: tweircp::chomp should chop parameters into groups based on switches
} -body {
  tweircp::chomp parameters
} -result {skipped {-S something} {--wat false wicked this way} {--comes true}}

cleanupTests
