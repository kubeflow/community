#!/bin/bash
cd /usr/share/grafana.homebrew
grafana-server -config /etc/grafana.homebrew/grafana.ini cfg:default.paths.data=/var/lib/grafana.homebrew 1>/var/log/grafana.homebrew.log 2>&1
