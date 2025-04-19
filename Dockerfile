FROM python:3.13.2-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    # To set up the PPA
    wget/stable \
    # To have a virtual screen
    xvfb/stable \
    # To install the Chromedriver
    unzip=6.0-28 \
    # To add apt-key
    gnupg=2.2.40-1.1 \
    # To run the tests as the user: selenium when development
    sudo=1.9.13p3-1+deb12u1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
# See:
# - Dockerfile with chromedriver
#   https://gist.github.com/varyonic/dea40abcf3dd891d204ef235c6e8dd79
# - Linux Software Repositories – Google
#   https://www.google.com/linuxrepositories/
# Set up the Chrome PPA
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# Update the package list and install chrome
RUN apt-get update && apt-get install -y --no-install-recommends google-chrome-stable/stable \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_VERSION=133.0.6943.126
ENV CHROMEDRIVER_DIR=/chromedriver
RUN mkdir $CHROMEDRIVER_DIR \
# - Chrome for Testing availability
#   https://googlechromelabs.github.io/chrome-for-testing/
 && wget -q --continue -P $CHROMEDRIVER_DIR https://storage.googleapis.com/chrome-for-testing-public/$CHROMEDRIVER_VERSION/linux64/chromedriver-linux64.zip \
 && unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR
# Put Chromedriver into the PATH
ENV PATH=$CHROMEDRIVER_DIR:$PATH
WORKDIR /workspace
RUN groupadd -g 1000 selenium \
 && useradd -m -s /bin/bash -u 1000 -g 1000 selenium \
 && install -d -o selenium -g root /workspace/.selenium-cache \
 # For development
 && pip --no-cache-dir install uv==0.6.14
USER selenium
RUN  pip --no-cache-dir install --user uv==0.6.14
ENV PATH=/home/selenium/.local/bin:$PATH
ENTRYPOINT ["uv", "run"]
