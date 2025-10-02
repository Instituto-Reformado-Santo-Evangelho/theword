# Guia de Contribuição para Revisores e Editores

Bem-vindo ao projeto TheWord - Módulo de Bíblia Família 35! Este guia explica como você pode contribuir como revisor ou editor, **sem necessidade de conhecimento de programação**.

## Como Funciona o Processo

O projeto utiliza scripts Perl para automatizar a conversão do texto bíblico em módulos para o TheWord. O processo é simples e direto:

### 1. Preparação do Texto

Você precisará de dois arquivos de entrada:

- **input-verses.txt** - Cole aqui o texto dos versículos do PDF, sem modificações
- **input-notes.txt** - Cole aqui as notas de rodapé do PDF, sem modificações

### 2. Execução do Script Principal

Execute o script Perl que formata o texto automaticamente:

```bash
perl perl/index.pl [NomeLivro] [Capítulo:Versículos]
```

**Exemplos:**
```bash
perl perl/index.pl Lucas 4:1-7    # Capítulo 4, versículos 1 a 7
perl perl/index.pl Mateus 5:30    # Capítulo 5, todos os 30 versículos
```

O script irá:
- Quebrar o texto em linhas, onde cada linha representa um versículo
- Formatar as notas de rodapé no padrão do TheWord
- Criar os arquivos **edit-verses.txt** e **edit-notes.txt**

### 3. Revisão e Edição Manual

Após a execução do script, você será solicitado a:

1. **Revisar edit-verses.txt**:
   - Coloque um asterisco (*) em cada referência de nota
   - Edite títulos usando a tag `<TS1>Título Aqui<Ts>`
   - Edite subtítulos usando a tag `<TS2>Subtítulo Aqui<Ts>`
   - Corrija erros de digitação ou formatação

2. **Revisar edit-notes.txt**:
   - Verifique se as notas estão corretamente formatadas
   - Corrija qualquer erro de conversão

3. **Pressione Enter** para continuar quando terminar a revisão

### 4. Resultado Final

O script irá gerar o arquivo **merged.txt** com o texto final, pronto para ser incorporado ao módulo principal.

### 5. Incorporação ao Módulo Principal

Para adicionar o livro revisado ao módulo principal F35.nt:

```bash
perl perl/merged-main.pl [NomeLivro]
```

**Exemplo:**
```bash
perl perl/merged-main.pl Lucas
```

## Padrões de Formatação

### Títulos e Subtítulos
- **Título:** `<TS1>Texto do Título<Ts>`
- **Subtítulo:** `<TS2>Texto do Subtítulo<Ts>`

### Notas de Rodapé
- Marque cada referência de nota com um asterisco (*) no texto
- O script irá substituir automaticamente por `<sup>número</sup>`

### Versículos
- Cada linha corresponde a um versículo
- As referências (capítulo:versículo) são adicionadas automaticamente pelo script

## Diretrizes para Revisão

1. **Fidelidade ao Original**: Mantenha-se fiel ao texto original do PDF
2. **Correções Pontuais**: Corrija apenas erros evidentes de digitação
3. **Formatação Consistente**: Siga os padrões estabelecidos para títulos e notas
4. **Atenção aos Detalhes**: Verifique se todos os versículos estão presentes e na ordem correta

## Lista de Verificação do Revisor

- [ ] Texto copiado corretamente dos arquivos de entrada
- [ ] Script executado sem erros
- [ ] Todos os asteriscos de notas adicionados
- [ ] Títulos e subtítulos formatados corretamente
- [ ] Notas de rodapé verificadas
- [ ] Numeração de versículos correta e sequencial
- [ ] Arquivo merged.txt gerado com sucesso
- [ ] Livro incorporado ao módulo principal F35.nt

## Livros Disponíveis para Revisão

Atualmente, os seguintes nomes de livros são reconhecidos pelo script:

- **Mateus** (Mt)
- **Marcos** (Mc)
- **Lucas** (Lc)
- **João** (Jo)

Para adicionar suporte a outros livros do Novo Testamento, é necessário atualizar o arquivo `perl/lib/Convert.pm`.

## Relatando Problemas

Se encontrar algum problema durante a revisão:

1. Anote o livro, capítulo e versículo onde ocorreu
2. Descreva o problema encontrado
3. Abra uma issue no GitHub ou entre em contato com os mantenedores

## Necessita de Ajuda?

- Consulte o arquivo README.md para informações gerais do projeto
- Veja exemplos de livros já revisados em `modules/bible/f35/`
- Entre em contato com os mantenedores do projeto

---

**Importante**: Você não precisa saber programação! Os scripts Perl fazem o trabalho pesado. Seu papel é garantir a qualidade e precisão do texto através da revisão cuidadosa.

> "Seca-se a erva, e cai a flor, porém a palavra de nosso Deus subsiste eternamente" (Isaías 40.8)
