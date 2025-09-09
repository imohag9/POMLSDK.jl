```@meta
CurrentModule = POMLSDK
```
# Hierarchy Management

This guide explains how to manage the hierarchical structure of prompts in POMLSDK.jl.

## Understanding the Stack-Based Approach

POMLSDK uses a stack to manage the current position within the prompt hierarchy. This approach is essential for creating nested structures that follow the POML standard.

The key components of hierarchy management are:

1. **Current Parent**: The node where new elements will be added
2. **Stack**: A data structure that keeps track of the current parent and its ancestors
3. **Push**: Moving deeper into the hierarchy
4. **Pop**: Moving back up the hierarchy

## The Stack Operations

### `add_node!(p, node)`

Moves the current parent to `node`, making it the target for subsequent additions:

```julia
task_node = task(p, caption="Data Analysis")
add_node!(p, task_node)  # Now task_node is the current parent
```

After this operation, any new elements added will be children of `task_node`.

### `pop_node!(p)`

Moves back up one level in the hierarchy:

```julia
pop_node!(p)  # Returns to the previous parent (whatever was current before task_node)
```

This is crucial for properly closing nested structures.

## Common Hierarchy Patterns

### Basic Nesting

```julia
p = Prompt()

# Create a task
task_node = task(p, caption="Main Task")
add_node!(p, task_node)

# Add content to the task
add_text(p, "Perform the following analysis:")

# Create a nested example set
example_set_node = example_set(p)
add_node!(p, example_set_node)

# Add examples
example_node = example(p)
add_node!(p, example_node)
add_text(p, "Input: Sample data\nOutput: Expected result")
pop_node!(p)  # Back to example_set

pop_node!(p)  # Back to task
pop_node!(p)  # Back to root
```

### Multiple Levels of Nesting

```julia
p = Prompt()

role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a helpful assistant.")

task_node = task(p, caption="Data Processing")
add_node!(p, task_node)
add_text(p, "Process the following data:")

example_set_node = example_set(p)
add_node!(p, example_set_node)

example_node = example(p)
add_node!(p, example_node)

input_node = tag(p, "input")
add_node!(p, input_node)
add_text(p, "Raw data points: [1.2, 3.4, 5.6]")
pop_node!(p)

output_node = tag(p, "output")
add_node!(p, output_node)
add_text(p, "Processed result: [1.5, 3.7, 5.9]")
pop_node!(p)

pop_node!(p)  # Back to example_set
pop_node!(p)  # Back to task
pop_node!(p)  # Back to role
pop_node!(p)  # Back to root
```

## Error Prevention

### Always Pair Push and Pop

For every `add_node!`, there should be a corresponding `pop_node!`:

```julia
# Good practice
task_node = task(p, caption="Task")
add_node!(p, task_node)
# Add content
add_text(p, "Task description")
pop_node!(p)  # Always match push with pop

# Bad practice (missing pop_node!)
task_node = task(p, caption="Task")
add_node!(p, task_node)
add_text(p, "Task description")
# Missing pop_node! will cause subsequent content to be added to this task
```

### Check Stack Depth

Before popping, you can check if there's anything to pop:

```julia
if length(p.current_parent_stack) > 1  # Always keep root
    pop_node!(p)
end
```

## Advanced Patterns

### Reusing Nodes

You can push the same node multiple times if needed:

```julia
p = Prompt()

task_node = task(p, caption="Main Task")
add_node!(p, task_node)
add_text(p, "First part of the task")

# Do other things...

add_node!(p, task_node)  # Return to the same task node
add_text(p, "Additional task instructions")
pop_node!(p)
pop_node!(p)
```

### Conditional Structure Building

```julia
function add_analysis_section(p, include_examples::Bool)
    analysis_node = task(p, caption="Data Analysis")
    add_node!(p, analysis_node)
    add_text(p, "Analyze the provided data.")
    
    if include_examples
        example_set_node = example_set(p)
        add_node!(p, example_set_node)
        # Add examples...
        pop_node!(p)  # Back to analysis_node
    end
    
    pop_node!(p)  # Back to root
end

p = Prompt()
add_analysis_section(p, true)
```

## Debugging Hierarchy Issues

If you're having trouble with unexpected nesting:

1. **Print the current stack**:
   ```julia
   println("Current stack depth: $(length(p.current_parent_stack))")
   ```

2. **Dump intermediate POML**:
   ```julia
   println("Intermediate state: $(dump_poml(p))")
   ```

3. **Use try-catch blocks**:
   ```julia
   try
       # Hierarchy operations
   catch e
       println("Hierarchy error: $e")
       # Reset to root if needed
       while length(p.current_parent_stack) > 1
           pop_node!(p)
       end
   end
   ```

## Best Practices

- **Always comment your push/pop pairs**:
  ```julia
  add_node!(p, task_node)  # Entering task structure
  # ... content ...
  pop_node!(p)  # Exiting task structure
  ```

- **Use indentation to reflect hierarchy** in your code

- **Consider creating helper functions** for common nested structures

- **Validate your final POML** with `dump_poml(p)` to ensure proper nesting

By mastering hierarchy management, you can create complex, well-structured prompts that effectively communicate with LLMs according to the POML standard.