    require 'csv'

    # Leer el archivo 
    file_path = File.join('dataset', 'zoo_data_with_header.csv')
    data = CSV.read(file_path, headers: true)

    # Separar encabezado y los datos
    dataArr = data.to_a
    headers = dataArr.shift
    
    # Mesclar filas
    dataArr.shuffle!
    split_index = (dataArr.size * 0.8).round

    # Separar los datos en 2 dataset
    training_data = dataArr[0...split_index]
    testing_data = dataArr[split_index..-1]

    # Guardar datos de entrenamiento 
    CSV.open('zoo_testing_data.csv', 'w') do |csv|
        csv << headers # Escribir encabezados
        testing_data.each do |row|
        csv << row
        end
    end

    # Guardar datos de prueba
    CSV.open('zoo_training_data.csv', 'w') do |csv|
        csv << headers # Escribir encabezados
        training_data.each do |row|
        csv << row
        end
    end

    puts "Datos guardados exitosamente."