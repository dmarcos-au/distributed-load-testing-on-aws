FROM node:12.14-alpine

RUN apk add --update \
    coreutils=8.31-r0 \
    build-base=0.5-r1 \
    sudo=1.8.31-r0 \
    bash=5.0.11-r1 \
    git=2.24.1-r0 \
    unzip=6.0-r6 \
    libffi-dev=3.2.1-r6 \
    openssl-dev=1.1.1d-r3 \
    python3=3.8.2-r0 \
    python3-dev=3.8.2-r0 \
    py-pip

RUN pip3 install --upgrade pip==20.0.2

RUN pip3 install --no-cache-dir awscli==1.16.77

RUN apk add openjdk11

RUN wget https://apache.mirror.digitalpacific.com.au//jmeter/binaries/apache-jmeter-5.2.1.tgz
RUN tar -xvzf apache-jmeter-5.2.1.tgz
RUN rm apache-jmeter-5.2.1.tgz

RUN mv apache-jmeter-5.2.1 /jmeter

ENV JMETER_HOME /jmeter

# Add Jmeter to the Path
ENV PATH $JMETER_HOME/bin:$PATH


ADD ./load-test.sh /scripts/
RUN chmod 755 /scripts/load-test.sh
ENTRYPOINT ["sh", "-c","./scripts/load-test.sh"]