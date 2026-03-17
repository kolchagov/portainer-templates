# Portainer Templates

This repository contains my selection of Portainer templates.

- `templates.json` contains my local template custom created entries.
- `templates_v3.json` contains curated list of entries, collected from internet and is the base Portainer v3 template set used for merging.
- `all.json` is the merged output.
- `stacks/` contains compose files for stack-based templates.

After updating the templates, run `./merger.sh` to rebuild `all.json`.