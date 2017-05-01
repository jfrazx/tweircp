package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

test stripColor_shouldRemoveColourEncoding {
  Test: tweircp::stripColor {\x0304,02Example\x03} == Example
} -body {
  tweircp::stripColor {\x0304,02Example\x03}
} -result "Example"

test stripColor_shouldRemoveColourEncodingLeavingStyle {
  Test: tweircp::stripColor {\x0304\x1D,02Example\x03\x1D} == {\x1DExample\x1D}
} -body {
  tweircp::stripColor {\x0304,02\x1DExample\x03\x1D}
} -result {\x1DExample\x1D}

test stripStyle_shouldRemoveStyleEncoding {
  Test: tweircp::stripStyle {\x1D,02Example\x1D} == Example
} -body {
  tweircp::stripStyle {\x1DExample\x1D}
} -result Example

test stripStyle_shouldRemoveStyleEncodingLeavingColor {
  Test: tweircp::stripStyle {\x0304,02\x1DExample\x03\x1D} == {\x0304,02Example\x03}
} -body {
  tweircp::stripStyle {\x0304,02\x1DExample\x03\x1D}
} -result {\x0304,02Example\x03}

test clean_shouldRemoveStyleAndColorEncoding {
  Test: tweircp::clean {\x0304,02\x1DExample\x03\x1D} == Example
} -body {
  tweircp::clean {\x0304,02\x1DExample\x03\x1D}
} -result Example


cleanupTests
