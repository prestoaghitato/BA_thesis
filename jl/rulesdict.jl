#==
input: csv file
output: jdl file

Creates a Dict of Dicts. Parent Dict has string keys for every rule. Nested
Dicts have the following keys holding the respective values for all occurences
of a rule:
    :confidence => Float64[],
    :occurrences => Int64[],
    :duration_sec => Float64[],
    :observations => 0
==#
using DataFrames, HDF5, JLD

function extract(df)
    #==
    in: DataFrame
    out: Dict
    ==#
    # create Dict
    rules = Dict()
    #iterate over DataFrame rows
    for i in 1:size(df, 1)
        # create empty rule template
        emptyrule = Dict(
            :confidence => Float64[],
            :occurrences => Int64[],
            :duration_sec => Float64[],
            :observations => 0
        )
        currentrulename = df[i,:rule]
        if !haskey(rules, currentrulename)
            # create if it doesn't exist
            rules[currentrulename] = emptyrule
        end
        #== appends rule values to Dict arrays ==#
        # get addressess in rules Dict
        confidence = rules[currentrulename][:confidence]
        occurrences = rules[currentrulename][:occurrences]
        duration_sec = rules[currentrulename][:duration_sec]

        # get values from DataFrame
        confidence_value = df[i,:confidence]
        occurrences_value = df[i,:occurrences]
        duration_sec_value = df[i,:duration_sec]

        # add values to rules Dict
        append!(confidence, confidence_value)
        append!(occurrences, occurrences_value)
        append!(duration_sec, duration_sec_value)
        # one more observation recorded
        rules[currentrulename][:observations] += 1
    end
    return rules
end


function savejdl(file, name)
    #==
    save Dict to jdl file
    in:  Dict filename
    out: nothing
    ==#
    save("output/"*name*".jld", "data", file)
end


function main()
    # iterate through files in input directory
    for filename in readdir("input")
        # get file extension
        extension = filename[end-3:end]
        # do some stuff if it's a csv file
        if extension == ".csv"
            name = filename[1:end-4]
            df = readtable("input/"*filename)
            rules = extract(df)
            savejdl(rules, name)
        end
    end
end


# do stuff
main()
