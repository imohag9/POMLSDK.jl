# POMLSDK [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://imohag9.github.io/POMLSDK.jl/dev/) [![Build Status](https://github.com/imohag9/POMLSDK.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/imohag9/POMLSDK.jl/actions/workflows/CI.yml?query=branch%3Amain) 


**POMLSDK.jl** 
This package implements the Prompt Orchestration Markup Language (POML)  standard developed by Microsoft Research : [POML specification](https://microsoft.github.io/poml/latest/).

This is a Julia package for creating structured prompts for Large Language Models (LLMs) using a Prompt Object Model Language (POML)-like approach. It provides a programmatic API to build complex, hierarchical prompt structures with metadata, examples, and multi-modal content, moving beyond simple string-based prompts.

## Installation

You can install it directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/imohag9/POMLSDK.jl")
```


## Overview

POMLSDK offers a fluent API to construct prompts as structured object models. This allows for better organization, reusability, and programmatic manipulation of prompts before they are serialized into a textual format suitable for LLMs.

Key features include:
*   **Hierarchical Structure:** Build prompts using a tree of nodes (roles, tasks, examples, etc.).
*   **Rich Content Types:** Support for text, tables (markdown), lists, images (base64), and metadata.
*   **Tool Integration:** Define and request tools/functions with structured parameters.
*   **Metadata Support:** Attach source information, attributes, and annotations.
*   **Serialization:** Convert the structured prompt object into a POML-like string format.

## Usage

The core workflow involves creating a `Prompt` object and then using specialized functions to add tags and content to it. The `add_node!` and `pop_node!` functions manage the current position within the prompt hierarchy.

```julia
using POMLSDK

# 1. Create a new Prompt
p = Prompt()


# 2 Add a structured component, like a role
role_node = role(p, caption="System")
add_node!(p, role_node) # Make 'role_node' the current parent
add_text(p, "Adhere to the highest standards of accuracy.")
pop_node!(p) # Move back to the previous parent (the root)

# 3. Add a task
task_node = task(p, priority="high", caption="Data Summary")
add_node!(p, task_node)
add_text(p, "Summarize the provided sales data.")

# 4. Add an example set for the task
example_set_node = example_set(p)
add_node!(p, example_set_node)

example_node = example(p)
add_node!(p, example_node)
# Add input and output parts (simplified - often nested tags)
input_node = tag(p, "input") # Using generic tag
add_node!(p, input_node)
add_text(p, "Q1 Sales: $1.2M, Q2 Sales: $1.5M")
pop_node!(p)

output_node = tag(p, "output")
add_node!(p, output_node)
add_text(p, "Sales increased by 25% from Q1 to Q2.")
pop_node!(p)
pop_node!(p) # Pop example

# Add another example if needed...

pop_node!(p) # Pop example_set
pop_node!(p) # Pop task

# 5. Add a table with data
sales_data = [
    ["Quarter", "Sales (USD)"],
    ["Q1", "1200000"],
    ["Q2", "1500000"],
    ["Q3", "1100000"],
    ["Q4", "1800000"]
]
table_node = table(p, data=sales_data)
# table() function handles adding the node and its content

# 6. Serialize the prompt to POML format
poml_string = dump_poml(p)
println(poml_string)
```

### Key Functions

*   `Prompt()`: Creates a new prompt object.
*   `tag(p, name, attrs...)`: Creates a generic XML tag node. Most other specific functions use this internally.
*   `role(p, attrs...)`, `task(p, attrs...)`, `example(p, attrs...)`, `example_set(p, attrs...)`, `table(p, data=...)`, `list(p, attrs...)`, `list_item(p, attrs...)`, `image(p, src=..., attrs...)`, `tool_request(p, name=..., attrs...)`, `tool_definition(p, name=..., description=..., attrs...)`: Create specific semantic tags.
*   `meta(p, attrs...)`, `meta_tag(p, key=..., value=...)`, `meta_attribute(p, name=..., value=...)`: Handle metadata.
*   `add_text(p, content)`: Adds text content to the *current* node in the hierarchy.
*   `add_node!(p, node)`: Makes `node` the new parent for subsequent additions.
*   `pop_node!(p)`: Moves the current parent back up one level in the hierarchy.
*   `dump_poml(p)`: Serializes the prompt object structure into a POML-formatted string.


## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

This package draws inspiration from the concepts of structured prompting and markup languages like XML, adapting them for the Julia ecosystem.


