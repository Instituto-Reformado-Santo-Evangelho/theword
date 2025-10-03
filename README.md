# TheWord - Módulo de Bíblia Família 35

Módulo bíblico para o software [TheWord](https://www.theword.net) baseado no **Novo Testamento segundo a Família 35**, tradução do **Dr. Wilbur Norman Pickering**, extraída do livro [O Soberano Criador Já Falou, 3° Edição](https://www.prunch.com.br/wp-content/uploads/2024/08/O-Soberano-Criador-ja-Falou-3-br-c.pdf).

![TheWord Software](./assets/theword.gif)

## 📖 **Como Usar Este Módulo**

### **Opção 1: Download Direto**
Baixe o arquivo principal e carregue no TheWord:
- **[F35.nt](modules/bible/f35/F35.nt)** (clique com botão direito → "Salvar como")

### **Opção 2: Git Clone**
```bash
git clone https://github.com/Instituto-Reformado-Santo-Evangelho/theword.git
```
Depois abra `theword/modules/bible/f35/F35.nt` no TheWord.

### **Atualizações**
```bash
cd theword
git pull
```

## 📚 **Livros Disponíveis**

### **✅ Completos** 
- **Mateus** (Mt.nt) - 28 capítulos
- **Marcos** (Mc.nt) - 16 capítulos  
- **Lucas** (Lc.nt) - 24 capítulos

### **🔄 Em Andamento**
- **João** (Jo.nt) - Em revisão

### **📋 Planejados**
- Atos, Romanos, 1-2 Coríntios
- Gálatas, Efésios, Filipenses
- Colossenses, 1-2 Tessalonicenses
- 1-2 Timóteo, Tito, Filemom
- Hebreus, Tiago, 1-2 Pedro
- 1-2-3 João, Judas, Apocalipse

O módulo principal **F35.nt** é atualizado automaticamente com todos os livros revisados.

## 🤝 **Como Contribuir**

### **Para Revisores e Editores**
Consulte o [**CONTRIBUTING.md**](CONTRIBUTING.md) - não é necessário conhecimento de programação!

**Resumo rápido**:
1. Instalar ferramentas: https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools
2. Configurar projeto: `perl tools/bin/setup.pl --interactive`
3. Editar textos e processar
4. Resultado pronto para TheWord!

### **Para Desenvolvedores**
As ferramentas técnicas estão no repositório separado:
- **[theword-tools](https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools)**: Scripts, validação, preview, etc.

## 📄 **Sobre a Tradução**

### **Família 35**
O texto grego da Família 35 representa aproximadamente 35% dos manuscritos gregos do Novo Testamento, oferecendo uma base textual sólida e bem atestada.

### **Dr. Wilbur Norman Pickering**
Reconhecido erudito em crítica textual do Novo Testamento, defensor do texto majoritário e da preservação providencial das Escrituras.

### **Características da Tradução**
- **Fidelidade ao texto grego**: Tradução formal e precisa
- **Notas explicativas**: Comentários textuais e interpretativos
- **Linguagem atual**: Português contemporâneo e claro

## 🛠️ **Especificações Técnicas**

### **Formato TheWord**
- **Codificação**: UTF-8 com BOM (Byte Order Mark)
- **BOM necessário**: EF BB BF para compatibilidade com acentos
- **Formato**: Texto simples com tags HTML
- **Compatibilidade**: TheWord 4.0+

### **Estrutura de Tags**
- **Títulos**: `<TS1>Título Principal<Ts>`
- **Subtítulos**: `<TS2>Subtítulo<Ts>`
- **Notas**: `<RF q=123>Texto da nota<Rf>`
- **Ênfase**: `<FU>texto sublinhado<Fu>`

### **Organização de Arquivos**
```
modules/bible/f35/
├── F35.nt                  # Módulo principal (todos os livros)
├── Mt.nt                   # Mateus individual  
├── Mc.nt                   # Marcos individual
├── Lc.nt                   # Lucas individual
└── README.md               # Informações dos módulos
```

## 📊 **Estatísticas do Projeto**

- **Versículos processados**: 2.779 (NT completo: ~7.957)
- **Notas explicativas**: 1.823+
- **Taxa de conclusão**: ~35% do Novo Testamento
- **Qualidade**: 95%+ (validação automática)

## 🆘 **Suporte**

### **Problemas com o Módulo**
- **Issues**: https://github.com/Instituto-Reformado-Santo-Evangelho/theword/issues
- **Discussões**: https://github.com/Instituto-Reformado-Santo-Evangelho/theword/discussions

### **Problemas com Ferramentas**
- **Issues técnicas**: https://github.com/Instituto-Reformado-Santo-Evangelho/theword-tools/issues

### **TheWord Software**
- **Site oficial**: https://www.theword.net
- **Documentação**: https://www.theword.net/index.php?article.doc&l=english

## 📜 **Licença**

Este projeto visa a preservação e disseminação da Palavra de Deus. O uso é livre para fins educacionais, ministeriais e pessoais.

## 🙏 **Agradecimentos**

- **Dr. Wilbur Norman Pickering**: Pela excelente tradução
- **Equipe IRSE**: Pela digitalização e revisão
- **Comunidade TheWord**: Pelo software e suporte
- **Contribuidores**: Todos os revisores e editores voluntários

---

> "Seca-se a erva, e cai a flor, porém a palavra de nosso Deus subsiste eternamente" (Isaías 40.8)

**Versão do Módulo**: 1.3  
**Última Atualização**: Outubro 2025  
**Próxima Revisão**: João (em andamento)