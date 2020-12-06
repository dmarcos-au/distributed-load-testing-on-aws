FROM blazemeter/taurus
# taurus includes python and pip
RUN /usr/bin/python3 -m pip install --upgrade pip
RUN pip install --no-cache-dir awscli
# Taurus working directory  = /bzt-configs
ADD ./load-test-v2.sh /bzt-configs/
RUN chmod 755 /bzt-configs/load-test-v2.sh
ENTRYPOINT ["sh", "-c","./load-test-v2.sh"]
