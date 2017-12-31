{%- from "supervisor/map.jinja" import supervisor with context %}

supervisor_packages:
  pkg.installed:
    - pkgs: {{ supervisor.pkgs }}
