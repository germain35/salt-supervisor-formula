{%- from "supervisor/map.jinja" import supervisor with context %}


{%- if supervisor.pip_install %}
  {%- if supervisor.python_version is defined %}

    {%- set string_version = supervisor.python_version|string %}
    {%- set major_version  = string_version.split('.')[0]|int %}

supervisor_python_packages:
  pkg.installed:
    - pkgs: 
      - python{{major_version}}-pip
      - python{{major_version}}-setuptools

supervisor_package:
  pip.installed:
    - name: {{ supervisor.pkg }}
    - bin_env: /usr/bin/pip{{supervisor.python_version}}
    - require:
      - pkg: supervisor_python_packages
  
  {%- else %}

supervisor_python_packages:
  pkg.installed:
    - pkgs: 
      - python-pip
      - python-setuptools

supervisor_package:
  pip.installed:
    - name: {{ supervisor.pkg }}
    - require:
      - pkg: supervisor_python_packages

  {%- endif %}
{%- else %}

supervisor_package:
  pkg.installed:
    - name: {{ supervisor.pkg }}

{%- endif %}
