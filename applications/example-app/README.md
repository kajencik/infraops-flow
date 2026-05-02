# example-app

> Replace this file with real application documentation. The structure below is a guide.

## What it is

A short description of what this application does and why it exists in the environment.

## Where it runs

- **Host:** `mini-pc-1` (or container on `mini-pc-1`, or cloud resource — be specific)
- **Port / endpoint:** `http://mini-pc-1:8080`
- **Started by:** systemd unit `example-app.service`

## Dependencies

| Dependency        | Type         | Notes                                  |
|-------------------|--------------|----------------------------------------|
| `nas-1/app-data`  | File share   | Application writes output here         |
| `edge-router`     | Network      | Requires LAN route to be up            |
| `monitoring-db`   | Service      | Reports metrics to local Prometheus    |

## How to verify it is working

```powershell
# Quick reachability check
Test-NetConnection -ComputerName mini-pc-1 -Port 8080
```

Expected: `TcpTestSucceeded: True`

Check logs if not responding:
```bash
journalctl -u example-app.service --since "1 hour ago"
```

## Operational notes

- This application restarts automatically on failure but does not alert. Monitor via the recurring checks.
- A known issue: the app writes a large temp file during index builds. If `nas-1/app-data` fills up, this is usually the cause.
- Last confirmed working: see the most recent session log that mentions `example-app`.
