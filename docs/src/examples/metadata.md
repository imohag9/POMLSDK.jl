```@meta
CurrentModule = PomlSDK
```
# Metadata Example

This example demonstrates how to add and use metadata in PomlSDK.jl prompts.

## Basic Metadata Structure

Metadata provides contextual information about your prompt, such as source, version, and author:

```julia
using PomlSDK

p = Prompt()

# Create metadata section
meta_node = meta(p)
add_node!(p, meta_node)

# Add metadata tags
meta_tag(p, key="author", value="Your Name")
meta_tag(p, key="source", value="user_input")
meta_tag(p, key="project", value="sales_analysis")

# Add metadata attributes
meta_attribute(p, name="version", value="1.0")
meta_attribute(p, name="created", value="2023-10-15")
meta_attribute(p, name="last_modified", value="2023-10-20")

pop_node!(p)  # Pop metadata section

# Add actual prompt content
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a helpful AI assistant.")
pop_node!(p)

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```

This will generate POML XML with a metadata section containing the specified information.

## Metadata for Data Provenance

Track the source and processing of data in your prompts:

```julia
using PomlSDK

p = Prompt()

# Create metadata section
meta_node = meta(p)
add_node!(p, meta_node)

# Data source information
meta_tag(p, key="data_source", value="sales_database")
meta_tag(p, key="data_query", value="SELECT * FROM quarterly_sales WHERE year=2023")
meta_tag(p, key="data_extraction_date", value="2023-10-15")

# Data processing information
meta_tag(p, key="data_processing", value="aggregated_by_product")
meta_tag(p, key="data_filters", value="region=NorthAmerica")

# Prompt context
meta_tag(p, key="analysis_purpose", value="identify_sales_trends")
meta_tag(p, key="target_audience", value="executive_team")

pop_node!(p)  # Pop metadata

# Add prompt content
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a data analyst. Analyze the provided sales data and identify key trends.")
pop_node!(p)

# Serialize
poml_string = dump_poml(p)
println(poml_string)
```

## Metadata for Prompt Versioning

Track different versions of your prompts:

```julia
using PomlSDK

p = Prompt()

# Metadata for versioning
meta_node = meta(p)
add_node!(p, meta_node)

meta_tag(p, key="prompt_id", value="sales_analysis_v3")
meta_tag(p, key="version", value="3.1")
meta_tag(p, key="previous_version", value="sales_analysis_v2")

# Version history
version_history = [
    ["2023-10-01", "1.0", "Initial version"],
    ["2023-10-05", "2.0", "Added Q3 data"],
    ["2023-10-15", "3.0", "Improved examples"],
    ["2023-10-20", "3.1", "Fixed data formatting"]
]

# Add version history as a table
cp = captioned_paragraph(p, caption="Version History")
add_node!(p, cp)
version_table = table(p, data=version_history)
pop_node!(p)

pop_node!(p)  # Pop metadata

# Add prompt content
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a data analyst. Analyze the provided sales data and identify key trends.")
pop_node!(p)

# Serialize
poml_string = dump_poml(p)
println(poml_string)
```

## Metadata for Tool Integration

When using tools, metadata can provide important context:

```julia
using PomlSDK
using JSON

p = Prompt()

# Metadata for tool integration
meta_node = meta(p)
add_node!(p, meta_node)

# Tool configuration
meta_tag(p, key="tool_config", value="enabled")
meta_tag(p, key="available_tools", value="calculator,weather_api")
meta_tag(p, key="tool_timeout", value="5000ms")

# Tool usage context
meta_tag(p, key="tool_purpose", value="enhance_accuracy_of_responses")
meta_tag(p, key="tool_safety_checks", value="enabled")

pop_node!(p)  # Pop metadata

# Define tools
tool_defs = tool_definition(p)
add_node!(p, tool_defs)

calc_tool = tool_definition(
    p,
    name="calculator",
    description="Performs basic math operations",
    parameters=Dict(
        "operation" => Dict(
            "type" => "string",
            "enum" => ["add", "subtract", "multiply", "divide"]
        ),
        "a" => Dict("type" => "number"),
        "b" => Dict("type" => "number")
    )
)

pop_node!(p)  # Pop tool_definitions

# Task with tool request
task_node = task(p, caption="Math Problem")
add_node!(p, task_node)
add_text(p, "What is 15 multiplied by 23?")

# Tool request
tool_req = tool_request(
    p,
    name="calculator",
    parameters=Dict(
        "operation" => "multiply",
        "a" => 15,
        "b" => 23
    )
)

pop_node!(p)  # Pop task

# Serialize
poml_string = dump_poml(p)
println(poml_string)
```

## Complete Metadata Example

Here's a comprehensive example showing multiple metadata use cases:

```julia
using PomlSDK
using JSON

p = Prompt()

# Metadata section
meta_node = meta(p)
add_node!(p, meta_node)

# Basic metadata
meta_tag(p, key="author", value="Data Team")
meta_tag(p, key="project", value="Q4_Sales_Analysis")
meta_attribute(p, name="version", value="2.3")
meta_attribute(p, name="created", value="2023-10-01")
meta_attribute(p, name="last_modified", value="2023-10-20")

# Data source metadata
data_source_cp = captioned_paragraph(p, caption="Data Source Information")
add_node!(p, data_source_cp)

data_source_tags = [
    ["Database", "sales_db_prod"],
    ["Table", "quarterly_sales"],
    ["Query", "SELECT * FROM quarterly_sales WHERE year=2023"],
    ["Extraction Date", "2023-10-15"],
    ["Processing Steps", "aggregated_by_product, filtered_region"]
]

data_source_table = table(p, data=data_source_tags)
pop_node!(p)  # Pop data_source_cp

# Analysis context metadata
analysis_cp = captioned_paragraph(p, caption="Analysis Context")
add_node!(p, analysis_cp)

analysis_tags = [
    ["Purpose", "Identify Q4 sales trends"],
    ["Target Audience", "Executive team"],
    ["Timeframe", "2023-10-01 to 2023-12-31"],
    ["Key Metrics", "Revenue, Growth Rate, Market Share"]
]

analysis_table = table(p, data=analysis_tags)
pop_node!(p)  # Pop analysis_cp

# Tool configuration metadata
tools_cp = captioned_paragraph(p, caption="Tool Configuration")
add_node!(p, tools_cp)

tools_tags = [
    ["Available Tools", "calculator, data_analyzer"],
    ["Tool Timeout", "5000ms"],
    ["Safety Checks", "enabled"]
]

tools_table = table(p, data=tools_tags)
pop_node!(p)  # Pop tools_cp

pop_node!(p)  # Pop metadata

# System role
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a senior data analyst. Analyze the provided sales data and provide actionable insights for the executive team.")
pop_node!(p)

# Task with examples
task_node = task(p, caption="Sales Analysis")
add_node!(p, task_node)
add_text(p, "Analyze the quarterly sales data and identify trends, opportunities, and risks.")

# Example set
example_set_node = example_set(p)
add_node!(p, example_set_node)

# Example 1
example_node = example(p)
add_node!(p, example_node)
input_node = tag(p, "input")
add_node!(p, input_node)
add_text(p, "Q1 Sales: $1.2M, Q2 Sales: $1.5M, Q3 Sales: $1.1M, Q4 Sales: $1.8M")
pop_node!(p)
output_node = tag(p, "output")
add_node!(p, output_node)
add_text(p, "Sales increased by 25% from Q1 to Q2, dipped in Q3, and had a strong finish in Q4.")
pop_node!(p)
pop_node!(p)  # Pop example

pop_node!(p)  # Pop example_set
pop_node!(p)  # Pop task

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```


## Best Practices for Metadata Usage

- **Be consistent**: Use consistent keys and value formats across prompts
- **Keep it relevant**: Only include metadata that provides useful context
- **Balance detail**: Provide enough detail without overwhelming the prompt
- **Use structured data**: For complex metadata, consider using tables
- **Version your prompts**: Track changes to improve reproducibility
- **Document your schema**: Maintain a reference for your metadata structure
- **Consider automation**: Generate metadata programmatically where possible
- **Validate metadata**: Ensure metadata follows expected formats

By effectively using metadata in your prompts, you can provide valuable context that helps with prompt management, debugging, and understanding the provenance of your prompt structures.