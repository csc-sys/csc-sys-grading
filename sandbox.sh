#!/bin/zsh -f

if [[ -e /etc/alternatives ]]; then
  alternatives=(--ro-bind /etc/alternatives /etc/alternatives)
fi

bwrap --ro-bind /usr /usr \
      --ro-bind /etc/fonts /etc/fonts \
      --dir /var \
      --symlink ../tmp var/tmp \
      --proc /proc \
      --dev-bind /dev dev \
      --symlink usr/lib /lib \
      --symlink usr/lib64 /lib64 \
      --symlink usr/bin /bin \
      --symlink usr/sbin /sbin \
      --symlink usr/local /local \
      --bind $PWD /tmp \
      --bind /opt /opt \
      --bind /home/prof /home/prof \
      --unshare-all \
      --chdir /tmp/ \
      --uid 1002 \
      --die-with-parent \
      --dir /run/user/$UID \
      --setenv XDG_RUNTIME_DIR "/run/user/$UID" \
      --setenv PS1 "bwrap$ " \
      $alternatives \
      --file 8 /etc/passwd \
      --file 9 /etc/group \
      --chmod 0555 / \
      "$@" \
    8< <(getent passwd $UID 65534) \
    9< <(getent group $GID 65534)
