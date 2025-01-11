Terraform Functions

This module makes it easy to create custom functions inside terraform to simplify code management.

The Functions module uses templatestring() to do its work and has a workaround to simulate a templatefile() call from inside an other template.
Some functions are built in and always accessible, but you can also create your own via an argument to the Functions module.