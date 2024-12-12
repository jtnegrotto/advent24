require 'forwardable'

class Scanner
  extend Forwardable
  include Enumerable

  attr_reader :reports
  def_delegator :reports, :each

  def initialize(file)
    @reports = file.each_line.lazy
      .map(&:strip).reject(&:empty?)
      .map { |line| Report.parse(line) }
  end

  class Report
    def self.parse(report)
      new(report.split.map(&:to_i))
    end

    attr_reader :levels, :change_threshold, :anomaly_tolerance

    def initialize(levels, change_threshold: 1..3, anomaly_tolerance: 1)
      @levels = levels.freeze
      @change_threshold = change_threshold
      @anomaly_tolerance = anomaly_tolerance
    end

    def changes
      levels.each_cons(2).map { |a, b| a - b }
    end

    def monotonic?
      changes.map { |change| change <=> 0 }.uniq.size <= 1
    end

    def changes_acceptable?
      changes.all? { |change| change_threshold.cover? change.abs }
    end

    def within_anomaly_tolerance?
      anomaly_alternatives.any?(&:valid?)
    end

    def valid?
      (monotonic? && changes_acceptable?) || within_anomaly_tolerance?
    end

    private

    def anomaly_alternatives
      return [] unless anomaly_tolerance.positive?

      levels.each_index.lazy.map do |i|
        Report.new(
          levels[0...i] + levels[i + 1..],
          change_threshold: change_threshold,
          anomaly_tolerance: anomaly_tolerance - 1,
        )
      end
    end
  end
end

scanner = Scanner.new(ARGF)
puts scanner.count(&:valid?)
