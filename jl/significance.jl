using DataFrames

#==
create a DataFrame for 
==#

function gothroughfiles()
    # iterate through files in input directory
    for filename in readdir("input")
        # get file extension
        extension = filename[end-3:end]
        # do some stuff if it's a csv file
        if extension == ".csv"
            # open csv file
            open("input/"*filename) do file
                # convert csv to DataFrame
                df = readtable(file)
                # iterate over DataFrame rows
                for i in 1:size(df, 1)
                    println(df[i, 1])
                end
            end
        end
    end
end
