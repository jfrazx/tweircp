package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl


set wicked "something wicked this way comes"

test capitalize_shouldCapitalizeWord {
  Test: tweircp::capitalize "word" == "Word"
} -body {
  ::tweircp::capitalize "word"
} -result "Word"

test capitalize_shouldCapitalizeFirstWordOnly {
  Test: tweircp::capitalize "more than one word" == "More than one word"
} -body {
  ::tweircp::capitalize "more than one word"
} -result "More than one word"

test capitalizeEvery_willCapitailzeEveryWord {
  Test: tweircp::capitalizeEvery "something wicked this way comes" == "Something Wicked This Way Comes"
} -body {
  tweircp::capitalizeEvery $wicked
} -result "Something Wicked This Way Comes"

test capitalizeEvery_willCapitalizeEveryWordSplitOnUnderscore {
  Test tweircp::capitalizeEvery "something_wicked_this_way_comes" == "Something Wicked This Way Comes"
} -body {
  tweircp::capitalizeEvery [join $wicked _] _
} -result "Something Wicked This Way Comes"


cleanupTests
