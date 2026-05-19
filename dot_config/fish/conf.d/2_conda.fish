# Lazy: defer conda hook + `activate base` until first conda/python/pip/mamba call (~1.8s saved per shell).
if test -f $HOME/miniconda3/bin/conda
    function __load_conda
        functions -e conda python pip mamba __load_conda
        eval $HOME/miniconda3/bin/conda "shell.fish" hook | source
        conda activate base
    end
    function conda;  __load_conda; conda  $argv; end
    function python; __load_conda; python $argv; end
    function pip;    __load_conda; pip    $argv; end
    function mamba;  __load_conda; mamba  $argv; end
else if test -f "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
    . "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
    conda activate base
else if test -d "$HOME/miniconda3/bin"
    set -x PATH $HOME/miniconda3/bin $PATH
end
