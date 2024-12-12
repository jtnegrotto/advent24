puts ARGF
  .each_line
  .map(&:strip).reject(&:empty?)     # clean up input
  .flat_map(&:split).map(&:to_i)     # split lines and parse to ints
  .partition.with_index { _2.even? } # partition back into two lists
  .then {
    t = _2.tally                     # tally the second list
    _1.map { |n| n * (t[n] || 0) }   # get similarity score
  }
  .sum

