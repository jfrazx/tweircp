package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set dictionary [dict create \
  thing [list type [list boolean] secret [list false]] \
  wicked [list type [list integer] secret [list true]] \
  this [list type [list alpha] secret [list false]] \
  comes [list type [list alnum] secret [list false]] \
  ]

test types_checkTypeBoolean {
  Test: tweircp::typeCheck test value is boolean
} -body {
  tweircp::typeCheck $dictionary thing 1
} -result true

test types_shouldThrowErrorBoolean {
  Test: tweircp::typeCheck should throw error on invalid value
} -body {
  tweircp::typeCheck $dictionary thing camel
} -returnCodes { error } -result "thing value 'camel' is not of the required type: boolean"

test types_checkTypeInteger {
  Test: tweircp::typeCheck test value is integer
} -body {
  tweircp::typeCheck $dictionary wicked 23
} -result true

test types_shouldThrowErrorInteger {
  Test: tweircp::typeCheck should throw error on invalid value
} -body {
  tweircp::typeCheck $dictionary wicked camel
} -returnCodes { error } -result "A supplied value was of an invalid type"

test types_checkTypeAlpha {
  Test: tweircp::typeCheck test value is alpha
} -body {
  tweircp::typeCheck $dictionary this camel
} -result true

test types_shouldThrowErrorAlpha {
  Test: tweircp::typeCheck should throw error on invalid value
} -body {
  tweircp::typeCheck $dictionary this 23
} -returnCodes { error } -result "this value '23' is not of the required type: alpha"

test types_checkTypeAlnum {
  Test: tweircp::typeCheck test value is alnum
} -body {
  tweircp::typeCheck $dictionary comes camel23
} -result true

test types_shouldThrowErrorAlnum {
  Test: tweircp::typeCheck should throw error on invalid value
} -body {
  tweircp::typeCheck $dictionary comes \{\}
} -returnCodes { error } -result "comes value '{}' is not of the required type: alnum"


cleanupTests
