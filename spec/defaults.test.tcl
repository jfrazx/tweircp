package require tcltest
namespace import ::tcltest::*
source ../lib/tweircp.tcl

set options [list {something.first.upcase.alpha "Something in the air tonight"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: first, upcase, alpha
} -body {
  tweircp::defaults $options
} -result {something {required 1 secret 0 alias 0 value {} type alpha transform upcase options first processed 0 help {Something in the air tonight}}}

set options [list {wicked.arg.downcase people "Life is like a box of wickedness"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: arg, downcase
} -body {
  tweircp::defaults $options
} -result {wicked {required 0 secret 0 alias 0 value people type {} transform downcase options arg processed 0 help {Life is like a box of wickedness}}}

set options [list \
  {this.required self "This, self, it's all about the instance"} \
  {t.alias this "Alias for --this"} \
]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: required, alias
} -body {
  tweircp::defaults $options
} -result {this\
  {required 1 secret 0 alias 0 value self type {} transform {} options {} processed 0 help {This, self, it's all about the instance}}\
t\
  {required 0 secret 0 alias 1 value this type {} transform {} options {} processed 0 help {Alias for --this}}}

set options [list {way.secret.required.integer "This is a secret parameter"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: secret, required, integer
} -body {
  tweircp::defaults $options
} -result {way {required 1 secret 1 alias 0 value {} type integer transform {} options {} processed 0 help {This is a secret parameter}}}

set options [list {c.boolean 1 "A boolean with a default value"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: boolean with default
} -body {
  tweircp::defaults $options
} -result {c {boolean 1 required 0 secret 0 alias 0 value 1 type boolean transform {} options {} processed 0 help {A boolean with a default value}}}


set options [list {o "An optional boolean with no default value (That's not entirely true, TWEIRCP will assign false(0), you just haven't made a default)"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: boolean without default
} -body {
  tweircp::defaults $options
} -result {o {boolean 1 required 0 secret 0 alias 0 value 0 type {} transform {} options {} processed 0 help {An optional boolean with no default value (That's not entirely true, TWEIRCP will assign false(0), you just haven't made a default)}}}


set options [list {m.range.alnum.trimright.required "Switch that will take a range of arguments"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: required range alnum trimright
} -body {
  tweircp::defaults $options
} -result {m {required 1 secret 0 alias 0 value {} type alnum transform trimright options range processed 0 help {Switch that will take a range of arguments}}}


set options [list {e.rest.trim "This unswitched property will have all remaining content assigned"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: rest trim
} -body {
  tweircp::defaults $options
} -result {e {required 0 secret 0 alias 0 value {} type {} transform trim options rest processed 0 help {This unswitched property will have all remaining content assigned}}}


set options [list {s.required.capitalize.only.these.are.the.only.valid.options "Only must be used last, everything after is considered a possible option"}]

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: required capitalize only
} -body {
  tweircp::defaults $options
} -result {s {only {these are the only valid options} required 1 secret 0 alias 0 value {} type {} transform capitalize options only processed 0 help {Only must be used last, everything after is considered a possible option}}}


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

test defaults_buildDictOfDefaultOptions {
  Test: Build a dictionary of defaults values and options: All together now!
} -body {
  tweircp::defaults $options
} -result {something\
{required 1 secret 0 alias 0 value {} type alpha transform upcase options first processed 0 help {Something in the air tonight}}\
wicked\
{required 0 secret 0 alias 0 value people type {} transform downcase options arg processed 0 help {Life is like a box of wickedness}}\
this\
{required 1 secret 0 alias 0 value self type {} transform {} options {} processed 0 help {This, self, it's all about the instance}}\
t\
{required 0 secret 0 alias 1 value this type {} transform {} options {} processed 0 help {Alias for --this}}\
way\
{required 1 secret 1 alias 0 value {} type integer transform {} options {} processed 0 help {This is a secret parameter}}\
c\
{boolean 1 required 0 secret 0 alias 0 value 1 type boolean transform {} options {} processed 0 help {A boolean with a default value}}\
o\
{boolean 1 required 0 secret 0 alias 0 value 0 type {} transform {} options {} processed 0 help {An optional boolean with no default value (That's not entirely true, TWEIRCP will assign false(0), you just haven't made a default)}}\
m\
{required 1 secret 0 alias 0 value {} type alnum transform trimright options range processed 0 help {Switch that will take a range of arguments}}\
e\
{required 0 secret 0 alias 0 value {} type {} transform trim options rest processed 0 help {This unswitched property will have all remaining content assigned}}\
s\
{only {these are the only valid options} required 1 secret 0 alias 0 value {} type {} transform capitalize options only processed 0 help {Only must be used last, everything after is considered a possible option}}}

cleanupTests
