# Inventory

This directory is the ledger of things with names, addresses, roles, and a habit of misbehaving at inconvenient times.

In the sample environment, this is where the operator finally stopped saying things like "the small box near the router" and started writing down what each system actually is.

- `devices.example.json` introduces the cast: `edge-router`, `mini-pc-1`, `nas-1`, `ap-1`, `home-automation-1`, and `ops-laptop`
- `networks.example.json` shows the main LAN and the small management network the operator eventually decided was worth the effort
- `fileshares.example.json` shows where backups and operational exports landed after they were rescued from random workstation paths
- `service-topology.example.json` shows how servers, applications, and dependencies can be modeled together, including shared database use and simple static-site hosting

Keep the schema stable, keep the examples readable, and resist the urge to make inventory files look like an accidental CMDB.