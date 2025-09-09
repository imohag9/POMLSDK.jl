```@meta
CurrentModule = PomlSDK
```


# PomlSDK.jl



**PomlSDK.jl** is a Julia package for creating structured prompts for Large Language Models (LLMs) using the [Prompt Orchestration Markup Language (POML)](https://microsoft.github.io/poml/latest/) standard developed by Microsoft.

## Overview

PomlSDK provides a programmatic API to build complex, hierarchical prompt structures with metadata, examples, and multi-modal content. It allows you to move beyond simple string-based prompts to a structured representation that can be serialized into the POML XML format.

### Key Features

- **Hierarchical Structure**: Build prompts using a tree of semantic nodes (roles, tasks, examples, etc.)
- **Rich Content Types**: Support for text, tables (markdown), lists, images (base64), and metadata
- **Tool Integration**: Define and request tools/functions with structured parameters
- **Metadata Support**: Attach source information, attributes, and annotations
- **Serialization**: Convert structured prompt objects to valid POML XML

## Installation

```julia
using Pkg
Pkg.add("PomlSDK")
```

## Quick Example

```julia
using PomlSDK

# Create a new prompt
p = Prompt()

# Add a role with text
role_node = role(p, caption="System")
add_node!(p, role_node)
add_text(p, "You are a helpful AI assistant.")
pop_node!(p)

# Add a task
task_node = task(p, caption="Data Analysis")
add_node!(p, task_node)
add_text(p, "Summarize the following sales data.")
pop_node!(p)

# Serialize to POML format
poml_string = dump_poml(p)
println(poml_string)
```

