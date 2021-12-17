#!/bin/sh

rm -r logs
rm -r $HOME/.rsk

java -cp rskj-core-3.1.0-IRIS-all.jar -Drpc.providers.web.cors=* co.rsk.Start --regtest
