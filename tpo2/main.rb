#!/usr/bin/env ruby

require "csv"
require "ruby-graphviz"
require_relative "decision_tree"

# Dataset
DATASET_FILE = "credit.data"

dataset = CSV.parse(File.read(DATASET_FILE), headers: true)
dataset_attrs = dataset.headers
dataset_attrs.delete("class")

tree = ML::TreeNode.new
ML::decision_tree(dataset, dataset_attrs, tree, "class")
tree.show_descendants
tree.save_graphviz("tree.png")
