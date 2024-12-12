$><<$<.read.split.map(&:to_i)            # Read, split, parse to int array
  .each_slice(2).to_a.transpose          # Columnize pairs
  .then{|a,b|a.sum{_1*(b.tally[_1]||0)}} # Sum similarity scores

