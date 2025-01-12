locals {
    regex = "template\\(.*\"(?P<template>.*)\", *(?P<parameter>{.*}) *\\)"
    files = fileset("${path.module}/functions", "*.tf")
    content = merge(
        { for file in local.files : trimsuffix(file, ".tf") => file("${path.module}/functions/${file}")}, 
        { for name, content in var.custom : (name) => "$${jsonencode(\n${content})}" }
    )
    content_by_line = { for function, content in local.content : function => [ for line in split("\n", content) : chomp(line)]}
    content_without_comments = { for function, content in local.content_by_line : function => [ for line in content : line if !startswith(trimspace(line), "#")]}
    content_indexed = { for function, lines in local.content_without_comments : function => {
        for index in range(length(lines)) : index => lines[index]
    }}
    content_without_envelope_code = { for function, lines in local.content_indexed : function => [
        for index, line in lines : line if index != tostring(0) && index != tostring(length(lines)-1)
    ]}

    expand_functions = { for function, lines in local.content_without_envelope_code : function => flatten([
        for line in lines : try([
            ["{ for parameter in ${regex(local.regex, line).parameter} : \"output\" => "],
            local.content_without_envelope_code[regex(local.regex, line).template],
            ["}.output"]],
            line)
    ])}
    expand_functions1 = { for function, lines in local.expand_functions : function => flatten([
        for line in lines : try([
            ["{ for parameter in ${regex(local.regex, line).parameter} : \"output\" => "],
            local.expand_functions[regex(local.regex, line).template],
            ["}.output"]],
            line)
    ])}
    output = { for function, lines in local.expand_functions1 : function => join("", flatten([
        "$${jsonencode(",
        lines,
        ")}"
    ]))}
}
