    require 'csv'

    # Leer el archivo 
    file_path = File.join('datasets', 'zoo.data')
    headers = ['hair', 'feathers', 'eggs', 'milk', 'airborne', 'aquatic', 'predator', 'toothed', 'backbone', 'breathes', 'venomous', 'fins', 'legs', 'tail', 'domestic', 'catsize', 'type']
    data = CSV.read(file_path)
    dataArr = data.to_a

    #Retiramos tuplas vampire y girl
    dataArr.filter! {|row| row[0] != "girl" && row[0] != "vampire"}

    class_names = {"1" => "Mamifero", "2" => "Ave", "3" => "Reptil", "4" => "Pez", "5" => "Anfibio", "6" => "Insecto", "7" => "Molusco"}
    #Retiramos columna animal_name, cambiamos 0 y 1 por FALSE TRUE y cambiamos clases numericas por nominal
    legs_index = headers.index("legs")
    type_index = headers.index("type")
    dataArr.each do |row|
        row.shift
        row.each_index do |index|
            if(index != legs_index && index != type_index)
                row[index] = row[index] == "0" ? "FALSE" : "TRUE"
            elsif(index == type_index)
                row[index] = class_names[row[index]]
            end
        end
    end

    # Mezclar filas
    dataArr.shuffle!
    split_index = (dataArr.size * 0.8).round

    # Separar los datos en 2 dataset
    training_data = dataArr[0...split_index]
    testing_data = dataArr[split_index..-1]

    # Guardar datos de entrenamiento 
    CSV.open('datasets/zoo_testing_data.csv', 'w') do |csv|
        csv << headers # Escribir encabezados
        testing_data.each do |row|
        csv << row
        end
    end

    # Guardar datos de prueba
    CSV.open('datasets/zoo_training_data.csv', 'w') do |csv|
        csv << headers # Escribir encabezados
        training_data.each do |row|
        csv << row
        end
    end

    puts "Datos guardados exitosamente."
