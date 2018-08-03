#==
α = 0.05  # not debatable, thank you very much
==#

using DataFrames, HDF5, HypothesisTests, JLD

function txttocleancsv(directory, filename)
    #==
    clean raw txt file and save as csv
    in:
        directory   ::String, directory of txt files
        filename    ::String, name of file to be cleaned
    ==#
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
            end
        end
    end
end


function separatesuccedents(df)
    #==
    in:
        df          ::DataFrame
    out:
        df_infant   ::DataFrame
        df_mother   ::DataFrame
    ==#
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


function addrulestodict(df, rulesdict, realornull)
    #==
    add new rules to rulesdict
    in:
        df          ::DataFrame, contains new rules to be added
        rulesdict   ::Dict, may contain rules, new ones are added
        realornull  ::Symbol, indicates whether df contains real or null data
    out:
        rulesdict   ::Dict, with new rules added
    ==#
    #iterate over DataFrame rows
    for i in 1:size(df, 1)
        # empty rule template
        emptyrule = Dict(
            :antecedent => "",
            :succedent => "",
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
            # add antecedent and succedent separately for csv later
            rulesdict[currentrulename][:antecedent] = df[i,:antecedent]
            rulesdict[currentrulename][:succedent]  = df[i,:succedent]
        end
        #== appends rule values to Dict arrays ==#
        # get addressess in rules Dict (views)
        confidence = rulesdict[currentrulename][realornull][:confidence]
        occurrences = rulesdict[currentrulename][realornull][:occurrences]
        duration_sec = rulesdict[currentrulename][realornull][:duration_sec]
        # get values from DataFrame
        confidence_value = df[i,:confidence]
        occurrences_value = df[i,:occurrences]
        duration_sec_value = df[i,:duration_sec]
        # add values to rules Dict
        push!(confidence, confidence_value)
        push!(occurrences, occurrences_value)
        push!(duration_sec, duration_sec_value)
        # increment observation counter
        rulesdict[currentrulename][realornull][:observations] += 1
    end
    return rulesdict
end


function prettyint(n; style="spaces")
    #==
    in: Int < 10000
    out: String
    ==#
    if style == "zeros"
        if n < 10
            return string("000", n)
        elseif n < 100
            return string("00", n)
        elseif n < 1000
            return string("0", n)
        else
            return string(n)
        end
    elseif style == "spaces"
        if n < 10
            return string("   ", n)
        elseif n < 100
            return string("  ", n)
        elseif n < 1000
            return string(" ", n)
        else
            return string(n)
        end
    end
end


function prettyprinting(stats, n)
    #== print pretty summary ==#

    prettyfinal =  ""
    prettyfinal *= "SUMMARY:\n\n"
    prettyfinal *= "Total number of rules: $(stats[:totalnumberofrules])\n\n"
    prettyfinal *= "Number of rules with  >= n null observations:\n"
    prettyfinal *= "  n  | null \n"
    prettyfinal *= "-----|------\n"
    for i in 1:n
        prettyi = prettyint(i)
        # real = prettyint(stats[:realarray][i])
        null = prettyint(stats[:nullarray][i])
        # both = prettyint(stats[:minarray][i])
        prettyfinal *= "$prettyi | $null\n"
    end
    prettyfinal *= "Minimum null observations for significance: $(stats[:minsignull])\n"
    prettyfinal *= "α = $(stats[:α])\n\n"
    prettyfinal *= "number of rules with significant\n"
    nsfm = stats[:numsigrulesformetric]
    prettyfinal *= "confidence:  $(prettyint(nsfm[:sigcon]))\n"
    prettyfinal *= "occurrences: $(prettyint(nsfm[:sigocc]))\n"
    prettyfinal *= "duration:    $(prettyint(nsfm[:sigdur]))\n"
    prettyfinal *= "con & occ:   $(prettyint(nsfm[:sigconocc]))\n"
    prettyfinal *= "con & dur:   $(prettyint(nsfm[:sigcondur]))\n"
    prettyfinal *= "occ & dur:   $(prettyint(nsfm[:sigoccdur]))\n"
    prettyfinal *= "all three:   $(prettyint(nsfm[:sigallthree]))\n"

    println(prettyfinal)
end

function statistics(n, rules, test, minsignull)
    #==
    collect statistical information
    in:
        n           ::Int   maximum value for which we want to show the number of
                            rules that have been observed that many times
        rules       ::Dict  store all rules and their metrics
        minsignull  ::Int   minimum number of null observations for calculating significance
    ==#

    ### How many rules with n observations do we have? -- counters
    # create arrays to store observation values in
    nullarray = Array{Int64}(n)
    # initialise arrays to 0
    for i in 1:n
        nullarray[i] = 0
    end

    # initialise stats Dict
    stats = Dict(
        :numsigrulesformetric => Dict(),        # how many rules with significant metric m do we have?
        :sigstrings => Dict(),                  # String[] storing all rule keys with significance for metric m
        :totalnumberofrules => length(rules),   # how many observations were there?
        :minsignull => minsignull,              # how many null observations do we want to calculate significance?
        :α => 0.05                              # α-level (not debatable, sorry not sorry)
    )

    # add counters to :numsigrulesformetric
    metricabb = ["con", "occ", "dur", "conocc", "condur", "occdur", "allthree"]
    for a in metricabb
        newkey = convert(Symbol, "sig"*a)
        stats[:numsigrulesformetric][newkey] = 0
        stats[:sigstrings][newkey] = String[]
    end

    # iterate through Dict to calculate table values
    for key in keys(rules)

        # how many rules with n null observations do we have?
        nullobservations = rules[key][:null][:observations]
        # increment appropriate array values
        for i in 1:min(n, nullobservations)  # only count as far as n
            nullarray[i] += 1
        end

        ### How many rules with significant metric m do we have? -- counters
        # was significance calculated?
        if haskey(rules[key], :significance)
            # what was significant?
            issigcon = rules[key][:significance][:confidence] < stats[:α]
            issigocc = rules[key][:significance][:occurrences] < stats[:α]
            issigdur = rules[key][:significance][:duration_sec] < stats[:α]

            # increment appropriate counters and store rule keys in arrays
            if issigcon
                stats[:numsigrulesformetric][:sigcon] += 1
                push!(stats[:sigstrings][:sigcon], key)
            end
            if issigocc
                stats[:numsigrulesformetric][:sigocc] += 1
                push!(stats[:sigstrings][:sigocc], key)
            end
            if issigdur
                stats[:numsigrulesformetric][:sigdur] += 1
                push!(stats[:sigstrings][:sigdur], key)
            end
            if issigcon && issigocc
                stats[:numsigrulesformetric][:sigconocc] += 1
                push!(stats[:sigstrings][:sigconocc], key)
            end
            if issigcon && issigdur
                stats[:numsigrulesformetric][:sigcondur] += 1
                push!(stats[:sigstrings][:sigcondur], key)
            end
            if issigocc && issigdur
                stats[:numsigrulesformetric][:sigoccdur] += 1
                push!(stats[:sigstrings][:sigoccdur], key)
            end
            if issigcon && issigocc && issigdur
                stats[:numsigrulesformetric][:sigallthree] += 1
                push!(stats[:sigstrings][:sigallthree], key)
            end
        end
    end

    # how many rules had [n] observations of real, null, or both?
    stats[:nullarray] = nullarray

    return stats
end

function rankedtest(real, null)
    real = mean(real)
    len = length(null)
    geq = 0
    for i in null
        if i >= real
            geq += 1
        end
    end
    pvalue = geq/len
    return pvalue
end

function dicttodf(rules; all=true)
    #==
    in:
        rules   ::Dict
    out:
        df      ::DataFrame
    ==#
    df = DataFrame(
        antecedent = String[],
        succedent = String[],
        p_con = Float64[],
        p_occ = Float64[],
        p_dur = Float64[],
        null_obs = Int64[],
    )

    for rule in keys(rules)
        antecedent = rules[rule][:antecedent]
        succedent = rules[rule][:succedent]
        null_obs = rules[rule][:null][:observations]

        if haskey(rules[rule], :significance)
            p_con = rules[rule][:significance][:confidence]
            p_occ = rules[rule][:significance][:occurrences]
            p_dur = rules[rule][:significance][:duration_sec]
        else
            p_con = 999
            p_occ = 999
            p_dur = 999
        end
        if !all
            if p_con < 0.05 || p_occ < 0.05 || p_dur < 0.05
                push!(df, [antecedent, succedent, p_con, p_occ, p_dur, null_obs])
            end
        else
            push!(df, [antecedent, succedent, p_con, p_occ, p_dur, null_obs])
        end
    end
    return df
end


function dostuff(n; minsignull=5)
    # directories array
    directories = ["input/real/", "input/null/"]
    # NOTE: there's a better way to do this, check scope docs
    test = nothing  # needed outside for loop

    # dirty text file to clean csv file
    for directory in directories        # iterate over directories
        for file in readdir(directory)  # iterate over files in directory
            extension = file[end-3:end] # get file extension
            if extension == ".txt"      # do some stuff if it's a txt file
                name = file[1:end-4]    # get file name without extension
                txttocleancsv(directory, name)  # clean and convert to csv
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

                # NOTE: not separating succedents anymore
                # separate rules by reaction time and appropriate succedent
                # df_infant, df_mother = separatesuccedents(df)
                # df_both = [df_infant; df_mother]  # vcat resulting DataFrames
                df_both = df

                # merge antecedent and succedent to rule column
                df_both[:rule] = df_both[:antecedent] .* df_both[:succedent]
                # remove now obsolete antecedent and succedent columns
                # delete!(df_both, [:antecedent, :succedent])
                writetable(directory*name*"_both.csv", df_both)  # write to file
                rm(directory*file)      # delete old csv file
            end
        end
    end


    # RT-sorted csv file to Dict
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
                rules = addrulestodict(df, rules, realornull)
                # rm(directory*file)  # delete old csv file  # NOTE: maybe uncomment this?
            end
        end
    end

    # calculate significance
    for key in keys(rules)
        for realornull in [:real, :null]
            # remove unnecessary keys where observations == 0
            if rules[key][realornull][:observations] == 0
                for metric in [:confidence, :occurrences, :duration_sec]
                    delete!(rules[key][realornull], metric)
                end
            end
        end
        # enough data for significance?
        enoughreal = rules[key][:real][:observations] >= 1
        enoughnull = rules[key][:null][:observations] >= minsignull
        if enoughreal && enoughnull
            # and let's fucking calculate some p-values
            # create significance key
            rules[key][:significance] = Dict(
                :confidence => 1.1,
                :occurrences => 1.1,
                :duration_sec => 1.1,
            )
            for metric in [:confidence, :occurrences, :duration_sec]
                test = rankedtest(
                    rules[key][:real][metric],  # real data
                    rules[key][:null][metric],  # null data
                )
                # store p-values in Dict
                rules[key][:significance][metric] = test
            end
        end
    end

    # save summary to DataFrame
    df = dicttodf(rules; all=false)  # NOTE: only save significant rules
    # and write as csv to output directory
    writetable("output/results.csv", df)

    stats = statistics(n, rules, test, minsignull)
    prettyprinting(stats, n)
    return rules, stats
end


rules, stats = dostuff(10; minsignull=5)
