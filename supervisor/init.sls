{%- from "supervisor/map.jinja" import supervisor with context %}

include:
  - supervisor.install
  - supervisor.config
  - supervisor.service