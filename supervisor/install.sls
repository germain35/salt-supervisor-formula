{%- from "supervisor/map.jinja" import supervisor with context %}


{%- if supervisor.pip_install %}
  {%- if supervisor.python.get('version', False) %}

    {%- set string_version = supervisor.python.version|string %}
    {%- set major_version  = string_version.split('.')[0]|int %}

supervisor_python_packages:
  pkg.installed:
    - pkgs: 
      - python{{major_version}}-pip
      - python{{major_version}}-setuptools
    - reload_modules: true

supervisor_package:
  pip.installed:
    - name: {{ supervisor.pkg }}
    - bin_env: {{ supervisor.python.pip.bin_env }}
    {%- if supervisor.python.pip.get('no_index', False) %}
    - no_index: True
    {%- endif %}
    {%- if supervisor.python.pip.get('index_url', False) %}
    - index_url: {{ supervisor.python.pip.index_url }}
      {%- if supervisor.python.pip.get('trusted_host', False) %}
    - trusted_host: {{ supervisor.python.pip.trusted_host }}
      {%- endif %}
    {%- endif %}
    {%- if supervisor.python.pip.get('find_links', False) %}
    - find_links: {{ supervisor.python.pip.find_links }}
    {%- endif %}
    - require:
      - pkg: supervisor_python_packages
  
  {%- else %}

supervisor_python_packages:
  pkg.installed:
    - pkgs: 
      - python-pip
      - python-setuptools
    - reload_modules: true

supervisor_package:
  pip.installed:
    - name: {{ supervisor.pkg }}
    {%- if supervisor.python.pip.get('no_index', False) %}
    - no_index: True
    {%- endif %}
    {%- if supervisor.python.pip.get('index_url', False) %}
    - index_url: {{ supervisor.python.pip.index_url }}
      {%- if supervisor.python.pip.get('trusted_host', False) %}
    - trusted_host: {{ supervisor.python.pip.trusted_host }}
      {%- endif %}
    {%- endif %}
    {%- if supervisor.python.pip.get('find_links', False) %}
    - find_links: {{ supervisor.python.pip.find_links }}
    {%- endif %}
    - require:
      - pkg: supervisor_python_packages
    - require:
      - pkg: supervisor_python_packages

  {%- endif %}
{%- else %}

supervisor_package:
  pkg.installed:
    - name: {{ supervisor.pkg }}

{%- endif %}
