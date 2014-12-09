# Ruby spec demo

# Cycles:

while true
  puts "abc"
end

puts "qwe" while 1

begin
  puts "def"
end while 1 < 2

until 5 < 10
  puts "hello"
end

puts "yee" until false

begin
  puts "infinite"
end until false

for variable in ["expression"]
  puts variable
end

# Not cycles (these are usual method calls, according to lang spec):

(1..2).each do |i|
  puts "Not"
end

3.times do
  puts "a real"
end

[4,5,6].map { "cycle" }
