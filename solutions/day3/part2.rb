require 'strscan'

class Interpreter
  class FunctionScanner
    FUNCTION_CALL = %r{
      (?<function_name> mul | do | don't )
      \(
        (?<function_args> (?: \d+ (?: , \d+ )* )? )
      \)
    }x

    attr_reader :scanner

    def initialize string
      @scanner = StringScanner.new(string)
    end

    def each
      until scanner.eos?
        func = scanner.scan_until(FUNCTION_CALL)
        break unless func
        yield current_instruction
      end
    end

    private

    def current_instruction
      {
        function: function_name,
        args: function_args
      }
    end

    def function_name
      scanner[:function_name].to_sym
    end

    def function_args
      args = scanner[:function_args].split(',').map(&:strip)
      args.map!(&:to_i) if args.all? { _1.match?(/\A\d+\z/) }
      args
    end
  end

  attr_reader :scanner, :disabled, :sum

  def initialize(string_or_io)
    string = string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io
    @scanner = FunctionScanner.new(string)
    @sum = 0
    @disabled = false
  end

  def call
    scanner.each do |instruction|
      catch(:invalid_arguments) do
        interpret(instruction)
      end
    end

    @sum
  end

  private

  def interpret(instruction)
    case instruction[:function]
    when :mul
      throw :invalid_arguments unless instruction[:args].size == 2
      throw :invalid_arguments unless instruction[:args].all? { _1.is_a?(Integer) }
      return if @disabled
      @sum += instruction[:args].inject(:*)
    when :do
      throw :invalid_arguments unless instruction[:args].empty?
      @disabled = false
    when :"don't"
      throw :invalid_arguments unless instruction[:args].empty?
      @disabled = true
    end
  end
end

puts Interpreter.new(ARGF).call
