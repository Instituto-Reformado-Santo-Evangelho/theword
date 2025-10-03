# Módulos TheWord - Família 35

Esta pasta contém os módulos bíblicos para o software TheWord baseados no Novo Testamento segundo a Família 35.

## 🔒 **POLÍTICA DE SEGURANÇA - LEIA ANTES DE EDITAR**

### **📁 Estrutura de Arquivos**

```
f35/
├── F35.nt        🔒 MÓDULO PRINCIPAL - NÃO EDITE DIRETAMENTE
├── Mt.nt         ✅ Mateus individual - Editável por revisores
├── Mc.nt         ✅ Marcos individual - Editável por revisores  
├── Lc.nt         ✅ Lucas individual - Editável por revisores
├── Jo.nt         ✅ João individual - Editável por revisores
└── README.md     🔒 Documentação - Apenas mantenedores
```

### **⚠️ IMPORTANTE: NÃO EDITE F35.nt DIRETAMENTE**

#### **Por que esta política?**
- **F35.nt** é usado por **todos os usuários** do módulo
- Uma corrupção afeta **centenas de pessoas**
- **Rollback** é complexo e demorado
- **Qualidade** deve ser garantida antes da integração

#### **Como contribuir corretamente:**
1. ✅ **Edite apenas livros individuais** (Mt.nt, Mc.nt, Lc.nt, Jo.nt)
2. ✅ **Valide** seu livro com as ferramentas
3. ✅ **Submeta PR** apenas do livro específico
4. ✅ **Aguarde** integração pelos mantenedores

## 📊 **Status dos Livros**

### **✅ Completos e Integrados**
- **Mt.nt** (Mateus) - 28 capítulos - 952 versículos
- **Mc.nt** (Marcos) - 16 capítulos - 678 versículos  
- **Lc.nt** (Lucas) - 24 capítulos - 1.149 versículos

### **🔄 Em Revisão**
- **Jo.nt** (João) - 21 capítulos - ~878 versículos

### **📋 Planejados**
- Atos (28 capítulos)
- Romanos (16 capítulos)
- 1-2 Coríntios (29 capítulos)
- [... demais livros do NT]

## 🛠️ **Como Usar os Módulos**

### **Módulo Principal (Usuários Finais)**
```
Instalar no TheWord: F35.nt
```
- Contém **todos os livros** revisados e validados
- **Sempre estável** e testado
- Atualizado apenas após validação completa

### **Módulos Individuais (Desenvolvimento)**
```
Para testes: Mt.nt, Mc.nt, Lc.nt, Jo.nt
```
- **Desenvolvimento ativo** de cada livro
- Podem estar **em diferentes estágios** de revisão
- **Use por sua conta e risco** em produção

## 🔄 **Processo de Integração**

### **Workflow Automático**
```bash
# 1. Revisor edita livro individual
git add Lc.nt
git commit -m "Lucas: revisão capítulos 10-15"

# 2. Mantenedor valida e integra
perl tools/bin/validate.pl --file=Lc.nt --strict
perl tools/bin/integrate.pl --books=Mt,Mc,Lc,Jo --output=F35.nt

# 3. Release quando apropriado
git tag v1.4.0 -m "Release: João completo integrado"
```

### **Validações Automáticas**
- **Sintaxe**: Tags TheWord corretas
- **Integridade**: Todos os versículos presentes
- **Qualidade**: Score de qualidade > 95%
- **Compatibilidade**: Funciona no TheWord

## 📈 **Estatísticas de Qualidade**

### **F35.nt (Módulo Principal)**
- **Livros integrados**: 3 (Mt, Mc, Lc)
- **Versículos**: 2.779 de ~7.957 total
- **Notas**: 1.823+
- **Qualidade**: 98%+ (validação automática)
- **Última integração**: [Data da última atualização]

### **Livros Individuais**
| Livro | Status | Qualidade | Última Atualização |
|-------|--------|-----------|-------------------|
| Mt.nt | ✅ Estável | 98% | 2025-09-15 |
| Mc.nt | ✅ Estável | 97% | 2025-09-20 |
| Lc.nt | ✅ Estável | 99% | 2025-10-01 |
| Jo.nt | 🔄 Revisão | 95% | 2025-10-02 |

## 🆘 **Solução de Problemas**

### **"Meu livro não aparece no F35.nt"**
- ✅ Verifique se o livro individual está validado
- ✅ Aguarde a próxima integração dos mantenedores
- ✅ Livros são integrados em lotes, não individualmente

### **"Encontrei erro no F35.nt"**
- ❌ **NÃO** edite F35.nt diretamente
- ✅ Identifique o livro individual com o problema
- ✅ Edite o livro específico (Mt.nt, Mc.nt, etc.)
- ✅ Submeta PR do livro corrigido

### **"Como testar minha contribuição?"**
```bash
# Validar livro individual
perl tools/bin/validate.pl --file=Jo.nt --strict

# Preview no navegador
perl tools/bin/preview.pl --html --file=Jo.nt

# Testar no TheWord (livro individual)
# Carregar Jo.nt temporariamente para testes
```

## 🎯 **Metas do Projeto**

### **Curto Prazo**
- ✅ João (Jo.nt) completo e integrado
- ✅ Atos (At.nt) iniciado
- ✅ Sistema de integração automatizado

### **Médio Prazo**  
- ✅ 50% do NT integrado ao F35.nt
- ✅ Equipe de revisores expandida
- ✅ Qualidade 99%+ consistente

### **Longo Prazo**
- ✅ NT completo no F35.nt
- ✅ Velho Testamento (se aprovado)
- ✅ Múltiplas traduções suportadas

---

**Lembre-se**: A política de segurança existe para proteger o trabalho de todos. Sempre edite **livros individuais** e deixe a integração com os mantenedores! 🔒✅

> "Toda Escritura é inspirada por Deus e útil para o ensino" (2 Timóteo 3:16)