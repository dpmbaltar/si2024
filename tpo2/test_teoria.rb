#Funciones Auxiliares
def attr_frequency(data, attr_name)
    freq = Hash.new(0)
    freq.default = 0
    data.each do |d|
        freq[d[attr_name]]+=1
    end
    return freq
end

def data_subset(data, attr_name, attr_value)
    return data.select {|row| row[attr_name] == attr_value}
end

#Funciones entropia
def data_entropy(data, class_attr_name)
    freq = attr_frequency(data, class_attr_name)
    sum = 0
    freq.each do |cname, cfreq| 
        prob = cfreq/data.length.to_f
        sum += (prob) * Math.log(prob, 2)
    end
    return sum * -1
end

def attribute_entropy(data, attr_name, class_attr_name)
    freq = attr_frequency(data, attr_name)
    sum = 0
    freq.each do |aval, afreq|
        subset = data_subset(data, attr_name, aval)
        entropy_subset = data_entropy(subset, class_attr_name)
        sum+= (afreq/data.length.to_f) * entropy_subset
    end
    return sum
end

def gain(data_entropy, attr_entropy)
    return data_entropy - attr_entropy
end

# Arbol
class TreeNode
    def initialize(content)
        @content = content
        @children = []
    end
    def setContent(newContent)
        @content = newContent
    end
    def addChild(edge, child)
        @children.push({"node" => child, "edge" => edge})
    end
    def toString
        return "(#{@content})"
    end
    def getChildren
        return @children
    end
    def showChildren
        @children.each do |child|
            puts "\-> child with branch #{child["edge"]} is #{child["node"].toString}"
        end
    end
end

class Tree
    def initialize(rootNode)
        @root = rootNode
    end
    
    def getRoot
        return @root
    end

    def showTree
        puts showDescendants(@root, "", 0)
    end

    def showDescendants(node, edge, level)
        string = ""
        if(!node.nil?)
            if(level!=0)
                string+=" " * (level*3)
                string+="|\n"
                string+=" " * (level*3)
                string+="| [#{edge}]\n"
                string+=" " * (level*3)
                string+="|__"

                string+="#{node.toString}\n"
            elsif
                string += "#{node.toString}\n"
            end
            children = node.getChildren
            level+=1
            children.each do |child|
                string+= showDescendants(child["node"], child["edge"], level)
            end
        end
        return string
    end
end

def 

#dataset de teoria
test_ds = [
    { "age" => "young", "has_job" => false, "own_house" => false, "credit_rating" => "fair", "class" => "no"},
    { "age" => "young", "has_job" => false, "own_house" => false, "credit_rating" => "good", "class" => "no"},
    { "age" => "young", "has_job" => true, "own_house" => false, "credit_rating" => "good", "class" => "yes"},
    { "age" => "young", "has_job" => true, "own_house" => true, "credit_rating" => "fair", "class" => "yes"},
    { "age" => "young", "has_job" => false, "own_house" => false, "credit_rating" => "fair", "class" => "no"},
    { "age" => "middle", "has_job" => false, "own_house" => false, "credit_rating" => "fair", "class" => "no"},
    { "age" => "middle", "has_job" => false, "own_house" => false, "credit_rating" => "good", "class" => "no"},
    { "age" => "middle", "has_job" => true, "own_house" => true, "credit_rating" => "good", "class" => "yes"},
    { "age" => "middle", "has_job" => false, "own_house" => true, "credit_rating" => "excellent", "class" => "yes"},
    { "age" => "middle", "has_job" => false, "own_house" => true, "credit_rating" => "excellent", "class" => "yes"},
    { "age" => "old", "has_job" => false, "own_house" => true, "credit_rating" => "excellent", "class" => "yes"},
    { "age" => "old", "has_job" => false, "own_house" => true, "credit_rating" => "good", "class" => "yes"},
    { "age" => "old", "has_job" => true, "own_house" => false, "credit_rating" => "good", "class" => "yes"},
    { "age" => "old", "has_job" => true, "own_house" => false, "credit_rating" => "excellent", "class" => "yes"},
    { "age" => "old", "has_job" => false, "own_house" => false, "credit_rating" => "fair", "class" => "no"}
]

test_ds_attributes = ["age", "has_job", "own_house", "credit_rating"]

#algoritmo arbol de decision
#Nota: esta codeado medio asi nomas para ver si andaba, se puede hacer más prolijo y modularlo mas
def decisionTree(data, attributes, tree_node, class_attr_name)
    class_frequency = attr_frequency(data, class_attr_name)
    if(class_frequency.length == 1)
        tree_node.setContent(data[0][class_attr_name])
    elsif (attributes.length == 0)
        most_frequent_class = class_frequency.max_by{|key, value| value}[0]
        tree_node.setContent(most_frequent_class)
    else
        p0 = data_entropy(data, class_attr_name)
        max_gain = {"gain" => 0, "attribute" => nil}
        attributes.each do |attribute|
            pi = attribute_entropy(data, attribute, class_attr_name)
            gain = p0 - pi
            if(gain > max_gain["gain"])
                max_gain["gain"] = gain
                max_gain["attribute"] =  attribute
            end
        end
        if(max_gain["gain"] < 0.05)
            most_frequent_class = class_frequency.max_by{|key, value| value}[0]
            tree_node.setContent(most_frequent_class)
        else
            tree_node.setContent(max_gain["attribute"])
            data_freq_by_attr = attr_frequency(data, max_gain["attribute"])
            data_freq_by_attr.each do |attr_value, freq|
                child = TreeNode.new(nil)
                tree_node.addChild(attr_value, child)
                data_with_value = data.select {|row| row[max_gain["attribute"]] == attr_value}
                attributes_except = attributes.select {|row| row["name"] != max_gain["attribute"]}
                decisionTree(data_with_value, attributes_except, child, class_attr_name)
            end
        end
    end
end

#pruebas
root = TreeNode.new(nil)
decisionTree(test_ds, test_ds_attributes, root, "class")
tree = Tree.new(root)
puts tree.showTree
