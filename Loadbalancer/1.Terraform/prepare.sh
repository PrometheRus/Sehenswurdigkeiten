#!/bin/bash

# r=9tlKJ|
# 5GlC~%8n

wget -qO terraform.zip https://mirror.selectel.ru/3rd-party/hashicorp-releases/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform.zip && rm LICENSE.txt && sudo mv terraform /usr/local/bin && rm terraform.zip

# создаем сервисного пользователя по инструкции https://docs.selectel.ru/terraform/quickstart/#add-service-user

tee ~/.terraformrc > /dev/null << EOF
provider_installation {
  network_mirror {
    url = "https://tf-proxy.selectel.ru/mirror/v1/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
EOF
