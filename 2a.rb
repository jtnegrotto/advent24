class Scanner
  attr_reader :reports

  def initialize(file)
    @reports = file.each_line.lazy
      .map(&:strip).reject(&:empty?)
      .map { |line| Report.parse(line) }
  end

  class Report
    def self.parse(report)
      new(report.split.map(&:to_i))
    end

    attr_reader :levels, :change_threshold

    def initialize(levels, change_threshold: 1..3)
      @levels = levels
      @change_threshold = change_threshold
    end

    def changes
      levels.each_cons(2).map { |a, b| a - b }
    end

    def monotonic?
      signs = changes.map { |change| change <=> 0 }.uniq
      signs.size <= 1
    end

    def changes_acceptable?
      changes.all? { |change| change_threshold.cover? change.abs }
    end

    def valid?
      monotonic? && changes_acceptable?
    end

    def inspect
      <<~REPORT.strip
        <Report [#{levels.join(',')}] valid=#{valid?} mono=#{monotonic?} max_change=#{changes.max} min_change=#{changes.min}>
      REPORT
    end
  end
end

scanner = Scanner.new(ARGF)
puts scanner.reports.count(&:valid?)
# => 224
