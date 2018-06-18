using DataFrames, HDF5, JLD

#==
create joined Dict from a rule's null and real values

input:
    jdl file, Dict of Dicts. Parent Dict has string keys for every rule. Nested
    Dicts have the following keys holding the respective values for all
    occurences of a rule:
        :confidence => Float64[],
        :occurrences => Int64[],
        :duration_sec => Float64[],
        :observations => 0


Final Dict structure:

Parent Dict has String key for every rule
"rulekey" Dict has keys
    :real => Dict
    :null => Dict
    :significance => Dict
:real and :null Dicts have keys
    # arrays containing all confidence/occurence/duration values for the given
    # rule found in the real or null data
    :all_confidences => Float64[]
    :all_occurrences => Int64[]
    :all_durations   => Float64[]
:significance Dict has keys
    # arrays containing the p-values for testing the rule's real distribution of
    # a metric against the rule's null distribution of that metric
    :sig_confidence  => Float64
    :sig_occurrences => Float64
    :sig_durations   => Float64
    # :sig_ns is an array storing N of real and null observations for all three
    # metrics, structured as follows:
    # [[n_real_con, n_real_occ, n_real_dur]
    #  [n_null_con, n_null_occ, n_null_dur]]
    # first parameter:  1=real, 2=null
    # second parameter: 1=con,  2=occ, 3=dur
    :sig_ns          => Array{Int64}(2,3)

first create :real Dict, then :null Dict
rules without a real part don't have to be generated (maybe)
:significance Dict can then be generated from imported data
==#


function loadjdl(filename)
    #==
    load jdl file
    in: filename without extension
    out: Dict
    ==#
    out = load("input/"*filename*".jdl")["data"]
    return out
end


function savejdl(file, name)
    #==
    save Dict to jdl file
    in:  Dict filename
    out: nothing
    ==#
    save("output/"*name*".jld", "data", file)
end


function createfinaldatastructure()
    #==
    in: null jld file, real jdl file
    out: Dict
    ==#
    # iterate through files in input directory
        rules_sig_prepared = Dict()
    for filename in readdir("input")
        # get file extension
        extension = filename[end-3:end]
        # if it's a jdl file, get its name and load it
        if extension == ".jdl"
            name = filename[1:end-4]
            source = loadjdl(filename)
            # is it null data?
            if contains(name, "null")
                # iterate over keys
                for key in keys(source)
                    if haskey(rules_sig_prepared, key)
                        rules_sig_prepared[key]
                    else
                        # do stuff if key doesn't exist
                    end
                end
            # is it real data?
            elseif contains(name, "real")
                # do stuff with control data
            end

        end
    end
end
