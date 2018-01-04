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
      - pkg: supervisor_packages


{%- for program, values in supervisor.get('programs', {}).iteritems() %}
  {%- if ( 'enabled' in values and values.enabled ) or 'enabled' not in values %}

supervisor_{{ program }}_service:
  supervisord.running:
    - name: {{ program }}
    - update: {{ supervisor.program_update }}
    - restart: {{ supervisor.program_restart }}
    - conf_file: {{ supervisor.conf_file }}
    - require:
      - service: supervisor_service
      - file: supervisor_{{ program }}_config

  {%- else %}

supervisor_{{ program }}_service:
  supervisord.dead:
    - name: {{ program }}
    - conf_file: {{ supervisor.conf_file }}
    - require:
      - service: supervisor_service

  {%- endif %}
{%- endfor %}
