FROM alpine:3.13

RUN apk add --virtual .asdf-deps --no-cache jq bash openssh curl git gnupg grep yq cargo alpine-sdk openssl-dev zlib-dev bzip2-dev readline-dev sqlite-dev libffi-dev musl-dev
SHELL ["/bin/bash", "-l", "-c"]

RUN adduser -s /bin/bash -h /get -D get && \
    mkdir -p /gitlab-environment-toolkit/keys && \
    mkdir /environments

ENV PATH="/get/.asdf/shims:/get/.asdf/bin:$PATH"
ENV GCP_AUTH_KIND="application"

COPY ansible /gitlab-environment-toolkit/ansible
COPY terraform /gitlab-environment-toolkit/terraform
COPY .tool-versions /gitlab-environment-toolkit/.tool-versions
COPY ./scripts/setup-get-symlinks.sh /gitlab-environment-toolkit/scripts/setup-get-symlinks.sh

RUN chown -R get:get /gitlab-environment-toolkit && \
    chown -R get:get /environments

USER get
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
    pip install --no-cache-dir -r /gitlab-environment-toolkit/ansible/requirements/ansible-python-packages.txt

# Install Ansible & Dependencies
RUN pip install --no-cache-dir ansible --user && \
    /get/.local/bin/ansible-galaxy install -r /gitlab-environment-toolkit/ansible/requirements/ansible-galaxy-requirements.yml

# Copy Environments on login
RUN echo -e '\n. /gitlab-environment-toolkit/scripts/setup-get-symlinks.sh' >> ~/.bashrc && \
    echo -e '\n export PATH="/get/.local/bin:$PATH"' >> ~/.bashrc

CMD 'bash'
