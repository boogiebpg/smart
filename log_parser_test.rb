require 'minitest/autorun'
require_relative "log_parser"

class LogParserTest < Minitest::Test
  def test_incorrect_log_lines_skipping
    parser = LogParser.new("test_data/incorrect.log")
    assert_equal ["/help_page/1"], parser.parsed_data.keys
  end

  def parser
    @parser ||= LogParser.new("test_data/correct.log")
  end

  def data
    parser.parsed_data
  end

  def incorrect_log_values
    [
      "/test/uri incorrect_ip",
      "one two 1.2.3.4",
      "/test/uri 1.2.3",
      "/test/uri 1.2.3.4.5",
    ]
  end

  def test_count
    assert_equal 3, data["/help_page/1"][:count]
    assert_equal 2, data["/contact"][:count]
    assert_equal 1, data["/home"][:count]
  end

  def test_unique_count
    assert_equal 2, data["/help_page/1"][:unique_count]
    assert_equal 2, data["/contact"][:unique_count]
    assert_equal 1, data["/home"][:unique_count]
  end

  def test_ips
    assert_equal ["126.318.035.038", "126.318.035.066"], data["/help_page/1"][:ips].to_a
    assert_equal ["184.123.665.067", "184.123.665.167"], data["/contact"][:ips].to_a
    assert_equal ["184.123.665.067"], data["/home"][:ips].to_a
  end

  def test_parse_line_with_regex_method_success
    parse_results = parser.send(:parse_line_with_regex, "/test/uri 1.2.3.4")
    assert_equal ["/test/uri", "1.2.3.4"], parse_results
  end

  def test_process_line_method_treat_count_and_unique_count_correctly
    assert_nil parser.parsed_data["/test/uri"]
    parser.send(:process_line, "/test/uri", "1.2.3.4")
    assert_equal 1, parser.parsed_data["/test/uri"][:count]
    assert_equal 1, parser.parsed_data["/test/uri"][:unique_count]
    parser.send(:process_line, "/test/uri", "1.2.3.4")
    assert_equal 2, parser.parsed_data["/test/uri"][:count]
    assert_equal 1, parser.parsed_data["/test/uri"][:unique_count]
  end

  def test_parse_line_with_regex_method_exception
    incorrect_log_values.each_with_index do |line, index|
      assert_nil parser.send(:parse_line_with_regex, line[index])
    end
  end

  def test_sort_by_visits
    results = []
    parser.sort_by(:count) do |url, visits|
      results << "#{url} #{visits} visits"
    end
    assert_equal "/help_page/1 3 visits", results[0]
    assert_equal "/contact 2 visits", results[1]
    assert_equal "/home 1 visits", results[2]
  end

  def test_sort_by_unique_views
    results = []
    parser.sort_by(:unique_count) do |url, unique_views|
      results << "#{url} #{unique_views} unique views"
    end
    assert_equal "/help_page/1 2 unique views", results[0]
    assert_equal "/contact 2 unique views", results[1]
    assert_equal "/home 1 unique views", results[2]
  end
end
