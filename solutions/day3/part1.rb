puts ARGF.read
  .scan(/(mul\((?<a>\d+),(?<b>\d+)\))/)
  .map { _1.map(&:to_i).reduce(:*) }
  .sum
