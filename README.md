## Trilha DevOps - Aula 1 de 4: Infraestrutura como Código com Terraform

Este projeto faz parte de uma trilha de 4 aulas sobre DevOps, focando em práticas modernas de automação e infraestrutura como código (IaC) utilizando o Terraform na Azure.

### O que é Terraform?
Terraform é uma ferramenta open source para provisionamento e gerenciamento de infraestrutura como código. Com ele, você pode criar, alterar e versionar recursos de nuvem de forma automatizada e segura.

### Estrutura do Código
O código deste repositório provisiona:
- Um Resource Group na Azure
- Um cluster Kubernetes (AKS)
- Dois servidores SQL e dois bancos de dados
- Um Container Registry (ACR)
- Um Key Vault para armazenar segredos
- Geração de senhas aleatórias para os bancos
- Atribuição de permissões entre recursos

Os arquivos principais são:
- `main.tf`: definição dos recursos
- `variables.tf`: variáveis utilizadas no projeto
- `envs/prod.tfvars`: variáveis específicas para o ambiente de produção

### Dependências
Antes de executar, instale:
- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)

### Como Executar
1. **Autentique-se na Azure:**
	```pwsh
	az login
	```
2. **Inicialize o Terraform:**
	```pwsh
	terraform init
	```
3. **Visualize o plano de execução:**
	```pwsh
	terraform plan -var-file="envs/prod.tfvars"
	```
	Ou exporte o plano para um arquivo:
	```pwsh
	terraform plan -var-file="envs/prod.tfvars" -out=plan.tfplan
	```
4. **Aplicar as mudanças:**
	```pwsh
	terraform apply -var-file="envs/prod.tfvars"
	```
	Ou usando o plano exportado:
	```pwsh
	terraform apply "plan.tfplan"
	```
5. **Destruir a infraestrutura:**
	```pwsh
	terraform destroy -var-file="envs/prod.tfvars"
	```

> **Dica:** Utilize o parâmetro `-var-file` quando você para garantir que está aplicando as configurações do ambiente desejado. Caso seja para o ambiente default, não precisa informar.

---
Siga as próximas aulas para evoluir a automação e integração contínua da sua infraestrutura!
