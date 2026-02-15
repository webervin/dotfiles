

# Added by Toolbox App
export PATH="$PATH:/Users/ervin/Library/Application Support/JetBrains/Toolbox/scripts"


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# following needs to be full path:
export GIT_TRACE2_EVENT="${HOME}/.git/trace2-logs"
[ -d "${GIT_TRACE2_EVENT}" ] || mkdir -p ${GIT_TRACE2_EVENT} 
# Make any export errors visible:
export GIT_TRACE2_DST_DEBUG=1

export BUILDKIT_PROGRESS=plain
