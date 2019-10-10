# Simplified OpenWPM Dockerfile

FROM ubuntu:18.04

# This is just a performance optimization and can be skipped by non-US
# based users
RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list

# Instead of running install-pip-and-packages.sh, the packages are installed
# manually using pip and pip3 so that python2 and python3 are supported in the
# final image.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y apt-utils sudo python-pip python3-pip

# For some reasons, python3-publicsuffix doesn't work with pip3 at the moment,
# so install it from the ubuntu repository
RUN apt-get -y install python3-publicsuffix

# Install system dependencies and Node.
WORKDIR /opt/OpenWPM
COPY ./install-system.sh ./install-node.sh ./
RUN ./install-system.sh --no-flash
RUN ./install-node.sh
RUN rm -r /var/lib/apt/lists/* -vf
RUN apt-get --purge autoremove && apt-get clean -y
RUN npm install -g trash-cli

# Everything up to this point should be cached unless you (hopefully rarely) change install-*.sh

COPY . .
RUN ./build-extension.sh

# Move the firefox binary away from the /opt/OpenWPM root so that it is available if
# we mount a local source code directory as /opt/OpenWPM
RUN mv firefox-bin /opt/firefox-bin
ENV FIREFOX_BINARY /opt/firefox-bin/firefox-bin

# Install Python packages from requirements.txt.
RUN pip3 install -U -r requirements.txt

# Optionally create an OpenWPM user. This is not strictly required since it is
# possible to run everything as root as well.
RUN adduser --disabled-password --gecos "OpenWPM"  openwpm

# Start the demo
CMD python3 demo.py
