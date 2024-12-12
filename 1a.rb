puts ARGF
  .each_line
  .map(&:strip).reject(&:empty?)     # clean up input
  .flat_map(&:split).map(&:to_i)     # split lines and parse to ints
  .partition.with_index { _2.even? } # partition back into two lists
  .map(&:sort)                       # sort both lists
  .inject(:zip)                      # zip sorted lists together
  .map { _1.inject(:-).abs }         # get abs diffs of each pair
  .sum
