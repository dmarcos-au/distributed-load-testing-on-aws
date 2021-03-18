#!/bin/bash

# set a uuid for the results xml file name in S3
UUID=$(cat /proc/sys/kernel/random/uuid)

echo "S3_BUCKET:: ${S3_BUCKET}"
echo "S3_BUCKET_CONSOLE:: ${S3_BUCKET_CONSOLE}"
echo "TEST_ID:: ${TEST_ID}"
echo "TEST_TYPE:: ${TEST_TYPE}"
echo "PREFIX:: ${PREFIX}"
echo "UUID ${UUID}"
echo "RUN_REPORT:: ${RUN_REPORT}"

run_test() {
  echo "Download test scenario"
  aws s3 cp s3://$S3_BUCKET/test-scenarios/$TEST_ID.json test.json

  # download JMeter jmx file
  if [ "$TEST_TYPE" != "simple" ]; then
    aws s3 cp s3://$S3_BUCKET/public/test-scenarios/$TEST_TYPE/$TEST_ID.jmx ./
    # if a zip has been uploaded that contains the jmeter test and test data
    aws s3 cp s3://$S3_BUCKET/public/test-scenarios/$TEST_TYPE/$TEST_ID.zip ./
    unzip $TEST_ID.zip
    # rename jmeter script to what bzt expects
    echo "renaming jmeter scripts: mv *.jmx $TEST_ID.jmx"
    mv *.jmx $TEST_ID.jmx
  fi

  echo "Running test"
  bzt test.json -o modules.console.disable=true

  # upload custom results to S3 if any
  # every file goes under $TEST_ID/$PREFIX/$UUID to distinguish the result correctly
  if [ "$TEST_TYPE" != "simple" ]; then
    cat $TEST_ID.jmx | grep filename > results.txt
    sed -i -e 's/<stringProp name="filename">//g' results.txt
    sed -i -e 's/<\/stringProp>//g' results.txt
    sed -i -e 's/ //g' results.txt

    echo "Files to upload as results"
    cat results.txt

    files=(`cat results.txt`)
    for f in "${files[@]}"; do
      p="s3://$S3_BUCKET/results/$TEST_ID/JMeter_Result/$PREFIX/$UUID/$f"
      if [[ $f = /* ]]; then
        p="s3://$S3_BUCKET/results/$TEST_ID/JMeter_Result/$PREFIX/$UUID$f"
      fi

      echo "Uploading $p"
      aws s3 cp $f $p
    done
  fi

  echo "Uploading results"
  aws s3 cp /tmp/artifacts/results.xml s3://$S3_BUCKET/results/${TEST_ID}/${PREFIX}-${UUID}.xml
  aws s3 cp /tmp/artifacts/kpi.jtl s3://$S3_BUCKET/results/${TEST_ID}/report-${PREFIX}-${UUID}.jtl
}

run_report() {
    echo "Download test results from s3://${S3_BUCKET}/results/${TEST_ID}"
    aws s3 sync s3://$S3_BUCKET/results/${TEST_ID} .
    ls -al

    echo "setting report granularity to 1 second"
    echo "jmeter.reportgenerator.overall_granularity=1000" >> ~/.bzt/jmeter-taurus/5.2.1/bin/user.properties

    echo "combining reports"
    echo "timeStamp,elapsed,label,responseCode,responseMessage,threadName,success,failureMessage,bytes,sentBytes,grpThreads,allThreads,Latency,Hostname,Connect" > logs.xjtl
    tail -n +2 -q *.jtl >> logs.xjtl

    echo "generting report"
    # TODO: download jmeter manually to avoid hardcoding version in path (which could change)
    ~/.bzt/jmeter-taurus/5.2.1/bin/jmeter -g logs.xjtl -o output

    echo "uploading report to s3://$S3_BUCKET_CONSOLE/console/dashboard/${TEST_ID}/"
    aws s3 sync output s3://$S3_BUCKET_CONSOLE/console/dashboard/${TEST_ID}/

}

if [[ "$RUN_REPORT" =~ "true" ]]
then
    echo "Running report"
      run_report
else
    echo "Running test"
      run_test
fi
