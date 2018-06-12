using DataFrames

# rules = Dict(
#     :dummyrule => Dict(
#         :confidence => [
#             0.1,
#             0.2,
#             0.3,
#             0.4,
#             0.5
#         ],
#         :occurrences => [
#             1,
#             2,
#             3,
#             4,
#             5
#         ],
#         :duration_sec => [
#             0.1,
#             0.2,
#             0.3,
#             0.4,
#             0.5
#         ]
#     )
# )

function mainy(df)
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
            :duration_sec => Float64[]
        )
        currentrulename = df[i, :rule]
        function addstuff()
            #== appends rule values to Dict arrays ==#
            # get addressess in rules Dict
            confidence = rules[currentrulename][:confidence]
            occurrences = rules[currentrulename][:occurrences]
            duration_sec = rules[currentrulename][:duration_sec]

            # get values from DataFrame
            confidence_value = df[i, :confidence]
            occurrences_value = df[i, :occurrences]
            duration_sec_value = df[i, :duration_sec]

            # add values to rules Dict
            append!(confidence, confidence_value)
            append!(occurrences, occurrences_value)
            append!(duration_sec, duration_sec_value)
        end
        if haskey(rules, currentrulename)
            # do something if key exists
            addstuff()
        else
            # create the key
            rules[currentrulename] = emptyrule
            addstuff()
        end
    end
    return rules
end

sandbox = readtable("input/sandbox.csv")

rules = mainy(sandbox)
