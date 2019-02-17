# devstats installation on Ubuntu

Prerequisites:
- Ubuntu 18.04.
- [golang](https://golang.org).
    - `apt-get update`
    - `sudo locale-gen "en_US.UTF-8"`
    - Add to `/etc/environment`:
    ```
    LC_ALL=en_US.UTF-8
    LANG=en_US.UTF-8
    ```
    - Check if language/locale settings are ok: `perl -e exit`.
    - `apt install golang` - this installs Go 1.10.1.
    - `apt install git psmisc jsonlint yamllint gcc`
    - `mkdir /data; mkdir /data/dev`
1. Configure Go:
    - For example add to `~/.bash_profile`:
     ```
     GOPATH=/data/dev; export GOPATH
     PATH=$PATH:$GOPATH/bin; export PATH
     ```
    - Logout and login again.
    - [golint](https://github.com/golang/lint): `go get -u github.com/golang/lint/golint`
    - [goimports](https://godoc.org/golang.org/x/tools/cmd/goimports): `go get -u golang.org/x/tools/cmd/goimports`
    - [goconst](https://github.com/jgautheron/goconst): `go get -u github.com/jgautheron/goconst/cmd/goconst`
    - [usedexports](https://github.com/jgautheron/usedexports): `go get -u github.com/jgautheron/usedexports`
    - [errcheck](https://github.com/kisielk/errcheck): `go get -u github.com/kisielk/errcheck`
    - If you want to use ElasticSearch output: [elastic](https://github.com/olivere/elastic): `go get -u github.com/olivere/elastic`.
2. Go to `$GOPATH/src/` and clone devstats there:
    - `git clone https://github.com/cncf/devstats.git`, cd `devstats`
    - Set reuse TCP connections: `./cron/net_tcp_config.sh`
4. Go to devstats directory, so you are in `~/dev/go/src/devstats` directory and compile binaries:
    - `make`
5. If compiled sucessfully then execute test coverage that doesn't need databases:
    - `make test`
    - Tests should pass.
6. Install binaries & metrics:
    - `sudo make install` or `make install` as root.
7. Install Postgres database ([link](https://gist.github.com/sgnl/609557ebacd3378f3b72)):
    - `apt install postgresql`.
    - `devstats` repo directory must be available for postgres user. `chmod -R ugo+r /data/`.
    - `sudo -i -u postgres`, `psql` and as root `sudo -u postgres psql` to test installation.
    - Postgres only allows local connections by default so it is secure, we don't need to disable external connections:
    - Config file is: `/etc/postgresql/10/main/pg_hba.conf`, instructions to enable external connections (not recommended): `http://www.thegeekstuff.com/2014/02/enable-remote-postgresql-connection/?utm_source=tuicool`
    - Set bigger maximum number of connections, at least 4x number of your CPU cores or more: `/etc/postgresql/10/main/postgresql.conf`. Default is 100. `max_connections = 300`.
    - You can also set `shared_buffers = ...` to something like 25% of your RAM. This is optional.
    - `service postgresql restart`
    - `swapoff -a` and remove any swap from `/etc/fstab`.
8. Clone `devstats-example`. It demonstrates DevStats setup for a `github.com/homebrew` org.
    - `git clone https://github.com/cncf/devstats-example.git`, cd `devstats`
    - See `SETUP_OTHER_PROJECT.md` to see how to enable DevStats on your own project.
9. Install Grafana.
    - Go to: `https://grafana.com/grafana/download`. Prefer newest nightly build for your arch.
    - `wget https://s3-us-west-2.amazonaws.com/grafana-releases/master/grafana_5.x.x_amd64.deb`.
    - `sudo dpkg -i grafana_5.x.x_amd64.deb`
    - `service grafana-server stop` - stop default Grafana, we only need it as a source of configuration, binaries etc.
10. Run automatic deploy
    - `PG_PASS=... PG_PASS_RO=... PG_PASS_TEAM=... ./deploy.sh`.
    - You can also take a look at DevStats' `ADDING_NEW_PROJECT.md` file for more info about setting up new projects.
    - You should end up with Grafana running on port 3001 on your server's IP: `http://X.Y.Z.V:3001`.
    - This deployment uses `147.75.105.130:3001`.
11. Configure Grafana
    - Login as "admin/admin" to `http://X.Y.Z.V:3001`, change password to something more secure.
    - Choose "Add data source" or Configuration -> data sources, then add PostgreSQL DB with those settings:
    - Name "psql", Type "PostgreSQL", host "127.0.0.1:5432", database "your_project" (`homebrew` in this case), user "ro_user" (this is the select-only user for psql), password you used for `PG_PASS_RO`, ssl-mode "disabled".
    - Run `devel/put_all_charts.sh`, then go to Home -> Manage: select "Dashboards" dashboard, and click star icon to make it favorite.
    - Go to Configuration -> Preferences, change Organization name to "Your project" - this will allow anonymous access, change "Home dashboard" to "Dashboards".
    - Go to User -> Preferences and and set Home dashboard to "Dashboards" (you can only choose from favorites).
    - Sign out and ten remove `/login` part from the redirected URL. You should be able to access dashboards as an anonymous user.
    - If all is fine, cleanup local Grafana DB copies: `Run `devel/put_all_charts_cleanup.sh`.
    - If you have modified dashboards on the Grafana UI, download them as JSONs: `./devel/get_all_sqlite_jsons.sh`.
    - cp devstats.sh $GOPATH/bin/
    - You can use `crontab` file as an example of enabling hourly cron sync: `crontab -e`
