#!/usr/bin/ruby

require 'set'

MATRIX = 4
MAX_ROW = MAX_COL = MATRIX - 1

WORDS = 'words.txt'

RELATIVES = [
  [  0,  1 ],   # 0 N
  [  1,  1 ],   # 1 NE
  [  1,  0 ],   # 2 E
  [  1, -1 ],   # 3 SE
  [  0, -1 ],   # 4 S
  [ -1, -1 ],   # 5 SW
  [ -1,  0 ],   # 6 W
  [ -1,  1 ],   # 7 NW
]

VALUES = {}

def resolve_relative(cur, rel)
  [ cur[0] + rel[0], cur[1] + rel[1] ]
end

def connect(neighbor)
  x = neighbor[0]
  y = neighbor[1]
  key = neighbor.join('')

  if ((x < 0) or (x > MAX_ROW)) or
     ((y < 0) or (y > MAX_COL))
    #puts "DEBUG: out of bounds!"
    return
  end

  if @ancestors.include?(neighbor)
    #puts "DEBUG: you're already in use!"
    #print "DEBUG: "; p @ancestors
    return
  end

  if ! @string.empty?
    re = Regexp.new("^#{@string}#{VALUES[key]}", true)
    if @a_words.grep(re).empty?
      #puts "DEBUG: impossible prefix: '#{@string}#{VALUES[key]}'"
      return
    end
  end

  @ancestors << neighbor
  @string << VALUES[key]

  #puts "debug[#{x},#{y}] (#{VALUES[key]}): #{@string}"

  if @string.length > 2
    if @s_words.include?("#{@string}\n")
      puts "FOUND: #{@string}"
      (@results << @string.dup)
    end
  end

  RELATIVES.each do |rel|
    abs = resolve_relative(neighbor, rel)
    connect(abs)
  end

  @ancestors.delete(neighbor)
  @string.chop!
end

begin
  @a_words = File.open(WORDS).readlines
  @s_words = @a_words.to_set
rescue => e
  puts "couldnt open words file: #{e}"
  exit 1
end

puts "Enter rows, one per line:"
3.downto(0) do |i|
  j=0
  row = gets.chomp

  #if row.size == 5 and row.match(/qu/)
  #end
  
  row.split(//).each do |letter|
    VALUES["#{j}#{i}"] = letter
    j += 1
  end
end

puts "\nFinding words for you...."
@results = []

0.upto(MAX_COL).each do |col|
  0.upto(MAX_ROW).each do |row|

    root = [row,col]
    @ancestors = Set.new
    @string = ''

    @ancestors << root
    @string << VALUES[root.join('')]

    RELATIVES.each do |rel|
      abs = resolve_relative(root, rel)
      connect(abs)
    end
  end
end

puts "[done calculating]\n"
@results.sort_by { |word| word.length }.uniq.each do |shortest|
  puts shortest
end
