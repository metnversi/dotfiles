FROM debian:trixie
COPY . /usr/local/share/dotfiles
RUN apt update && apt install -y gawk \
    && bash -x /usr/local/share/dotfiles/security/admin.sh \
    && chmod +x /usr/local/share/dotfiles/security/docker/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/share/dotfiles/security/docker/docker-entrypoint.sh"]
