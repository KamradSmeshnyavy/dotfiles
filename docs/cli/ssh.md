# SSH

[🇷🇺 Русский](ssh.ru.md)

The SSH client config.

## Paths

- **In the repo:** `cli/ssh`
- **Linked to:** `~/.ssh`

## What differs from the defaults

- Global settings (`Host *`):
  - language variables are forwarded (`LANG`, `LC_*`);
  - agent forwarding on (`ForwardAgent yes`), X11 forwarding off;
  - `ServerAliveInterval 15`, `ConnectTimeout 20`.
- A `bastion` host alias with a preset key, user and address.
