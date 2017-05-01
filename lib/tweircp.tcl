# tweircp.tcl

# -- type checking --
#item.boolean  -- the next parameter must be a boolean value
#item.integer  -- the next parameter must be an integer value
#item.double   -- the next parameter must be a double value
#item.digit    -- the next parameter must be a digit
#item.alpha    -- the next parameter must be an alpha character
#item.alnum    -- the next parameter must be an alphanumeric character


# -- argument options --
#item           -- boolean
#item.alias     -- designates this property is an alias of another
#item.arg       -- single argument
#item.range     -- one or more arguments
#item.secret    -- option not listed in help
#item.only.everything.after.is.all.i.may.be  -- this must be the last argument
#item.required  -- a required option
#item.first     -- a required, unswitched option that will always be first
#item.first_or  -- a required, possibly switched option that will always be first if unswitched !!!!!! not implemented
#item.rest      -- everything that remains after distribution of all other parameters, this option will not be switched

# -- transformations --
#item.upper     -- apply string toupper to argument
#item.lower     -- apply string tolower to argument
#item.cap       -- capitalize the first character in the first word
#item.capall    -- capitalize the first character in every word
#item.trim      -- removes whitespace from the beginning and end of the string
#item.trimleft  -- removes whitespace from the beginning of the string
#item.trimright -- removes whitespace from the end of the string

# eggdrop stuff
# find bind type

package provide tweircp 0.0.1
package require lodash

namespace eval ::tweircp {
  namespace export parse parsed defaults chomp nextSwitch sys_defaults

  set sys_defaults [dict create \
    silent 0          \
    clean 1           \
    syntax ""         \
    target ""         \
    empty_error 0     \
    syntax_on_empty 0 \
    unknown_error 1   \
    usage "--- %bind% Options ---------------" \
  ]

  set optionable [list "alias" "arg" "range" "secret" "only" "required" "first" "first_or" "rest"]
  set transformable [list "capitalize" "cap" "capall" "caps" "tolower" "lower" "downcase" "toupper" "upper" "upcase" "trim" "trimright" "trimleft" "triml" "trimr"]
  set typeable [list "alnum" "alpha" "boolean" "digit" "double" "integer"]
}

namespace eval ::ircp {
  namespace export [namespace import ::tweircp::*]
}

# non-destructively parse passed options
proc ::tweircp::parse { arglist parameters { opts {} } } {
  ::tweircp::parsed arglist $parameters $opts
}

# destructively parse passed options
proc ::tweircp::parsed { arglist parameters { opts {} } } {
  upvar 1 $arglist arguments
  set defaults [::tweircp::defaults $parameters]
  set options [::tweircp::options $opts]
  #set caller [lindex [split [info level [expr [info level] - 2]]] 0]

  # @todo change this, make the response more flexible without adding additional burdensome options
  if { ([_::empty $arguments] && [dict get $options syntax_on_empty]) || [_::includes $arguments "--syntax"] } {

    if { ![dict get $options silent] } {
      puthelp "PRIVMSG [dict get $options target] :[dict get $options syntax]"
    }

    return false

  } elseif { [_::includes $arguments "--help"] } {
      #process help (does nothing currently)
      return [::tweircp::buildHelp $parameters]
  }

  if { [catch { set result [::tweircp::parser arguments $defaults $options] } err] } {
    if { ![dict get $options silent] } {
      return -code error $err
    }
    return false
  }

  return $result
}

proc ::tweircp::parser { args_list defaults options } {
  upvar 1 $args_list arguments

  set rest [list]
  set splitted [::tweircp::prepare $options]
  set _rest_ [::tweircp::findOption $defaults "rest"]

  while { [llength $splitted] } {
    set arg [_::flatten [_::shift splitted]]

    if { ![_::startsWith $arg -] } {
      _::push rest $arg
      continue
    }

    set prop [_::shift arg]

    if { [_::contains $prop =] } {
      _::unshift arg [string range $prop [expr { [string first = $prop]+1 }] end]
      set prop [lindex [split $prop =] 0]
    }

    ::tweircp::assign [expr { [_::startsWith $prop --] ? [string trim $prop -] : [split [string trim $prop -] ""] }] $options

    if { ![_::empty $arg] } { _::push rest $arg }
  }

  dict set defaults [expr { [_::empty $_rest_] ? "_rest_" : $_rest_ }] value [_::flatten $rest]

  ::tweircp::build $defaults $options
}

proc ::tweircp::prepare { options } {
  upvar 1 defaults defaults arguments arguments rest rest
    # remove text color and styling
  if { [dict get $options clean] } {
    set arguments [::tweircp::clean $arguments]
  }

  if { ~[set index [_::indexOf $arguments --]] } {
    dict set defaults -- value [_::slice $arguments [expr { $index+1 }]]
    _::splice arguments $index
  }

  set splitted [::tweircp::chomp arguments]

  if { ![_::empty [set first [::tweircp::findOption $defaults "first"]]] } {
    set range [_::includes [dict get $defaults $first options] "range"]
    set take [_::flatten [_::shift splitted]]

    dict set defaults $first value [expr { $range ? [_::splice take 0] : [_::shift take] }]
    dict set defaults $first processed 1

    if { ![_::empty $take] } { _::unshift rest $take }
  }

  return $splitted
}

proc ::tweircp::assign { properties options } {
  upvar 1 defaults defaults arg arg

  while { [llength $properties] } {
    set property [_::pop properties]

    # Do this instead of check for dict exists property
    # if allowing unknown properties is enabled and that unknown property is
    # included more than once, it gets added the first time and the second it
    # will exist, but the other necessary properties will not, thus resulting in
    # an error
    if { ![_::includes [dict keys $defaults] $property] } {
      if { ![dict get $options unknown_error] } {
        dict set defaults $property value [expr { [_::empty $arg] ? 1 : [_::flatten [_::splice arg 0]] }]
      } else {
        # if the property is unknown and unknown_error is set, return an error
        return -code error "Can not process unknown property: `$property`"
      }
      continue
    }

    # check if the property we are processing is an alias,
    # if so, switch to what it references
    if { [::tweircp::isAlias $defaults $property] } {

      set property [dict get $defaults $property value]
    }

    if { [dict get $defaults $property processed] } { continue }

    dict set defaults $property processed 1

    if { [dict exists $defaults $property boolean] } {

      dict set $defaults $property value [expr { ![dict get $defaults $property value] }]
      continue
    }

    set range [_::includes [dict get $defaults $property options] "range"]

    dict set defaults $property value [expr { $range ? [_::splice arg 0] : [_::shift arg] }]
  }
}

# @todo document
proc ::tweircp::build { dictionary options } {
  set result [list]

  dict for { key infos } $dictionary {
    set value [dict get $infos value]

    # ensures key was processed as a default and not added on the fly, which will be missing other needed keys
    if { [dict exists $infos required] } {
      if { [::tweircp::isAlias $dictionary $key] } { continue }
      set secret [dict get $infos secret]

      if { [dict get $infos required] && [_::empty $value] } {
        # if a required value is not present, return an error
        return -code error [expr { $secret ? "Missing value for a required property" : "Missing a value for required property: $key" }]
      }

      set value [::tweircp::transforms $value [dict get $infos transform]]

      ::tweircp::typeCheck $dictionary $key $value

      # this key will only exist if option found while setting defaults
      if { [dict exists $infos only] } {
        if { ![_::includes [dict get $infos only] $value] } {

          return -code error [expr { $secret ? "A supplied value is not allowed" : "$key value $value is not allowed: [dict get $dictionary $key only]" }]
        }
      }
    }

    _::push result $key
    _::push result $value
  }

  return $result
}

# @todo
proc ::tweircp::buildHelp { } {

}

# Process typechecking for values
proc ::tweircp::typeCheck { dictionary key value } {
  foreach type [dict get $dictionary $key type] {
    if { ![string is $type -strict $value] } {
      return -code error [expr { [dict get $dictionary $key secret] ? "A supplied value was of an invalid type" : "$key value '$value' is not of the required type: $type" }]
    }
  }

  return true
}

# Process all string transformations on passed string according to transformations
proc ::tweircp::transforms { string transformations } {
  _::reduce $transformations {
    { string transform } {
      ::tweircp::transform $string $transform
    }
  } $string
}

# Create the working options from the system defaults and the passed options lists
#
# @param [string[]] options: List of lists of options
# @return [dict]  -- A dictionary of command options
proc ::tweircp::options { options } {
  set defaults $::tweircp::sys_defaults

  foreach { element value } $options {
    if { ![_::includes [dict keys $defaults] $element] } {
      return -code error "unknown script option '$element'"
    }

    dict set defaults $element $value
  }

  return $defaults
}

# Change the default script options
#
# @param [string[]] opts: The list of lists of new script options
# @return [void]
proc ::tweircp::setOptions { opts } {
  set ::tweircp::sys_defaults [::tweircp::options $opts]
}

# Setup default values, possible transformations, type checking and argument options from the passed
# parameters list
#
# @param [string[]] parameters: The list of lists that are argument options
# @return [dict]  -- A dict of defaults and options
proc ::tweircp::defaults { parameters } {
  set defaults [dict create]
  set verify [list]

  foreach param $parameters {
    set property [_::first [set opts [split [_::first $param] "." ]]]
    set modifiers [_::rest $opts]
    set help [lindex $param end]

    if { [llength $param] != 3 } {
      if { [_::include $modifiers "alias"] } {
        set default $help
        set help "alias for $default"
      } else {
        set default ""
      }
    } else {
      set default [lindex $param 1]
    }

    if { ~[set index [_::indexOf $modifiers "only"]] } {
      dict set defaults $property only [string trim [_::splice modifiers [incr index]]]
    }

    if { [_::empty $modifiers] || [_::includes $modifiers "boolean"] } {
      if { [_::empty $default] || ![string is boolean $default] } {
        set default 0
      }

      dict set defaults $property boolean 1
    }

    foreach opt [list "required" "secret" "alias"] {
      set val 0

      if { ~[set index [_::indexOf $modifiers $opt]] } {
        _::splice modifiers $index 1
        set val 1
      }

      # adds the referenced property to list to be verified of existence
      if { $val && $opt eq "alias" } { _::push verify $default }

      dict set defaults $property $opt $val
    }

    if { [_::includes $modifiers "first"] } {
      dict set defaults $property required 1
    }

    set partition [::tweircp::partition $modifiers]

    dict set defaults $property value $default
    dict set defaults $property type [lindex $partition 0]
    dict set defaults $property transform [lindex $partition 1]
    dict set defaults $property options [lindex $partition 2]
    dict set defaults $property processed 0
    dict set defaults $property help $help
  }

  ::tweircp::verify $defaults $verify
}

proc ::tweircp::partition { modifiers } {
  set partition [_::partition $modifiers {
    { element } {
      _::includes $::tweircp::typeable $element
    }
  }]

  set types [lindex $partition 0]

  set partition [_::partition [lindex $partition 1] {
    { element } {
      _::includes $::tweircp::transformable $element
    }
  }]

  list $types {*}$partition
}

# Determines if the passed property is an alias for another
#
# @param [dict] dictionary: The dict to check
# @param [string] property: The property to determine alias status
# @return [boolean]
proc ::tweircp::isAlias { dictionary property } {
  dict get $dictionary $property alias
}

# Find a key in the passed dictionary with options including property
#
# @param [dict] dictionary: The dictionary to check for option property
# @param [string] property: The property to search
# @param [boolean] all: Optionally find all keys matching options property
# @return [list|string] -- The found key or list of keys
proc ::tweircp::findOption { dictionary property { all false } } {
  set result [list]

  foreach key [dict keys $dictionary] {
    if { [dict exists $dictionary $key options] } {
      if { [_::includes [dict get $dictionary $key options] $property] } {

        if { !$all } { return $key }

        _::push result $key
      }
    }
  }

  return $result
}

# Verifies that the passed dictionary has all the keys in verifiable, else it returns an error
#
# @param [dict] dictionary: The dict to check for keys
# @param [string[]] verifiable: A list of string keys to confirm existence
# @return [void]  -- returns error if a key is missing
proc ::tweircp::verify { dictionary verifiable } {
  foreach key $verifiable {
    if { ![dict exists $dictionary $key] } {

      return -code error "missing expected key '$key' from dictionary"
    }
  }

  return $dictionary
}

# Chops the passed arguments into a list of lists based on switches
#
# @param [string] args_list: The list of arguments to chomp up
# @return [list[list]]
proc tweircp::chomp { args_list } {
  upvar 1 $args_list arguments
  set result [list]

  while { [llength $arguments] } {
    _::push result [_::splice arguments 0 [::tweircp::nextSwitch $arguments 0]]
  }

  return $result
}

# Using the passed list and optional starting index, returns the numeric index of the next switch
# i.e (anything starting with -)
#
# @param [string] list: The string to search for the next switch
# @param [integer] index: The optional index to start searching from
# @return [integer]
proc tweircp::nextSwitch { list { index 0 } } {
  if { [_::empty $list] || $index > [llength $list] } { return $index }
  if { ![string is integer -strict $index] || $index < 0 } { set index 0 }

  set length [llength $list]

  for { incr index } { $index < $length } { incr index } {
    if { [string index [lindex $list $index] 0] eq "-" } {
      break
    }
  }

  return $index
}

# Transforms the given string based on 'transformation'
#
# @param [string] string: The string to transform
# @param [string] transformation: The operation to perform on the passed string
# @return [string]
proc tweircp::transform { string transformation } {
  switch -exact -- $transformation {
    capitalize -
    cap {
      ::tweircp::capitalize $string
    }
    caps -
    capall {
      ::tweircp::capitalizeEvery $string
    }
    tolower -
    lower -
    downcase {
      string tolower $string
    }
    toupper -
    upper -
    upcase {
      string toupper $string
    }
    trim {
      string trim $string
    }
    trimright -
    trimr {
      string trimright $string
    }
    trimleft -
    triml {
      string trimleft $string
    }
  }
}

# Capitalize the first word in the passed string
#
# @param [string] word: The string to capitalize
# @return [string]
proc ::tweircp::capitalize { word } {
  string toupper $word 0 0
}

# Capitalize every word in the passed string or list
#
# @param [string] list: The string to capitalize every word
# @param [string] split: An optional character to split the string with, defaults to " "(space)
# @return [string]
proc ::tweircp::capitalizeEvery { list { split " " } } {
  _::reduce [split $list $split] {
    { sentence word } {
      concat $sentence [::tweircp::capitalize $word]
    }
  } {}
}

# Remove color and style codes from the passed string
#
# @param [string] string: The string to cleanse
# @return [string]
proc ::tweircp::clean { string } {
  ::tweircp::stripColor [::tweircp::stripStyle $string]
}

# Remove text coloring from the passed string
#
# @param [string] color: The string to remove color
# @return [string]
proc ::tweircp::stripColor { color } {
  regsub -all -- {(\\x03\d{0,2}(,\d{0,2})?|\\u200B)} $color ""
}

# Remove text styling from the passed string
#
# @param [string] style: The string to remove style
# @return [string]
proc ::tweircp::stripStyle { style } {
  regsub -all -- {\\x(0F|02|1D|16|1F)} $style ""
}
