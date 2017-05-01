package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

test transform_upper {
  Test: tweircp::transform something upper == SOMETHING
} -body {
  tweircp::transform something upper
} -result SOMETHING

test transform_capitalize {
  Test tweircp::transform something capitalize == Something
} -body {
  tweircp::transform something capitalize
} -result Something

test transform_capall {
  Test: tweircp::transform "something wicked this way comes" capall == "Something Wicked This Way Comes"
} -body {
  tweircp::transform "something wicked this way comes" capall
} -result "Something Wicked This Way Comes"

test transform_downcase {
  Test tweircp::transform SOMETHING downcase == something
} -body {
  tweircp::transform SOMETHING downcase
} -result something

test transform_trimright {
  Test tweircp::transform "something wicked    " trimright == "something wicked"
} -body {
  tweircp::transform "something wicked    " trimright
} -result "something wicked"

test transform_trimleft {
  Test tweircp::transform "    something wicked" trimleft == "something wicked"
} -body {
  tweircp::transform "    something wicked" trimleft
} -result "something wicked"

test transform_trim {
  Test tweircp::transform "    something wicked    " trim == "something wicked"
} -body {
  tweircp::transform "    something wicked    " trim
} -result "something wicked"

test transforms_trimleftUpcase {
  Test tweircp::transforms "    something wicked" "trimleft upcase" == "SOMETHING WICKED"
} -body {
  tweircp::transforms "    something wicked" "trimleft upcase"
} -result "SOMETHING WICKED"

test transforms_trimrDowncase {
  Test tweircp::transforms "    SOMETHING WICKED     " "trimleft upcase" == "    something wicked"
} -body {
  tweircp::transforms "    SOMETHING WICKED    " "trimr downcase"
} -result "    something wicked"

test transforms_upcaseDowncaseCaps {
  Test tweircp::transforms "something wicked" "upcase downcase caps" == "Something Wicked"
} -body {
  tweircp::transforms "something wicked" "upcase downcase caps"
} -result "Something Wicked"


cleanupTests
