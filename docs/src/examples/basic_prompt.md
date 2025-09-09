```@meta
CurrentModule = POMLSDK
```
# Basic Prompt Example

This example demonstrates how to create a simple structured prompt using POMLSDK.jl.

## Creating a Basic Prompt

```julia
using POMLSDK

# Create a new prompt
p = Prompt()

# Add a system role
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a helpful AI assistant that can answer questions about geography.")
pop_node!(p)

# Add a user task
task_node = task(p, caption="Geography Question")
add_node!(p, task_node)
add_text(p, "What is the capital of France?")
pop_node!(p)

# Serialize to POML format
poml_string = dump_poml(p)
println(poml_string)
```

This will generate the following POML XML:

```xml
<poml>
  <role caption="System">You are a helpful AI assistant that can answer questions about geography.</role>
  <task caption="Geography Question">What is the capital of France?</task>
</poml>
```

## Adding Examples for Few-shot Learning

```julia
using POMLSDK

p = Prompt()

# System role
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a geography expert. Answer questions concisely.")
pop_node!(p)

# Task with examples
task_node = task(p, caption="Geography Quiz")
add_node!(p, task_node)
add_text(p, "Answer these geography questions:")

# Example set
example_set_node = example_set(p)
add_node!(p, example_set_node)

# Example 1
example_node = example(p)
add_node!(p, example_node)
input_node = tag(p, "input")
add_node!(p, input_node)
add_text(p, "What is the capital of Germany?")
pop_node!(p)
output_node = tag(p, "output")
add_node!(p, output_node)
add_text(p, "Berlin")
pop_node!(p)
pop_node!(p)

# Example 2
example_node2 = example(p)
add_node!(p, example_node2)
input_node2 = tag(p, "input")
add_node!(p, input_node2)
add_text(p, "What is the longest river in Africa?")
pop_node!(p)
output_node2 = tag(p, "output")
add_node!(p, output_node2)
add_text(p, "The Nile")
pop_node!(p)
pop_node!(p)

pop_node!(p)  # Pop example_set
pop_node!(p)  # Pop task

# Current question
task_node2 = task(p, caption="Current Question")
add_node!(p, task_node2)
add_text(p, "What is the highest mountain in the world?")
pop_node!(p)

# Generate POML
poml_string = dump_poml(p)
println(poml_string)
```

This creates a prompt with examples that can help guide the AI's responses through few-shot learning.