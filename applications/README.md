# Applications

This folder documents the services and applications running in the environment.

Each application gets its own subfolder with at minimum a `README.md` that answers:
- what it is and what it does
- where it runs (host, container, cloud resource)
- what it depends on (other services, shares, network paths)
- how to verify it is working
- known operational notes (quirks, maintenance windows, past incidents worth remembering)

## Structure

```
applications/
  <app-name>/
    README.md        # primary documentation
    runbook.md       # optional: step-by-step procedures for common operations
  README.md          # this file
```

## Conventions

- Folder name matches the service or application name as it appears in `inventory/service-topology.json`.
- Keep documentation factual and current; outdated documentation is worse than none.
- If an application is decommissioned, move its folder to an `applications/_archive/` subfolder rather than deleting it.
  Historical context about what used to run (and why it was removed) has operational value.
