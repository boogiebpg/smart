require_relative "log_parser"

filename = ARGV[0]
unless filename
  puts "Please provide a file name as argument."
  return
end

log_parser = LogParser.new(filename)

puts "Log sorted by visits:"
log_parser.sort_by(:count) do |url, count|
  puts "#{url} #{count} visits"
end
puts

puts "Log sorted by unique views:"
log_parser.sort_by(:unique_count) do |url, unique_views|
  puts "#{url} #{unique_views} unique views"
end
