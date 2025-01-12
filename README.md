Terraform Functions

This module makes it easy to create custom functions inside terraform to simplify code management.

The Functions module uses templatestring() to do its work and has a workaround to simulate a templatefile() call from inside an other template.
Some functions are built in and always accessible, but you can also create your own via an argument to the Functions module.

Code Example:

```
module "f" {
    source = "./modules/terraform-functions"
    custom = {
        multiply_by_10 = <<-EOT
            template("a", {parameter = parameter})
        EOT
    }
}

output "output" {
    value = jsondecode(templatestring(module.f.t["multiply_by_10"], {parameter = 34}))
}
```

Output : 340
