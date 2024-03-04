#!/bin/zsh -f

if [[ -e /etc/alternatives ]]; then
  alternatives=(--ro-bind /etc/alternatives /etc/alternatives)
fi

bwrap --ro-bind /usr /usr \
      --dir /var \
      --symlink ../tmp var/tmp \
      --proc /proc \
      --dev /dev \
      --symlink usr/lib /lib \
      --symlink usr/lib64 /lib64 \
      --symlink usr/bin /bin \
      --symlink usr/sbin /sbin \
      --symlink usr/local /local \
      --bind $PWD /tmp \
      --bind /opt /opt \
      --chdir /tmp \
      --unshare-all \
      --die-with-parent \
      --dir /run/user/$UID \
      --setenv XDG_RUNTIME_DIR "/run/user/$UID" \
      --setenv PS1 "bwrap$ " \
      $alternatives \
      --file 8 /etc/passwd \
      --file 9 /etc/group \
      "$@" \
    8< <(getent passwd $UID 65534) \
    9< <(getent group $GID 65534)
