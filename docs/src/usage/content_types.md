```@meta
CurrentModule = PomlSDK
```
# Content Types

This guide explains how to add different types of content to your prompts using PomlSDK.jl.

## Text Content

The most basic content type is plain text, added using `add_text()` which can only be done inside a tag:

```julia
p = Prompt()


# Add text within a role
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "Follow these guidelines:")
add_text(p, "- Be concise")
add_text(p, "- Provide accurate information")
pop_node!(p)
```

### Text Best Practices

- **Add spaces manually**: `add_text(p, "Hello, "); add_text(p, "world!")` produces "Hello, world!"
- **Use line breaks**: `add_text(p, "Line 1\nLine 2")` for multi-line content
- **Consider text length**: Very long text segments may affect LLM performance

## Tables

PomlSDK supports creating tables with the `table()` function:

```julia
p = Prompt()

# Create a table from 2D array data
sales_data = [
    ["Quarter", "Sales (USD)"],
    ["Q1", "1,200,000"],
    ["Q2", "1,500,000"],
    ["Q3", "1,100,000"],
    ["Q4", "1,800,000"]
]

table_node = table(p, data=sales_data)
```


## Lists

Create ordered and unordered lists with `list()` and `list_item()`:

```julia
p = Prompt()

# Unordered list (default)
list_node = list(p)
add_node!(p, list_node)

item1 = list_item(p)
add_node!(p, item1)
add_text(p, "First item")
pop_node!(p)

item2 = list_item(p)
add_node!(p, item2)
add_text(p, "Second item")
pop_node!(p)

pop_node!(p)

# Ordered list
ordered_list = list(p, style="ordered")
add_node!(p, ordered_list)
# Add items...
pop_node!(p)
```



## Images

Embed images using base64 encoding with the `image()` function:

```julia
p = Prompt()

# Add an image from file
img_data = read("assets/chart.png", Vector{UInt8})
img_node = image(p, src=img_data, alt="Sales Chart", format="png")

# Or directly with base64 string 
img_node = image(p, src="image/png;base64,iVBORw0KG...", alt="Sales Chart")
```

### Image Best Practices

- **Always provide alt text** for accessibility
- **Compress images** before embedding to reduce prompt size
- **Consider file format** - PNG for charts, JPEG for photos
- **Use appropriate size** - large images increase token count

## Metadata

Add metadata to your prompts using the `meta` functions:

```julia
p = Prompt()

meta_node = meta(p)
add_node!(p, meta_node)

# Add metadata tags
meta_tag(p, key="author", value="Your Name")
meta_tag(p, key="source", value="user_input")

# Add metadata attributes
meta_attribute(p, name="version", value="1.0")
meta_attribute(p, name="created", value="2023-10-15")

pop_node!(p)
```

### Metadata Use Cases

- **Source tracking**: Where the prompt content originated
- **Versioning**: Track prompt iterations
- **Context information**: Additional information about the prompt's purpose
- **Provenance**: Record who created or modified the prompt

## Documents

Reference external documents with the `document()` function:

```julia
p = Prompt()

# Reference a PDF document
doc_node = document(p, src="reports/annual_summary.pdf", parser="pdf")

# Reference a text file
txt_node = document(p, src="data/notes.txt", parser="text")
```

### Document Parameters

- **src**: Path to the document
- **parser**: Specifies how to process the document (pdf, text, etc.)
- **selectedPages**: For PDFs, which pages to include
- **maxPages**: Maximum number of pages to process

## Combining Content Types

Complex prompts often combine multiple content types:

```julia
p = Prompt()

role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a data analyst. Use the provided information to answer questions.")
pop_node!(p)

task_node = task(p, caption="Sales Analysis")
add_node!(p, task_node)
add_text(p, "Analyze the quarterly sales data below and identify trends.")

# Add sales table
sales_data = [
    ["Quarter", "Revenue", "Growth"],
    ["Q1", "$1.2M", "+5%"],
    ["Q2", "$1.5M", "+25%"],
    ["Q3", "$1.1M", "-27%"],
    ["Q4", "$1.8M", "+64%"]
]
table_node = table(p, data=sales_data)

# Add chart image
img_node = image(p, src="charts/sales_trend.png", alt="Quarterly sales trend")

# Add key points as a list
list_node = list(p, style="unordered")
add_node!(p, list_node)

item1 = list_item(p)
add_node!(p, item1)
add_text(p, "Q2 showed strongest growth at 25%")
pop_node!(p)

item2 = list_item(p)
add_node!(p, item2)
add_text(p, "Q3 experienced a significant dip")
pop_node!(p)

pop_node!(p)  # Pop list

pop_node!(p)  # Pop task

# Add metadata
meta_node = meta(p)
add_node!(p, meta_node)
meta_tag(p, key="dataset", value="2023_sales")
meta_attribute(p, name="analysis_date", value="2023-12-15")
pop_node!(p)

poml_string = dump_poml(p)
```

## Advanced Content Handling

### Handling Complex Data Types

PomlSDK automatically converts complex data types to appropriate string representations:

```julia
# Dictionary data
params = Dict("operation" => "sum", "values" => [1, 2, 3, 4])
tool_req = tool_request(p, name="calculator", parameters=params)

# Array data
items = ["apple", "banana", "cherry"]
list_node = list(p, items=items)
```

### Custom Serialization

For specialized content, you can implement custom serialization:

```julia
function custom_serialize(p::Prompt, data::MyCustomType)
    # Convert to appropriate format
    json_str = JSON.json(data)
    
    # Add as text or metadata
    meta_attr = meta_attribute(p, name="custom_data", value=json_str)
    
    # Or add as a specialized tag
    custom_node = tag(p, "custom", data=json_str)
    add_node!(p, custom_node)
    # Add more structured content if needed
    pop_node!(p)
end
```

## Best Practices for Content Types

- **Balance richness with token count**: More complex content increases token usage
- **Use appropriate content type**: Tables for structured data, lists for sequences
- **Provide context**: Always explain what the content represents
- **Validate content**: Ensure tables are properly formatted, images are valid
- **Consider accessibility**: Provide alt text for images, clear captions for tables

By effectively using these content types, you can create rich, structured prompts that communicate more effectively with LLMs.