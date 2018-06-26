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
    prettyfinal *= "Number of rules with  >= n observations:\n"
    prettyfinal *= "  n  | real | null | both \n"
    prettyfinal *= "-----|------|------|------\n"
    for i in 1:n
        prettyi = prettyint(i)
        real = prettyint(stats[:realarray][i])
        null = prettyint(stats[:nullarray][i])
        both = prettyint(stats[:minarray][i])
        prettyfinal *= "$prettyi | $real | $null | $both\n"
    end
    prettyfinal *= "\nMinimum real observations for significance: $(stats[:minsigreal])\n"
    prettyfinal *= "Minimum null observations for significance: $(stats[:minsignull])\n"
    prettyfinal *= "Test used: $(stats[:testtype])\n"
    prettyfinal *= "α = $(stats[:α])\n\n"
    prettyfinal *= "number of rules with significant\n"
    prettyfinal *= "             left | both | right \n"
    prettyfinal *= "            ------|------|-------\n"
    nsfm = stats[:numsigrulesformetric]
    prettyfinal *= "confidence:  $(prettyint(nsfm[:sigconleft])) | $(prettyint(nsfm[:sigconboth])) |  $(prettyint(nsfm[:sigconright]))\n"
    prettyfinal *= "occurrences: $(prettyint(nsfm[:sigoccleft])) | $(prettyint(nsfm[:sigoccboth])) |  $(prettyint(nsfm[:sigoccright]))\n"
    prettyfinal *= "duration:    $(prettyint(nsfm[:sigdurleft])) | $(prettyint(nsfm[:sigdurboth])) |  $(prettyint(nsfm[:sigdurright]))\n"
    prettyfinal *= "con & occ:   $(prettyint(nsfm[:sigconoccleft])) | $(prettyint(nsfm[:sigconoccboth])) |  $(prettyint(nsfm[:sigconoccright]))\n"
    prettyfinal *= "con & dur:   $(prettyint(nsfm[:sigcondurleft])) | $(prettyint(nsfm[:sigcondurboth])) |  $(prettyint(nsfm[:sigcondurright]))\n"
    prettyfinal *= "occ & dur:   $(prettyint(nsfm[:sigoccdurleft])) | $(prettyint(nsfm[:sigoccdurboth])) |  $(prettyint(nsfm[:sigoccdurright]))\n"
    prettyfinal *= "all three:   $(prettyint(nsfm[:sigallthreeleft])) | $(prettyint(nsfm[:sigallthreeboth])) |  $(prettyint(nsfm[:sigallthreeright]))\n"

    println(prettyfinal)
end

function statistics(n, rules, test, minsigreal, minsignull)
    #==
    collect statistical information
    in:
        n           ::Int, maximum value for which we want to show the number of rules that have been observed that many times
        rules       ::Dict, store all rules and their metrics
        test        ::HypothesisTests, significance test used
        minsigreal  ::Int, minimum number of real observations for calculating significance
        minsignull  ::Int, minimum number of null observations for calculating significance
    ==#

    ### How many rules with n observations do we have? -- counters
    # create arrays to store observation values in
    realarray = Array{Int64}(n)
    nullarray = Array{Int64}(n)
    minarray = Array{Int64}(n)
    # initialise arrays to 0
    for i in 1:n
        realarray[i] = 0
        nullarray[i] = 0
        minarray[i] = 0
    end

    # initialise stats Dict
    stats = Dict(
        :numsigrulesformetric => Dict(),            # how many rules with significant metric m do we have?
        :sigmetricarrays => Dict(),                 # String[] storing all rule keys with significance for metric m
        :totalnumberofrules => length(rules),       # how many observations were there?
        :testtype => string(typeof(test))[17:end],  # what type of test was used?
        :minsigreal => minsigreal,                  # how many real observations do we want to calculate significance?
        :minsignull => minsignull,                  # how many null observations do we want to calculate significance?
        :α => 0.05                                  # α-level (not debatable, sorry not sorry)
    )

    # add counters to :numsigrulesformetric
    metricabb = ["con", "occ", "dur", "conocc", "condur", "occdur", "allthree"]
    tailstr = ["left", "both", "right"]
    for a in metricabb
        for b in tailstr
            newkey = convert(Symbol, "sig"*a*b)
            newallkey = convert(Symbol, "allsig"*a*b)
            stats[:numsigrulesformetric][newkey] = 0
            stats[:sigmetricarrays][newallkey] = String[]
        end
    end

    # iterate through Dict to calculate table values
    for key in keys(rules)

        ### How many rules with n observations do we have? -- calculation
        # how many real and null observations?
        realobservations = rules[key][:real][:observations]
        nullobservations = rules[key][:null][:observations]
        # what's the lower value of the two?
        minobservations = min(realobservations, nullobservations)
        # increment appropriate array values
        for i in 1:min(n, realobservations)  # only count as far as n
            realarray[i] += 1
        end
        for i in 1:min(n, nullobservations)
            nullarray[i] += 1
        end
        for i in 1:min(n, minobservations)
            minarray[i] += 1
        end

        ### How many rules with significant metric m do we have? -- counters
        # was significance calculated?
        if haskey(rules[key], :sigleft)
            # what was significant?
            issigconleft = rules[key][:sigleft][:confidence] < stats[:α]
            issigoccleft = rules[key][:sigleft][:occurrences] < stats[:α]
            issigdurleft = rules[key][:sigleft][:duration_sec] < stats[:α]

            issigconright = rules[key][:sigright][:confidence] < stats[:α]
            issigoccright = rules[key][:sigright][:occurrences] < stats[:α]
            issigdurright = rules[key][:sigright][:duration_sec] < stats[:α]

            issigconboth = rules[key][:sigboth][:confidence] < stats[:α]
            issigoccboth = rules[key][:sigboth][:occurrences] < stats[:α]
            issigdurboth = rules[key][:sigboth][:duration_sec] < stats[:α]

            # increment appropriate counters and store rule keys in arrays
            # left significance
            if issigconleft
                stats[:numsigrulesformetric][:sigconleft] += 1
                push!(stats[:sigmetricarrays][:allsigconleft], key)
            end
            if issigoccleft
                stats[:numsigrulesformetric][:sigoccleft] += 1
                push!(stats[:sigmetricarrays][:allsigoccleft], key)
            end
            if issigdurleft
                stats[:numsigrulesformetric][:sigdurleft] += 1
                push!(stats[:sigmetricarrays][:allsigdurleft], key)
            end
            if issigconleft && issigoccleft
                stats[:numsigrulesformetric][:sigconoccleft] += 1
                push!(stats[:sigmetricarrays][:allsigconoccleft], key)
            end
            if issigconleft && issigdurleft
                stats[:numsigrulesformetric][:sigcondurleft] += 1
                push!(stats[:sigmetricarrays][:allsigcondurleft], key)
            end
            if issigoccleft && issigdurleft
                stats[:numsigrulesformetric][:sigoccdurleft] += 1
                push!(stats[:sigmetricarrays][:allsigoccdurleft], key)
            end
            if issigconleft && issigoccleft && issigdurleft
                stats[:numsigrulesformetric][:sigallthreeleft] += 1
                push!(stats[:sigmetricarrays][:allsigallthreeleft], key)
            end

            # two-tailed significance
            if issigconboth
                stats[:numsigrulesformetric][:sigconboth] += 1  # BUG
                push!(stats[:sigmetricarrays][:allsigconboth], key)
            end
            if issigoccboth
                stats[:numsigrulesformetric][:sigoccboth] += 1
                push!(stats[:sigmetricarrays][:allsigoccboth], key)
            end
            if issigdurboth
                stats[:numsigrulesformetric][:sigdurboth] += 1
                push!(stats[:sigmetricarrays][:allsigdurboth], key)
            end
            if issigconboth && issigoccboth
                stats[:numsigrulesformetric][:sigconoccboth] += 1
                push!(stats[:sigmetricarrays][:allsigconoccboth], key)
            end
            if issigconboth && issigdurboth
                stats[:numsigrulesformetric][:sigcondurboth] += 1
                push!(stats[:sigmetricarrays][:allsigcondurboth], key)
            end
            if issigoccboth && issigdurboth
                stats[:numsigrulesformetric][:sigoccdurboth] += 1
                push!(stats[:sigmetricarrays][:allsigoccdurboth], key)
            end
            if issigconboth && issigoccboth && issigdurboth
                stats[:numsigrulesformetric][:sigallthreeboth] += 1
                push!(stats[:sigmetricarrays][:allsigallthreeboth], key)
            end

            # right significance
            if issigconright
                stats[:numsigrulesformetric][:sigconright] += 1
                push!(stats[:sigmetricarrays][:allsigconright], key)
            end
            if issigoccright
                stats[:numsigrulesformetric][:sigoccright] += 1
                push!(stats[:sigmetricarrays][:allsigoccright], key)
            end
            if issigdurright
                stats[:numsigrulesformetric][:sigdurright] += 1
                push!(stats[:sigmetricarrays][:allsigdurright], key)
            end
            if issigconright && issigoccright
                stats[:numsigrulesformetric][:sigconoccright] += 1
                push!(stats[:sigmetricarrays][:allsigconoccright], key)
            end
            if issigconright && issigdurright
                stats[:numsigrulesformetric][:sigcondurright] += 1
                push!(stats[:sigmetricarrays][:allsigcondurright], key)
            end
            if issigoccright && issigdurright
                stats[:numsigrulesformetric][:sigoccdurright] += 1
                push!(stats[:sigmetricarrays][:allsigoccdurright], key)
            end
            if issigconright && issigoccright && issigdurright
                stats[:numsigrulesformetric][:sigallthreeright] += 1
                push!(stats[:sigmetricarrays][:allsigallthreeright], key)
            end
        end
    end

    # how many rules had [n] observations of real, null, or both?
    stats[:realarray]           = realarray
    stats[:nullarray]           = nullarray
    stats[:minarray]            = minarray

    return stats
end


function dostuff(n; minsigreal=1, minsignull=5)
    # directories array
    directories = ["input/real/", "input/null/"]
    # NOTE: there's a better way to do this, check scope docs
    test = nothing  # needed outside of for loop

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
                rules = addrulestodict(df, rules, realornull)
                # rm(directory*file)  # delete old csv file
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
        enoughreal = rules[key][:real][:observations] >= minsigreal
        enoughnull = rules[key][:null][:observations] >= minsignull
        if enoughreal && enoughnull
            # and let's fucking calculate some p-values
            # create significance keys
            sides = [:sigleft, :sigboth, :sigright]
            for side in sides
                rules[key][side] = Dict(
                    :confidence => Float64[],
                    :occurrences => Float64[],
                    :duration_sec => Float64[]
                )
            end
            for metric in [:confidence, :occurrences, :duration_sec]
                test = OneSampleTTest(
                    mean(rules[key][:real][metric]),     # xbar::Real
                    std(rules[key][:real][metric]),      # stddev::Real
                    length(rules[key][:real][metric]),   # n::Int
                    mean(rules[key][:null][metric])      # μ0::Real = 0
                )
                # store p-values in Dict
                for side in sides
                    if side == :sigleft
                        rules[key][side][metric] = pvalue(test, tail=:left)
                    elseif side == :sigboth
                        rules[key][side][metric] = pvalue(test, tail=:both)
                    else
                        rules[key][side][metric] = pvalue(test, tail=:right)
                    end
                end
            end
        end
    end

    # save summary to DataFrame
    df = DataFrame(
        rule = String[],
        real_obs = Int64[],
        null_obs = Int64[],
        p_confidence_left = Float64[],
        p_occurrences_left = Float64[],
        p_duration_left = Float64[],
        p_confidence_both = Float64[],
        p_occurrences_both = Float64[],
        p_duration_both = Float64[],
        p_confidence_right = Float64[],
        p_occurrences_right = Float64[],
        p_duration_right = Float64[]
    )
    for rule in keys(rules)
        if haskey(rules[rule], :sigleft)
            real_obs = rules[rule][:real][:observations]
            null_obs = rules[rule][:null][:observations]

            p_confidence_left = rules[rule][:sigleft][:confidence]
            p_occurrences_left = rules[rule][:sigleft][:occurrences]
            p_duration_left = rules[rule][:sigleft][:duration_sec]

            p_confidence_both = rules[rule][:sigboth][:confidence]
            p_occurrences_both = rules[rule][:sigboth][:occurrences]
            p_duration_both = rules[rule][:sigboth][:duration_sec]

            p_confidence_right = rules[rule][:sigright][:confidence]
            p_occurrences_right = rules[rule][:sigright][:occurrences]
            p_duration_right = rules[rule][:sigright][:duration_sec]
            row = [
                rule,
                real_obs,
                null_obs,
                p_confidence_left,
                p_occurrences_left,
                p_duration_left,
                p_confidence_both,
                p_occurrences_both,
                p_duration_both,
                p_confidence_right,
                p_occurrences_right,
                p_duration_right
            ]
            push!(df, row)
        end
    end

    # and save as csv to output
    writetable("output/results.csv", df)

    # BUG: save Dict as jdl, doesn't work for some reason
    # savejdl(rules, name)
    stats = statistics(n, rules, test, minsigreal, minsignull)
    prettyprinting(stats, n)
    return rules, stats
end


rules, stats = dostuff(10; minsigreal=2, minsignull=5)
