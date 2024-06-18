module Medidas

    def self.showMultiMatrix(data, real_class_attr_name, predicted_class_attr_name, classes)
        matrix = {}
        tab = "==predicciones ->>>=="
        header_string = tab+"     No se pudo clasificar     |     "
        classes.each do |real_class|
            header_string+=real_class+"     |     "
            matrix[real_class] = {"No se pudo clasificar" => 0}
            classes.each do |pred_class|
                matrix[real_class][pred_class] = 0
            end
        end
        data.each do |tuple|
            matrix[tuple[real_class_attr_name]][tuple[predicted_class_attr_name]] += 1
        end
        body_string = ""
        temp_row_name = ""
        matrix.each do |class_name, values|
            temp_row_name = "#{class_name} (real)"
            body_string+=temp_row_name+" " * (tab.size - temp_row_name.size)
            values.each do |pred_name, pred_value|
                ps = pred_name.size + 8;
               body_string+=" "*(ps / 2)+"#{pred_value.to_s}"+" "*(ps - (ps / 2) - pred_value.to_s.size)+" | ";
            end
            body_string+="\n";
        end
        puts header_string
        puts body_string
    end

    def self.confusionMatrix(data, real_class_attr_name, predicted_class_attr_name, positive_class_value)
        matrix = {
            "real_positives" => {"classified_positive" => 0, "classified_negative" => 0},
            "real_negatives" => {"classified_positive" => 0, "classified_negative" => 0},
            "true_positives" => 0,
            "true_negatives" => 0,
            "false_positives" => 0,
            "false_negatives" => 0,
            "positives" => 0,
            "negatives" => 0,
        }
        data.each do |tuple|
            real = tuple[real_class_attr_name]
            predicted = tuple[predicted_class_attr_name]
            if(real == positive_class_value)
                matrix["positives"] += 1
                if(predicted == positive_class_value)
                    matrix["real_positives"]["classified_positive"] += 1
                    matrix["true_positives"] += 1
                else
                    matrix["real_positives"]["classified_negative"] += 1
                    matrix["false_negatives"] += 1
                end
            else
                matrix["negatives"] += 1
                if(predicted == positive_class_value)
                    matrix["real_negatives"]["classified_positive"] += 1
                    matrix["false_positives"] += 1
                else
                    matrix["real_negatives"]["classified_negative"] += 1
                    matrix["true_negatives"] += 1
                end
            end
        end
        return matrix
    end

    def self.accuracy(confusionMatrix)
        return (confusionMatrix["true_positives"] + confusionMatrix["true_negatives"]).to_f / (confusionMatrix["positives"] + confusionMatrix["negatives"])
    end

    def self.precision(confusionMatrix)
        return  confusionMatrix["true_positives"].to_f / (confusionMatrix["true_positives"] + confusionMatrix["false_positives"])
    end

    def self.recall(confusionMatrix)
        return confusionMatrix["true_positives"].to_f / (confusionMatrix["true_positives"] + confusionMatrix["false_negatives"])
    end

    #Para un valor de clase en particular
    def self.reviewPredictionOf(data, real_class_attr_name, predicted_class_attr_name, positive_class_value)
        puts "\n >> Showing overall prediction accuracy for class #{positive_class_value}"
        matrix = confusionMatrix(data, real_class_attr_name, predicted_class_attr_name, positive_class_value)
        accuracy = accuracy(matrix)
        precision = precision(matrix)
        recall = recall(matrix)
        puts "======Confusion Matrix======"
        top_header="[   Classified Positive   ][   Classified Negative   ]"
        left_header_a="[   Real Positives   ]"
        left_header_b="[   Real Negatives   ]"
        matrix_string=" "*left_header_a.length+top_header+"\n"
        center_tp=top_header.length/4-matrix["true_positives"].to_s.length
        center_fn=top_header.length/4-matrix["false_negatives"].to_s.length
        matrix_string+=left_header_a+" "*center_tp+"#{matrix["true_positives"]}"+" "*center_tp+" | "+" "*center_fn+"#{matrix["false_negatives"]}"+" "*center_fn+"\n"
        center_fp=top_header.length/4-matrix["false_positives"].to_s.length
        center_tn=top_header.length/4-matrix["true_negatives"].to_s.length
        matrix_string+=left_header_b+" "*center_fp+"#{matrix["false_positives"]}"+" "*center_fp+" | "+" "*center_tn+"#{matrix["true_negatives"]}"+" "*center_tn+"\n"
        puts matrix_string
        puts "\n======Accuracy======"
        puts accuracy.round(3)
        puts "\n======Precision======"
        puts precision.round(3)
        puts "\n======Recall======"
        puts recall.round(3)
    end

    #Para todas las clases
    def self.reviewEveryPrediction(data, real_class_attr_name, predicted_class_attr_name, class_values)
        puts ">> Showing overall accuracy for every class"
        class_values.each do |value|
            matrix = confusionMatrix(data, real_class_attr_name, predicted_class_attr_name, value)
            accuracy = accuracy(matrix)
            precision = precision(matrix)
            recall = recall(matrix)
            puts "--------------------"
            puts ">> Class value: #{value}"
            puts "-> OVERALL ACCURACY: #{accuracy.round(3)}"
            puts "-> True Positives: #{matrix["true_positives"]}"
            puts "-> True Negatives: #{matrix["true_negatives"]}"
            puts "-> False Positives: #{matrix["false_positives"]}"
            puts "-> False Negatives: #{matrix["false_negatives"]}"
            puts "-> Precision: #{precision.round(3)}"
            puts "-> Recall: #{recall.round(3)}"
        end
    end
end