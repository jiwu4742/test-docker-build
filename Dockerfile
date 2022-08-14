FROM ubuntu:focal

ARG TERRAFORM_DOCS_VERSION="0.16.0"
ARG TFLINT_VERSION="0.37.0"
ARG YAMLLINT_VERSION="1.26.3"
ARG CHECKOV_VERSION="2.1.121"
ARG USER_ID="1001"

COPY .terraform-version .terragrunt-version /opt/

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    echo 'tzdata tzdata/Areas select Australia' >> ~/preseed.txt && \
    echo 'tzdata tzdata/Zones/Australia select Melbourne' >> ~/preseed.txt && \
    apt-get -q update && \
    apt-get -q install -y ca-certificates \
                          curl \
                          apt-transport-https \
                          lsb-release \
                          gnupg \
                          git \
                          unzip \
                          cloud-init && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get -q update && \
    apt-get -q install -y azure-cli \
                          python3-pip && \
    apt-get clean && \
    rm -rf /var/cache/apt && \
    git clone --depth 1 https://github.com/tfutils/tfenv.git /opt/tfenv && \
    ln -s /opt/tfenv/bin/tfenv /usr/local/bin && \
    ln -s /opt/tfenv/bin/terraform /usr/local/bin && \
    git clone --depth 1 https://github.com/cunymatthieu/tgenv.git /opt/tgenv && \
    ln -s /opt/tgenv/bin/tgenv /usr/local/bin && \
    ln -s /opt/tgenv/bin/terragrunt /usr/local/bin && \
    mkdir /opt/terragrunt-cache && \
    chmod -R a+w /opt/terragrunt-cache && \
    curl -Lo terraform-docs.tar.gz https://github.com/segmentio/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname | tr '[:upper:]' '[:lower:]')-amd64.tar.gz && \
    tar -xzf terraform-docs.tar.gz && \
    mv terraform-docs /usr/local/bin/terraform-docs && \
    chmod +x /usr/local/bin/terraform-docs && \
    rm terraform-docs.tar.gz && \
    curl -Lo tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip tflint.zip && mv tflint /usr/local/bin && \
    chmod +x /usr/local/bin/tflint && \
    rm tflint.zip && \
    pip3 install -q --no-cache-dir yamllint==${YAMLLINT_VERSION} checkov==${CHECKOV_VERSION} && \
    cd /opt && \
    tfenv install && \
    tgenv install && \
    useradd --uid="${USER_ID}" --shell /bin/bash terraformbuilder

USER terraformbuilder
WORKDIR /src

ENTRYPOINT ["/bin/bash", "-c"]