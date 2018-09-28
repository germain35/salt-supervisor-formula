{%- from "supervisor/map.jinja" import supervisor with context %}


{%- if supervisor.pip_install %}

supervisor_python_packages:
  pkg.installed:
    - pkgs: {{ supervisor.python.pkgs}}
    - reload_modules: true

  {%- for package in supervisor.get('pip_pkgs', []) %}
supervisor_{{package}}_pip_package:
  pip.installed:
    - name: {{ package }}
    {%- if supervisor.python.get('major_version', False) > 2 %}
    - bin_env: {{ supervisor.python.pip3_bin }}
    {%- endif %}
    {%- for k, v in supervisor.python.get('pip', {}).items() %}
    - {{k}}: {{v}}
    {%- endfor %}
    - require:
      - pkg: supervisor_python_packages
  {%- endfor %}

{%- else %}

supervisor_packages:
  pkg.installed:
    - pkgs: {{ supervisor.pkgs }}

{%- endif %}
