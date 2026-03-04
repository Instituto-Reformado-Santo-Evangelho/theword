# Arquitetura Interna - TheWord Tools (Família 35)

Este documento descreve a lógica de construção dos scripts e estabelece as diretrizes para manutenção da integridade absoluta do sistema.

## 1. Princípios de Design
O sistema é dividido em duas fases distintas para garantir a segurança dos dados:
*   **Fase de Geração (index.pl)**: Transforma entradas brutas em um arquivo intermediário (`output/merged.txt`).
*   **Fase de Integração (integrate.pl)**: Realiza a união cirúrgica do conteúdo revisado com o módulo bíblico final.

## 2. Componentes Críticos

### 2.1 TheWord::Merge (O Coração do Parser)
A lógica de contagem de versículos e notas reside aqui.
*   **Contagem de Versículos**: O script utiliza a tabela `tools/table-verses` para validar a quantidade exata de linhas. Uma linha no arquivo de edição **deve** corresponder a um versículo, mesmo que contenha títulos.
*   **Numeração de Notas**: A função `init_context` realiza um "scan" reverso no arquivo `.nt` de destino para encontrar o último versículo *antes* do bloco atual. Isso garante que, ao gerar o `merged.txt`, a numeração das notas já esteja perfeitamente sincronizada com o estado atual do livro.

### 2.2 integrate.pl (Integração Cirúrgica)
Diferente de um simples *append*, este script:
1.  Mapeia o livro por referências (`Capítulo:Versículo`).
2.  Suporta referências precedidas por títulos (Regex: `(?:^|<Ts>)\s*(\d+:\d+)\s`).
3.  **Renumeração Global**: Sempre que um trecho é integrado, o script re-sequencia **todas** as notas (`<RF q=N>`) do livro do início ao fim. Isso previne duplicatas ou saltos numéricos causados por inserções manuais.

## 3. Mandato de Integridade
Qualquer alteração nestes scripts deve respeitar:
1.  **UTF-8 com BOM**: O software TheWord exige que os arquivos `.nt` tenham o Byte Order Mark (BOM).
2.  **Regex de Títulos**: Títulos não contam como versículos. O parser deve sempre buscar o padrão `Cap:Ver` após a tag `<Ts>`.
3.  **Não-Duplicação**: O processo de integração deve ser idempotente para a mesma referência.

## 4. Fluxo de Trabalho
1. `index.pl João 1`: Gera arquivos para edição.
2. Edição manual em `output/edit-*.txt`.
3. `index.pl João 1`: Gera `output/merged.txt`.
4. `integrate.pl João`: Consolida no módulo final.
