#!/bin/bash

/bin/test -f /apps/mongo/bin/mongod &&\
/bin/test -d /apps/mongodb/ &&\
/bin/test -d /logs/mongo &&\
/bin/test ! -z "$(pgrep mongod)" &&\
/app/mongo/bin/mongod $@
