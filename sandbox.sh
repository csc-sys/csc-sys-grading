#!/bin/zsh -f
SET_UID=${SET_UID:-$UID}

if [[ -e /etc/alternatives ]]; then
  alternatives=(--ro-bind /etc/alternatives /etc/alternatives)
fi
java=(/etc/java*(N))
if [[ $java ]]; then
  java=(--bind $java[1] $java[1])
else
  java=()
fi

## unshare-net and unshare-cgroup are disabled as there are labs that require them.
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
      --bind /var/www /var/www \
      --bind /etc/ssl /etc/ssl \
      --bind /etc/pki /etc/pki \
      $java \
      --unshare-user --unshare-ipc --unshare-pid --unshare-uts \
      --chdir /tmp/ \
      --uid $SET_UID \
      --die-with-parent \
      --dir /run/user/$UID \
      --setenv XDG_RUNTIME_DIR "/run/user/$UID" \
      --setenv PS1 "bwrap$ " \
      $alternatives \
      --ro-bind /etc/hosts /etc/hosts \
      --file 8 /etc/passwd \
      --file 9 /etc/group \
      --chmod 0555 / \
      "$@" \
    8< <(getent passwd $SET_UID 65534) \
    9< <(getent group $GID 65534)


#      --bind /sys /sys \
#      --bind /usr/share /usr/share \
#      --bind /usr/lib /usr/lib \
