{%- from "supervisor/map.jinja" import supervisor with context %}

{%- set osfamily   = salt['grains.get']('os_family') %}
{%- set os         = salt['grains.get']('os') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - supervisor.install
  - supervisor.service

{%- if supervisor.pip_install %}
supervisor_init_script:
  file.managed:
    - name: {{ supervisor.init_script }}
    - source: salt://supervisor/files/init/{{osfamily}}.init
    - user: root
    - mode: 755
    - watch_in:
      - service: supervisor_service
    - require:
      - sls: supervisor.install

supervisor_systemctl_reload:
  module.wait:
    - service.systemctl_reload: []
    - watch:
      - file: supervisor_init_script
    - watch_in:
      - service: supervisor_service
{%- endif %}

supervisor_config:
  file.managed:
    - name: {{ supervisor.conf_file }}
    - source: salt://supervisor/files/supervisord.conf.jinja
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
      - sls: supervisor.install
    - watch_in:
      - service: supervisor_service

supervisor_log_dir:
  file.directory:
    - name: {{ supervisor.config.supervisord.childlogdir }}
    - user: root
    - mode: 755
    - require_in:
      - service: supervisor_service

supervisor_program_dir:
  file.directory:
    - name: {{ supervisor.program_dir }}
    - user: root
    - mode: 755
    - force: True
    - clean: {{ supervisor.purge_program_dir }}

{%- for program, values in supervisor.get('programs', {}).iteritems() %}
  {%- if ( 'enabled' in values and values.enabled ) or 'enabled' not in values %}
supervisor_program_{{ program }}_config:
  file.managed:
    - name: {{ supervisor.program_dir }}/{{ program }}.conf
    - source: salt://supervisor/files/program.conf.jinja
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - defaults:
        program: {{ program }}
        values: {{ values }}
    - require:
      - file: supervisor_program_dir
    - watch_in:
      - cmd: supervisor_program_update

  {%- else %}

supervisor_program_{{ program }}_config_absent:
  file.absent:
    - name: {{ supervisor.program_dir }}/{{ program }}.conf
    - watch_in:
      - cmd: supervisor_program_update

  {%- endif %}
{%- endfor %}
