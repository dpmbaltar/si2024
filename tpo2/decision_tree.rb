require "ruby-graphviz"

module ML

  # Frecuencia de valores del atributo.
  def self.attr_frequency(data, attr_name)
    data.group_by { |row| row[attr_name] }.map { |k, v| [k, v.length] }.to_h
  end

  # Subconjunto de datos con con valor de atributo.
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

      if max_gain["gain"] < 0.05
        most_frequent_class = class_frequency.max_by { |key, value| value }[0]
        tree_node.content =  most_frequent_class
      else
        tree_node.content = max_gain["attribute"]
        data_freq_by_attr = attr_frequency(data, max_gain["attribute"])
        data_freq_by_attr.each do |attr_value, freq|
          child = TreeNode.new
          tree_node.add_child(attr_value, child)
          data_with_value = data.select { |row| row[max_gain["attribute"]] == attr_value }
          attributes_except = attributes.select { |name| name != max_gain["attribute"] }
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

    def to_h
      { node: self, edge: nil }
    end

    def to_s
      "(#{@content})"
    end

    def conditions(context)
      generate_conditions(context.to_s, self, "", 0)
    end

    def predict(row, row_context, binding_object)
      eval(self.conditions(row_context), binding_object)
    end

    def showChildren
      @children.each do |child|
        puts "\-> child with branch #{child[:edge]} is #{child[:node].to_s}"
      end
    end

    def show_descendants
      puts generate_tree_string(self, "", 0)
    end

    # Genera y guarda el árbol en un archivo de imagen PNG.
    def save_graphviz(filename)
      graphviz = GraphViz.new(:G, type: :digraph)
      graphviz.node[:shape] = "box"
      generate_graphviz(graphviz, self.to_h)
      graphviz.output(png: filename)
    end

    private

    def generate_conditions(context, node, str, lvl)
      return "  \"" << node.content << "\"" << "\n" if node.children.empty?

      offset = "  " * lvl
      node.children.size.times do |i|
        str << offset
        str << "els" if i > 0
        str << "if "
        str << "#{context}[\"#{node.content}\"] == \"#{node.children[i][:edge]}\"\n"
        str << offset << generate_conditions(context, node.children[i][:node], "", lvl+1)
        str << offset << "end\n" if (i+1) == node.children.size
      end

      str
    end

    # Genera recursivamente un objeto GraphViz para ver el árbol en una imagen.
    def generate_graphviz(gv = nil, current = nil, gv_parent: nil, parent: nil, n: 0)
      return if gv.nil? || current.nil?

      @n = 1 if n == 0
      @n += 1
      gv_node_id = "#{@n}-#{current[:node].content}"
      gv_node = gv.add_nodes(gv_node_id, label: current[:node].content)

      unless parent.nil?
        gv_label = current[:edge].to_s
        gv.add_edges(gv_parent, gv_node, label: gv_label)
      end

      current[:node].children.each do |child|
        generate_graphviz(gv, child, gv_parent: gv_node, parent: current, n: @n)
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
