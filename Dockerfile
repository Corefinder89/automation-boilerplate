FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# Install updates to base image
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install required packages
ENV TZ=Australia/Melbourne
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends software-properties-common \
                       apt-utils \
                       curl \
                       wget \
                       unzip \
                       libxss1 \
                       libappindicator1 \
                       libindicator7 \
                       libasound2 \
                       libgconf-2-4 \
                       libnspr4 \
                       libnss3 \
                       libpango1.0-0 \
                       fonts-liberation \
                       xdg-utils \
                       gpg-agent \
                       git && \
    rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:deadsnakes/ppa

# Install chrome
#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
#RUN apt-get -y update \
#    && apt-get install -y --no-install-recommends google-chrome-stable \
#    && rm -rf /var/lib/apt/lists/*

# Install firefox
RUN apt-get install -y --no-install-recommends firefox

# Install python version 3.0+
RUN add-apt-repository universe
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends python3.8 \
                  python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir app && mkdir drivers

# Copy drivers directory and app module to the machine
COPY app/requirements.txt /app/

# Upgrade pip and Install dependencies
RUN pip3 install --upgrade pip \
                 -r /app/requirements.txt # Install new module GitPython

COPY app /app
COPY drivers /drivers

# Execute test
ADD execute.sh .
RUN chmod +x execute.sh
ENTRYPOINT ["/bin/bash"]
