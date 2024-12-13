class WordSearch
  attr_reader :lines, :height, :width, :words

  def self.call(...)
    new(...).call
  end

  def initialize(input, words:)
    self.lines = input.split("\n").map(&:strip).compact
    @words = words
  end

  def lines=(lines)
    @lines = lines
    @height = @lines.size
    @width = @lines.first.size
  end

  def call
    found_words = Hash.new(0)
    @matched_coordinates = Set.new

    each_coordinate do |coordinate|
      find_words(coordinate).each do |word, count|
        found_words[word] += count
      end
    end

    found_words
  end

  def each_coordinate
    for x in 0..width-1
      for y in 0..height-1
        yield Coordinate.new(x, y)
      end
    end
  end

  def find_words(coordinate)
    found_words = Hash.new(0)

    words.each do |word|
      if (count = find_word(coordinate, word))
        found_words[word] = count
      end
    end

    found_words
  end

  def find_word(coordinate, word, direction: :any, visited: Set.new, path: [])
    return 0 unless coordinate.within?(width, height)
    if visited.include?(coordinate)
      puts "Visited #{coordinate} already"
      return
    end
    return 0 if self[coordinate] != word[0]

    path << coordinate
    return 1.tap { @matched_coordinates.merge(path) } if word.size == 1

    count = 0
    visited.add(coordinate)

    if direction == :any
      coordinate.adjacent(:any).each do |next_coordinate|
        next unless next_coordinate.within?(width, height)
        next_direction = next_coordinate.direction_from(coordinate)
        count += find_word(next_coordinate, word[1..], direction: next_direction, visited: visited, path: path)
      end
    else
      next_coordinate = coordinate.adjacent(direction)
      count += find_word(next_coordinate, word[1..], direction: direction, visited: visited, path: path)
    end

    visited.delete(coordinate)
    path.pop
    count
  end

  def[] coordinate
    return nil unless coordinate.within?(width, height)
    @lines[coordinate.y][coordinate.x]
  end

  # Added for debugging, prefer not to mutate global state for each call
  def matched_grid
    @lines.map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        @matched_coordinates.include?(Coordinate.new(x, y)) ? char : '.'
      end.join
    end.join("\n")
  end

  class Coordinate
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def adjacent(direction=:any)
      if direction == :any
        return Array(-1..1).product(Array(-1..1))
          .reject { |dx, dy| dx.zero? && dy.zero? }
          .map { |dx, dy| Coordinate.new(x + dx, y + dy) }
      end

      parts = direction.to_s.split('_')
      dx = parts.include?('left') ? -1 : parts.include?('right') ? 1 : 0
      dy = parts.include?('top') ? -1 : parts.include?('bottom') ? 1 : 0
      Coordinate.new(x + dx, y + dy)
    end

    def within? width, height
      x >= 0 && x < width && y >= 0 && y < height
    end

    def direction_from adjacent_coordinate
      dx = adjacent_coordinate.x - x
      dy = adjacent_coordinate.y - y

      x_direction = dx > 0 ? 'left' : dx < 0 ? 'right' : nil
      y_direction = dy > 0 ? 'top' : dy < 0 ? 'bottom' : nil

      return nil if x_direction.nil? && y_direction.nil?

      [y_direction, x_direction].compact.join('_').to_sym
    end

    def inspect
      "(#{x}, #{y})"
    end

    def hash
      [x, y].hash
    end

    def ==(other)
      other.is_a?(Coordinate) && x == other.x && y == other.y
    end
    alias eql? ==
  end
end

ws = WordSearch.new(ARGF.read, words: %w[XMAS])
puts ws.call.fetch('XMAS', 0)
