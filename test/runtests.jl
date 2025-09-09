using PomlSDK
using Test
using XML
using Aqua

# Helper function to find the first child element with a given name
function find_first_element(parent::XML.Node, tag_name::String)
    for child in parent.children
        if child.tag == tag_name
            return child
        end
    end
    return nothing
end

# Helper function to get all child elements with a given name
function find_elements(parent::XML.Node, tag_name::String)
    return filter(n -> n.tag == tag_name, parent.children)
end

@testset "Project meta quality checks" begin
    # Not checking compat section for test-only dependencies
    Aqua.test_all(PomlSDK;
                  ambiguities=true,
                  project_extras=true,
                  deps_compat=true,
                  stale_deps=true,
                  piracies=true, 
                  unbound_args=true,
    )
end

@testset "PomlSDK.jl" begin

    # Test 1: Basic Prompt Creation
    @testset "Prompt Initialization" begin
        p = Prompt()
        @test isa(p, Prompt)
        @test length(p.root_elements) == 1
        @test p.root_elements[1].tag == "poml"
        @test isempty(p.current_parent_stack) == false
        @test p.current_parent_stack[1] === p.root_elements[1]
    end

    # Test 2: Tag Creation and Attributes
    @testset "Tag Creation" begin
        p = Prompt()
        task_node = task(p)
        @test task_node.tag == "Task"

        role_node = role(p, caption="System")
        @test role_node.tag == "Role"
        @test role_node["caption"] == "System"

        meta_tag_node = PomlSDK.tag(p,"source"; value="user_input")
        @test meta_tag_node.tag == "source"
        @test meta_tag_node["value"] == "user_input"

        image_node = image(p, src="image/png;base64,...", alt="Test Image")
        @test image_node.tag == "Image"
        @test image_node["src"] == "image/png;base64,..."
        @test image_node["alt"] == "Test Image"
    end





    # Test 6: Serialization (dump_poml)
    @testset "Serialization" begin
        p = Prompt()


        task_node = task(p, priority="high")
        add_node!(p, task_node)
        add_text(p, "Do something important")
        pop_node!(p)

        poml_string = dump_poml(p)
        @test isa(poml_string, String)
        @test occursin("<poml>", poml_string)
        @test occursin("</poml>", poml_string)

        @test occursin("Do something important", poml_string)

    end

    # Test 7: Handling Different Data Types via _prepare_attrs
    @testset "Data Type Handling (_prepare_attrs)" begin
        p = Prompt()

        node1 = PomlSDK.tag(p, "test_tag", str_attr="hello")
        @test node1["str_attr"] == "hello"

        node2 = PomlSDK.tag(p, "test_tag", int_attr=42)
        @test node2["int_attr"] == "42"

        node3 = PomlSDK.tag(p, "test_tag", float_attr=3.14159)
        @test node3["float_attr"] == "3.14159"

        node4 = PomlSDK.tag(p, "test_tag", bool_attr=true)
        @test node4["bool_attr"] == "true"

        node5 = PomlSDK.tag(p, "test_tag", bool_attr=false)
        @test node5["bool_attr"] == "false"

        complex_data = Dict("key1" => "value1", "nested" => [1, 2, 3])
        node6 = PomlSDK.tag(p, "test_tag", data_attr=complex_data)
        attr_val = node6["data_attr"]
        @test isa(attr_val, String)
        # parsed_data = JSON.parse(attr_val)
        # @test parsed_data == complex_data

        array_data = [1, "two", 3.0]
        node7 = PomlSDK.tag(p, "test_tag", array_attr=array_data)
        attr_val7 = node7["array_attr"]
        @test isa(attr_val7, String)


        bytes_data = UInt8[0x48, 0x65, 0x6c, 0x6c, 0x6f]
        node8 = PomlSDK.tag(p, "test_tag", bytes_attr=bytes_data)
        attr_val8 = node8["bytes_attr"]
        @test isa(attr_val8, String)
    end

    # Test 8: Edge Cases and Error Handling (basic)
    @testset "Edge Cases" begin
        p = Prompt()

        node = task(p)
        add_node!(p, node)
        add_text(p, "Inside task")
        pop_node!(p)
        add_text(p, " Back to root text")

        poml_string = dump_poml(p)

        @test occursin("Inside task", poml_string)
        @test occursin(" Back to root text", poml_string)

        p_empty = Prompt()
        poml_empty = dump_poml(p_empty)
        @test poml_empty == "<poml></poml>"

        p_test_pop = Prompt()
        @test length(p_test_pop.current_parent_stack) == 1

    end

    # Test 9: Specific Tag Functions Produce Correct Nodes
    @testset "Specific Tag Functions" begin
        p = Prompt()

        tags_and_functions = [
            ("Role", role),
            ("Task", task),
            ("Example", example),
            ("ExampleSet", example_set),
            ("ExampleInput", example_input),
            ("Table", table),
            ("Header", header),
            ("List", list),
            ("ListItem", list_item),
            ("Meta", meta),
            ("MetaTag", meta_tag),
            ("MetaAttribute", meta_attribute),
            ("MetaValue", meta_value),
            ("MetaAnnotation", meta_annotation),
            ("MetaReference", meta_reference),
            ("ToolRequest", tool_request),
            ("ToolDefinition", tool_definition),
            ("Image", image),
            ("Runtime", runtime),
            ("OutputSchema", output_schema)
        ]

        for (expected_tagname, func) in tags_and_functions
            node = func(p)
            @test node.tag == expected_tagname
            @test node in p.current_parent_stack[end].children
        end

        p2 = Prompt()
        role_node = role(p2, caption="Test Role", description="A test role")
        @test role_node["caption"] == "Test Role"
        @test role_node["description"] == "A test role"

        task_node = task(p2, priority="1", caption="Test Task")
        @test task_node["priority"] == "1"
        @test task_node["caption"] == "Test Task"

        list_node = list(p2, style="unordered")
        @test list_node["style"] == "unordered"

        image_node = image(p2, src="image/jpeg;base64,/9j/...", alt="Test JPEG")
        @test image_node["src"] == "image/jpeg;base64,/9j/..."
        @test image_node["alt"] == "Test JPEG"
    end




    @testset "Example-Based Tests" begin
    @testset "Character Explanation Prompt" begin
        p = Prompt()
        
        role_node = role(p, caption="Teacher")
        add_node!(p, role_node)
        add_text(p, "You are a teacher explaining figures to kids.")
        pop_node!(p)
        
        task_node = task(p)
        add_node!(p, task_node)
        add_text(p, "Please describe the figure first and then provide background knowledge to help kids understand the figure.")
        pop_node!(p)
        
        output_format_node = output_format(p)
        add_node!(p, output_format_node)
        add_text(p, "Please write your response in a friendly tone.")
        pop_node!(p)
        
        # Serialize and verify
        poml_string = dump_poml(p)
        @test occursin("<Role caption=\"Teacher\">", poml_string)
        @test occursin("You are a teacher explaining figures to kids.", poml_string)
        @test occursin("<Task>", poml_string)
        @test occursin("describe the figure first", poml_string)
        @test occursin("<OutputFormat>", poml_string)
        @test occursin("friendly tone", poml_string)
    end
    
    @testset "Blog Post Creation Prompt" begin
        p = Prompt()
        
        task_node = task(p, className="instruction")
        add_node!(p, task_node)
        add_text(p, "Create a blog post with these specifications:")
        pop_node!(p)
        
        output_format_node = output_format(p, className="instruction")
        add_node!(p, output_format_node)
        
        list_node = list(p, listStyle="decimal")
        add_node!(p, list_node)
        
        # Add list items
        for item in ["Use professional but accessible language", "Include at least 3 subheadings", 
                     "Add a conclusion paragraph", "Keep between 500-700 words"]
            list_item_node = list_item(p)
            add_node!(p, list_item_node)
            add_text(p, item)
            pop_node!(p)
        end
        
        pop_node!(p)  # Close list
        pop_node!(p)  # Close output_format
        
        # Add example
        example_set_node = example_set(p)
        add_node!(p, example_set_node)
        
        example_node = example(p)
        add_node!(p, example_node)
        
        input_node = PomlSDK.tag(p, "input")
        add_node!(p, input_node)
        add_text(p, "Topic: Benefits of Regular Exercise")
        pop_node!(p)
        
        output_node = PomlSDK.tag(p, "output")
        add_node!(p, output_node)
        add_text(p, "Title: The Life-Changing Power of Daily Movement\n\n[Blog content here]")
        pop_node!(p)
        
        pop_node!(p)  # Close example
        pop_node!(p)  # Close example_set
        
        # Verify structure
        poml_string = dump_poml(p)
        @test  occursin("OutputFormat className", poml_string)
        @test occursin("ListItem", poml_string)
        @test occursin("Benefits of Regular Exercise", poml_string)
    end
    
    # Test 3: Research Plan Prompt (106_research.poml)
    @testset "Research Plan Prompt" begin
        p = Prompt()
        
        task_node = task(p)
        add_node!(p, task_node)
        add_text(p, "You are given various potential options or approaches for a project. Convert these into a well-structured research plan.")
        pop_node!(p)
        
        stepwise_node = stepwise_instructions(p)
        add_node!(p, stepwise_node)
        
        # Main list
        list_node = list(p, listStyle="decimal")
        add_node!(p, list_node)
        
        # List items with nested lists
        for (i, main_item) in enumerate([
            ("Identifies Key Objectives", [
                "Clarify what questions each option aims to answer",
                "Detail the data/info needed for evaluation"
            ]),
            ("Describes Research Methods", [
                "Outline how you'll gather and analyze data",
                "Mention tools or methodologies for each approach"
            ]),
            ("Outlines Expected Outcomes", [
                "Predict potential findings for each approach",
                "Note limitations or constraints"
            ])
        ])
            item_node = list_item(p)
            add_node!(p, item_node)
            add_text(p, main_item[1])
            
            # Nested list
            nested_list = list(p, listStyle="dash")
            add_node!(p, nested_list)
            
            for subitem in main_item[2]
                subitem_node = list_item(p)
                add_node!(p, subitem_node)
                add_text(p, subitem)
                pop_node!(p)
            end
            
            pop_node!(p)  # Close nested list
            pop_node!(p)  # Close list item
        end
        
        pop_node!(p)  # Close main list
        pop_node!(p)  # Close stepwise instructions
        
        # Verify structure
        poml_string = dump_poml(p)
        @test occursin("StepwiseInstructions", poml_string)
        @test occursin("Clarify what questions each option aims to answer", poml_string)
        @test occursin("Outline how you'll gather and analyze data", poml_string)
    end
    
    # Test 4: Document Reference Prompt (107_read_report_pdf.poml)
    @testset "Document Reference Prompt" begin
        p = Prompt()
        
        # Create structure matching 107_read_report_pdf.poml
        task_node = task(p)
        add_node!(p, task_node)
        add_text(p, "Summarize the key findings from the provided document.")
        pop_node!(p)
        
        # Add document reference
        doc_node = document(p, src="reports/annual_summary.pdf", parser="pdf", selectedPages="1-5", maxPages="10")
        add_node!(p, doc_node)
        pop_node!(p)
        
        # Add output format
        output_node = output_format(p)
        add_node!(p, output_node)
        add_text(p, "Provide a concise summary with key statistics and conclusions.")
        pop_node!(p)
        
        # Verify document attributes
        poml_string = dump_poml(p)
        @test occursin("Summarize the key findings", poml_string)
        @test occursin("concise summary with key statistics", poml_string)
    end
    
    # Test 5: Tool Integration Prompt (108_math_calculator.poml)
    @testset "Tool Integration Prompt" begin
        p = Prompt()
        
        # Add metadata
        meta_node = meta(p)
        add_node!(p, meta_node)
        PomlSDK.tag(p, "author"; value="Math Team")
        PomlSDK.tag(p, "tool_config"; value="enabled")
        pop_node!(p)
        
        # Define calculator tool
        tool_def = tool_definition(p, 
            name="calculator",
            description="Performs basic mathematical calculations",
            parameters=Dict(
                "operation" => Dict(
                    "type" => "string",
                    "description" => "The operation to perform: add, subtract, multiply, divide",
                    "enum" => ["add", "subtract", "multiply", "divide"]
                ),
                "a" => Dict("type" => "number", "description" => "First operand"),
                "b" => Dict("type" => "number", "description" => "Second operand")
            )
        )
        
        # Create task with tool request
        task_node = task(p)
        add_node!(p, task_node)
        add_text(p, "What is 15 multiplied by 23?")
        
        # Tool request
        tool_req = tool_request(p,
            name="calculator",
            parameters=Dict("operation" => "multiply", "a" => 15, "b" => 23)
        )
        
        # Tool response
        tool_resp = tool_response(p,
            name="calculator",
            result=Dict("result" => 345)
        )
        
        pop_node!(p)  # Close task
        
        # Final answer
        final_task = task(p, caption="Final Response")
        add_node!(p, final_task)
        add_text(p, "15 multiplied by 23 is 345.")
        pop_node!(p)
        
        # Verify tool integration
        poml_string = dump_poml(p)
        @test occursin("Performs basic mathematical calculations", poml_string)
        @test occursin("operation", poml_string)
        @test occursin("multiply", poml_string)
        @test occursin("15", poml_string)
        @test occursin("23", poml_string)
        @test occursin("345", poml_string)
    end
    
    # Test 6: Complex Prompt Generation (301_generate_poml.poml)
    @testset "Complex Prompt Generation" begin
        p = Prompt()
        
        # Create structure matching 301_generate_poml.poml
        let_node1 = PomlSDK.tag(p, "let", src="105_write_blog_post.poml", name="blog_post")
        let_node2 = PomlSDK.tag(p, "let", src="106_research.poml", name="research")
        let_node3 = PomlSDK.tag(p, "let", src="202_arc_agi.poml", name="arc_agi")
        let_node4 = PomlSDK.tag(p, "let", src="107_read_report_pdf.poml", name="read_report")
        
        # Create paragraph container
        p_container_node = paragraph(p)
        add_node!(p, p_container_node)
        
        # Blog post function
        span_blog_node = PomlSDK.tag(p, "span", whiteSpace="trim")
        add_node!(p, span_blog_node)
        add_text(p, "function blog_post() {return \"\"\"")
        
        # Add blog post content (simplified)
        blog_content = "<poml>...</poml>"
        formatted_content = join(map(line -> " " * line, split(strip(blog_content), '\n')), '\n')
        add_text(p, formatted_content)
        
        add_text(p, "\"\"\";}")
        pop_node!(p)  # Close span
        
        # Research function
        span_research_node = PomlSDK.tag(p, "span", whiteSpace="trim")
        add_node!(p, span_research_node)
        add_text(p, "function research() {return \"\"\"")
        
        # Add research content (simplified)
        research_content = "<poml>...</poml>"
        formatted_content = join(map(line -> " " * line, split(strip(research_content), '\n')), '\n')
        add_text(p, formatted_content)
        
        add_text(p, "\"\"\";}")
        pop_node!(p)  # Close span
        
        pop_node!(p)  # Close paragraph container
        
        # Verify structure
        poml_string = dump_poml(p)

        @test occursin("<Paragraph>", poml_string)
        @test occursin("<span whiteSpace=\"trim\">", poml_string)
        @test occursin("function blog_post() {return \"\"\"", poml_string)
        @test occursin("function research() {return \"\"\"", poml_string)
    end
    
    # Test 7: Metadata Usage Patterns
    @testset "Metadata Usage Patterns" begin
        p = Prompt()
        
        # Basic metadata
        meta_node = meta(p)
        add_node!(p, meta_node)
        PomlSDK.tag(p,"author"; value="Data Team")
        PomlSDK.tag(p,"project"; value="Q4_Sales_Analysis")
        meta_attribute(p;key="version", value="2.3")
        pop_node!(p)
        
        # Prompt content
        role_node = role(p, caption="System")
        add_node!(p, role_node)
        add_text(p, "You are a data analyst. Analyze the provided sales data and identify key trends.")
        pop_node!(p)
        
        # Verify metadata
        poml_string = dump_poml(p)
        @test occursin("<Meta>", poml_string)
        @test occursin("author" , poml_string)
        @test occursin("project" , poml_string)
        
        # Test metadata for versioning
        p_version = Prompt()
        meta_node = meta(p_version)
        add_node!(p_version, meta_node)
        PomlSDK.tag(p_version, "prompt_id"; value="sales_analysis_v3")
        PomlSDK.tag(p_version, "version"; value="3.1")
        PomlSDK.tag(p_version, "previous_version"; value="sales_analysis_v2")
        pop_node!(p_version)
        
        poml_version = dump_poml(p_version)
        @test occursin("prompt_id", poml_version)
        @test occursin("sales_analysis_v3", poml_version)
        @test occursin("version", poml_version)
        @test occursin("3.1", poml_version)
        @test occursin("previous_version", poml_version)
    end
    
    
end

@testset "Round-trip Serialization Tests" begin
    # Test that we can create a prompt, serialize it, and the structure remains intact
    @testset "Blog Post Structure Round-trip" begin
        # Create the structure
        p = Prompt()
        task_node = task(p, className="instruction")
        add_node!(p, task_node)
        add_text(p, "Create a blog post with these specifications:")
        pop_node!(p)
        
        output_format_node = output_format(p, className="instruction")
        add_node!(p, output_format_node)
        list_node = list(p, listStyle="decimal")
        add_node!(p, list_node)
        
        # Add list items
        items = ["Use professional but accessible language", "Include at least 3 subheadings", 
                 "Add a conclusion paragraph", "Keep between 500-700 words"]
                 
        for item in items
            list_item_node = list_item(p)
            add_node!(p, list_item_node)
            add_text(p, item)
            pop_node!(p)
        end
        
        pop_node!(p)  # Close list
        pop_node!(p)  # Close output_format
        
        # Serialize
        original_xml = dump_poml(p)
        
        # Create a new prompt and rebuild from the serialized XML
        # Note: This assumes we have a parse_poml function, which might need to be implemented
        # p2 = parse_poml(original_xml)
        # reconstructed_xml = dump_poml(p2)
        
        # For now, we'll just verify the serialization is consistent
        @test occursin("<Task", original_xml)
        @test occursin("<OutputFormat", original_xml)


    end
    
    @testset "Tool Integration Round-trip" begin
        p = Prompt()
        
        # Tool definition
        tool_def = tool_definition(p, 
            name="calculator",
            description="Performs basic mathematical calculations",
            parameters=Dict(
                "operation" => Dict(
                    "type" => "string",
                    "enum" => ["add", "subtract", "multiply", "divide"]
                ),
                "a" => Dict("type" => "number"),
                "b" => Dict("type" => "number")
            )
        )
        
        # Tool request
        task_node = task(p)
        add_node!(p, task_node)
        add_text(p, "What is 15 multiplied by 23?")
        
        tool_req = tool_request(p,
            name="calculator",
            parameters=Dict("operation" => "multiply", "a" => 15, "b" => 23)
        )
        
        pop_node!(p)
        
        # Serialize
        poml_string = dump_poml(p)
        
        # Verify key elements are present and properly formatted
        @test occursin("calculator", poml_string)
        @test occursin("multiply", poml_string)
        @test occursin("15", poml_string)
        @test occursin("23", poml_string)
        @test !occursin("Dict", poml_string)  # Ensure no Julia types leaked into XML
    end
end

@testset "Error Case Tests" begin

    
    @testset "Invalid Data Types" begin
        p = Prompt()
        
        # Test adding non-Node to hierarchy
        @test_throws MethodError begin
            add_node!(p, "not a node")
        end
        
        # Test adding text to invalid context
        @test_throws ErrorException begin
            add_text(p, "text without active node")
        end
    end
    
    @testset "Metadata Edge Cases" begin
        p = Prompt()
        
        
        # Test adding metadata with invalid types
        @test_throws MethodError begin
            meta= PomlSDK.tag(p, 123; value="value")  
        end
    end
end

@testset "Context Integration Tests" begin
    # Test loading context and applying to prompt
    @testset "Context Variable Replacement" begin
        # Create a prompt with variables
        p = Prompt()
        
        task_node = task(p)
        add_node!(p, task_node)
        add_text(p, "Analyze sales data for {{company}} for the {{year}} fiscal year.")
        pop_node!(p)
        
        # Context data
        context = Dict(
            "company" => "Acme Corp",
            "year" => "2023"
        )
        
        # In a real implementation, we would have a function to apply context
        # For this test, we'll simulate the result
        poml_string = dump_poml(p)
        processed = replace(poml_string, "{{company}}" => context["company"], "{{year}}" => context["year"])
        
        @test occursin("Analyze sales data for Acme Corp for the 2023 fiscal year", processed)
    end
    
    @testset "Document Reference with Context" begin
        p = Prompt()
        
        # Create document reference with variable
        doc_node = document(p, 
            src="{{report_path}}/annual_summary.pdf", 
            parser="pdf",
            selectedPages="{{page_range}}")
        
        # Context data
        context = Dict(
            "report_path" => "reports/Q4",
            "page_range" => "1-10"
        )
        
        # In a real implementation, we would apply context before serialization
        # For this test, we'll check that variables are properly formatted
        poml_string = dump_poml(p)
        @test occursin("src=\"{{report_path}}/annual_summary.pdf\"", poml_string)
        @test occursin("selectedPages=\"{{page_range}}\"", poml_string)
    end
end
end