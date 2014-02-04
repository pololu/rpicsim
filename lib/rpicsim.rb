require_relative 'rpicsim/version'
require_relative 'rpicsim/sim'
require_relative 'rpicsim/call_stack_info'

# TODO: add a feature for Flash size reports
# TODO: add a feature for RAM usage reports

# TODO: add a feature for calculating the minimum and maximum iteration
#   time from one point in the program to another
#   (as a special case, this lets you calculate the iteration time of the
#     main loop if both points are the same)

# TODO: add matchers: have_value(44), have_value.in(0..3), and maybe:
#    have_value.between(0, 14)     (like RSpec built-in matcher)
#    have_value.within(3).of(56)   (like RSpec built-in matcher)