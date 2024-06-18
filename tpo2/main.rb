#!/usr/bin/env ruby

require "csv"
require "ruby-graphviz"
require_relative "decision_tree"
require_relative "medidas"

# Dataset
DATASET_TRAINING_FILE = "data/zoo_training_data_withoutcolumnAnimalName.csv"
DATASET_TESTING_FILE = "data/zoo_testing_data_withoutcolumnAnimalName.csv"
DATASET_TESTING_PREDICTIONS_FILE = "data/zoo_testing_predictions.csv"
CLASS_ATTRIBUTE = "type"
CLASSES = ["Ave", "Reptil", "Molusco", "Pez", "Anfibio", "Mamifero", "Insecto"]

# Training dataset
dataset_training = CSV.parse(File.read(DATASET_TRAINING_FILE), headers: true)
dataset_training_attrs = dataset_training.headers
dataset_training_attrs.delete(CLASS_ATTRIBUTE)

# Crear árbol de decisión
decision_tree = ML::TreeNode.new
ML::decision_tree(dataset_training, dataset_training_attrs, decision_tree, CLASS_ATTRIBUTE)
#decision_tree.show_descendants
decision_tree.save_graphviz("decision_tree.png")

# Testing dataset
dataset_testing = CSV.parse(File.read(DATASET_TESTING_FILE), headers: true)
dataset_testing_attrs = dataset_testing.headers

predictions = ML::predict_dataset(decision_tree, dataset_testing)
CSV.open(DATASET_TESTING_PREDICTIONS_FILE, 'w') do |csv|
  csv << predictions.headers
  predictions.each do |row|
  csv << row
  end
end

Medidas::showMultiMatrix(predictions, "type", "predicted_class", CLASSES)
negatives = dataset_testing.each.select { |row| row["type"] != decision_tree.predict(row, :row, binding) }
positives = dataset_testing.each.select { |row| row["type"] == decision_tree.predict(row, :row, binding) }

negatives_percent = negatives.size / dataset_testing.size.to_f * 100
positives_percent = positives.size / dataset_testing.size.to_f * 100

puts "Total (training): %i" % dataset_training.size
puts "Total (testing): %i" % dataset_testing.size
puts "Total negativos (testing): %i (%.2f%%)" % [negatives.size, negatives_percent]
puts "Total positivos (testing): %i (%.2f%%)" % [positives.size, positives_percent]