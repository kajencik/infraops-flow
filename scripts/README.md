# Scripts

This is where the repo stops talking about operations and starts doing small, useful pieces of it.

In the sample environment, scripts are the modest part of the system: they support the operator, they do not pretend to replace them.

Guidelines:

- keep environment-specific values out of the script body
- prefer config or parameters over hardcoded targets
- treat write actions as explicit and reviewable
- separate reusable helpers into `scripts/lib/`

Good scripts in this repo should feel boring in the best way: readable, parameterized, and unlikely to surprise an operator at 23:40, especially when the rest of the environment is already generating enough noise on its own.

Current script:

- `host-health.ps1` collects a read-only Windows host snapshot without assuming anything about the rest of the environment.