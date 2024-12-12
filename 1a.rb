$><<$<.read.split.map(&:to_i)               # Read, split, parse to int array
  .each_slice(2).to_a.transpose.map(&:sort) # Pair, columnize, sort ints
  .reduce(:zip).sum{(_1-_2).abs}            # Pair columns, diff, sum
