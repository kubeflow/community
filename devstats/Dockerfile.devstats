# Dockerfile for devstats
# Based on https://github.com/cncf/devstats/blob/master/INSTALL_UBUNTU17.md
FROM golang:1.11.5

RUN apt-get update -y && \
	apt-get install -y apt-transport-https \
	git psmisc jsonlint yamllint gcc

RUN mkdir -p /go/src 

ENV GOPATH /go

RUN cd ${GOPATH}/src && \
	git clone https://github.com/cncf/devstats.git devstats

RUN go get -u github.com/golang/lint/golint && \
  go get golang.org/x/tools/cmd/goimports

RUN go get github.com/jgautheron/goconst/cmd/goconst && \
	go get github.com/jgautheron/usedexports

RUN go get github.com/kisielk/errcheck && \
	go get github.com/lib/pq

RUN go get golang.org/x/text/transform && \
	go get golang.org/x/text/unicode/norm

RUN go get github.com/google/go-github/github && \
	go get golang.org/x/oauth2

RUN go get gopkg.in/yaml.v2 && \
	go get github.com/mattn/go-sqlite3


# Add /go/src/devstats to the path so that all the binaries will be on the path.
# This is needed by the devstats binary.
ENV PATH $PATH:/etc/gha2db:/${GOPATH}/bin

# Commit c905db8106d057f70a694ecd1276c9e32290152f is master on 02/14.
# Recommendation from Devstats folks was to us master.
RUN cd ${GOPATH}/src/devstats && \
	git checkout c905db8106d057f70a694ecd1276c9e32290152f && \
	make

RUN  cd ${GOPATH}/src/devstats && \
	 make install

# TODO(jlewi): Do we need to fix the userid of postgres so we can run as that user?

# Create postgres user and group with fixed userid and groupid so we can run container as that user.
# 
RUN groupadd -g 1000 postgres && \
	useradd -r -u 1000 -g postgres --create-home --shell=/bin/bash postgres

# Install postgress
#
# This is based on 
# https://github.com/docker-library/postgres/blob/master
RUN apt-get install -y postgresql-client postgresql sudo gosu

# Install emacs
RUN apt-get install -y emacs

# Install Ruby this is used by gitdm
# We set the environment because of this issue
# https://stackoverflow.com/questions/17031651/invalid-byte-sequence-in-us-ascii-argument-error-when-i-run-rake-dbseed-in-ra
ENV RUBYOPT "-KU -E utf-8:utf-8"

RUN apt-get install -y ruby gem
RUN gem install bundle pry octokit

# Keep this in sync with whatever package apt installs; maybe we should pin apt-install?
ENV PG_MAJOR 9.6

# make the sample config easier to munge (and "correct by default")
RUN mv -v "/usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample" /usr/share/postgresql/ \
	&& ln -sv ../postgresql.conf.sample "/usr/share/postgresql/$PG_MAJOR/" \
	&& sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH $PATH:/usr/lib/postgresql/$PG_MAJOR/bin

RUN mkdir -p /home/
COPY postgre-docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/postgre-docker-entrypoint.sh

# Add postgres to the sudoers group because some of the devstats scripts require it
RUN adduser postgres sudo

RUN addgroup --gid 472 grafana && \
	adduser -u 472 --gid=472 grafana

# Workaround for https://github.com/cncf/devstats/issues/166
# devstats code assumes projects.yaml will be et /etc/gha2db
# but we will mount it from NFS
# 
RUN rm -rf /etc/gha2db && \
	ln -sf /mount/data/src/git_kubeflow-community/devstats/config /etc/gha2db

# TODO(jlewi): Per the instructions for devstats we should increase the number of default connections for postgres
