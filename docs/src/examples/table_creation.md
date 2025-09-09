```@meta
CurrentModule = POMLSDK
```
# Table Creation Example

This example demonstrates how to create and work with tables in POMLSDK.jl.

## Basic Table Creation

Tables can be created from 2D data arrays:

```julia
using POMLSDK

p = Prompt()

# Create table data (rows x columns)
sales_data = [
    ["Product", "Q1 Sales", "Q2 Sales", "Q3 Sales", "Q4 Sales"],
    ["Widget A", "120,000", "150,000", "110,000", "180,000"],
    ["Widget B", "85,000", "95,000", "105,000", "140,000"],
    ["Widget C", "60,000", "75,000", "90,000", "120,000"]
]

# Create the table
table_node = table(p, data=sales_data)

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```

This will create a markdown-formatted table embedded in the POML structure.

## Table with Caption

Add context to your tables with captions:

```julia
using POMLSDK

p = Prompt()

# Create captioned paragraph for the table
cp_node = captioned_paragraph(p, caption="2023 Sales Data by Product")
add_node!(p, cp_node)

# Table data
sales_data = [
    ["Product", "Q1", "Q2", "Q3", "Q4"],
    ["Widget A", "120", "150", "110", "180"],
    ["Widget B", "85", "95", "105", "140"],
    ["Widget C", "60", "75", "90", "120"]
]

# Create table
table_node = table(p, data=sales_data)

pop_node!(p)  # Pop captioned paragraph

# Serialize
poml_string = dump_poml(p)
println(poml_string)
```



## Complete Table Example

Here's a comprehensive example showing multiple table techniques:

```julia
using POMLSDK

p = Prompt()

# System role
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a data analyst. Use the provided tables to answer questions.")
pop_node!(p)

# Main task
task_node = task(p, caption="Sales Analysis")
add_node!(p, task_node)
add_text(p, "Analyze the quarterly sales data and identify trends.")

# Sales data table
sales_data = [
    ["Product", "Q1", "Q2", "Q3", "Q4", "Total"],
    ["Widget A", "120", "150", "110", "180", "560"],
    ["Widget B", "85", "95", "105", "140", "425"],
    ["Widget C", "60", "75", "90", "120", "345"],
    ["Widget D", "45", "60", "75", "100", "280"]
]

cp_sales = captioned_paragraph(p, caption="Quarterly Sales (in thousands)")
add_node!(p, cp_sales)
sales_table = table(p, data=sales_data)
pop_node!(p)

# Top products table (derived from sales data)
top_products = [
    ["Product", "Total Sales"],
    ["Widget A", "560"],
    ["Widget B", "425"],
    ["Widget C", "345"]
]

cp_top = captioned_paragraph(p, caption="Top Products by Annual Sales")
add_node!(p, cp_top)
top_table = table(p, data=top_products)
pop_node!(p)

pop_node!(p)  # Pop task

# Add metadata
meta_node = meta(p)
add_node!(p, meta_node)
meta_tag(p, key="dataset", value="2023_sales")
meta_attribute(p, name="analysis_date", value="2023-12-15")
pop_node!(p)

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```

## Tips for Effective Table Usage

- **Keep tables concise**: Large tables can overwhelm the LLM
- **Use captions**: Always provide context for what the table represents
- **Select relevant data**: Use `selectedColumns` and `selectedRecords` to focus on key information
- **Consider formatting**: Proper alignment and styling improve readability
- **Balance with text**: Combine tables with explanatory text for best results
- **Validate data**: Ensure numeric values are properly formatted
- **Watch token count**: Complex tables can significantly increase prompt size

By effectively using tables in your prompts, you can provide structured data to LLMs in a format they can easily process and analyze.