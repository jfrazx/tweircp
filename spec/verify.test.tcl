package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set dictionary [dict create something wicked this way comes now]
set keys [dict keys $dictionary]

test verify_allKeysShouldExist {
  Test: tweircp::verify [dict create something wicked this way comes now] [list something this comes] == true
} -body {
  tweircp::verify $dictionary $keys
} -returnCodes 0 -result "something wicked this way comes now"

set keys [linsert $keys 1 wicked]

test verify_shouldThrowError {
  Test: tweircp::verify [dict create something wicked this way comes now] [list something wicked this comes]
} -body {
  tweircp::verify $dictionary $keys
} -returnCodes { error } -result "missing expected key 'wicked' from dictionary"

cleanupTests
