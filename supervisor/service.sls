{%- from "supervisor/map.jinja" import supervisor with context %}

include:
  - supervisor.install
  - supervisor.config

supervisor_service:
  service.running:
    - name: {{ supervisor.service }}
    - enable: {{ supervisor.service_enabled }}
    - reload: {{ supervisor.service_reload }}
    - require:
      - sls: supervisor.install

supervisor_program_update:
  cmd.wait:
    - name: supervisorctl update
    - require:
      - service: supervisor_service

{%- if supervisor.program_restart %}
supervisor_program_restart:
  cmd.run:
    - name: supervisorctl restart all
    - require:
      - service: supervisor_service
      - cmd: supervisor_program_update
{%- endif %}
