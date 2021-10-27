FROM alpine:3.13

RUN apk add -u --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community git-crypt
RUN apk add --virtual .asdf-deps --no-cache jq bash openssh curl git gnupg grep yq cargo alpine-sdk openssl-dev zlib-dev bzip2-dev readline-dev sqlite-dev libffi-dev musl-dev
SHELL ["/bin/bash", "-l", "-c"]

ENV PATH="/root/.asdf/shims:/root/.asdf/bin:/root/.local/bin:$PATH"
ENV GCP_AUTH_KIND="application"

COPY ansible /gitlab-environment-toolkit/ansible
COPY terraform /gitlab-environment-toolkit/terraform
COPY .tool-versions /gitlab-environment-toolkit/.tool-versions
COPY ./scripts/setup-get-symlinks.sh /gitlab-environment-toolkit/scripts/setup-get-symlinks.sh

WORKDIR /gitlab-environment-toolkit
# Install ASDF
RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile && \
    source ~/.bashrc

# Install Terraform
RUN asdf plugin add terraform && \
    asdf install terraform

# Install Python & Dependencies
RUN asdf plugin add python && \
    asdf install python && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r /gitlab-environment-toolkit/ansible/requirements/requirements.txt --user

# Install Ansible & Dependencies
RUN /root/.local/bin/ansible-galaxy install -r /gitlab-environment-toolkit/ansible/requirements/ansible-galaxy-requirements.yml

# Copy Environments on login
RUN echo -e '\n export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc

CMD 'bash'
