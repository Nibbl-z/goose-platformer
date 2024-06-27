local str = {}

function str:split(input, splitter)
    if splitter == nil then
        splitter = "%s"
    end
    local t={}
    for str in string.gmatch(input, "([^"..splitter.."]+)") do
        table.insert(t, str)
    end
    return t
end

return str