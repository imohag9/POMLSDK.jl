mutable struct Prompt
    root_elements::Vector{XML.Node}
    current_parent_stack::Vector{XML.Node}
    function Prompt()
        root_elements = [XML.Element("poml")]
        current_parent_stack = root_elements
        new(root_elements, current_parent_stack)
    end
end

function push!(l::Vector{XML.Node}, n::XML.Node)
    Base.push!(l, n)
end

function add_node!(p::Prompt, node::XML.Node)
    Base.push!(p.current_parent_stack, node)
end

# Improved _prepare_attrs to handle bytes, booleans, and complex types (JSON)
function _prepare_attrs(; kwargs...)
    prepared = Dict{Symbol, String}()
    for (k, v) in kwargs
        if v === nothing
            continue
        end
        key_str = string(k) # Ensure key is a string
        if v isa Bool
            val_str = lowercase(string(v)) # "true" or "false"
        elseif v isa AbstractVector{UInt8} # Check for byte array
            # Encode bytes to base64
            val_str = String(base64encode(v))
        elseif v isa Number || v isa AbstractString
            val_str = string(v)
        else
            # Use JSON.json for complex types
            val_str = JSON.json(v)
        end
        prepared[Symbol(k)] = val_str
    end
    return prepared
end


export add_node!