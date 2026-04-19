# Scripts

Public-safe script logic should live here.

Guidelines:

- keep environment-specific values out of the script body
- prefer config or parameters over hardcoded targets
- treat write actions as explicit and reviewable
- separate reusable helpers into `scripts/lib/`

This initial scaffold does not yet include live scripts; it defines the layout and conventions first.