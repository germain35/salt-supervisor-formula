{%- from "supervisor/map.jinja" import supervisor with context %}


{%- if supervisor.pip_install %}

supervisor_pip_package:
  pkg.installed:
    - pkgs: {{ supervisor.pip_pkgs }}

  {%- for pkg in supervisor.pkgs %}
supervisor_{{pkg}}_pip_package:
  pip.installed:
    - name: {{ pkg }}
    - require:
      - pkg: supervisor_pip_package
  {%- endfor %}

{%- else %}

supervisor_packages:
  pkg.installed:
    - pkgs: {{ supervisor.pkgs }}

{%- endif %}
