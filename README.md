# dars-of-unusual-size
Generating DARs of arbitrary size

```./gendaml.sh <template-scale-factor> > daml/Iou.daml```

where <template-scale-factor> indicates number of times to repeat IOU templates

Rough approximation : each repetition is a multiplier on a 20MB dar size

Then run usual daml build
```daml build```

The dar will be output to .daml/dist/...

You can then upload the generated dar to the ledger under test to verify it is processed as expected.

Note that for most ledgers you will need
1) Increase the `--max-inbound-message-size` limit from the default of 4MB (a value of 80MB (80000000) will provide sufficient headroom)
2) Ensure that the running participant server java process has at least 4gb of heap for memory by setting the JAVA_ARGS environment variable
JAVA_ARGS=-Xmx4096m

In docker-compose this can be set as follows:
```
  service:
    image: <participant-server-image>
    environment:
      -  JAVA_ARGS=-Xmx4096m
```
