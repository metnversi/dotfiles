FROM debian:trixie

COPY . /usr/local/share/dotfiles

RUN apt update && apt install -y gawk && bash -x /usr/local/share/dotfiles/security/admin.sh

COPY security/docker/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
