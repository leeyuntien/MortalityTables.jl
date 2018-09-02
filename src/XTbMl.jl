import DataStructures
import XMLDict

function getXML(path)
    s = open(path) do file
        read(file,String)
    end
    return xml = XMLDict.xml_dict(s)

end
# get potentially missing value out of dict
function getVal(dict,key)
    try
        return val = parse(Float64,dict[key])
    catch y
        if isa(y,KeyError)
            return val = missing
        else
            throw(y)
        end
    end
end

struct XTbMLTable
    select::DataStructures.DefaultOrderedDict
    ultimate::DataStructures.DefaultOrderedDict
end

function loadXTbMLTable(path)

    x = getXML(path)
    name = x["XTbML"]["ContentClassification"]["TableName"]

    tbl = XTbMLTable(DataStructures.DefaultOrderedDict(missing),DataStructures.DefaultOrderedDict(missing))

    for ai in x["XTbML"]["Table"][1]["Values"]["Axis"]
        issue_age = parse(Int,ai[:t])
        tbl.select[issue_age] = DataStructures.DefaultOrderedDict(missing)
        for aj in ai["Axis"]["Y"]
            duration = parse(Int,aj[:t])
            rate = getVal(aj,"")
            if !ismissing(rate)
                tbl.select[issue_age][duration]= rate
            end
        end
    end

    for ai in x["XTbML"]["Table"][2]["Values"]["Axis"]["Y"]
        age = parse(Int,ai[:t])
        rate = getVal(ai,"")
        if !ismissing(rate)
            tbl.ultimate[age]= rate
        end
    end

    return (tbl, name)
end