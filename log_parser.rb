require 'set'

class LogParser
  # Here we can put some real regex for an uri and an ip,
  # but let's stick with the simple one, since it's not the scope of the task
  # and almost all ips in webserver.log are invalid as well.
  # Also we can use split(" ") if we don't care about log format verification.
  # Will be much faster, especially on big logs

  LOG_REGEX = /^([\S]{1,}) (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/.freeze

  def initialize(filename)
    @filename = filename
  end

  def parsed_data
    return @parsed_data if @parsed_data
    File.open(@filename, "r") do |file_data|
      file_data.each_line do |line|
        url, ip = parse_line_with_regex(line)
        next unless url
        process_line(url, ip)
      end
    end
    @parsed_data
  end

  def sort_by(value_key, &block)
    sorted_arr = parsed_data.sort do |h1,h2|
      h2[1][value_key] <=> h1[1][value_key]
    end
    sorted_arr.each do |url, value|
      yield(url, value[value_key])
    end
  end

  private

  def process_line(url, ip)
    @parsed_data = {} unless @parsed_data
    @parsed_data[url] = {count: 0, unique_count: 0, ips: Set.new} unless @parsed_data[url]
    @parsed_data[url][:count] += 1
    @parsed_data[url][:unique_count] += 1 unless @parsed_data[url][:ips].include?(ip)
    @parsed_data[url][:ips].add(ip)
  end

  def parse_line_with_regex(line)
    match = LOG_REGEX.match(line)
    return nil unless match
    [ match[1], match[2] ]
  end
end
