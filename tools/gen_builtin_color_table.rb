#!/usr/bin/env ruby


File.foreach('runtime/rgb.txt', chomp: true).map{|l| l.split(' ', 4)}.each do |line|
  rgb = line[0, 3].join(', ')
  name = line[3].downcase
  space = name.size >= 18 ? "\t" : name.size >= 10 ? "\t\t" : "\t\t\t"
  puts "        {(char_u *)\"#{name}\",#{space}RGB(#{rgb})},"
end
