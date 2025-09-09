```@meta
CurrentModule = POMLSDK
```
# Tool Usage Example

This example demonstrates how to integrate tools with POMLSDK.jl, following the POML standard for tool-enabled prompting.

## Basic Tool Definition and Request

```julia
using POMLSDK
using JSON

p = Prompt()

# Define a calculator tool
calc_tool = tool_definition(
    p,
    name="calculator",
    description="Performs basic mathematical calculations",
    parameters=Dict(
        "operation" => Dict(
            "type" => "string",
            "description" => "The operation to perform: add, subtract, multiply, divide",
            "enum" => ["add", "subtract", "multiply", "divide"]
        ),
        "a" => Dict(
            "type" => "number",
            "description" => "First operand"
        ),
        "b" => Dict(
            "type" => "number",
            "description" => "Second operand"
        )
    )
)

# Request the calculator tool
calc_request = tool_request(
    p,
    name="calculator",
    parameters=Dict(
        "operation" => "multiply",
        "a" => 5,
        "b" => 7
    )
)

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```

This will generate POML XML that defines the tool and requests its use.

## Complete Tool Workflow

Here's a more comprehensive example showing the full tool integration workflow:

```julia
using POMLSDK
using JSON

p = Prompt()

# 1. System instructions
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a helpful assistant with access to tools. When appropriate, use tools to get accurate information.")
pop_node!(p)

# 2. Define available tools
tool_defs = tool_definition(p)
add_node!(p, tool_defs)

# Calculator tool
calc_tool = tool_definition(
    p,
    name="calculator",
    description="Performs basic math operations",
    parameters=Dict(
        "operation" => Dict(
            "type" => "string",
            "description" => "Operation to perform",
            "enum" => ["add", "subtract", "multiply", "divide"]
        ),
        "a" => Dict("type" => "number"),
        "b" => Dict("type" => "number")
    )
)

# Weather tool
weather_tool = tool_definition(
    p,
    name="get_weather",
    description="Gets current weather for a location",
    parameters=Dict(
        "location" => Dict("type" => "string", "description" => "City and country")
    )
)

pop_node!(p)  # Pop tool_definitions

# 3. User task
task_node = task(p, caption="User Request")
add_node!(p, task_node)
add_text(p, "What is 15 multiplied by 23? Also, what's the weather in London?")
pop_node!(p)

# 4. Tool requests (simulating what the LLM might generate)
tool_reqs = tag(p, "tool_requests")
add_node!(p, tool_reqs)

# Calculator request
calc_req = tool_request(
    p,
    name="calculator",
    parameters=Dict(
        "operation" => "multiply",
        "a" => 15,
        "b" => 23
    )
)

# Weather request
weather_req = tool_request(
    p,
    name="get_weather",
    parameters=Dict(
        "location" => "London, UK"
    )
)

pop_node!(p)  # Pop tool_requests

# 5. Tool responses (simulating actual tool outputs)
tool_responses = tag(p, "tool_responses")
add_node!(p, tool_responses)

# Calculator response
calc_response = tag(p, "tool_response", name="calculator", id=calc_req.id)
add_node!(p, calc_response)
add_text(p, "345")
pop_node!(p)

# Weather response
weather_response = tag(p, "tool_response", name="get_weather", id=weather_req.id)
add_node!(p, weather_response)
add_text(p, JSON.json(Dict(
    "location" => "London, UK",
    "temperature" => 15,
    "conditions" => "Partly cloudy"
)))
pop_node!(p)

pop_node!(p)  # Pop tool_responses

# 6. Final answer generation
final_task = task(p, caption="Final Response")
add_node!(p, final_task)
add_text(p, "15 multiplied by 23 is 345. The current weather in London is 15°C with partly cloudy conditions.")
pop_node!(p)

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```

## Tool Chaining Example

This example demonstrates how to structure prompts for tool chaining:

```julia
using POMLSDK
using JSON

p = Prompt()

# Define tools
tool_defs = tool_definition(p)
add_node!(p, tool_defs)

search_tool = tool_definition(
    p,
    name="search_web",
    description="Searches the web for information",
    parameters=Dict(
        "query" => Dict("type" => "string", "description" => "Search query")
    )
)

calc_tool = tool_definition(
    p,
    name="calculate_percentage",
    description="Calculates percentages",
    parameters=Dict(
        "value" => Dict("type" => "number"),
        "total" => Dict("type" => "number"),
        "description" => Dict("type" => "string")
    )
)

pop_node!(p)  # Pop tool_definitions

# Initial task
task_node = task(p, caption="Research Request")
add_node!(p, task_node)
add_text(p, "What percentage of the world population lives in Japan?")
pop_node!(p)

# First tool request
tool_reqs = tag(p, "tool_requests")
add_node!(p, tool_reqs)

search_req = tool_request(
    p,
    name="search_web",
    parameters=Dict(
        "query" => "current population of Japan, current world population"
    )
)

pop_node!(p)  # Pop tool_requests

# First tool response
tool_responses = tag(p, "tool_responses")
add_node!(p, tool_responses)

search_resp = tag(p, "tool_response", name="search_web", id=search_req.id)
add_node!(p, search_resp)
add_text(p, JSON.json(Dict(
    "japan_population" => 125800000,
    "world_population" => 8000000000
)))
pop_node!(p)

pop_node!(p)  # Pop tool_responses

# Second tool request using first response
tool_reqs2 = tag(p, "tool_requests")
add_node!(p, tool_reqs2)

# Extract data from first response
response_text = XML.text(search_resp)
response_data = JSON.parse(response_text)
japan_pop = response_data["japan_population"]
world_pop = response_data["world_population"]

calc_req = tool_request(
    p,
    name="calculate_percentage",
    parameters=Dict(
        "value" => japan_pop,
        "total" => world_pop,
        "description" => "Japan's population as percentage of world population"
    )
)

pop_node!(p)  # Pop tool_requests

# Second tool response
tool_responses2 = tag(p, "tool_responses")
add_node!(p, tool_responses2)

calc_resp = tag(p, "tool_response", name="calculate_percentage", id=calc_req.id)
add_node!(p, calc_resp)
add_text(p, "1.5725")
pop_node!(p)

pop_node!(p)  # Pop tool_responses

# Final answer
final_task = task(p, caption="Final Response")
add_node!(p, final_task)
add_text(p, "Approximately 1.57% of the world population lives in Japan.")
pop_node!(p)

# Serialize
poml_string = dump_poml(p)
println(poml_string)
```

## Best Practices for Tool Integration

- **Clear parameter definitions**: Ensure all tool parameters are well-defined with types and descriptions
- **Include examples**: Add example tool requests and responses in your prompts
- **Handle errors**: Include examples of tool errors and how to respond
- **Manage state**: When chaining tools, ensure responses are properly linked to requests
- **Limit tool count**: Too many tools can confuse the LLM; focus on the most relevant ones
- **Provide context**: Explain why a tool is being used and what its output means
- **Validate parameters**: Ensure tool parameters match the expected format
- **Consider token limits**: Tool definitions can be lengthy; balance with other content

By effectively integrating tools into your prompts, you can create more powerful, accurate, and capable LLM applications that extend beyond the model's built-in knowledge.