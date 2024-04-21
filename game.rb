STDOUT.sync = true # AUTOGENERADO POR EL JUEGO, NO QUITAR

# Módulo para los algoritmos del juego.
module TronBattle
  # Ancho de la matriz del juego (eje x).
  WIDTH = 30
  # Alto de la matriz del juego (eje y).
  HEIGHT = 20
  # Posibles movimientos en el juego.
  MOVES = %w[UP DOWN LEFT RIGHT]

  # Estado del jugador.
  class Player
    # head: ubicación actual
    # tail: ubicación inicial
    # prev: ubicación anterior
    attr_accessor :head, :tail, :prev

    # Constructor.
    def initialize(x: -1, y: -1)
      @head = { x: x, y: y }
      @tail = { x: x, y: y }
      @prev = { x: x, y: y }
    end

    # Último movimiento del jugador.
    def last_move
      return nil if prev[:x] < 0 || prev[:y] < 0
      return "UP" if head[:y] < prev[:y]
      return "DOWN" if head[:y] > prev[:y]
      return "LEFT" if head[:x] < prev[:x]
      return "RIGHT" if head[:x] > prev[:x]
      nil
    end

    # Crea una copia del estado actual.
    def copy
      new_player = Player.new
      new_player.head.merge!(self.head)
      new_player.tail.merge!(self.tail)
      new_player.prev.merge!(self.prev)
      new_player
    end
  end

  # Estado del juego.
  class GameState
    # matrix: matriz de WIDTH*HEIGHT
    # player: instancia del jugador
    # enemy: instancia del enemigo
    attr_accessor :matrix, :player, :enemy

    # Constructor.
    def initialize
      @matrix = Array.new(HEIGHT) { Array.new(WIDTH, 0) }
      @player = Player.new
      @enemy = Player.new
    end
  end

  # Problema de optimización.
  class OptimizationProblem
    # state: estado del juego
    attr_accessor :state

    # Constructor.
    def initialize
      @state = GameState.new
    end

    # Generar estados vecinos.
    def generate_neighbors
      neighbors = MOVES.dup
      neighbors.delete("UP") if state.player.last_move == "DOWN"
      neighbors.delete("DOWN") if state.player.last_move == "UP"
      neighbors.delete("LEFT") if state.player.last_move == "RIGHT"
      neighbors.delete("RIGHT") if state.player.last_move == "LEFT"
      STDERR.puts "Vecinos: %s" % neighbors.to_s
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

    # Genera un sólo vecino.
    def generate_random_neighbor
      generate_neighbors.sample
    end

    # Calcula el valor de la heurística sobre el estado.
    def heuristic(solution)
      x = solution.player.head[:x]
      y = solution.player.head[:y]
      enemy_x = @state.enemy.head[:x]
      enemy_y = @state.enemy.head[:y]
      manhattan_distance(x, y, enemy_x, enemy_y) + penalty(x, y)
    end

    private

    # Calcula la distancia Manhattan desde (x0, y0) a (x1, y1).
    def manhattan_distance(x0, y0, x1, y1)
      (x1 - x0).abs + (y1 - y0).abs
    end

    # Calcula la penalización para (x, y).
    def penalty(x, y)
      return 50 if in_border?(x, y) || @state.matrix[y][x] == 1
      0
    end

    # Determina si (x, y) está en el borde de la matriz.
    def in_border?(x, y)
      x == -1 || y == -1 || x == WIDTH || y == HEIGHT
    end
  end

  # Algoritmo Hill Climbing.
  def self.hill_climbing(problem)
    neighbors = problem.generate_neighbors
    best_neighbor = neighbors.min_by { |neighbor| problem.heuristic(neighbor) }
  end

  # Algoritmo Simulated Annealing.
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

# Instancia del problema.
problem = TronBattle::OptimizationProblem.new

# Loop del juego.
loop do
  # n: número total de jugadores (2 to 4).
  # p: el número del jugador (0 to 3).
  n, p = gets.split.map { |x| x.to_i }
  n.times do |i|
    # x0: coordenada de inicio X de lightcycle (o -1)
    # y0: coordenada de inicio Y de lightcycle (o -1)
    # x1: coordenada de inicio X de lightcycle (puede ser igual que X0 si se juega antes que este jugador)
    # y1: coordenada de inicio Y de lightcycle (puede ser igual que Y0 si se juega antes que este jugador)
    x0, y0, x1, y1 = gets.split.map { |x| x.to_i }

    # Generar nuevo estado del juego
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

  # Aplicar Hill Climbing para encontrar el próximo movimiento
  solution = TronBattle.hill_climbing(problem)
  # Aplicar Simulated Annealing para encontrar el próximo movimiento
  # solution = TronBattle.simulated_annealing(problem, 100, 0.95)

  STDERR.puts "Próximo movimiento: %s" % solution.player.last_move
  puts solution.player.last_move
end
