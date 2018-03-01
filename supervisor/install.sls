{%- from "supervisor/map.jinja" import supervisor with context %}


{%- if supervisor.pip_install %}

supervisor_pip_package:
  pkg.installed:
    - pkgs: {{ supervisor.pip_pkgs }}

supervisor_package:
  pip.installed:
    - name: {{ supervisor.pkg }}
    - require:
      - pkg: supervisor_pip_package

{%- else %}

supervisor_package:
  pkg.installed:
    - name: {{ supervisor.pkg }}

{%- endif %}
