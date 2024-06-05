require "csv"

DATASET_FILE = "data/zoo.data"

def attr_frequency(data, attr_name)
    freq = Hash.new(0)
    #freq.default = 0
    data.each do |d|
        freq[d[attr_name]]+=1
    end
    return freq
end

def data_subset(data, attr_name, attr_value)
    return data.select {|row| row[attr_name] == attr_value}
end


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

puts data_entropy(test_ds, "class") #entropia del dataset
puts attribute_entropy(test_ds, "own_house", "class") #entropia para el atributo own_house
puts attribute_entropy(test_ds, "age", "class") #entropia para el atributo age
print "ganancia de age: #{gain(data_entropy(test_ds, "class"), attribute_entropy(test_ds, "age", "class"))} \n"
print "ganancia de own_house: #{gain(data_entropy(test_ds, "class"), attribute_entropy(test_ds, "own_house", "class"))}"

dataset = CSV.parse(File.read(DATASET_FILE), headers: true)

index_names = {
    0 => "animal_name",
    "animal_name" => 0,
    1 => "hair",
    "hair" => 1,
    2 => "feathers",
    "feathers" => 2,
    3 => "eggs",
    "eggs" => 3,
    4 => "milk",
    "milk" => 4,
    5 => "airborne",
    "airborne" => 5,
    6 => "aquatic",
    "aquatic" => 6,
    7 => "predator",
    "predator" => 7,
    8 => "toothed",
    "toothed" => 8,
    9 => "backbone",
    "backbone" => 9,
    10 => "breathes",
    "breathes" => 10,
    11 => "venomous",
    "venomous" => 11,
    12 => "fins",
    "fins" => 12,
    13 => "legs",
    "legs" => 13,
    14 => "tail",
    "tail" => 14,
    15 => "domestic",
    "domestic" => 15,
    16 => "catsize",
    "catsize" => 16,
    17 => "type",
    "type" => 17
}
