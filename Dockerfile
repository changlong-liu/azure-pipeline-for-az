FROM python:3.8
RUN apt-get update
RUN apt-get install -y git python jq curl

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get install -y nodejs && apt-get install -y vim
RUN npm install -g autorest && npm install -g typescript
RUN apt install -y git
RUN apt-get install -y libunwind-dev
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb
RUN apt-get update && apt-get install -y apt-transport-https && apt-get update && apt-get install -y dotnet-sdk-3.1

COPY requirements.txt ./requirements.txt
RUN python -m venv /opt/venv
RUN /opt/venv/bin/python -m pip install --upgrade pip
# RUN /opt/venv/bin/pip install -r ./requirements.txt
RUN cat requirements.txt | xargs -n 1 /opt/venv/bin/pip install  || echo "some installation failed, but still go on..."

COPY run.sh /run.sh
RUN chmod 777 /run.sh && sed -i -e 's/\r$//' /run.sh

ENTRYPOINT [ "/bin/bash", "-c", "/run.sh $0 $@" ]
# ENTRYPOINT [ "/bin/bash" ]