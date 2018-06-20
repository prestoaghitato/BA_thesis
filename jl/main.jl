#==
α = 0.05  # not debatable, thank you very much
==#

using DataFrames, HDF5, HypothesisTests, JLD

function clean(directory, filename)
    # open raw file
    open(directory*filename*".txt") do file
        lines = readlines(file)
        # open output file
        open(directory*filename*".csv", "w") do output
            # add header
            header = "antecedent,succedent,confidence,occurrences,duration_sec\n"
            write(output, header)
            # create regex
            r1 = r"\s\s+"
            # iterate through lines
            for line in lines
                # apply modifications one after another
                out = replace(line, ", ", ";")
                out = replace(out, r1, ",")
                out *= "\n"
                out = replace(out, " ", ",")
                # write to output
                write(output, out)
                # and you're so done, just end end end end it
            end
        end
    end
end


function separatesuccedents(df)
    # add boolean columns to state whether only
    # mother or only infant are in the succedent
    df[:mother_succ] = false
    df[:infant_succ] = false

    # put appropriate booleans in mother_succ and infant_succ columns
    for i in size(df, 1):-1:1  # iterate backwards (not necessary anymore)
        succ = df[i,:succedent]
        # if the mother is not/only the infant is in the succedent
        if !(contains(succ, ";m") || contains(succ, "(m"))
            df[i,:infant_succ] = true
        else
            df[i,:infant_succ] = false
        end
        # if the infant is not/only the mother is in the succedent
        if !(contains(succ, ";i") || contains(succ, "(i"))
            df[i,:mother_succ] = true
        else
            df[i,:mother_succ] = false
        end
    end

    # create Dataframes with rules containing
    # only mother or only infant in the succedent
    df_infant = df[(df[:infant_succ] .== true),:]
    df_mother = df[(df[:mother_succ] .== true),:]

    # delete now obsolete boolean columns
    for key in [:infant_succ, :mother_succ]
        delete!(df_infant, key)
        delete!(df_mother, key)
    end

    # return two DataFrames
    return df_infant, df_mother
end


function csvtorulesdict(df)
    #==
    NOTE: modify to directly create rules Dict
    NOTE: no need to create separate Dicts for real and null first
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


function iterateoverfiles(directories, filetype)
    #==
    NOTE: Does not work. At all.
    in: String[]    directories
        String      filetype
    ==#
    for directory in directories
        for file in readdir(directory)
            extension = file[end-3:end]
            if extension == filetype
                name = file[1:end-4]
                # do interesting stuff
            end
        end
    end
end


function createdictionary(df, rulesdict, realornull)
    #==
    in: DataFrame
    out: Dict
    ==#
    #iterate over DataFrame rows
    for i in 1:size(df, 1)
        # create empty rule template
        emptyrule = Dict(
            :real => Dict(
                :confidence => Float64[],
                :occurrences => Int64[],
                :duration_sec => Float64[],
                :observations => 0
            ),
            :null => Dict(
                :confidence => Float64[],
                :occurrences => Int64[],
                :duration_sec => Float64[],
                :observations => 0
            ),
        )
        currentrulename = df[i,:rule]
        if !haskey(rulesdict, currentrulename)
            # create if it doesn't exist
            rulesdict[currentrulename] = emptyrule
        end
        #== appends rule values to Dict arrays ==#
        # get addressess in rules Dict
        confidence = rulesdict[currentrulename][realornull][:confidence]
        occurrences = rulesdict[currentrulename][realornull][:occurrences]
        duration_sec = rulesdict[currentrulename][realornull][:duration_sec]

        # get values from DataFrame
        confidence_value = df[i,:confidence]
        occurrences_value = df[i,:occurrences]
        duration_sec_value = df[i,:duration_sec]

        # add values to rules Dict
        append!(confidence, confidence_value)
        append!(occurrences, occurrences_value)
        append!(duration_sec, duration_sec_value)
        # one more observation recorded
        rulesdict[currentrulename][realornull][:observations] += 1
    end
    return rulesdict
end


function dostuff()
    # directories array
    directories = ["input/real/", "input/null/"]

    # dirty text file to clean csv file
    for directory in directories        # iterate over directories
        for file in readdir(directory)  # iterate over files in directory
            extension = file[end-3:end] # get file extension
            if extension == ".txt"      # do some stuff if it's a txt file
                name = file[1:end-4]    # get file name without extension
                clean(directory, name)  # clean and convert to csv
                rm(directory*file)      # delete txt file
            end
        end
    end

    # csv file to two csv files with reaction times sorted
    for directory in directories        # identical code
        for file in readdir(directory)
            extension = file[end-3:end]
            if extension == ".csv"
                name = file[1:end-4]
                df = readtable(directory*file)  # read csv into DataFrame
                # separate rules by reaction time and appropriate succedent
                df_infant, df_mother = separatesuccedents(df)
                df_both = [df_infant; df_mother]  # vcat resulting DataFrames
                # merge antecedent and succedent to rule column
                df_both[:rule] = df_both[:antecedent] .* df_both[:succedent]
                # remove now obsolete antecedent and succedent columns
                delete!(df_both, [:antecedent, :succedent])
                writetable(directory*name*"_both.csv", df_both)  # write to file
                rm(directory*file)      # delete old csv file
            end
        end
    end


    # rt-sorted csv file to Dict
    rules = Dict()  # initialise rules Dictionary
    for directory in directories
        if directory == "input/real/"
            realornull = :real
        else
            realornull = :null
        end
        for file in readdir(directory)
            extension = file[end-3:end]
            if extension == ".csv"
                name = file[1:end-4]
                df = readtable(directory*file)  # read csv into DataFrame
                # add current csv to rules Dict
                rules = createdictionary(df, rules, realornull)
                # rm(directory*file)  # delete old csv file
            end
        end
    end

    # remove unnecessary keys where observations == 0
    minimumsig = 1  # how many occurrences to calculate significance_
    for key in keys(rules)
        for realornull in [:real, :null]
            if rules[key][realornull][:observations] == 0
                for metric in [:confidence, :occurrences, :duration_sec]
                    delete!(rules[key][realornull], metric)
                end
            end
        end
        # enough data for significance?
        enoughreal = rules[key][:real][:observations] > minimumsig
        enoughnull = rules[key][:null][:observations] > minimumsig
        if enoughreal && enoughnull
            # create significance keys
            rules[key][:significance] = Dict(
                :confidence => Float64[],
                :occurrences => Float64[],
                :duration_sec => Float64[]
            )
            # then let's fucking calculate some p-values
            for metric in [:confidence, :occurrences, :duration_sec]
                test = OneSampleTTest(
                    mean(rules[key][:real][metric]),     # xbar::Real
                    std(rules[key][:real][metric]),      # stddev::Real
                    length(rules[key][:real][metric]),   # n::Int
                    mean(rules[key][:null][metric])      # μ0::Real = 0
                )
                # store p-values in Dict
                rules[key][:significance][metric] = pvalue(test)
            end
        end
    end

    # BUG: save Dict as jdl, doesn't work for some reason
    # savejdl(rules, name)
    return rules
end

# rules = dostuff()
