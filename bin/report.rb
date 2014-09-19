#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require(:default)

class RubySourceAnalyzer
  attr_reader :parser, :source

  def self.load_file(filename)
    new(File.read(filename))
  end

  def initialize(source)
    @source = source
    parse_source!
  end

protected

  def parse_source!
    @parser = YARD::Parser::Ruby::RubyParser.parse(@source)
  end
end

class Report < Struct.new(*%i{ lines empty_lines comments })
  def initialize
    members.each { |param| self[param] = 0 }
  end

  def show
    members.inject([]) do |str, param|
      str << "#{param} = #{self[param]}"
    end.join("\n")
  end
end

class ReportGenerator
  def initialize(filename)
    @filename = filename
    @analyzer = RubySourceAnalyzer.load_file(filename)
  end

  def report
    @report ||= generate_report!
  end

  def generate_report!
    Report.new.tap do |r|
      @analyzer.source.split("\n").each do |line|
        r.lines += 1
        r.empty_lines += 1 if line =~ /\A\s*\z/
      end

      # We could print all comments or any other tokens here
      r.comments = @analyzer.parser.tokens.count { |t| t[0] == :comment || t[0] == :embdoc_beg }
    end
  end
end

# By default analyze passed file or self
if $0 == __FILE__
  rg = ReportGenerator.new(ARGV.shift || __FILE__)
  puts rg.report.show
end
