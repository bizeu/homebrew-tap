#!/bin/sh
# shellcheck disable=SC2046

#
# installs plugins for project in #{name.to_s} remote dev server

set -eu

#META_DIRECTORY="/Users/Shared/JetBrains/plugins/PyCharm/meta"
META_DIRECTORY="#{data[:plugins]}/meta"

ids() {
  find "${META_DIRECTORY}" -mindepth 1 -maxdepth 1 -type f -name "*.json" -exec basename "{}" .json \; | sort -h;
}

list() {
  while read -r id; do
    printf '%s - ' "${id}"; jq -r .name "${META_DIRECTORY}/${id}.json"
  done
}

for arg; do
  shift
  case "${arg}" in
    --all) set -- "$@" $(ids) ; break ;;
    -h|--help|help)
      cat <<EOF
usage: #{remote.basename} /path/to/project --all|<plugin> [<plugin>...]
   or: #{remote.basename} ids
   or: #{remote.basename} names

installs plugins for project in #{name.to_s} remote dev server

commands:
  -h, --help, help        show this help and exit
  ids                     show all IDs of the local installed plugins
  names                   show all IDs and names of the local installed plugins
  <plugin> [<plugin>...]  to install the specified plugins on the remote

options:
  --all                   to install all local plugins on the remote for the project
EOF
      exit 0
      ;;
    ids) ids; exit 0 ;;
    list) ids | list; exit 0 ;;
    *) set -- "$@" "${arg}";;
  esac
done

#{remote_dev_server.to_s} installPlugins "$@"
