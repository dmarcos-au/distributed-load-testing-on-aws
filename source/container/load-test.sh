#!/bin/bash

run_test() {
    echo "Download test scenario"
    aws s3 cp s3://$S3_BUCKET/test-scenarios/$TEST_ID.jmx test.jmx

    echo "Running test"
    jmeter -n -t test.jmx -l test_out.jtl

    t=$(python -c "import random;print(random.randint(1, 10))")
    echo "sleep for: $t seconds."
    sleep $t

    echo "Uploading results"
    aws s3 cp test_out.jtl s3://$S3_BUCKET/results/${TEST_ID}_$TEST_RUN/${UUID}.jtl

    echo "Sending message to generate report"
    aws sqs send-message --queue-url $SQS_URL --message-body "{\"testId\": \"${TEST_ID}\", \"taskCount\": 1, \"runReport\": \"true\", \"testRun\": \"${TEST_RUN}\"}"
}

run_report() {
    
    echo "Download test results from s3://${S3_BUCKET}/results/${TEST_ID}_${TEST_RUN}"
    aws s3 sync s3://$S3_BUCKET/results/${TEST_ID}_$TEST_RUN .
    ls -al

    echo "combining reports"
    echo "timeStamp,elapsed,label,responseCode,responseMessage,threadName,dataType,success,failureMessage,bytes,sentBytes,grpThreads,allThreads,URL,Latency,IdleTime,Connect" > logs.xjtl
    tail -n +2 -q *.jtl >> logs.xjtl

    echo "generting report"
    jmeter -g logs.xjtl -o output

    echo "uploading report to S3"
    aws s3 sync output s3://$S3_BUCKET/results/${TEST_ID}_$TEST_RUN/output

    echo "Making folder public"
    aws s3 ls s3://$S3_BUCKET/results/${TEST_ID}_$TEST_RUN/output --recursive | awk '{cmd="aws s3api put-object-acl --acl public-read --bucket $S3_BUCKET --key "$4; system(cmd)}'

}

# set a uuid for the resultsxml file name in S3
UUID=$(cat /proc/sys/kernel/random/uuid)

echo "S3_BUCKET:: ${S3_BUCKET}"
echo "TEST_ID:: ${TEST_ID}"
echo "TEST_RUN ${TEST_RUN}"
echo "UUID ${UUID}"
echo "RUN_REPORT:: ${RUN_REPORT}"
echo "SQS_URL:: ${SQS_URL}"

cd scripts


if [[ "$RUN_REPORT" =~ "true" ]]
then
    echo "Running report"
      run_report
else
    echo "Running test"
      run_test
fi
