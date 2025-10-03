# Guia de Contribuição - TheWord Família 35

Bem-vindo ao projeto TheWord - Módulo de Bíblia Família 35! Este guia explica como contribuir como **revisor ou editor**, sem necessidade de conhecimento técnico.

## 🔒 **Importante: Política de Segurança**

### **⚠️ NÃO EDITE DIRETAMENTE O F35.nt**
- **F35.nt** é o módulo principal usado por todos os usuários
- **Revisores trabalham apenas em livros individuais**: Mt.nt, Mc.nt, Lc.nt, Jo.nt
- **Mantenedores** validam e integram ao F35.nt
- **Objetivo**: Proteger o módulo principal de corrupção

### **✅ Você pode editar**:
- `modules/bible/f35/Mt.nt` (Mateus)
- `modules/bible/f35/Mc.nt` (Marcos)  
- `modules/bible/f35/Lc.nt` (Lucas)
- `modules/bible/f35/Jo.nt` (João)
- Futuros livros individuais

### **❌ NÃO edite**:
- `modules/bible/f35/F35.nt` (módulo principal)

## 🎯 **Workflow Moderno de Contribuição**

### **1. Instalação das Ferramentas** (uma vez)
```bash
# Clonar ferramentas modernas
git clone https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools.git

# Instalar no workspace theword
cd theword-tools
perl deploy/install.pl --target=/caminho/para/theword --interactive
```

### **2. Workflow Simplificado**
```bash
# 1. Configurar projeto para livro específico
cd /caminho/para/theword
perl tools/bin/setup.pl --livro Lucas --capitulo 4:1-7

# 2. Editar arquivos criados:
#    - input-verses.txt (cole texto dos versículos do PDF)
#    - input-notes.txt (cole notas de rodapé do PDF)

# 3. Processar com preview e numeração automática
perl tools/bin/index.pl Lucas 4:1-7 --preview

# 4. Revisar edit-verses.txt:
#    - Adicionar asterisco (*) em cada referência de nota
#    - Formatar títulos: <TS1>Título<Ts>
#    - Formatar subtítulos: <TS2>Subtítulo<Ts>

# 5. Gerar livro individual (numeração automática 1, 2, 3...)
perl tools/bin/generate-book.pl --book Lucas --output modules/bible/f35/Lc.nt
```

### **3. Submissão Segura**
```bash
# 1. Validar seu livro individual
perl tools/bin/validate.pl --file modules/bible/f35/Lc.nt --strict

# 2. Commit apenas do livro individual
git add modules/bible/f35/Lc.nt
git commit -m "Lucas: capítulos 4-7 revisados e validados"

# 3. Criar Pull Request
git push origin feature/lucas-cap4-7
# Abrir PR no GitHub
```

## 📖 **Sistema de Numeração Moderno**

### **🎯 Numeração Local Automática**
- **Cada livro** usa numeração própria: 1, 2, 3, 4...
- **Sem conflitos** entre diferentes revisores
- **Conversão automática** para numeração global pelo sistema

### **Exemplo:**
```
Você edita Lucas e suas notas ficam:
<RF q=1>Primeira nota do Lucas<Rf>
<RF q=2>Segunda nota do Lucas<Rf>
<RF q=3>Terceira nota do Lucas<Rf>

O sistema automaticamente converte para numeração global no F35.nt!
```

## 📚 **Livros Disponíveis para Revisão**

### **✅ Completos (podem precisar de revisão)**
- **Mateus** (Mt.nt) - 28 capítulos
- **Marcos** (Mc.nt) - 16 capítulos
- **Lucas** (Lc.nt) - 24 capítulos

### **🔄 Em Andamento**  
- **João** (Jo.nt) - Precisa de revisores!

### **📋 Planejados (precisam de revisores)**
- Atos, Romanos, 1-2 Coríntios
- Gálatas, Efésios, Filipenses
- Colossenses, 1-2 Tessalonicenses
- 1-2 Timóteo, Tito, Filemom
- Hebreus, Tiago, 1-2 Pedro
- 1-2-3 João, Judas, Apocalipse

## 📖 **Formatação de Texto**

### **Títulos e Subtítulos**
- **Título Principal**: `<TS1>Texto do Título<Ts>`
- **Subtítulo**: `<TS2>Texto do Subtítulo<Ts>`

### **Notas de Rodapé**
- Marque cada referência com asterisco (*) no texto
- O sistema substitui automaticamente por números sequenciais

### **Exemplo**
```
<TS1>O Evangelho segundo LUCAS<Ts>
<TS2>Dedicatória<Ts>
1:1 Já que muitos têm empreendido* pôr em ordem uma narração...
```

## 🛡️ **Vantagens do Sistema Moderno**

### **Para Você (Revisor)**
- ✅ **Numeração automática**: Sempre 1, 2, 3... (sem pensar em números globais)
- ✅ **Trabalho isolado**: Seu livro não afeta outros
- ✅ **Impossível quebrar F35.nt**: Sistema protegido
- ✅ **Preview em tempo real**: Veja resultado instantaneamente
- ✅ **Validação automática**: Problemas detectados automaticamente

### **Para o Projeto**
- ✅ **F35.nt sempre estável**: Nunca corrompido por contribuidores
- ✅ **Múltiplos revisores**: Trabalho simultâneo sem conflitos
- ✅ **Integração controlada**: Apenas livros validados são integrados
- ✅ **Qualidade garantida**: Múltiplas camadas de validação

## 🚀 **Recursos Modernos Disponíveis**

### **Preview Avançado**
```bash
# Preview colorido no terminal
perl tools/bin/preview.pl --file modules/bible/f35/Lc.nt

# Preview HTML no navegador
perl tools/bin/preview.pl --html --book Lucas

# Preview interativo (navegação versículo por versículo)
perl tools/bin/preview.pl --interactive
```

### **Validação de Qualidade**
```bash
# Análise de qualidade automática
perl tools/bin/validate.pl --quality --file modules/bible/f35/Lc.nt

# Comparação de alterações
perl tools/bin/preview.pl --comparison --before Lucas-antigo.nt --after Lc.nt
```

## 🆘 **Precisa de Ajuda?**

- **Ferramentas Modernas**: https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools
- **Issues**: https://github.com/Instituto-Reformado-Santo-Evangelho/theword/issues
- **Documentação Completa**: Após instalar, veja `tools/docs/`
- **Guia de Segurança**: [SECURITY-POLICY.md](https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools/blob/main/docs/SECURITY-POLICY.md)

## ✅ **Lista de Verificação do Revisor**

- [ ] Ferramentas modernas instaladas (`tools/` existe no diretório)
- [ ] Projeto configurado para livro específico (não F35.nt)
- [ ] Texto copiado do PDF para os arquivos input
- [ ] Processamento executado com preview
- [ ] Asteriscos (*) adicionados nas referências de notas
- [ ] Títulos formatados com tags `<TS1>` e `<TS2>`
- [ ] **Livro individual** gerado e validado (Mt.nt, Mc.nt, etc.)
- [ ] **NÃO** editou F35.nt diretamente
- [ ] Pull Request criado com apenas um livro
- [ ] Numeração automática funcionando (1, 2, 3...)

---

**Sistema Moderno**: Você trabalha apenas em **livros individuais** com **numeração automática**. Os mantenedores cuidam da integração ao **F35.nt principal**. Simples, seguro e eficiente! 🚀

> "Seca-se a erva, e cai a flor, porém a palavra de nosso Deus subsiste eternamente" (Isaías 40.8)