require 'mediawiki_api'
require_relative '../wikiutils'
require_relative '../generalutils'

def edit(old, new)
  backlinkarray = []
  JSON.parse($other_mw.get_backlinks(old))["query"]["backlinks"].each do |title|
    backlinkarray.push(title["title"])
  end
  backlinkarray.each do |i|
    if $other_mw.get_wikitext(i) == false
      puts "#{i} could not be edited because its content is nil. Continuing...\n"
      next
    else
      text = $other_mw.get_wikitext(i)
      text = text.gsub(/\{\{[Uu]\|#{old}/, "{{U|#{new}")
      text = text.gsub(/\[\[[Uu]ser\:#{old}/, "[[User:#{new}")
      text = text.gsub(/\[\[[Uu]ser talk\:#{old}/, "[[User talk:#{new}")
      text = text.gsub(/[Ss]pecial\:Contributions\/#{old}/, "Special:Contributions/#{new}")
      $mw.edit(title: i, text: text, bot: 1, summary: "Fixing user links.")
      puts "#{i} has been edited.\n"
    end
  end
end

puts "Which Wiki would you like to edit?\n"
wiki = gets.chomp
puts "How many username links would you like to change this session?\n"
num = gets.chomp.to_i
initial = 0

puts "Signing into #{wiki}..."
$mw = MediawikiApi::Client.new("http://#{wiki}.gamepedia.com/api.php")
$mw.log_in(General_Utils::File_Utils.get_secure(0).chomp, General_Utils::File_Utils.get_secure(1).chomp)
$other_mw = Wiki_Utils::Client.new("http://#{wiki}.gamepedia.com/api.php")
puts "Successfully signed into #{wiki}!"

if num.is_a? Numeric
  while initial < num
    puts "Which username would you like to change?\n"
    name = gets.chomp
    puts "What would you like to replace the username with?\n"
    new_name = gets.chomp

    edit(name, new_name)
    initial += 1
  end
  puts "Successfully completed changing username links provided by user. Exiting with exit code 0."
else
  puts "SEVERE: NUMBER OF USERNAMES PROVIDED IS NOT A VALID NUMBER. EXITING WITH EXIT CODE 1"
  exit 1
end
exit 0
