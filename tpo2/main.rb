#!/usr/bin/env ruby

require "csv"
require "ruby-graphviz"
require_relative "decision_tree"

# Dataset
DATASET_FILE = "data/credit.csv"
CLASS_ATTRIBUTE = "class"

dataset = CSV.parse(File.read(DATASET_FILE), headers: true)
dataset_attrs = dataset.headers
dataset_attrs.delete(CLASS_ATTRIBUTE)

tree = ML::TreeNode.new
ML::decision_tree(dataset, dataset_attrs, tree, CLASS_ATTRIBUTE)
tree.show_descendants
#tree.save_graphviz("tree.png")

row_no = { "age" => "young", "has_job" => "false", "own_house" => "false", "credit_rating" => "fair" }
row_yes = { "age" => "young", "has_job" => "true", "own_house" => "false", "credit_rating" => "good" }

puts
puts tree.conditions(:row)
puts
puts tree.predict(row_no, :row_no, binding)
puts tree.predict(row_yes, :row_yes, binding)
