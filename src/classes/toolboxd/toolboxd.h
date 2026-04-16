toolboxd(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/wyxd/$1/g" "${WYX_DIR}/src/classes/toolboxd/toolboxd.class")
    else
        . <(sed "s/wyxd/$1/g" $(dirname ${BASH_SOURCE[0]})/toolboxd.class)
    fi
}