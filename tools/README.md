# TheWord Tools - Ferramentas de Desenvolvimento

Conjunto de ferramentas para processamento e validação de textos bíblicos para o software TheWord.

## 🎯 **Objetivo**

Este repositório contém as **ferramentas técnicas** para o projeto [TheWord Família 35](../theword). 
Foi separado para manter o repositório principal focado no **conteúdo bíblico** e tornar o ambiente mais acessível para revisores e editores.

## 📦 **Instalação Rápida**

```bash
# Clonar ferramentas
git clone https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools.git

# Instalar no workspace theword
cd theword-tools
perl deploy/install.pl --target=/path/to/theword

# Ou instalação interativa
perl deploy/install.pl --interactive
```

## 🛠️ **Componentes**

### **Scripts Principais**
- **`theword-setup`**: Configuração automática de projetos
- **`theword-process`**: Processamento de textos
- **`theword-preview`**: Sistema de preview avançado
- **`theword-validate`**: Validação e análise de qualidade
- **`theword-server`**: Servidor de preview web

### **Bibliotecas Perl**
- **`TheWord::Config`**: Configuração centralizada
- **`TheWord::Logger`**: Sistema de logging
- **`TheWord::Validate`**: Validação robusta
- **`TheWord::Preview`**: Sistema de preview
- **`TheWord::Deploy`**: Sistema de instalação

### **Servidor Preview** 
- **SalopServer**: Servidor HTTP em C para preview web
- **API REST**: Comunicação entre Perl e servidor
- **Interface Web**: Preview em tempo real no navegador

## 🚀 **Workflow de Desenvolvimento**

### **Para Usuários Finais (Revisores/Editores)**
```bash
# No repositório theword (após instalação)
theword-setup Lucas 4:1-7    # Configura projeto
# Editar input-verses.txt e input-notes.txt
theword-process Lucas 4:1-7   # Processa com preview automático
theword-server start          # Inicia servidor web (opcional)
```

### **Para Desenvolvedores das Ferramentas**
```bash
# Desenvolvimento no theword-tools
git clone theword-tools
cd theword-tools

# Testes
perl -Ilib t/run_tests.pl

# Deploy local para teste
perl deploy/install.pl --target=./test-workspace --dev-mode
```

## 📁 **Estrutura do Projeto**

```
theword-tools/
├── src/                        # Código fonte
│   ├── bin/                    # Scripts executáveis
│   │   ├── theword-setup.pl
│   │   ├── theword-process.pl
│   │   ├── theword-preview.pl
│   │   └── theword-validate.pl
│   ├── lib/TheWord/            # Módulos Perl
│   │   ├── Config.pm
│   │   ├── Logger.pm
│   │   ├── Validate.pm
│   │   ├── Preview.pm
│   │   └── Deploy.pm
│   └── templates/              # Templates de configuração
├── server/                     # Servidor preview
│   ├── salopserver/            # Integração C
│   ├── web/                    # Interface web
│   └── api/                    # API REST
├── deploy/                     # Sistema de instalação
│   ├── install.pl              # Instalador principal
│   ├── update.pl               # Atualizador
│   └── detect-env.pl           # Detecção de ambiente
├── tests/                      # Testes automatizados
├── docs/                       # Documentação técnica
└── README.md                   # Este arquivo
```

## 🌐 **Servidor Preview**

### **Recursos**
- **Preview em tempo real**: Alterações refletidas automaticamente
- **Interface moderna**: HTML5 + CSS3 + JavaScript
- **API RESTful**: Comunicação com scripts Perl
- **Multi-formato**: Console, HTML, PDF (futuro)
- **Navegação**: Entre versículos, capítulos, livros

### **Tecnologias**
- **Backend**: SalopServer (C) - alto performance
- **API**: JSON REST para comunicação
- **Frontend**: Vanilla JS + CSS moderno
- **Protocol**: HTTP/WebSocket para updates em tempo real

## 🔧 **Comandos Disponíveis (Pós-instalação)**

### **Configuração**
```bash
theword-setup --livro Lucas --capitulo 4:1-7
theword-setup --interactive
theword-setup --clean --backup
```

### **Processamento**
```bash
theword-process Lucas 4:1-7
theword-process Lucas 4:1-7 --preview --quality
theword-process Lucas 4:1-7 --html-preview --server
```

### **Preview**
```bash
theword-preview --file merged.txt
theword-preview --html --book Lucas
theword-preview --interactive
theword-preview --quality --detailed
```

### **Servidor**
```bash
theword-server start           # Inicia em http://localhost:8080
theword-server stop            # Para o servidor
theword-server status          # Status do servidor
theword-server config          # Configuração do servidor
```

### **Validação**
```bash
theword-validate --all         # Valida todos os arquivos
theword-validate --book Lucas  # Valida livro específico
theword-validate --quality     # Análise de qualidade
```

## 📊 **Vantagens da Separação**

### **Para o Projeto TheWord**
- ✅ **Repositório limpo**: Apenas conteúdo bíblico
- ✅ **Foco claro**: Revisores veem apenas o essencial
- ✅ **Instalação simples**: Um comando instala tudo
- ✅ **Updates automáticos**: Ferramentas sempre atuais

### **Para Desenvolvedores**
- ✅ **Código organizado**: Separação de responsabilidades
- ✅ **Versionamento independente**: Tools vs Content
- ✅ **CI/CD dedicado**: Testes e builds específicos
- ✅ **Colaboração**: Equipes focadas

### **Para Usuários**
- ✅ **Interface amigável**: Comandos simples e claros
- ✅ **Preview web**: Visualização no navegador
- ✅ **Workflow fluido**: Menos fricção no processo
- ✅ **Qualidade automática**: Detecção de problemas

## 🔗 **Integração com TheWord**

### **Instalação no Workspace**
```bash
# No diretório theword
curl -sSL https://github.com/IRSE/theword-tools/raw/main/deploy/quick-install.sh | bash

# Ou manualmente
git clone https://github.com/IRSE/theword-tools.git
cd theword-tools
perl deploy/install.pl --target=../theword
```

### **Estrutura Resultante**
```
theword/                        # Repositório principal
├── modules/bible/f35/          # Conteúdo bíblico
├── input-verses.txt            # Templates de entrada
├── input-notes.txt             
├── tools/                      # [INSTALADO PELO DEPLOY]
│   ├── bin/                    # Scripts prontos para uso
│   ├── lib/                    # Bibliotecas
│   ├── server/                 # Servidor preview
│   └── config/                 # Configurações
└── CONTRIBUTING.md             # Guia simples para revisores
```

## 🧪 **Desenvolvimento e Testes**

### **Ambiente de Desenvolvimento**
```bash
git clone theword-tools
cd theword-tools

# Instalar dependências
cpan install Term::ANSIColor Test::More JSON::PP

# Executar testes
prove -r tests/

# Deploy de desenvolvimento
perl deploy/install.pl --dev-mode --target=./test-env
```

### **Contribuindo**
1. **Fork** o repositório
2. **Branch** para sua feature: `git checkout -b feature/nova-funcionalidade`
3. **Commit** suas alterações: `git commit -m 'Add nova funcionalidade'`
4. **Push** para branch: `git push origin feature/nova-funcionalidade`
5. **Pull Request** com descrição detalhada

## 📈 **Roadmap Técnico**

### **v1.0 - Separação e Deploy** ✅
- ✅ Estrutura de repositórios separados
- ✅ Sistema de instalação automática
- ✅ Comandos unificados
- ✅ Documentação completa

### **v1.1 - Servidor Preview**
- [ ] Integração com SalopServer
- [ ] API REST funcional
- [ ] Interface web básica
- [ ] WebSocket para updates

### **v1.2 - Interface Avançada**
- [ ] Interface web rica
- [ ] Navegação entre livros/capítulos
- [ ] Editor integrado no browser
- [ ] Export para múltiplos formatos

### **v2.0 - Produção**
- [ ] Performance otimizada
- [ ] Suporte multi-usuário
- [ ] Integração com Git
- [ ] Deployment em cloud

## 🤝 **Relacionamento com Projetos**

- **[theword](../theword)**: Repositório principal com conteúdo bíblico
- **[salopserver](../salopserver)**: Servidor HTTP em C para preview
- **TheWord Software**: Software final onde os módulos são usados

## 📄 **Licença**

Mesmo projeto, mesma licença do repositório principal TheWord.

---

> "A palavra de Deus é viva e eficaz" - Agora com ferramentas modernas! 📖⚡