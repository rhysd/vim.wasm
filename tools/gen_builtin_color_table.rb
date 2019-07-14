#!/usr/bin/env ruby


File.foreach('runtime/rgb.txt', chomp: true).map{|l| l.split(' ', 4)}.each do |line|
  rgb = line[0, 3].join(', ')
  name = line[3].downcase
  space = name.size >= 18 ? "\t" : name.size >= 10 ? "\t\t" : "\t\t\t"
  puts "        {(char_u *)\"#{name}\",#{space}RGB(#{rgb})},"
end

# From src/term.c
puts <<-EOS
        {(char_u *)"darkyellow",		RGB(0x8B, 0x8B, 0x00)}, /* No X11 */
        {(char_u *)"lightmagenta",		RGB(0xFF, 0x8B, 0xFF)}, /* No X11 */
        {(char_u *)"lightred",			RGB(0xFF, 0x8B, 0x8B)}, /* No X11 */
EOS
