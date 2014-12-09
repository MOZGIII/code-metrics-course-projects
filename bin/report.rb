#!/usr/bin/env ruby
require 'bundler/setup'
Bundler.require(:default)

require 'ostruct'

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

class Report < OpenStruct
  def show
    array = []
    each_pair do |key, val|
      array << "#{key} = #{val}"
    end
    array.join("\n")
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

  def count_tokens(tokens)
    @analyzer.parser.tokens.count { |t| tokens.member?(t[0]) }
  end

  def show_tokens(tokens)
    @analyzer.parser.tokens.each do |t|
      p t if tokens.member?(t[0])
    end
  end

  def count_keywords(keywords)
    @analyzer.parser.tokens.count { |t| t[0] == :kw && keywords.member?(t[1]) }
  end

  def count_ast(&block)
    count = 0
    @analyzer.parser.ast.traverse do |node|
      count += 1 if block.call(node)
    end
    count
  end

  def count_ast_unique(&block)
    hash = Hash.new(0)
    @analyzer.parser.ast.traverse do |node|
      val = block.call(node)
      hash[val] += 1 if val != nil
    end
    hash
  end

  def generate_report!
    Report.new.tap do |r|
      r.lines = 0
      r.empty_lines = 0

      @analyzer.source.split("\n").each do |line|
        r.lines += 1
        r.empty_lines += 1 if line =~ /\A\s*\z/
      end

      # We could print all comments or any other tokens here
      r.comments = count_tokens([:comment, :embdoc_beg])

      r.ops = count_tokens([:op])
      r.ops_max_depth = 1 # in ruby every operator is toplevel
      r.loops = count_keywords(["for", "while", "until"])
      r.loops2 = count_ast { |node| node.loop? } # other method, same result

      r.num_op = count_ast { |node| node.call? } # count method calls as exec operators
      r.num_methods = count_ast { |node| node.def? } # ruby only has methods, no functions
      r.num_op_to_f = r.num_op.to_f / r.num_methods

      idents = count_ast_unique do |node|
        # p node[0][0] if node.type == :var_field || node.type == :var_ref
        node[0][0] if node.type == :var_field || node.type == :var_ref
      end

      r.idents = idents.size
      r.max_spen = idents.values.max
    end
  end
end

# By default analyze passed file or self
if $0 == __FILE__
  rg = ReportGenerator.new(ARGV.shift || __FILE__)
  puts rg.report.show
end
