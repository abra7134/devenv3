#!/usr/bin/env bash

DEVENV3_VERSION="0.4beta"
DEVENV3_MAINTAINER_EMAIL="lekomtsev@unix-mastery.ru"

DEVENV3_APP_DIR="${HOME}/www"
DEVENV3_APP_DOMAIN="localhost"
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
      local info_message
      for info_message in "${@}"; do
        printf "!!! ${info_message}\n"
      done
      echo
      ;;
    "progress" )
      local progress_message
      for progress_message in "${@}"; do
        printf "[*] ${progress_message} ...\n"
      done
      ;;
    * )
      {
        local ident="!!! ${print_type^^}:"
        local ident_length="${#ident}"
        echo
        local error_message
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

  local command_type="$(type -t "${command}")"
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
    docker-compose build "${@}"
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

  local devenv3_alias
  for devenv3_alias in ${DEVENV3_ALIASES[@]}; do
    echo "  ${devenv3_alias} COMMAND [OPTIONS]"
  done
  echo
  echo "Commands:"
  local function_name
  for function_name in $(compgen -A function); do
    if [[ "${function_name}" =~ ^command_ ]]; then
      printf "  %-10s %s\n" "${function_name#command_}" "$(${function_name} description)"
    fi
  done
  echo
  echo "Run '${DEVENV3_ALIAS} COMMAND --help' for more information on a command (IN A FUTURE RELEASE)."
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

  progress "Writing '${devenv3_env_filepath}' file"
  {
    echo "USER_ID=`id --user`"
    echo "GROUP_ID=`id --group`"
  } > "${devenv3_env_filepath}" \
    || error "Failed to write file"

  if [ -f "${BASHRC_PATH}" ]; then
    progress "Appending DevEnv3 aliases to '${BASHRC_PATH}'"
    run sed --in-place \
      "/${begin_string}/,/${end_string}/d" \
      "${BASHRC_PATH}"
  elif [ ! -h "${BASHRC_PATH}" -a ! -e "${BASHRC_PATH}" ]; then
    progress "Writing DevEnv3 aliases to '${BASHRC_PATH}'"
  else
    error "Failed to write '${BASHRC_PATH}' because it's not a regular file"
  fi
  {
    echo "${begin_string}"
    local devenv3_alias
    for devenv3_alias in ${DEVENV3_ALIASES[@]}; do
      echo "alias ${devenv3_alias}=\"_devenv3_alias=${devenv3_alias} /usr/bin/env bash \\\"${DEVENV3_HOME_DIR}/${DEVENV3_FILENAME}\\\"\""
    done
    echo "${end_string}"
  } >> "${BASHRC_PATH}" \
    || error "Failed to write file"

  progress "Done"

  warning "To work of DevEnv3 aliases properly the '.bashrc' file need to be re-read" \
          "Please run another copy of terminal OR run this command: source ${BASHRC_PATH}"
}

function command_ls {
  if [[ "${1}" == "description" ]]; then
    echo "List all installed applications"
    return 0
  fi

  local print_format="%-20s %-40s %-2s %-20s %-20s %-12s %-10s\n"
  printf "${print_format}" \
    "NAME" "URL" "TP" "HOME" "INDEX FILE" "PHP" "BRANCH"

  local app_{branch,dir,home,index_file,name,php_version,type,url}
  local index_{dir,file}
  for app_dir in "${DEVENV3_APP_DIR}/"*; do
    if [[    ! -d "${app_dir}" \
          && ! -h "${app_dir}" ]]; then
      continue
    fi

    app_name="${app_dir##*/}"

    case "${app_name}" in
      "catchall" )
        app_url="http://*.${DEVENV3_APP_DOMAIN}/"
        ;;
      "default" )
        app_url="http://${DEVENV3_APP_DOMAIN}/"
        ;;
      * )
        app_url="http://${app_name}.${DEVENV3_APP_DOMAIN}/"
        ;;
    esac

    app_home=$(
      run realpath \
        --relative-base="${DEVENV3_APP_DIR}" \
        "${app_dir}"
    )

    app_branch="-"
    app_index_file="-"
    app_type=""
    app_php_version="-"

    # Don't process application if realdir begin with / that is OUTSIDE applications directory
    if [[ "${app_home::1}" == "/" ]]; then
      app_home="(OUTSIDE)"
    # And also if resolved directory is not exists
    elif [[ ! -d "${DEVENV3_APP_DIR}/${app_home}" ]]; then
      app_home="(MISSING)"
    else
      if [[ "${app_name}" == "${app_home}" ]]; then
        app_type="=="
      else
        app_type="->"
      fi

      # Overwrite a app_dir with real directory
      app_dir="${DEVENV3_APP_DIR}/${app_home}"
      # For a pretty printing
      app_home+="/"

      for app_php_version in "7.2" "7.1" "5.6"; do
        if [[ -f "${app_dir}/.profile_php${app_php_version}" ]]; then
          break
        fi
      done
      if [[ -f "${app_dir}/.profile_xdebug" ]]; then
        app_php_version+="+xdebug"
      fi

      for index_dir in "public/" "api/web/" "web/" ""; do
        if [[ -d "${app_dir}/${index_dir}" ]]; then
          break
        fi
      done
      for index_file in "index.htm" "index.html" "index.php" ""; do
        if [[ -f "${app_dir}/${index_dir}${index_file}" ]]; then
          break
        fi
      done
      if [[ -z "${index_file}" ]]; then
        app_index_file="(NOT FOUND)"
      else
        app_index_file="${index_dir}${index_file}"
      fi

      index_dir="${app_dir}"
      # Walk to all upper directories when a searching of branch name like 'hg' command :)
      while [[ "${index_dir}" != "${DEVENV3_APP_DIR}" ]]; do
        if [[ -s "${index_dir}/.hg/branch" ]]; then
          read app_branch <"${index_dir}/.hg/branch"
          break
        fi
        index_dir="${index_dir%/*}"
      done
    fi

    printf "${print_format}" \
      "${app_name}" \
      "${app_url}" \
      "${app_type}" \
      "${app_home}" \
      "${app_index_file}" \
      "${app_php_version}" \
      "${app_branch}"
  done

  echo
  info "Legend:" \
       "  TP - type of application: '->' is alias, '==' is a direct transformation of an application name to a folder name"
}


function command_rm {
  if [[ "${1}" == "description" ]]; then
    echo "Remove unnecessary applications or their aliases"
    return 0
  fi

  local command="${1}"
  if [[ -z "${command}" || "${command}" == "--help" ]]; then
    warning \
      "Please specify applications which must be removed" \
      "Usage: ${DEVENV3_ALIAS} ${command_name} <application_name1> [application_name2]..."
  fi

  local app_{dir,home,name}
  for app_name in "${@}"; do
    app_dir="${DEVENV3_APP_DIR}/${app_name}"

    if [ -h "${app_dir}" ]; then
      app_home=$(
        run realpath \
          --relative-base="${DEVENV3_APP_DIR}" \
          "${app_dir}"
      )

      # Remove an alias only at inside of DEVENV3_APP_DIR directory
      if [[ "${app_home::1}" != "/" ]]; then
        progress "Remove an alias '${app_name}' of '${app_home}' application"
        run rm "${app_dir}"
      fi

    elif [ -d "${app_dir}" ]; then
      progress "Remove an application '${app_name}'"
      run rm --recursive "${app_dir}"
    fi
  done

  progress "Done"
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
      "Usage: ${DEVENV3_ALIAS} ${command_name} <command> [parameters]"
  fi

  shift
  local pwd_rel_dir="${PWD#${DEVENV3_APP_DIR}/}"
  if [[ "${PWD}" == "${pwd_rel_dir}" ]]; then
    error "The '${DEVENV3_ALIAS} ${command_name}' command must be runned inside any application directory!"
  fi

  command_run_at "${pwd_rel_dir}" "${command}" "${@}"
}

function command_run_at {
  if [[ "${1}" == "description" ]]; then
    echo "Run any command at selected application inside the DevEnv3 (for example: composer, php and etc)"
    return 0
  fi

  local app_path="${1}"
  if [[ -z "${app_path}" ]]; then
    warning \
      "Please specify an application name where the command will run" \
      "Usage: ${DEVENV3_ALIAS} ${command_name} <application_name> <command> [parameters]"
  fi

  shift
  local app_name="${app_path%%/*}"
  local app_dir="${DEVENV3_APP_DIR}/${app_name}"
  if [[ ! -d "${app_dir}" ]]; then
    error \
      "The specified '${app_name}' application is not exists, please check and try again" \
      "To view list of all installed applications please use the command:" \
      "$ de3 ls"
  fi

  local command="${1}"
  if [[ -z "${command}" || "${command}" == "--help" ]]; then
    warning \
      "Please specify a running command" \
      "Usage: ${DEVENV3_ALIAS} ${command_name} <application_name> <command> [parameters]"
  fi
  shift

  local app_php_version
  for app_php_version in "7.2" "7.1" "5.6"; do
    if [[ -f "${app_dir}/.profile_php${app_php_version}" ]]; then
      break
    fi
  done

  local container_name="php-fpm-${app_php_version/./}"  # With remove a . (dot) from php version
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

  progress "Run a '${command}' command at application '${app_name}' using '${container_name}' container"
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
      --workdir "/www/${app_path}" \
      "${container_id}" \
      "${command}" "${@}"
}

function command_set_at {
  if [[ "${1}" == "description" ]]; then
    echo "Set any parameters at selected application (for example: PHP version, enable/disable Xdebug, ...)"
    return 0
  fi

  local app_path="${1}"
  if [[ -z "${app_path}" ]]; then
    warning \
      "Please specify an application name where set parameters" \
      "Usage: ${DEVENV3_ALIAS} ${command_name} <application_name> <parameter_name> <parameter_value>"
  fi

  local app_name="${app_path%%/*}"
  local app_dir="${DEVENV3_APP_DIR}/${app_name}"
  if [[ ! -d "${app_dir}" ]]; then
    error \
      "The specified '${app_name}' application is not exists, please check and try again" \
      "To view list of all installed applications please use the command:" \
      "$ de3 ls"
  fi

  shift
  local parameter_name="${1}"
  local parameter_value="${2}"
  case "${parameter_name}" in
    "alias" | "Alias" | "ALIAS" )
      if [[ ! "${parameter_value}" =~ ^[-a-zA-Z0-9]+$ ]]; then
        error "Please specify a correct alias name with symbols 'a-z' and digits '0-9' only supported"
      fi

      local app_alias_path="${DEVENV3_APP_DIR}/${parameter_value}"
      if [[ -d "${app_alias_path}" ]]; then
        error "The application '${parameter_value}' is already exists, an alias creation is impossible, skipping"
      elif [[ -h "${app_alias_path}" ]]; then
        error "The alias '${parameter_value}' is already exists, please specify an another name"
      fi

      if [[ -h "${app_dir}" ]]; then
        local app_home=$(
          run realpath \
            --relative-base="${DEVENV3_APP_DIR}" \
            "${app_dir}"
        )
        progress "Create a symlink '${parameter_value}' -> '${app_path}' (which is alias to '${app_home}')"
      else
        progress "Create a symlink '${parameter_value}' -> '${app_path}'"
      fi

      run ln --symbolic \
        "${app_path}" \
        "${app_alias_path}"

      progress "Done"
      ;;
    "php" | "Php" | "PHP" )
      if [[ ! "${parameter_value}" =~ ^(5\.6|7\.1|7\.2)$ ]]; then
        error "Please specify a correct version of PHP-interpreter: '5.6', '7.1' or '7.2' only supported"
      fi

      local app_php_version
      local app_php_profile_file
      for app_php_version in "7.2" "7.1" "5.6"; do
        app_php_profile_file="${app_dir}/.profile_php${app_php_version}"
        if [[ -f "${app_php_profile_file}" ]]; then
          break
        fi
      done

      if [[ "${parameter_value}" == "${app_php_version}" ]]; then
        warning "The application '${app_name}' has already use PHP ${app_php_version} version, skipping..."
      fi

      if [[ "${app_php_version}" != "5.6" ]]; then
        progress "Remove the old '${app_php_profile_file}' file"
        run rm --force \
          "${app_php_profile_file}"
      fi

      if [[ "${parameter_value}" != "5.6" ]]; then
        app_php_profile_file="${app_dir}/.profile_php${parameter_value}"
        progress "Write the new '${app_php_profile_file}' empty file"
        run touch \
          "${app_php_profile_file}"
      fi

      progress "Done"
      ;;
    "xdebug" | "Xdebug" | "XDEBUG" )
      if [[ ! "${parameter_value}" =~ ^(on|On|ON|off|Off|OFF)$ ]]; then
        error "Please specify a correct value of parameter: 'on' and 'off' only supported"
      fi

      local app_php_xdebug="off"
      local app_php_xdebug_file="${app_dir}/.profile_xdebug"
      if [[ -f "${app_php_xdebug_file}" ]]; then
        app_php_xdebug="on"
      fi

      # Compared with a lowest case version of ${parameter_value}
      case "${app_php_xdebug} -> ${parameter_value,,}" in
        "on -> on" )
          warning "The application '${app_name}' already use XDebug extension, skipping..."
          ;;
        "off -> off" )
          warning "The application '${app_name}' already don't use XDebug extension, skipping..."
          ;;
        "on -> off" )
          progress "Remove the old '${app_php_xdebug_file}' file"
          run rm --force \
            "${app_php_xdebug_file}"
          ;;
        "off -> on" )
          progress "Write the new '${app_php_xdebug_file}' empty file"
          run touch \
            "${app_php_xdebug_file}"
          ;;
      esac

      progress "Done"
      ;;
    * )
      warning \
        "Please specify a parameter and its value which will be set" \
        "Usage: ${DEVENV3_ALIAS} ${command_name} <application_name> <parameter_name> <parameter_value>" \
        "" \
        "Parameters:  alias <alias_name>  Set an alias (alternavite name)" \
        "             php (5.6|7.1|7.2)   Set a version of PHP-interpreter which will be used" \
        "             xdebug (on|off)     Enable or disable usage XDebug extension with PHP"
      ;;
  esac

}

function command_up {
  if [[ "${1}" == "description" ]]; then
    echo "Run the DevEnv3 (with preliminary run of the 'down' command)"
    return 0
  fi

  info \
    "The Development Environment will run in a foreground (with a realtime log printing)" \
    "For stop it please press CTRL-C"

  info \
    "For access to your applications please type in the browser:" \
    "http://<application_name>.localhost"

  progress "Starting 'docker-compose down' command"
  run_inside_de3 \
    docker-compose down
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
