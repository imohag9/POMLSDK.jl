```@meta
CurrentModule = POMLSDK
```
# Getting Started with POMLSDK.jl

Welcome to the POMLSDK.jl documentation! This guide will help you get started with creating structured prompts for LLMs using the POML standard.

## Understanding POML

[POML (Prompt Orchestration Markup Language)](https://microsoft.github.io/poml/latest/) is a standard developed by Microsoft for creating structured prompts. It provides a way to define complex prompt structures with metadata, examples, and multi-modal content, moving beyond simple string-based prompts.

## Basic Concepts

POMLSDK.jl implements the following key concepts from the POML standard:

- **Prompt**: The root object that contains all prompt elements
- **Hierarchy**: A tree structure where elements can be nested within each other
- **Tags**: Semantic elements like `role`, `task`, `example`, etc.
- **Content**: Text, tables, lists, and other data that goes inside tags
- **Metadata**: Information about the prompt, its source, and context

## Your First Prompt

Let's create a simple prompt that instructs an AI assistant:

```julia
using POMLSDK

# 1. Create a new Prompt object
p = Prompt()

# 2. Add a role (system instructions)
role_node = role(p, caption="System")
add_node!(p, role_node)  # Make role_node the current parent
add_text(p, "You are a helpful AI assistant specialized in data analysis.")
pop_node!(p)  # Return to root

# 3. Add a task for the AI
task_node = task(p, caption="Data Summary")
add_node!(p, task_node)
add_text(p, "Summarize the provided sales data.")
pop_node!(p)

# 4. Serialize to POML format
poml_string = dump_poml(p)
println(poml_string)
```

This will produce XML similar to:

```xml
<poml>
  <role caption="System">You are a helpful AI assistant specialized in data analysis.</role>
  <task caption="Data Summary">Summarize the provided sales data.</task>
</poml>
```

## Understanding the Hierarchy

POMLSDK uses a stack-based approach to manage the prompt hierarchy:

- `add_node!(p, node)` makes `node` the current parent for subsequent additions
- `pop_node!(p)` moves back up one level in the hierarchy

This allows you to create nested structures:

```julia
# Create a task with examples
task_node = task(p, caption="Data Analysis")
add_node!(p, task_node)

# Add examples
example_set_node = example_set(p)
add_node!(p, example_set_node)

example_node = example(p)
add_node!(p, example_node)
# Add input/output structure
input_node = tag(p, "input")
add_node!(p, input_node)
add_text(p, "Q1 Sales: $1.2M, Q2 Sales: $1.5M")
pop_node!(p)

output_node = tag(p, "output")
add_node!(p, output_node)
add_text(p, "Sales increased by 25% from Q1 to Q2.")
pop_node!(p)
pop_node!(p)  # Pop example
pop_node!(p)  # Pop example_set
pop_node!(p)  # Pop task
```
