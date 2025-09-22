echo "Running $(basename "$0")"

#############################################
#Path sources and other exports
export VISUAL=vim
export EDITOR="$VISUAL"
export ANDROID_HOME=$HOME/adt-bundle-mac-x86_64-20140702/sdk/
export GPG_TTY=$(tty)


export PATH="${LOCAL_USER_HOME}/.local/aws-cli/:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:${LOCAL_USER_BIN}:${LOCAL_USER_GO_BIN}/"
export PATH="$PATH:$HOME/bin/:/usr/local/deployd/bin"
export PATH="/usr/local/opt/ruby/bin:/opt/homebrew/bin/:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/bin:/usr/local/sessionmanagerplugin/bin:$PATH"
export PATH="/opt/homebrew/opt/node@14/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

export PATH="~/office/repos/ovterraform/terraform/terrarun/:~/office/repos/ovterraform/terraform/terrarun/tool_library/:~/office/repos/temp/sessionmanager-bundle/bin:$PATH"
if [ -d "$HOME/.local/bin" ]; then
         PATH="$HOME/.local/bin:$PATH"
fi
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
#for compilers to find node@14 you may need to set:
export ldflags="-l/opt/homebrew/opt/node@14/lib"
export cppflags="-i/opt/homebrew/opt/node@14/include"

if [[ -e ~/.kube ]]; then 

export KUBECONFIG=$(for i in $(find ~/.kube -name "*.yaml") ; do echo -n ":$i"; done | cut -c 2-)
fi