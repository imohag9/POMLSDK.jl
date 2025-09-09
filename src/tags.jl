function tag(p::Prompt, tag_name::String; kwargs...)
    attrs = _prepare_attrs(; kwargs...)
    node = XML.Element(tag_name; attrs...)
    if isempty(p.current_parent_stack)
        push!(p.root_elements, node)
    else
        push!(p.current_parent_stack[end].children, node)
    end
    return node
end

function pop_node!(p::Prompt)
    if length(p.current_parent_stack) === 1
       error("No popping when only root element remains")
    end
    Base.pop!(p.current_parent_stack)

end

function dump_poml(p::Prompt)
    xml_strings = String[]
    for root in p.root_elements
        # Check if the root element is empty (has no children)
        if isempty(root.children)
            # Manually create a proper empty element with both opening and closing tags
            Base.push!(xml_strings, "<$(root.tag)></$(root.tag)>")
        else
            # Use the normal XML writer for non-empty elements
            Base.push!(xml_strings, XML.write(root))
        end
    end
    return join(xml_strings, "")
end

function write_poml(io::IO,p::Prompt)
    write(io, dump_poml(p))
end

function add_text(p::Prompt, content::String)
    if isempty(p.root_elements[1].children)
        error("No open tag to add text to.")
    end
    node = p.current_parent_stack[end]
    push!(node.children, XML.Text(content))
end

# POML components
function document(p::Prompt; kwargs...)
    return tag(p, "Document"; kwargs...)
end
function role(p::Prompt; kwargs...)
    return tag(p, "Role"; kwargs...)
end
# function text(p::Prompt; kwargs...)
#     return tag(p, "text"; kwargs...)
# end
function task(p::Prompt; kwargs...)
    return tag(p, "Task"; kwargs...)
end
function output_format(p::Prompt; kwargs...)
    return tag(p, "OutputFormat"; kwargs...)
end
function stepwise_instructions(p::Prompt; kwargs...)
    return tag(p, "StepwiseInstructions"; kwargs...)
end
function hint(p::Prompt; kwargs...)
    return tag(p, "Hint"; kwargs...)
end
function introducer(p::Prompt; kwargs...)
    return tag(p, "Introducer"; kwargs...)
end
function example_set(p::Prompt; kwargs...)
    return tag(p, "ExampleSet"; kwargs...)
end
function example(p::Prompt; kwargs...)
    return tag(p, "Example"; kwargs...)
end
function example_input(p::Prompt; kwargs...)
    return tag(p, "ExampleInput"; kwargs...)
end
function example_output(p::Prompt; kwargs...)
    return tag(p, "ExampleOutput"; kwargs...)
end
function question(p::Prompt; kwargs...)
    return tag(p, "Question"; kwargs...)
end
function system_message(p::Prompt; kwargs...)
    return tag(p, "SystemMessage"; kwargs...)
end
function human_message(p::Prompt; kwargs...)
    return tag(p, "HumanMessage"; kwargs...)
end
function ai_message(p::Prompt; kwargs...)
    return tag(p, "AIMessage"; kwargs...)
end
function tool_message(p::Prompt; kwargs...)
    return tag(p, "ToolMessage"; kwargs...)
end
function message_content(p::Prompt; kwargs...)
    return tag(p, "MessageContent"; kwargs...)
end
function conversation(p::Prompt; kwargs...)
    return tag(p, "Conversation"; kwargs...)
end
function table(p::Prompt; kwargs...)
    return tag(p, "Table"; kwargs...)
end
function tree(p::Prompt; kwargs...)
    return tag(p, "Tree"; kwargs...)
end
function folder(p::Prompt; kwargs...)
    return tag(p, "Folder"; kwargs...)
end
function captioned_paragraph(p::Prompt; kwargs...)
    return tag(p, "CaptionedParagraph"; kwargs...)
end
function webpage(p::Prompt; kwargs...)
    return tag(p, "Webpage"; kwargs...)
end
# Renamed from text_tag to text
function text(p::Prompt; kwargs...)
    return tag(p, "Text"; kwargs...)
end
function paragraph(p::Prompt; kwargs...)
    return tag(p, "Paragraph"; kwargs...)
end
function inline(p::Prompt; kwargs...)
    return tag(p, "Inline"; kwargs...)
end
function newline(p::Prompt; kwargs...)
    return tag(p, "Newline"; kwargs...)
end
function header(p::Prompt; kwargs...)
    return tag(p, "Header"; kwargs...)
end
function sub_content(p::Prompt; kwargs...)
    return tag(p, "SubContent"; kwargs...)
end
function bold(p::Prompt; kwargs...)
    return tag(p, "Bold"; kwargs...)
end
function italic(p::Prompt; kwargs...)
    return tag(p, "Italic"; kwargs...)
end
function strikethrough(p::Prompt; kwargs...)
    return tag(p, "Strikethrough"; kwargs...)
end
function underline(p::Prompt; kwargs...)
    return tag(p, "Underline"; kwargs...)
end
# Renamed from code_tag to code
function code(p::Prompt; kwargs...)
    return tag(p, "Code"; kwargs...)
end
# Renamed from list_tag to list
function list(p::Prompt; kwargs...)
    return tag(p, "List"; kwargs...)
end
function list_item(p::Prompt; kwargs...)
    return tag(p, "ListItem"; kwargs...)
end
# Renamed from object_tag to object
function object(p::Prompt; kwargs...)
    return tag(p, "Object"; kwargs...)
end
function image(p::Prompt; kwargs...)
    return tag(p, "Image"; kwargs...)
end
function audio(p::Prompt; kwargs...)
    return tag(p, "Audio"; kwargs...)
end
function tool_request(p::Prompt; kwargs...)
    return tag(p, "ToolRequest"; kwargs...)
end
function tool_response(p::Prompt; kwargs...)
    return tag(p, "ToolResponse"; kwargs...)
end

# Added missing tags from _tags.py

function output_schema(p::Prompt; kwargs...)
    return tag(p, "OutputSchema"; kwargs...)
end
function tool_definition(p::Prompt; kwargs...)
    return tag(p, "ToolDefinition"; kwargs...)
end
function runtime(p::Prompt; kwargs...)
    return tag(p, "Runtime"; kwargs...)
end

# Meta components
function meta(p::Prompt; kwargs...)
    return tag(p, "Meta"; kwargs...)
end
function meta_tag(p::Prompt; kwargs...)
    return tag(p, "MetaTag"; kwargs...)
end
function meta_attribute(p::Prompt; kwargs...)
    return tag(p, "MetaAttribute"; kwargs...)
end
function meta_value(p::Prompt; kwargs...)
    return tag(p, "MetaValue"; kwargs...)
end
function meta_annotation(p::Prompt; kwargs...)
    return tag(p, "MetaAnnotation"; kwargs...)
end
function meta_reference(p::Prompt; kwargs...)
    return tag(p, "MetaReference"; kwargs...)
end
function meta_link(p::Prompt; kwargs...)
    return tag(p, "MetaLink"; kwargs...)
end
function meta_group(p::Prompt; kwargs...)
    return tag(p, "MetaGroup"; kwargs...)
end
function meta_id(p::Prompt; kwargs...)
    return tag(p, "MetaId"; kwargs...)
end
function meta_type(p::Prompt; kwargs...)
    return tag(p, "MetaType"; kwargs...)
end
function meta_source(p::Prompt; kwargs...)
    return tag(p, "MetaSource"; kwargs...)
end
function meta_target(p::Prompt; kwargs...)
    return tag(p, "MetaTarget"; kwargs...)
end
function meta_label(p::Prompt; kwargs...)
    return tag(p, "MetaLabel"; kwargs...)
end
function meta_description(p::Prompt; kwargs...)
    return tag(p, "MetaDescription"; kwargs...)
end
function meta_property(p::Prompt; kwargs...)
    return tag(p, "MetaProperty"; kwargs...)
end
function meta_value_type(p::Prompt; kwargs...)
    return tag(p, "MetaValueType"; kwargs...)
end
function meta_unit(p::Prompt; kwargs...)
    return tag(p, "MetaUnit"; kwargs...)
end
function meta_constraint(p::Prompt; kwargs...)
    return tag(p, "MetaConstraint"; kwargs...)
end
function meta_example(p::Prompt; kwargs...)
    return tag(p, "MetaExample"; kwargs...)
end
function meta_note(p::Prompt; kwargs...)
    return tag(p, "MetaNote"; kwargs...)
end



export Prompt, tag, pop_node!, dump_poml, write_poml, add_text,
       document, role, task, output_format, stepwise_instructions, hint, introducer,
       example_set, example, example_input, example_output, question,
       system_message, human_message, ai_message, tool_message, message_content,
       conversation, table, tree, folder, captioned_paragraph, webpage,
       text, paragraph, inline, newline, header, sub_content, bold, italic,
       strikethrough, underline, code, list, list_item, object, image, audio,
       tool_request, tool_response, output_schema, tool_definition, runtime,
       meta, meta_tag, meta_attribute, meta_value, meta_annotation, meta_reference,
       meta_link, meta_group, meta_id, meta_type, meta_source, meta_target,
       meta_label, meta_description, meta_property, meta_value_type, meta_unit,
       meta_constraint, meta_example, meta_note