using DataFrames


function main()
    # create output file
    open("output/output.csv", "w") do output
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
                    workthroughDataFrame(df)
                end
            end
        end
    end
end


function workthroughDataFrame(df)
    # do stuff with DataFrame
end
