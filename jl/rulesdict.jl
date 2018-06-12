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
    emptyrule = Dict(
        :confidence => Float64[],
        :occurrences => Float64[],
        :duration_sec => Float64[]
    )
    #iterate over DataFrame rows
    for i in 1:size(df, 1)  # NOTE: uncomment when done
        currentrulename = df[i, :rule]
        if haskey(rules, currentrulename)
            # do something if key exists
        else
            rules[convert(Symbol, currentrulename)] = emptyrule
        end
    end
    return rules
end

sandbox = readtable("input/sandbox.csv")

rules = mainy(sandbox)
