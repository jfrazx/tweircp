package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set dictionary [dict create \
  something [list alias 0] \
  wicked [list alias 1] \
]

test isAlias_determinePassedPropertyIsAlias {
  Test: Determine if passed property is alias for another property
} -body {
  tweircp::isAlias $dictionary something
} -result 0

test isAlias_determinePassedPropertyIsAlias {
  Test: Determine if passed property is alias for another property
} -body {
  tweircp::isAlias $dictionary wicked
} -result 1


set dictionary [dict create \
  something [list options "first"] \
  wicked [list options "rest"] \
  this [list options "required"] \
  way [list options "required"] \
  comes [list options "required"] \
]

test findOptions_determineOptionExistsForAnyProperty {
  Test: Determine if passed option exists with any property of dict
} -body {
  tweircp::findOption $dictionary "rest"
} -result wicked

test findOptions_determineOptionExistsForAnyProperty {
  Test: Get an empty list if no property exists with option
} -body {
  tweircp::findOption $dictionary "range"
} -result [list]

test findOptions_determineOptionExistsForAnyProperty {
  Test: Get the first item back if multiple properties exist with option
} -body {
  tweircp::findOption $dictionary "required"
} -result this

test findOptions_determineOptionExistsForAnyProperty {
  Test: Get all properties back if multiple properties exist with option
} -body {
  tweircp::findOption $dictionary "required" 1
} -result [list this way comes]


cleanupTests
