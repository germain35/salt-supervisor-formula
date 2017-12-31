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
  - source: salt://supervisor/files/supervisor.conf
  - mode: 644
  - template: jinja
  - require:
    - pkg: supervisor_packages
  - watch_in:
    - service: supervisor_service


{%- for program, values in supervisor.get('prgrams', {}).iteritems() %}
supervisor_program_{{ program }}:
  {% if ( 'enabled' in values and values.enabled ) or 'enabled' not in values %}
  file.managed:
    - name: {{ supervisor.program_dir }}/{{ program }}.conf
    - source: salt://supervisor/templates/program.conf.tmpl
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - defaults:
        program: {{ program }}
        values: {{ values }}
    - watch_in:
      - supervisord: supervisor_program_{{ program }}_running
  {%- elif 'enabled' in values and not values.enabled %}
  file.absent:
    - name: {{ supervisor.program_dir }}/{{ program }}.conf
    - watch_in:
      - supervisord: supervisor_program_{{ program }}_absent
  {%- endif %}

supervisor_program_{{ program }}_running:
  supervisord.running:
    - name: {{ program }}
    - update: {{ supervisor.program_update }}
    - restart: {{ supervisor.program_restart }}
    - require:
      - pkg: supervisor_packages


supervisor_program_{{ program }}_dead:
  supervisord.running:
    - name: {{ program }}
    - require:
      - pkg: supervisor_packages


{%- endfor %}
