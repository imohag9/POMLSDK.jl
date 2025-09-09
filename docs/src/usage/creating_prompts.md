```@meta
CurrentModule = POMLSDK
```
# Creating Prompts

This guide explains how to create structured prompts using POMLSDK.jl.

## Prompt Structure

In POMLSDK, prompts are built as hierarchical structures. The basic workflow involves:

1. Creating a `Prompt` object
2. Adding semantic tags (role, task, example, etc.)
3. Managing the hierarchy with `add_node!` and `pop_node!`
4. Adding content with `add_text`
5. Serializing with `dump_poml`

## Creating a Prompt Object

All prompts start with a `Prompt` object:

```julia
p = Prompt()
```

This creates an empty prompt structure with a root `<poml>` element.

## Adding Semantic Tags

POMLSDK provides several functions for adding semantic tags that correspond to the POML standard:

```julia
# Add a role (typically for system instructions)
role_node = role(p, caption="System")

# Add a task (what the AI should do)
task_node = task(p, caption="Data Analysis", priority="high")

# Add examples for few-shot learning
example_set_node = example_set(p)
example_node = example(p)

# Add metadata
meta_node = meta(p)
```

These functions create the appropriate XML elements and add them to the current position in the prompt hierarchy.

## Managing the Hierarchy

The key to building complex prompts is managing the hierarchy with `add_node!` and `pop_node!`:

```julia
# Start with the root prompt
p = Prompt()

# Add a task and make it the current parent
task_node = task(p, caption="Data Analysis")
add_node!(p, task_node)

# Now all additions will be inside the task
add_text(p, "Analyze the following sales data.")

# Add an example set within the task
example_set_node = example_set(p)
add_node!(p, example_set_node)

# Add examples within the example set
example_node = example(p)
add_node!(p, example_node)
add_text(p, "Input: Q1 Sales: $1.2M\nOutput: Sales were strong in Q1.")
pop_node!(p)  # Back to example_set

example_node2 = example(p)
add_node!(p, example_node2)
add_text(p, "Input: Q2 Sales: $1.5M\nOutput: Sales increased by 25%.")
pop_node!(p)  # Back to example_set
pop_node!(p)  # Back to task
pop_node!(p)  # Back to root
```

## Adding Text Content

Use `add_text` to add textual content to the current node:

```julia
# Add text to the current node
add_text(p, "You are a helpful AI assistant.")

# Can add multiple text segments
add_text(p, "This is additional ")
add_text(p, "text content.")
```

Text content is accumulated within the current node, so the above would result in "You are a helpful AI assistant.This is additional text content." (note there's no space added between segments).

## Complete Prompt Example

Here's a complete example creating a structured prompt:

```julia
using POMLSDK

p = Prompt()

# Add system role
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a financial analyst AI that provides accurate data summaries.")
pop_node!(p)

# Add task with examples
task_node = task(p, caption="Financial Analysis")
add_node!(p, task_node)
add_text(p, "Analyze quarterly sales data and identify trends.")

# Add examples
example_set_node = example_set(p)
add_node!(p, example_set_node)

# Example 1
example_node = example(p)
add_node!(p, example_node)
input_node = tag(p, "input")
add_node!(p, input_node)
add_text(p, "Q1 Sales: $1.2M, Q2 Sales: $1.5M")
pop_node!(p)
output_node = tag(p, "output")
add_node!(p, output_node)
add_text(p, "Sales increased by 25% from Q1 to Q2.")
pop_node!(p)
pop_node!(p)

# Example 2
example_node2 = example(p)
add_node!(p, example_node2)
input_node2 = tag(p, "input")
add_node!(p, input_node2)
add_text(p, "Q3 Sales: $1.1M, Q4 Sales: $1.8M")
pop_node!(p)
output_node2 = tag(p, "output")
add_node!(p, output_node2)
add_text(p, "Sales dipped in Q3 but had a strong finish in Q4.")
pop_node!(p)
pop_node!(p)

pop_node!(p)  # Pop example_set
pop_node!(p)  # Pop task

# Serialize to POML
poml_string = dump_poml(p)
println(poml_string)
```

## Best Practices

- **Maintain clear hierarchy**: Always `pop_node!` after you're done with a node
- **Use descriptive captions**: Add `caption` attributes to make your structure clear
- **Modularize**: Create functions for common prompt structures
- **Validate**: Check your generated POML with an XML validator

