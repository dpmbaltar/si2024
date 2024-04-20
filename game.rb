STDOUT.sync = true # DO NOT REMOVE
# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

# Game algorithms module.
module TronBattle
  # Game grid's width (x axis).
  WIDTH = 30
  # Game grid's height (y axis).
  HEIGHT = 20
  # Game's possible moves.
  MOVES = %w[UP DOWN LEFT RIGHT]

  # Player state.
  class Player
    # head: player's last coordinates
    # tail: player's start coordinates
    # prev: player's previous coordinates
    attr_accessor :head, :tail, :prev

    # Constructor.
    # At start, head, tail and previous coordinates are the same.
    def initialize(x: -1, y: -1)
      @head = { x: x, y: y }
      @tail = { x: x, y: y }
      @prev = { x: x, y: y }
    end

    # Player's last move.
    def last_move
      return nil if prev[:x] < 0 || prev[:y] < 0
      return "UP" if head[:y] < prev[:y]
      return "DOWN" if head[:y] > prev[:y]
      return "LEFT" if head[:x] < prev[:x]
      return "RIGHT" if head[:x] > prev[:x]
      nil
    end

    # Create copy.
    def copy
      new_player = Player.new
      new_player.head.merge!(self.head)
      new_player.tail.merge!(self.tail)
      new_player.prev.merge!(self.prev)
      new_player
    end
  end

  # Game state.
  class GameState
    # matrix: WIDTH*HEIGHT matrix
    # player: player head hash
    # enemy: enemy head hash
    attr_accessor :matrix, :player, :enemy

    # Constructor.
    def initialize
      @matrix = Array.new(HEIGHT) { Array.new(WIDTH, 0) }
      @player = Player.new
      @enemy = Player.new
    end
  end

  # Optimization Problem.
  class OptimizationProblem
    # state: game state instance
    attr_accessor :state

    # Constructor.
    def initialize
      @state = GameState.new
    end

    # Generate neighboring solutions.
    def generate_neighbors
      neighbors = MOVES.dup
      neighbors.delete("UP") if state.player.last_move == "DOWN"
      neighbors.delete("DOWN") if state.player.last_move == "UP"
      neighbors.delete("LEFT") if state.player.last_move == "RIGHT"
      neighbors.delete("RIGHT") if state.player.last_move == "LEFT"
      STDERR.puts "Neighbors: %s" % neighbors.to_s
      neighbors.map do |move|
        new_state = GameState.new
        new_state.matrix = state.matrix.dup
        new_state.enemy = state.enemy.copy
        new_state.player = state.player.copy
        new_state.player.prev.merge!(state.player.head)
        case move
        when "UP"
          new_state.player.head[:y] -= 1
        when "DOWN"
          new_state.player.head[:y] += 1
        when "LEFT"
          new_state.player.head[:x] -= 1
        when "RIGHT"
          new_state.player.head[:x] += 1
        end
        new_state
      end
    end

    # Generate a random neighboring solution.
    def generate_random_neighbor
      generate_neighbors.sample
    end

    # Calculate the heuristic value of the solution.
    def heuristic(solution)
      x = solution.player.head[:x]
      y = solution.player.head[:y]
      enemy_x = @state.enemy.head[:x]
      enemy_y = @state.enemy.head[:y]
      manhattan_distance(x, y, enemy_x, enemy_y) + penalty(x, y)
    end

    private

    # Manhattan distance from (x0, y0) to (x1, y1).
    def manhattan_distance(x0, y0, x1, y1)
      (x1 - x0).abs + (y1 - y0).abs
    end

    # Penalty value for (x, y).
    def penalty(x, y)
      return 50 if in_border?(x, y) || @state.matrix[y][x] == 1
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

  # Simulated Annealing.
  def self.simulated_annealing(problem, initial_temperature, cooling_rate)
    current = problem.state
    # En el primer movimiento, last_move es nulo
    current = problem.generate_random_neighbor if problem.state.player.last_move.nil?
    best_solution = current
    @@temperature ||= initial_temperature
    return best_solution if @@temperature <= 0.1

    neighbor = problem.generate_random_neighbor
    delta_e = problem.heuristic(neighbor) - problem.heuristic(current)

    if delta_e <= 0 || Math.exp(-delta_e / @@temperature) > rand
      current = neighbor
      best_solution = current if problem.heuristic(current) < problem.heuristic(best_solution)
    end

    @@temperature *= cooling_rate

    best_solution
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
    problem.state.matrix[y0][x0] = 1
    problem.state.matrix[y1][x1] = 1
    new_head = { x: x1, y: y1 }
    if p == i
      old_head = problem.state.player.head
      problem.state.player.prev.merge!(old_head)
      problem.state.player.head.merge!(new_head)
    else
      problem.state.enemy.head.merge!(new_head)
    end
  end

  # Write an action using puts
  # To debug: STDERR.puts "Debug messages..."

  # Apply Hill Climbing to find our next move
  solution = TronBattle.hill_climbing(problem)
  # solution = TronBattle.simulated_annealing(problem, 100, 0.95)
  STDERR.puts "Next move: %s" % solution.player.last_move
  puts solution.player.last_move
end
