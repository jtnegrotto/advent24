require 'strscan'

class Interpreter
  class Parser
    attr_reader :scanner

    def initialize(input)
      @scanner = StringScanner.new(input)
    end

    # Primitive parsers

    def match_string(string)
      -> { scanner.scan(/#{Regexp.escape(string)}/) }
    end

    def match_regexp(regexp)
      -> { scanner.scan(regexp) }
    end

    # Combinators

    def sequence(*parsers)
      -> {
        results = []
        parsers.each do |parser|
          result = parser.call
          return nil unless result
          results << result
        end
        results
      }
    end

    def choice(*parsers)
      -> {
        parsers.each do |parser|
          result = parser.call
          return result if result
        end
        nil
      }
    end

    def repeat(parser)
      -> {
        results = []
        while (result = parser.call)
          results << result
        end
        results
      }
    end

    def optional(parser, default: :optional)
      -> { parser.call || default }
    end

    def skip_until(parser)
      -> {
        while !scanner.eos?
          result = parser.call
          return result if result

          scanner.skip(/./m) || break
        end
        nil
      }
    end

    def map(parser, &block)
      transform(parser) do |result|
        result&.map(&block) || nil
      end
    end

    def transform(parser, &block)
      -> {
        result = parser.call
        result&.then(&block) || nil
      }
    end

    # High-level parsers

    def function_name
      choice(match_string('mul'), match_string("don't"), match_string("do"))
    end

    def open_paren
      match_string('(')
    end

    def close_paren
      match_string(')')
    end

    def number
      transform(match_regexp(/\d+/), &:to_i)
    end

    def comma
      match_string(',')
    end

    def argument
      number
    end

    def arguments
      transform(
        sequence(
          argument,
          optional(
            map(
              repeat(sequence(comma, argument)),
              &:last
            ),
            default: []
          )
        ),
        &:flatten
      )
    end

    def function_call
      transform(
        sequence(
          function_name,
          open_paren,
          optional(arguments, default: []),
          close_paren
        )
      ) do |name, _, args, _|
        { function: name, arguments: args }
      end
    end

    def program
      repeat(skip_until(function_call))
    end

    def each
      program.call.each do |instruction|
        yield instruction
      end
    end
  end

  attr_reader :state

  def initialize(input)
    @parser = Parser.new(input)
    @state = { enabled: true, sum: 0 }
  end

  def call
    @parser.each do |instruction|
      case instruction
      in { function: 'mul', arguments: [a, b] }
        @state[:sum] += a * b if @state[:enabled]
      in { function: 'do', arguments: [] }
        @state[:enabled] = true
      in { function: "don't", arguments: [] }
        @state[:enabled] = false
      else
        # Ignore invalid instructions like any other junk data
      end
    end

    @state[:sum]
  end
end

puts Interpreter.new(ARGF.read).call
