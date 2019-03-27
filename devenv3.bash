#!/bin/bash

DEVENV3_VERSION="0.2beta"
DEVENV3_MAINTAINER_EMAIL="lekomtsev@unix-mastery.ru"

DEVENV3_APP_DIR="${HOME}/www"
DEVENV3_HOME_DIR=$(dirname $(realpath "${0}"))
DEVENV3_FILENAME=$(basename "${0}")

DEVENV3_ALIASES=("de3" "denv3" "devenv3")
DEVENV3_ALIAS="${_devenv3_alias:-${DEVENV3_FILENAME}}"

BASHRC_PATH="${HOME}/.bashrc"

function _print {
  local print_type="${1}"
  shift

  if [[ -z "${1}" ]]; then
    return 0
  fi

  case "${print_type}" in
    "info" )
      for info_message in "${@}"; do
        printf "!!! ${info_message}\n"
      done
      echo
      ;;
    "progress" )
      for progress_message in "${@}"; do
        printf "[*] ${progress_message} ...\n"
      done
      ;;
    * )
      {
        local ident="!!! ${print_type^^}:"
        local ident_length="${#ident}"
        echo
        for error_message in "${@}"; do
          printf "%-${ident_length}s %s\n" "${ident}" "${error_message}"
          ident=""
        done
        echo
      } >&2
      ;;
  esac
}

function error {
  _print error "${@}"
  exit 1
}

function info {
  _print info "${@}"
}

function internal {
  _print internal \
    "Problem in '${FUNCNAME[2]}' -> '${FUNCNAME[1]}' function call at ${BASH_LINENO[1]} line:" \
    "${@}"
  exit 2
}

function progress {
  _print progress "${@}"
}

function warning {
  _print warning "${@}"
  exit 0
}

function run {
  local command="${1}"

  if [[ -z "${command}" ]]; then
    internal "Function parameters needs to be specified"
  fi

  command_type="$(type -t "${command}")"
  if [[ "${command_type}" == "file" ]]; then
    shift
    "${command}" "${@}" \
      || error "Failed of '${command}' command running" \
               "Please check and try again, or address the administrator"
  elif [[ -z "${command_type}" ]]; then
    error \
      "The command '${command}' must be exists at your system" \
      "Please install it from the package manager of your OS"
  else
    internal "The specified command '${command}' needs to be 'file' type, not '${command_type}'"
  fi
}

function run_inside_de3 {
  pushd "${DEVENV3_HOME_DIR}" >/dev/null
  run "${@}"
  popd >/dev/null
}

function main_footer {
  cat <<END_INFO

Development Environment 3 v${DEVENV3_VERSION}
Any questions please send to: ${DEVENV3_MAINTAINER_EMAIL}

DevEnv3 home directory: ${DEVENV3_HOME_DIR}
Applications directory: ${DEVENV3_APP_DIR}

END_INFO
}

function command_build {
  if [[ "${1}" == "description" ]]; then
    echo "Build Docker images for the DevEnv3 running"
    return 0
  fi

  info \
    "This command run a building of Docker images used in this environment" \
    "It can take some time"

  progress "Starting 'docker-compose build' command"
  run_inside_de3 \
    docker-compose build
  progress "Done"
}

function command_down {
  if [[ "${1}" == "description" ]]; then
    echo "Destroy containers and other Docker things of the DevEnv3 (situable for a upgrading)"
    return 0
  fi

  progress "Starting 'docker-compose down' command"
  run_inside_de3 \
    docker-compose down
  progress "Done"
}

function command_help {
  if [[ "${1}" == "description" ]]; then
    echo "Print this help"
    return 0
  fi

  echo "Usage:"
  for devenv3_alias in ${DEVENV3_ALIASES[@]}; do
    echo "  ${devenv3_alias} COMMAND [OPTIONS]"
  done
  echo
  echo "Commands:"
  for function_name in $(compgen -A function); do
    if [[ "${function_name}" =~ ^command_ ]]; then
      printf "  %-10s %s\n" "${function_name#command_}" "$(${function_name} description)"
    fi
  done
  echo
  echo "Run '${DEVENV3_ALIAS} COMMAND --help' for more information on a command."
  echo
  exit 0
}

function command_init {
  if [[ "${1}" == "description" ]]; then
    echo "Append DevEnv3 aliases to .bashrc and other initializations"
    return 0
  fi

  local begin_string="### DevEnv3 aliases BEGIN ###"
  local end_string="### DevEnv3 aliases END ###"
  local devenv3_env_filepath="${DEVENV3_HOME_DIR}/.env"

  progress "Creating Applications directory"
  run mkdir --parents \
    "${DEVENV3_APP_DIR}"

  progress "Writing ${devenv3_env_filepath} file"
  {
    echo "USER_ID=`id --user`"
    echo "GROUP_ID=`id --group`"
  } > "${devenv3_env_filepath}"

  progress "Appending DevEnv3 aliases to ${BASHRC_PATH}"
  run sed --in-place \
    "/${begin_string}/,/${end_string}/d" \
    "${BASHRC_PATH}"
  {
    echo "${begin_string}"
    for devenv3_alias in ${DEVENV3_ALIASES[@]}; do
      echo "alias ${devenv3_alias}=\"_devenv3_alias=${devenv3_alias} /bin/bash \\\"${DEVENV3_HOME_DIR}/${DEVENV3_FILENAME}\\\"\""
    done
    echo "${end_string}"
  } >> "${BASHRC_PATH}"

  progress "Done"

  warning "To work of DevEnv3 aliases properly the '.bashrc' file need to be re-read" \
          "Please run another copy of terminal OR run this command: source ${BASHRC_PATH}"
}

function command_ls {
  if [[ "${1}" == "description" ]]; then
    echo "List all projects in Applications directory"
    return 0
  fi

  local project_{name,path,php,index}
  local index_{dir,file,php}

  printf "%-30s %3s %30s\n" "PROJECT NAME" "PHP" "SELECTED INDEX FILE"
  for project_path in "${DEVENV3_APP_DIR}/"*; do
    if [[ ! -d "${project_path}" ]]; then
      continue
    fi

    project_name="${project_path##*/}"

    project_php="5.6"
    for index_php in "7.1" "7.2"; do
      if [[ -f "${project_path}/.profile_php${index_php}" ]]; then
        project_php="${index_php}"
      fi
    done

    for index_dir in "" "web" "api/web" "public"; do
      if [[ -d "${project_path}/${index_dir}" ]]; then
        project_index="${index_dir}"
      fi
    done

    for index_file in "index.htm" "index.html" "index.php" ""; do
      if [[ -f "${project_path}/${project_index}/${index_file}" ]]; then
        project_index+="/${index_file}"
        break
      fi
    done

    if [[ -z "${index_file}" ]]; then
      project_index="not found"
    fi

    printf "%-30s %3s %30s\n" "${project_name}/" "${project_php}" "${project_index}"
  done
}

function command_run {
  if [[ "${1}" == "description" ]]; then
    echo "Run any command inside the DevEnv3 (for example: composer, php and etc)"
    return 0
  fi

  local command="${1}"
  if [[ -z "${command}" || "${command}" == "--help" ]]; then
    warning \
      "Please specify a running command" \
      "Usage: ${DEVENV3_ALIAS} ${command_name} <command>"
  fi

  shift
  local pwd_rel_dir="${PWD#${DEVENV3_APP_DIR}/}"
  if [[ "${PWD}" == "${pwd_rel_dir}" ]]; then
    error "The '${DEVENV3_ALIAS} ${command_name}' command must be runned inside any Project directory!"
  fi

  local project_name="${pwd_rel_dir%%/*}"
  local php_version="56"
  if [[ -f "${DEVENV3_APP_DIR}/${project_name}/.profile_php7.1" ]]; then
    php_version="71"
  elif [[ -f "${DEVENV3_APP_DIR}/${project_name}/.profile_php7.2" ]]; then
    php_version="72"
  fi

  local container_name="php-fpm-${php_version}"
  progress "Checking of existing the '${container_name}' container"
  # The docker-compose v1.12.0 '-q' flag have only
  local container_id="$(run_inside_de3 docker-compose ps -q "${container_name}")"
  if [[    -z "${container_id}" \
        || -z "$(run docker ps --quiet \
                               --filter "status=running" \
                               --filter "id=${container_id}")" ]]; then
    error \
      "The necessary container have not 'running' state" \
      "Please run the DevEnv3 by '${DEVENV3_ALIAS} up' command"
  fi

  progress "Run a '${command}' command at project '${project_name}' using '${container_name}' container"
  # Use exec direct from docker to avoid a problem with BASH "${@}" expansion
  # Because with docker-compose command it is necessary to use next command:
  # /bin/sh -c "cd /www/${pwd_rel_dir}; ${command} ${@}"
  # 1. Hack with WORKDIR is using because Setting workdir for exec is not supported in API < 1.35 (1.22)
  # 2. This form of ${@} expanded only one parameter :(
  run_inside_de3 \
    docker exec \
      --interactive \
      --tty \
      --user www-data \
      --workdir "/www/${pwd_rel_dir}" \
      "${container_id}" \
      "${command}" "${@}"
}

function command_up {
  if [[ "${1}" == "description" ]]; then
    echo "Run the DevEnv3"
    return 0
  fi

  info \
    "The Development Environment will run in a foreground (with a realtime log printing)" \
    "For stop it please press CTRL-C"

  info \
    "For access to your projects please type in the browser:" \
    "http://<project_name>.localhost"

  progress "Starting 'docker-compose up' command"
  run_inside_de3 \
    docker-compose up
  progress "Done"
}

main_footer

command_name="${1:-help}"
if ! declare -F "command_${command_name}" >/dev/null; then
  command_name="help"
fi

shift
command_${command_name} "${@}"
