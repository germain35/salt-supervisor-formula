{%- from "supervisor/map.jinja" import supervisor with context %}

include:
  - supervisor.install

supervisor_service:
  service.running:
    - name: {{ supervisor.service }}
    - enable: {{ supervisor.service_enabled }}
    - reload: {{ supervisor.service_reload }}
    - require:
        - pkg: supervisor_packages
