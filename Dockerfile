#Base image
FROM ubuntu:focal

RUN DEBIAN_FRONTEND=noninteractive ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime

#update the image
RUN apt-get update

#install python
RUN apt install -y python3.8
RUN apt install -y python3-pip

#install robotframework and seleniumlibrary
RUN pip3 install robotframework
RUN pip3 install robotframework-seleniumlibrary

#The followig are needed for Chrome and Chromedriver installation
RUN apt-get install -y xvfb
RUN apt-get install -y zip
RUN apt-get install -y wget
RUN apt-get install ca-certificates
RUN apt-get install -y libnss3-dev libasound2 libxss1 libappindicator3-1 libindicator7 gconf-service \
    libgconf-2-4 libpango1.0-0 xdg-utils fonts-liberation libcurl3-gnutls libcurl3-nss libcurl4 libgbm1
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome*.deb
RUN rm google-chrome*.deb
RUN wget -N http://chromedriver.storage.googleapis.com/80.0.3987.106/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN chmod +x chromedriver
RUN cp /chromedriver /usr/bin
RUN rm chromedriver_linux64.zip

#Robot Specific
#RUN mkdir /robot
#RUN mkdir /results
#ENTRYPOINT ["robot"]

COPY entry_point.sh /opt/bin/entry_point.sh
RUN chmod +x /opt/bin/entry_point.sh

ENV DISPLAY=:99
ENV SCREEN_WIDTH 1280
ENV SCREEN_HEIGHT 720
ENV SCREEN_DEPTH 16

#Install Network shebang
RUN DEBIAN_FRONTEND=noninteractive apt update \
    && apt install -y --no-install-recommends software-properties-common curl gpg-agent \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository -y ppa:ansible/ansible \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" \
    && apt update && apt upgrade -y && apt install -y sshpass \
    && apt -y --no-install-recommends install python3.8 telnet curl openssh-client nano vim-tiny \
    iputils-ping build-essential libssl-dev libffi-dev python3-pip \
    python3-setuptools python3-wheel python3-netmiko net-tools ansible terraform \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install pyntc \
    && pip3 install napalm \
    && mkdir /root/.ssh/ \
    && echo "KexAlgorithms diffie-hellman-group1-sha1,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1" > /root/.ssh/config \
    && echo "Ciphers 3des-cbc,aes128-cbc,aes128-ctr,aes256-ctr" >> /root/.ssh/config \
    && chown -R root /root/.ssh/ \
    && ln -sf /usr/bin/python3.8 /usr/bin/python3

VOLUME [ "/root", "/etc", "/usr" ]

#ENTRYPOINT [ "/opt/bin/entry_point.sh" ]
#CMD [ "sh", "-c", "cd; exec bash -i" ]
ENTRYPOINT [ "/opt/bin/entry_point.sh" ]
