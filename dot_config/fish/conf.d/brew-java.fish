if not set -q JAVA_HOME; and type -q brew
    set -l prefix (brew --prefix openjdk 2>/dev/null)
    if test -d "$prefix"
        if test -d "$prefix/libexec/openjdk.jdk/Contents/Home"
            set -Ux JAVA_HOME "$prefix/libexec/openjdk.jdk/Contents/Home"
        else
            set -Ux JAVA_HOME "$prefix"
        end
        fish_add_path $JAVA_HOME/bin
    end
end
