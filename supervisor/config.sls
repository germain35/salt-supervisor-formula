{%- from "supervisor/map.jinja" import supervisor with context %}

{%- set osfamily   = salt['grains.get']('os_family') %}
{%- set os         = salt['grains.get']('os') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - supervisor.install
  - supervisor.service

supervisor_config:
  file.managed:
  - name: {{ supervisor.conf_file }}
  - source: salt://supervisor/templates/supervisord.conf.jinja
  - mode: 644
  - template: jinja
  - require:
    - pkg: supervisor_packages
  - watch_in:
    - service: supervisor_service


{%- for program, values in supervisor.get('programs', {}).iteritems() %}
  {%- if ( 'enabled' in values and values.enabled ) or 'enabled' not in values %}
supervisor_{{ program }}_config:
  file.managed:
    - name: {{ supervisor.program_dir }}/{{ program }}.conf
    - source: salt://supervisor/templates/program.conf.jinja
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - defaults:
        program: {{ program }}
        values: {{ values }}
    - watch_in:
      - supervisord: supervisor_{{ program }}_service

  {%- else %}

supervisor_program_{{ program }}_config:
  file.absent:
    - name: {{ supervisor.program_dir }}/{{ program }}.conf
    - require:
      - supervisord: supervisor_{{ program }}_service

  {%- endif %}
{%- endfor %}
