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
        push!(confidence, confidence_value)
        push!(occurrences, occurrences_value)
        push!(duration_sec, duration_sec_value)
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
        push!(confidence, confidence_value)
        push!(occurrences, occurrences_value)
        push!(duration_sec, duration_sec_value)
        # one more observation recorded
        rulesdict[currentrulename][realornull][:observations] += 1
    end
    return rulesdict
end


function dostuff(n; minsigreal=1, minsignull=5, tail=:both)
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

    function statistics()
        #== collect statistical information ==#

        function prettyprinting()
            #== print pretty summary ==#
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
            if typeof(test) == HypothesisTests.OneSampleTTest
                testused = "one-sample Student t-test"
            elseif typeof(test) == SignedRankTest
                testused = "Wilcoxon signed rank test"
            end

            prettyfinal =  ""
            prettyfinal *= "SUMMARY:\n\n"
            prettyfinal *= "Total number of rules: $totalnumberofrules\n\n"
            prettyfinal *= "Number of rules with  >= n observations:\n"
            prettyfinal *= "  n  | real | null | both \n"
            prettyfinal *= "-----|------|------|------\n"
            for i in 1:n
                prettyi = prettyint(i)
                real = prettyint(realarray[i])
                null = prettyint(nullarray[i])
                both = prettyint(minarray[i])
                prettyfinal *= "$prettyi | $real | $null | $both\n"
            end
            prettyfinal *= "\nMinimum real observations for significance: $minsigreal\n"
            prettyfinal *= "Minimum null observations for significance: $minsignull\n"
            prettyfinal *= "Test used: $testused\n"
            prettyfinal *= "α = $α\n\n"
            prettyfinal *= "number of rules with significant\n"
            prettyfinal *= "             left | both | right \n"
            prettyfinal *= "            ------|------|-------\n"
            prettyfinal *= "confidence:  $(prettyint(sigconleft)) | $(prettyint(sigconboth)) |  $(prettyint(sigconright))\n"
            prettyfinal *= "occurrences: $(prettyint(sigoccleft)) | $(prettyint(sigoccboth)) |  $(prettyint(sigoccright))\n"
            prettyfinal *= "duration:    $(prettyint(sigdurleft)) | $(prettyint(sigdurboth)) |  $(prettyint(sigdurright))\n"
            prettyfinal *= "con & occ:   $(prettyint(sigconoccleft)) | $(prettyint(sigconoccboth)) |  $(prettyint(sigconoccright))\n"
            prettyfinal *= "con & occ:   $(prettyint(sigcondurleft)) | $(prettyint(sigcondurboth)) |  $(prettyint(sigcondurright))\n"
            prettyfinal *= "con & occ:   $(prettyint(sigoccdurleft)) | $(prettyint(sigoccdurboth)) |  $(prettyint(sigoccdurright))\n"
            prettyfinal *= "con & occ:   $(prettyint(sigallthreeleft)) | $(prettyint(sigallthreeboth)) |  $(prettyint(sigallthreeright))\n"

            println(prettyfinal)
        end

        α = 0.05  # What's our α-value? (not debatable, sorry not sorry)
        totalnumberofrules = length(rules)  # how many rules do we have?

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

        ### How many rules with significant metric m do we have? -- counters
        # counters to count all significant metrics
        sigconleft      = 0
        sigoccleft      = 0
        sigdurleft      = 0
        sigconoccleft   = 0
        sigcondurleft   = 0
        sigoccdurleft   = 0
        sigallthreeleft = 0

        sigconboth      = 0
        sigoccboth      = 0
        sigdurboth      = 0
        sigconoccboth   = 0
        sigcondurboth   = 0
        sigoccdurboth   = 0
        sigallthreeboth = 0

        sigconright      = 0
        sigoccright      = 0
        sigdurright      = 0
        sigconoccright   = 0
        sigcondurright   = 0
        sigoccdurright   = 0
        sigallthreeright = 0

        # arrays to store rule keys in
        allsigconleft       = String[]
        allsigoccleft       = String[]
        allsigdurleft       = String[]
        allsigconoccleft    = String[]
        allsigcondurleft    = String[]
        allsigoccdurleft    = String[]
        allsigallthreeleft  = String[]

        allsigconboth       = String[]
        allsigoccboth       = String[]
        allsigdurboth       = String[]
        allsigconoccboth    = String[]
        allsigcondurboth    = String[]
        allsigoccdurboth    = String[]
        allsigallthreeboth  = String[]

        allsigconright      = String[]
        allsigoccright      = String[]
        allsigdurright      = String[]
        allsigconoccright   = String[]
        allsigcondurright   = String[]
        allsigoccdurright   = String[]
        allsigallthreeright = String[]

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
                issigconleft = rules[key][:sigleft][:confidence] < α
                issigoccleft = rules[key][:sigleft][:occurrences] < α
                issigdurleft = rules[key][:sigleft][:duration_sec] < α

                issigconright = rules[key][:sigright][:confidence] < α
                issigoccright = rules[key][:sigright][:occurrences] < α
                issigdurright = rules[key][:sigright][:duration_sec] < α

                issigconboth = rules[key][:sigboth][:confidence] < α
                issigoccboth = rules[key][:sigboth][:occurrences] < α
                issigdurboth = rules[key][:sigboth][:duration_sec] < α

                # increment appropriate counters and store rule keys in arrays
                # left significance
                if issigconleft
                    sigconleft += 1
                    push!(allsigconleft, key)
                end
                if issigoccleft
                    sigoccleft += 1
                    push!(allsigoccleft, key)
                end
                if issigdurleft
                    sigdurleft   += 1
                    push!(allsigdurleft, key)
                end
                if issigconleft && issigoccleft
                    sigconoccleft   += 1
                    push!(allsigconoccleft, key)
                end
                if issigconleft && issigdurleft
                    sigcondurleft   += 1
                    push!(allsigcondurleft, key)
                end
                if issigoccleft && issigdurleft
                    sigoccdurleft   += 1
                    push!(allsigoccdurleft, key)
                end
                if issigconleft && issigoccleft && issigdurleft
                    sigallthreeleft += 1
                    push!(allsigallthreeleft, key)
                end

                # two-tailed significance
                if issigconboth
                    sigconboth += 1
                    push!(allsigconboth, key)
                end
                if issigoccboth
                    sigoccboth += 1
                    push!(allsigoccboth, key)
                end
                if issigdurboth
                    sigdurboth   += 1
                    push!(allsigdurboth, key)
                end
                if issigconboth && issigoccboth
                    sigconoccboth   += 1
                    push!(allsigconoccboth, key)
                end
                if issigconboth && issigdurboth
                    sigcondurboth   += 1
                    push!(allsigcondurboth, key)
                end
                if issigoccboth && issigdurboth
                    sigoccdurboth   += 1
                    push!(allsigoccdurboth, key)
                end
                if issigconboth && issigoccboth && issigdurboth
                    sigallthreeboth += 1
                    push!(allsigallthreeboth, key)
                end

                # right significance
                if issigconright
                    sigconright += 1
                    push!(allsigconright, key)
                end
                if issigoccright
                    sigoccright += 1
                    push!(allsigoccright, key)
                end
                if issigdurright
                    sigdurright   += 1
                    push!(allsigdurright, key)
                end
                if issigconright && issigoccright
                    sigconoccright   += 1
                    push!(allsigconoccright, key)
                end
                if issigconright && issigdurright
                    sigcondurright   += 1
                    push!(allsigcondurright, key)
                end
                if issigoccright && issigdurright
                    sigoccdurright   += 1
                    push!(allsigoccdurright, key)
                end
                if issigconright && issigoccright && issigdurright
                    sigallthreeright += 1
                    push!(allsigallthreeright, key)
                end
            end
        end

        ### Put stuff in stats Dict.
        stats = Dict()  # initialise stats Dict (duh…)

        # how many rule observations in total?
        stats[:totalnumberofrules] = totalnumberofrules

        # how many rules had [n] observations of real, null, or both?
        stats[:realarray]           = realarray
        stats[:nullarray]           = nullarray
        stats[:minarray]            = minarray

        # how many rules were significant for metric m?
        stats[:sigconleft]          = sigconleft
        stats[:sigoccleft]          = sigoccleft
        stats[:sigdurleft]          = sigdurleft
        stats[:sigconoccleft]       = sigconoccleft
        stats[:sigcondurleft]       = sigcondurleft
        stats[:sigoccdurleft]       = sigoccdurleft
        stats[:sigallthreeleft]     = sigallthreeleft

        stats[:sigconboth]          = sigconboth
        stats[:sigoccboth]          = sigoccboth
        stats[:sigdurboth]          = sigdurboth
        stats[:sigconoccboth]       = sigconoccboth
        stats[:sigcondurboth]       = sigcondurboth
        stats[:sigoccdurboth]       = sigoccdurboth
        stats[:sigallthreeboth]     = sigallthreeboth

        stats[:sigconright]         = sigconright
        stats[:sigoccright]         = sigoccright
        stats[:sigdurright]         = sigdurright
        stats[:sigconoccright]      = sigconoccright
        stats[:sigcondurright]      = sigcondurright
        stats[:sigoccdurright]      = sigoccdurright
        stats[:sigallthreeright]    = sigallthreeright

        # String[] with significant rules' keys
        stats[:allsigconleft]           = allsigconleft
        stats[:allsigoccleft]           = allsigoccleft
        stats[:allsigdurleft]           = allsigdurleft
        stats[:allsigconoccleft]        = allsigconoccleft
        stats[:allsigcondurleft]        = allsigcondurleft
        stats[:allsigoccdurleft]        = allsigoccdurleft
        stats[:allsigallthreeleft]      = allsigallthreeleft

        stats[:allsigconboth]           = allsigconboth
        stats[:allsigoccboth]           = allsigoccboth
        stats[:allsigdurboth]           = allsigdurboth
        stats[:allsigconoccboth]        = allsigconoccboth
        stats[:allsigcondurboth]        = allsigcondurboth
        stats[:allsigoccdurboth]        = allsigoccdurboth
        stats[:allsigallthreeboth]      = allsigallthreeboth

        stats[:allsigconright]           = allsigconright
        stats[:allsigoccright]           = allsigoccright
        stats[:allsigdurright]           = allsigdurright
        stats[:allsigconoccright]        = allsigconoccright
        stats[:allsigcondurright]        = allsigcondurright
        stats[:allsigoccdurright]        = allsigoccdurright
        stats[:allsigallthreeright]      = allsigallthreeright

        prettyprinting()
        return stats
    end



    # BUG: save Dict as jdl, doesn't work for some reason
    # savejdl(rules, name)
    stats = statistics()
    return rules
end


# dostuff(n, minsigreal, minsignull, tail)
rules = dostuff(20; minsigreal=2, minsignull=5, tail=:both)
