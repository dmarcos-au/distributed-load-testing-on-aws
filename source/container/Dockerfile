FROM node:12.14-alpine

RUN apk add --update \
    coreutils \
    build-base \
    sudo \
    bash \
    git \
    unzip \
    libffi-dev \
    openssl-dev \
    python3 \
    python3-dev \
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
