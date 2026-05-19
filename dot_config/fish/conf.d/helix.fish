if type -q npm; and not set -q NODE_MODULES_GLOBAL
    set -Ux NODE_MODULES_GLOBAL (npm root -g)
end

if type -q hx
    set -gx EDITOR hx
end
