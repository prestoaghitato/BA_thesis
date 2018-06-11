
function clean(filename)
    # open raw file
    open("input/"*filename*".txt") do file
        lines = readlines(file)
        # open output file
        open("output/"*filename*".csv", "w") do output
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

function main()
    # iterate through files in input directory
    for file in readdir("input")
        # get file extension
        extension = file[end-3:end]
        # do some stuff if it's a text file
        if extension == ".txt"
            name = file[1:end-4]
            clean(name)
        end
    end
end
