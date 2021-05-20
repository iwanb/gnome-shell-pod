ARG fedora_version=32
FROM fedora:${fedora_version}

RUN dnf update -y &&                                                                     \
    dnf install -y gnome-session-xsession gnome-extensions-app \
                   sudo xorg-x11-server-Xvfb xdotool glib2-devel patch jq unzip

COPY systemd /etc/systemd

# Start Xvfb via systemd on display :99.
# Add the gnomeshell user with no password.
RUN systemctl enable xvfb@:99.service && \
    systemctl set-default multi-user.target && \
    adduser -m -U -G users,adm,wheel gnomeshell && \
    echo "gnomeshell     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    sudo -u gnomeshell systemctl enable --user gnome-xsession@:99

# Add the scripts.
COPY enable-extension.sh set-env.sh /home/gnomeshell/

CMD [ "/usr/sbin/init", "systemd.unified_cgroup_hierarchy=0" ]
