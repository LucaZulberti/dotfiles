# CLAUDE.md (utente)

Note persistenti per Claude Code, valide in ogni progetto di questo utente.

## Agente SSH

Se un comando che richiede l'agente SSH (firma di un commit, git push su un remoto ssh, comando ssh verso un altro host) fallisce perche SSH_AUTH_SOCK e assente o non valido, cosa tipica dopo il reattach di una sessione tmux o zellij, provare prima a ripristinarlo con la funzione bash reload-ssh-agent, prima di segnalare il problema:

```
source ~/.bashrc.d/reload-ssh-agent.sh
reload-ssh-agent
```

Poi ritentare il comando originale.

Sorgente della funzione: `dot_bashrc.d/reload-ssh-agent.sh` nel repo chezmoi (https://github.com/LucaZulberti/dotfiles), porting bash di `dot_config/fish/functions/reload-ssh-agent.fish`. Su alcuni server e installata anche a livello di sistema in `/opt/profile.d/reload-ssh-agent.sh`, gia disponibile senza sourcing manuale.
