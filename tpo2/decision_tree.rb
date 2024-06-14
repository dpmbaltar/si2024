require "ruby-graphviz"

module ML

  # Frecuencia de valores del atributo.
  def self.attr_frequency(data, attr_name)
    data.group_by { |row| row[attr_name] }.map { |k, v| [k, v.length] }.to_h
  end

  # Subconjunto de datos con valor de atributo.
  def self.data_subset(data, attr_name, attr_value)
    data.select { |row| row[attr_name] == attr_value }
  end

  # Función de entropía.
  def self.data_entropy(data, class_attr_name)
    attr_freq = attr_frequency(data, class_attr_name)
    attr_freq.transform_values do |freq|
      prob = freq / data.length.to_f
      prob * Math::log2(prob)
    end.values.sum * -1
  end

  # Entropía.
  def self.attr_entropy(data, attr_name, class_attr_name)
    sum = 0
    attr_freq = attr_frequency(data, attr_name)
    attr_freq.each do |aval, afreq|
      subset = data_subset(data, attr_name, aval)
      entropy_subset = data_entropy(subset, class_attr_name)
      sum += (afreq / data.length.to_f) * entropy_subset
    end
    sum
  end

  # Ganancia de información.
  def self.gain(data_entropy, attr_entropy)
    data_entropy - attr_entropy
  end

  # Algoritmo Árbol de Decisión.
  def self.decision_tree(data, attributes, tree_node, class_attr_name)
    class_frequency = attr_frequency(data, class_attr_name)
    if class_frequency.length == 1
      tree_node.content = data[0][class_attr_name]
    elsif attributes.length == 0
      most_frequent_class = class_frequency.max_by { |key, value| value }[0]
      tree_node.content = most_frequent_class
    else
      p0 = data_entropy(data, class_attr_name)
      max_gain = { "gain" => 0, "attribute" => nil }
      attributes.each do |attribute|
        pi = attr_entropy(data, attribute, class_attr_name)
        gain = p0 - pi
        if gain > max_gain["gain"]
          max_gain["gain"] = gain
          max_gain["attribute"] =  attribute
        end
      end

      if max_gain["gain"] < 0.25
        most_frequent_class = class_frequency.max_by { |key, value| value }[0]
        tree_node.content =  most_frequent_class
      else
        tree_node.content = max_gain["attribute"]
        data_freq_by_attr = attr_frequency(data, max_gain["attribute"])
        data_freq_by_attr.each do |attr_value, freq|
          child = TreeNode.new(nil)
          tree_node.add_child(attr_value, child)
          data_with_value = data.select { |row| row[max_gain["attribute"]] == attr_value }
          attributes_except = attributes.select { |row| row["name"] != max_gain["attribute"] }
          decision_tree(data_with_value, attributes_except, child, class_attr_name)
        end
      end
    end
  end

  # Nodo para contruir un árbol.
  class TreeNode

    # Getters/setters
    attr_accessor :content, :children

    def initialize(content = nil)
      @content = content
      @children = []
    end

    def add_child(edge, child)
      @children.push({ node: child, edge: edge })
    end

    def to_s
      "(#{@content})"
    end

    def showChildren
      @children.each do |child|
        puts "\-> child with branch #{child[:edge]} is #{child[:node].to_s}"
      end
    end

    def show_descendants
      puts generate_tree_string(self, "", 0)
    end

    def save_graphviz(filename)
      graph = GraphViz.new(:G, type: :digraph)
      graph.node[:shape] = "box"
      generate_graphviz(graph, self, nil)
      graph.output(png: filename)
    end

    private

    def generate_graphviz(graph = nil, tree_node = nil, parent = nil)
      return if graph.nil? || tree_node.nil?

      current = graph.add_nodes(tree_node.content)
      graph.add_edges(parent, current) unless parent.nil?
      tree_node.children.each do |child|
        generate_graphviz(graph, child[:node], current)
      end
    end

    def generate_tree_string(node, edge, level)
      string = ""
      if !node.nil?
        if level != 0
          string += " " * (level*3)
          string += "|\n"
          string += " " * (level*3)
          string += "| [#{edge.to_s}]\n"
          string += " " * (level*3)
          string += "|__"
          string += "#{node.to_s}\n"
        elsif
          string += "#{node.to_s}\n"
        end

        level += 1
        node.children.each do |child|
          string += generate_tree_string(child[:node], child[:edge], level)
        end
      end
      string
    end
  end
end
