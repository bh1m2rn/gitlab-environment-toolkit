FROM google/cloud-sdk:alpine

RUN apk add -u --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community git-crypt
RUN apk add --virtual .asdf-deps --no-cache jq bash openssh curl git grep alpine-sdk openssl-dev libffi-dev py3-pip py3-wheel python3-dev
SHELL ["/bin/bash", "-c"]

RUN mkdir -p /gitlab-environment-toolkit/keys && \
    mkdir /environments

ENV PATH="/root/.asdf/shims:/root/.asdf/bin:/root/.local/bin:$PATH"
ENV GCP_AUTH_KIND="application"

COPY ansible /gitlab-environment-toolkit/ansible
COPY terraform /gitlab-environment-toolkit/terraform
COPY .tool-versions /gitlab-environment-toolkit/.tool-versions
COPY ./bin/docker/setup-get-symlinks.sh /gitlab-environment-toolkit/scripts/setup-get-symlinks.sh

USER root
WORKDIR /gitlab-environment-toolkit

# Install ASDF
RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile && \
    source ~/.bashrc

# Install Terraform
RUN asdf plugin add terraform && \
    asdf install terraform

# Install Python Packages
RUN pip install --no-cache-dir -r /gitlab-environment-toolkit/ansible/requirements/requirements.txt --user

# Install remaining cloud tools
RUN pip install --no-cache-dir awscli --user
RUN gcloud components install kubectl -q
RUN curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sh

# Install Ansible & Dependencies
RUN /root/.local/bin/ansible-galaxy install -r /gitlab-environment-toolkit/ansible/requirements/ansible-galaxy-requirements.yml

# Copy Environments on login
RUN echo -e '\n. /gitlab-environment-toolkit/scripts/setup-get-symlinks.sh' >> ~/.bashrc && \
    echo -e '\n export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc

CMD 'bash'
