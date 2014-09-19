=begin

Hello and welcome!

This test shows the insane complexity of comment varitaions in ruby.
Do not use this to test other people code since it's truly difficult to satisfy.

(comment #1)

=end

# Comment #2, can chain

=begin
Comment number 3
Multiline stuff allowed
# Not a new comment here
=end

"# nope, I'm a string"

<<-HEREDOC
  Heredoc semantics supported: # not a coment
  # niether this one is

# nor this one

=begin
 nor this
=end

HEREDOC

# The 4-th one, real comment

"#{
  # comment inside a string block, goes as 5
  "Also recusrively: #{
    # 2-nd level block, works, now it's 6

=begin
  And 7-th,
  multiline one
=end
  }"
}"

# Since we use AST parser and token analyzer from the leading documentation generator for Ruby, it should work really well.
# Comments count is a hell of a task for normal people. Not much easier than writing a compiler for the particular language.
# There were 3 comments in a row (including this one), which technically count as 3, so count ther as 3 and now we're at 10

# Overall this file contains 52 lines, 16 of which are empty lines, and 11 comments, incuding this one
