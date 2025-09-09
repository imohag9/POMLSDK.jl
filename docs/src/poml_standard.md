# POML Standard Implementation

PomlSDK.jl implements the [Prompt Orchestration Markup Language (POML)](https://microsoft.github.io/poml/latest/) standard developed by Microsoft. This documentation explains how PomlSDK maps to the official POML specification.

## What is POML?

POML (Prompt Orchestration Markup Language) is a standard for creating structured prompts for Large Language Models (LLMs). It provides a way to define complex prompt structures with metadata, examples, and multi-modal content, moving beyond simple string-based prompts.

## PomlSDK Implementation

PomlSDK.jl provides a programmatic Julia API to build prompts according to the POML standard. The package maps directly to the POML XML structure but provides a more developer-friendly interface.

### Core Elements Mapping

| POML XML Element | PomlSDK.jl Function | Description |
|------------------|------------------------|-------------|
| `<role>` | `role()` | Defines a role in the conversation (e.g., System, Assistant) |
| `<task>` | `task()` | Specifies the main task for the AI to perform |
| `<example>` | `example()` | Provides a single example for few-shot learning |
| `<example_set>` | `example_set()` | Groups multiple examples together |
| `<table>` | `table()` | Creates a markdown-formatted table |
| `<list>` | `list()` | Creates a list (ordered or unordered) |
| `<list_item>` | `list_item()` | Creates a list item |
| `<meta>` | `meta()` | Contains metadata about the prompt |
| `<meta_tag>` | `meta_tag()` | Adds a key-value metadata tag |
| `<meta_attribute>` | `meta_attribute()` | Adds a named metadata attribute |
| `<tool_request>` | `tool_request()` | Requests the use of a specific tool |
| `<tool_definition>` | `tool_definition()` | Defines a tool that can be used |
| `<image>` | `image()` | Embeds an image (base64 encoded) |
| `<document>` | `document()` | References an external document |

### Document Structure

The POML standard specifies that a document should have the following structure:

```xml
<poml>
  <role>...</role>
  <task>...</task>
  <example_set>...</example_set>
  <!-- Other elements -->
</poml>
```

PomlSDK.jl follows this structure exactly when serializing with `dump_poml()`.

### Advanced Features

PomlSDK implements several advanced POML features:

#### Tool Integration

POML supports tool definitions and requests, which PomlSDK implements through:

```julia
# Define a tool
tool_def = tool_definition(p, name="calculator", description="Performs basic math")

# Request a tool
tool_req = tool_request(p, name="calculator", parameters=Dict("operation" => "add", "a" => 5, "b" => 7))
```

#### Multi-modal Content

PomlSDK supports embedding images and documents:

```julia
# Add an image
img_node = image(p, src="image/png;base64,...", alt="Description")

# Add a document reference
doc_node = document(p, src="data.pdf", parser="pdf")
```

#### Metadata

PomlSDK provides comprehensive metadata support:

```julia
# Create metadata section
meta_node = meta(p)

# Add tags
meta_tag(p, key="author", value="Your Name")
meta_tag(p, key="source", value="user_input")

# Add attributes
meta_attribute(p, name="version", value="1.0")
```

## Differences from Official Implementation

While PomlSDK closely follows the POML standard, there are some implementation differences due to Julia's language characteristics:

1. **Hierarchy Management**: PomlSDK uses `add_node!`/`pop_node!` instead of context managers (like Python's `with` statements)
2. **Attribute Handling**: Attributes are handled through keyword arguments rather than separate method calls
3. **Data Type Conversion**: Automatic conversion of Julia types to appropriate string representations for XML

## Validation

To validate that your generated POML conforms to the standard, you can:

1. Use an XML validator with the POML schema
2. Compare against the [official POML examples](https://microsoft.github.io/poml/latest/examples.html)
3. Process through a POML-compliant LLM system

## Resources

- [Official POML Documentation](https://microsoft.github.io/poml/latest/)
- [POML GitHub Repository](https://github.com/microsoft/poml)
- [POML Specification](https://microsoft.github.io/poml/latest/specification.html)