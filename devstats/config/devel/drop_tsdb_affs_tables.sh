#!/bin/bash
if [ -z "$1" ]
then
  echo "$0: need database name argument"
  exit 1
fi
proj=$1
# snum_stats scompany_activity shcom* shpr_comps* ssex ssexcum scountries scountriescum
# sudo -E -u postgres psql $proj -c "drop table snum_stats" || exit 1
# sudo -E -u postgres psql $proj -c "drop table scompany_activity" || exit 2
# sudo -E -u postgres psql $proj -c "drop table ssex" || exit 3
# sudo -E -u postgres psql $proj -c "drop table ssexcum" || exit 4
# sudo -E -u postgres psql $proj -c "drop table scountries" || exit 5
# sudo -E -u postgres psql $proj -c "drop table scountriescum" || exit 6
tables=`sudo -E -u postgres psql $proj -qAntc '\dt' | cut -d\| -f2`
for table in $tables
do
  base1=${table:0:5}
  base2=${table:0:10}
  if ( [ "$base1" = "shcom" ] || [ "$base2" = "shpr_comps" ] )
  then
    sudo -E -u postgres psql $proj -c "drop table $table" || exit 1
    echo "dropped $table"
  fi
done
