package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set ::lastbind "!help"

set options {}
set usage "--- %bind% Options ---------------"

proc puthelp { message } {
  puts $message
}

test help_buildHelpFromOptions {
  Test: Should format usage with ::lastbind
} -body {
  tweircp::buildHelp $options $usage
} -result {{--- !help Options ---------------}}

set options {{way.secret.required.integer "This is a secret parameter"}}

test help_ShouldNotIncludeSecretOptions {
  Test: Should ignore secret values
} -body {
  tweircp::buildHelp $options ""
} -result {}

set options {{this.required self "This, self, it's all about the instance"}}

test help_ShouldAppendValues {
  Test: Shoud append values
} -body {
  tweircp::buildHelp $options ""
} -result {{<--this> <this>                         | This, self, it's all about the instance}}

set options {{something.first.upcase.alpha "Something in the air tonight"}}

test help_ShouldNotAppendValues {
  Test: Should not append values when modifier first used
} -body {
  tweircp::buildHelp $options ""
} -result {{<something>                             | Something in the air tonight}}

set options {{t.alias this "Alias for --this"}}

test help_ShouldSetAlias {
  Test: Should set alias
} -body {
  tweircp::buildHelp $options ""
} -result {{<-t>                                    | Alias for --this}}

set options {{c.boolean 1 "A boolean with a default value"}}
test help_ShouldModifySingleSwitches {
  Test: Should generate help for single switches
} -body {
  tweircp::buildHelp $options ""
} -result {{<-c>                                    | A boolean with a default value}}

set options [list \
  {something.first.upcase.alpha "Something in the air tonight"} \
  {wicked.arg.downcase people "Life is like a box of wickedness"} \
  {this.required self "This, self, it's all about the instance"} \
  {t.alias this "Alias for --this"} \
  {way.secret.required.integer "This is a secret parameter"} \
  {c.boolean 1 "A boolean with a default value"} \
  {o "An optional boolean with no default value (That's not entirely true, TWEIRCP will assign false(0), you just haven't made a default)"} \
  {m.range.alnum.trimright.required "Switch that will take a range of arguments"} \
  {e.rest.trim "This unswitched property will have all remaining content assigned"} \
  {s.required.capitalize.only.these.are.the.only.valid.options "Only must be used last, everything after is considered a possible option"}
]

