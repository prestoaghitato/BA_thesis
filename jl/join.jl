using DataFrames

#==
create joined Dict from a rule's null and real values
==#


function loadjdl(filename)
    #==
    load jdl file
    in: filename without extension
    out: Dict
    ==#
    out = load("output/"*filename*".jdl")["data"]
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


function main()
    # iterate through files in input directory
        rules_sig_prepared = Dict()
    for filename in readdir("input")
        # get file extension
        extension = filename[end-3:end]
        # if it's a jdl file, get its name and load it
        if extension == ".jdl"
            name = filename[1:end-4]
            source = loadjdl(filename)
            # is it null or real data?
            if contains(name, "null")
                # iterate over keys
                for key in keys(source)
                    if haskey(rules_sig_prepared, key)
                        rules_sig_prepared[key]
                    else
                        # do stuff if key doesn't exist
                    end
                end
            elseif contains(name, "real")
                # do stuff with control data
            end

        end
    end
end
