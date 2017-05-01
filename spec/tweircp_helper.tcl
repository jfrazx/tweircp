lappend auto_path [file join [file dirname [info script]] ".."]
package require tcltest

namespace import ::tcltest::*

configure -file "*.test.tcl"

## Usage:
# configure -file patternList
# configure -notfile patternList
# configure -match patternList
# configure -skip patternList
# matchFiles patternList = shortcut for configure -file
# skipFiles patternList = shortcut for configure -notfile
# match patternList = shortcut for configure -match
# skip patternList = shortcut for configure -skip

### Examples:

## Run Only Selective Files

# Run only tests in sum.test
# tclsh tweircp_spec.tcl -file sum.test

# Same as above
# tclsh tweircp_spec.tcl matchFiles sum.test

# Run all files with names start with s
# tclsh all.tcl -file 's*.test.tcl'


## Skipping Files

# Will run all, but sum.test
# tclsh all.tcl -notfile sum.test

# Same as above
# tclsh all.tcl skipFiles sum.test

# Skips all files with names start with a or b
# tclsh all.tcl -notfile 'a*.test b*.test'


## Run Based on Test Names

# Run only tests whose names start with 'square_'
# tclsh all.tcl -match 'square_*'

# Same as above
# tclsh all.tcl match 'square_*'

# Only tests with Negative or Zero in their names
# tclsh all.tcl -match '*Negative* *Zero*'

# Tests names that end with Zero
# tclsh all.tcl -match '*Zero'


## Skip Tests Based on Test Names

# Skip tests that start with sum
# tclsh all.tcl -skip 'sum*'

# Skip tests that start with sum
# tclsh all.tcl skip 'sum*'

# Skip tests that contains either Positive or Negative in their names
# tclsh all.tcl -skip '*Positve* *Negative*'

if { [llength $argc] } {
  foreach { action arg } $::argv {
    if { [string match -* $action] } {
      configure $action $arg
    } else {
      $action $arg
    }
  }
}

runAllTests
