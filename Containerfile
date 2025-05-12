ARG FEDORA_MAJOR_VERSION="${FEDORA_VERSION:-42}"

FROM ghcr.io/ublue-os/bazzite-nvidia-open:stable-${FEDORA_MAJOR_VERSION} AS sefirot-base

ARG IMAGE_NAME="${MY_IMAGE_NAME:-sefirot-nvidia}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-butterflysky}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-nvidia}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${SOURCE_IMAGE:-bazzite-nvidia-open}"
ARG FEDORA_MAJOR_VERSION

## Copy system files over
COPY system_files /

## Add infrequently-updated packages

RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    sed -i -e 's@enabled=0@enabled=1@g' \
    /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:bazzite-org:bazzite.repo \
    /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:che:nerd-fonts.repo && \
    rpm-ostree install \
    cfonts \
    direnv \
    evtest \
    fd-find \
    firefox \
    libguestfs-tools \
    nerd-fonts \
    perf \
    powertop \
    strace \
    syncthing \
    virt-install \
    virt-manager \
    virt-viewer \
    zsh \
    zsh-syntax-highlighting && \
    cat /tmp/flatpak_install >> /usr/share/ublue-os/bazzite/flatpak/install && \
    /tmp/cleanup.sh && \
    ostree container commit

FROM sefirot-base AS sefirot-1password

## Add 1password
COPY system_files /
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    /tmp/install-1password.sh && \
    /tmp/cleanup.sh && \
    ostree container commit

## Next: install remaining packages
FROM sefirot-1password AS sefirot-nvidia
ARG FEDORA_MAJOR_VERSION

COPY system_files /
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    /tmp/install-chrome.sh && \
    /tmp/cleanup.sh && \
    ostree container commit
