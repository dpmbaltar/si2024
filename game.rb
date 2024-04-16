STDOUT.sync = true # DO NOT REMOVE
# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

# Game algorithms module.
module TronBattle
  # Grid width (x axis).
  WIDTH = 30
  # Grid height (y axis).
  HEIGHT = 20
  # Possible moves.
  MOVES = %w[UP DOWN LEFT RIGHT]

  # Optimization Problem.
  class OptimizationProblem
    # matrix: WIDTH*HEIGHT matrix
    # player: player head hash
    # enemy: enemy head hash
    attr_reader :matrix, :player, :enemy

    # Constructor.
    def initialize
      @matrix = Array.new(HEIGHT) { Array.new(WIDTH, 0) }
      @player = { x: -1, y: -1 }
      @enemy = { x: -1, y: -1 }
    end

    # Generate neighboring solutions.
    def generate_neighbors
      [
        { x: @player[:x], y: @player[:y] - 1, move: "UP" },
        { x: @player[:x], y: @player[:y] + 1, move: "DOWN" },
        { x: @player[:x] - 1, y: @player[:y], move: "LEFT" },
        { x: @player[:x] + 1, y: @player[:y], move: "RIGHT" }
      ]
    end

    # Generate a random neighboring solution.
    def generate_random_neighbor
      generate_neighbors.sample
    end

    # Calculate the heuristic value of the solution.
    def heuristic(solution)
      x = solution[:x]
      y = solution[:y]
      manhattan_distance(x, y, @enemy[:x], @enemy[:y]) + penalty(x, y)
    end

    private

    # Manhattan distance from (x0, y0) to (x1, y1).
    def manhattan_distance(x0, y0, x1, y1)
      (x1 - x0).abs + (y1 - y0).abs
    end

    # Penalty value for (x, y).
    def penalty(x, y)
      return 50 if in_border?(x, y) || @matrix[y][x] == 1
      0
    end

    # Whether (x, y) is in the grid's border.
    def in_border?(x, y)
      x == -1 || y == -1 || x == WIDTH || y == HEIGHT
    end
  end

  # Hill Climbing.
  def self.hill_climbing(problem)
    neighbors = problem.generate_neighbors
    best_neighbor = neighbors.min_by { |neighbor| problem.heuristic(neighbor) }
  end
end

# game problem instance
problem = TronBattle::OptimizationProblem.new

# game loop
loop do
  # n: total number of players (2 to 4).
  # p: your player number (0 to 3).
  n, p = gets.split.map { |x| x.to_i }
  n.times do |i|
    # x0: starting X coordinate of lightcycle (or -1)
    # y0: starting Y coordinate of lightcycle (or -1)
    # x1: starting X coordinate of lightcycle (can be the same as X0 if you play before this player)
    # y1: starting Y coordinate of lightcycle (can be the same as Y0 if you play before this player)
    x0, y0, x1, y1 = gets.split.map { |x| x.to_i }

    # Update game state
    problem.matrix[y0][x0] = 1
    problem.matrix[y1][x1] = 1
    head = { x: x1, y: y1 }
    if p == i
      problem.player.merge!(head)
    else
      problem.enemy.merge!(head)
    end
  end

  # Write an action using puts
  # To debug: STDERR.puts "Debug messages..."

  # Apply Hill Climbing to find our next move
  hill_climbing_solution = TronBattle.hill_climbing(problem)
  puts hill_climbing_solution[:move]
end
