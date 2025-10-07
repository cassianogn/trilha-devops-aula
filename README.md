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


--- Aula de AKS + helm

## Trilha DevOps - Aula 2 de 4: Kubernetes + Helm

Nesta segunda aula, evoluímos a infraestrutura criada anteriormente e passamos a publicar aplicações e ferramentas de observabilidade no AKS utilizando o Helm.

### Pré-requisitos
- Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli
- kubectl: https://kubernetes.io/docs/tasks/tools/
- Helm: https://helm.sh/docs/intro/install/
- Um cluster AKS e um Azure Container Registry (ACR) (podem ser provisionados pelo Terraform da aula anterior).

### Conectando na Azure e no AKS
```pwsh
az login
az acr login --name <acr-name>
az aks get-credentials -g <resource-group> -n <nome-do-cluster>
```

### Criando Namespaces
```pwsh
kubectl create namespace app
kubectl create namespace monitoring
```

### Publicando uma aplicação com Helm
```pwsh
# Criar um chart Helm
helm create app

# Renderizar manifests (pré-visualização)
helm template demoapi -f ./api/LuisDev.DemoApp/LuisDev.DemoApp/cicd/demoapp.helm.yaml ./helm/app > saida.yaml

# Instalar a aplicação
helm install demoapi -f ./api/LuisDev.DemoApp/LuisDev.DemoApp/cicd/demoapp.helm.yaml ./helm/app --namespace=app

# Atualizar a aplicação (exemplo alterando valor via --set)
helm upgrade --set version=0 demoapi -f ./api/LuisDev.DemoApp/LuisDev.DemoApp/cicd/demoapp.helm.yaml ./helm/app --namespace=app
```

### Observabilidade: Prometheus e Grafana com Helm
```pwsh
# Adicionar repositórios oficiais
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Instalar Prometheus + Grafana
helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 77.6.2 -n monitoring

# Atualizar instalação (Grafana com LoadBalancer exposto publicamente)
helm upgrade my-kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --reuse-values --set grafana.service.type=LoadBalancer,grafana.service.port=80

# Recuperar senha do Grafana (PowerShell)
kubectl get secret -n monitoring my-kube-prometheus-stack-grafana `
  -o jsonpath="{.data.admin-password}" | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}
```

## Trilha DevOps - Aula 3 de 4: Pipelines

### Concedendo permissão para a Service Principal da pipeline (para criar Role Assignments)
Antes de criar a pipeline, para o terraform poder executar corretamente, siga este guia:
Este guia mostra:
Como identificar qual Service Principal a sua pipeline do Azure DevOps está usando.
Como dar acesso de administrador na subscription (ou no escopo desejado) para permitir que o Terraform crie Role Assignments (ex.: AcrPull no ACR).

#### 1) Identificar a Service Principal usada pela pipeline
Opção A — Pelo Azure DevOps (mais direto)
No Azure DevOps, acesse Project settings → Service connections.
Abra a Service Connection que a pipeline usa (o nome aparece no YAML, ex.: environmentServiceNameAzureRM e/ou backendServiceArm).
Clique em Manage service principal / Manage App registration.
No portal do Azure será aberta a Aplicação (App registration / Enterprise application). Anote:
Application (client) ID
Object ID
Display name (nome da SP)
Dica: o nome exibido nessa tela é exatamente a identidade que você deve escolher quando for atribuir a função (role) no IAM.
Opção B — Pelo log da pipeline (se estiver usando OIDC com AzureCLI@2)
Se você usa um passo AzureCLI@2 com addSpnToEnvironment: true, a pipeline exporta variáveis:
servicePrincipalId → Application (client) ID
tenantId → Tenant
Esses valores também podem ser usados para localizar a SP no Entra ID.

#### 2) Conceder permissão de User Access Administrator (ou Owner) na Subscription
Por quê? Para criar roleAssignments (RBAC) via Terraform, a identidade que executa o apply precisa ter permissão de gravar RBAC no escopo alvo. As funções que permitem isso são User Access Administrator (recomendado para este caso) ou Owner.
Onde? No escopo da Subscription é o modo mais simples quando RGs e recursos são criados pelo próprio Terraform (porque ainda não existem antes).
2.1 Via Portal do Azure
Acesse Assinaturas → selecione sua Subscription.
Abra Controle de acesso (IAM) → Adicionar → Adicionar atribuição de função.
Em Função, escolha User Access Administrator (ou Proprietário/Owner, se preferir).
Em Membros, selecione Usuário, grupo ou entidade de serviço → Selecionar membros.
Busque pelo nome da Service Principal (anotado na etapa 1) e selecione.
Examinar + atribuir para concluir.
Observação: a propagação do RBAC pode levar alguns minutos. Se ainda aparecer 403 logo depois, aguarde e tente novamente.