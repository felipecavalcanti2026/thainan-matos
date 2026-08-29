# Thainan Matos — site

`index.html` é autossuficiente: um arquivo, zero build, zero dependência.
Duplo clique já abre. Deploy: joga a pasta inteira em qualquer host estático.

---

## 1. As 9 fotos — é isso que falta para o site parar de parecer vazio

Salvar em `img/casos/` com estes nomes exatos. **A ordem importa**: o
enquadramento que joga a marca d'água para fora de quadro já está calibrado
arquivo por arquivo.

| arquivo | foto | marca d'água | atributo no HTML |
|---|---|---|---|
| `caso-01.jpg` | lábios, colete listrado | nenhuma | `data-corte="nenhum"` |
| `caso-02.jpg` | camiseta listrada preta/branca | topo | `data-corte="topo" data-zoom="sim"` |
| `caso-03.jpg` | polo branca, loira | topo | `data-corte="topo"` |
| `caso-04.jpg` | blazer camel | topo | `data-corte="topo"` |
| `caso-05.jpg` | toalha azul | topo + base | `data-corte="ambos"` |
| `caso-06.jpg` | loira, corrente dourada | topo + base | `data-corte="ambos"` |
| `caso-07.jpg` | cacheada, blusa rosa | nenhuma | `data-corte="nenhum"` |
| `caso-08.jpg` | cabelo preto, camisa branca | topo | `data-corte="topo" data-zoom="sim"` |
| `caso-09.jpg` | brinco dourado, blusa preta | base | `data-corte="base"` |

Enquanto os arquivos não existirem, cada card mostra o monograma TM e o nome do
arquivo que falta. É placeholder desenhado, não erro — a página não quebra.

### Carrossel
As fotos ficam numa faixa contínua que desliza sozinha, sangrando de ponta a ponta.
O trilho carrega os 9 casos **duas vezes**: a animação desloca exatamente a largura
da primeira leva (9 cartões + 9 vãos), então a emenda cai no mesmo pixel e o laço
fica invisível. A segunda leva é decorativa — `aria-hidden="true"`, fora do leitor de tela.

- Velocidade: `animation:desliza 64s` em `.carrossel__trilho`. Menor = mais rápido.
- Pausa sozinho no hover e no foco por teclado.
- Em `prefers-reduced-motion`, vira faixa rolável à mão com scroll-snap e as cópias somem.
- Se trocar a quantidade de fotos, ajuste o `9` do comentário e mantenha a duplicação:
  o cálculo `-50% - vao/2` só fecha se as duas levas forem idênticas.

### Como o corte funciona
As molduras são todas 1:1. Como as fotos têm largura ≤ altura, `object-fit:cover`
numa moldura quadrada **só corta na vertical** — as laterais ficam intactas, que é
o que importa num antes/depois lado a lado. O `data-corte` decide para qual ponta
vai a sobra; é assim que a marca sai de quadro.

- `topo` → sobra sai por cima
- `base` → sobra sai por baixo
- `ambos` → divide entre as duas pontas, com folga extra
- `data-zoom="sim"` → só para foto de origem quadrada, que não tem sobra natural

Sobrou resto de logo? Troque `data-corte="topo"` por `data-corte="topo" data-zoom="sim"`.
Comeu testa demais? Tire o `data-zoom`.

### Limpeza definitiva (opcional)
O enquadramento resolve na tela, mas o arquivo original continua com a marca.
Para gerar arquivos limpos de verdade — usa `sips`, que já vem no macOS:

```bash
./_limpar-marca.sh
```

Escreve em `img/casos/limpas/`. Depois substitua os originais e troque todos os
`data-corte` por `"nenhum"`, removendo os `data-zoom`.

---

## 2. Placeholders a preencher

Busque no `index.html` por colchetes:

- `[DDD]` e `[NUMERO]` — WhatsApp (8 links: nav, hero, galeria, fecho, rodapé, flutuante)
- `[CIDADE/UF]` — rótulo do hero e rodapé
- `[X]` — anos de atuação (selo sobre o retrato)
- `[PRIMEIRO PARÁGRAFO]` e `[SEGUNDO PARÁGRAFO]` — seção Sobre. **Não é currículo.**
  O primeiro tem que abrir numa CENA (o caso ou o dia que fez a Thainan mudar de método);
  formação, registro e tempo de atuação entram dentro da história. O segundo é a primeira
  vez que ela recusou um procedimento que a paciente insistia em fazer.
- `[ENDEREÇO COMPLETO]`, `[BAIRRO]`, `[EMAIL]` — rodapé
- `[REGISTRO PROFISSIONAL Nº]` — rodapé (CRO / COREN / CRM / CRBM, conforme o caso)
- `[USUARIO]` — Instagram

```bash
sed -i '' 's/\[DDD\]/11/g; s/\[NUMERO\]/999999999/g; s|\[CIDADE/UF\]|São Paulo/SP|g' index.html
```

## 3. Outras imagens (opcionais — sem elas o bloco vira placeholder com monograma)
- `img/retrato-hero.jpg` — 4:5, Thainan em atendimento
- `img/thainan-retrato.jpg` — 4:5, retrato da seção Sobre
- `img/protocolo-perfil.jpg` / `img/protocolo-mandibula.jpg` — 4:3
- `img/prova/print-01.jpg` … `print-08.jpg` — prints de WhatsApp, 9:16

---

## 4. Estrutura — 7 dobras

A página segue uma escada de decisão. Cada dobra resolve uma objeção antes da
seguinte aparecer. Se for editar, mantenha a peça na função dela:

| # | Dobra | Função | O que o leitor pensa ao sair |
|---|---|---|---|
| 01 | Hero | Desejo | "Quero ficar mais bonita" |
| 02 | Medos + 3 pilares | Dor | "Tenho medo de ficar artificial" |
| 03 | Método Leitura Facial + 4 etapas | Autoridade | "Essa profissional pensa diferente / ela tem um método" |
| 04 | Antes-depois + protocolos | Prova | "Os resultados comprovam" |
| 05 | Procedimentos | Valor | "As ferramentas são meio, não fim" |
| 06 | Thainan + depoimentos | Conexão | "Entendi quem é a profissional" |
| 07 | FAQ + CTA final | Conversão | "Não tenho mais objeções. Vou agendar." |

Três CTAs intermediários (dobras 01, 03, 04) mais o final. Todos apontam para o
mesmo WhatsApp, com mensagens pré-preenchidas diferentes — dá para saber de qual
dobra o lead veio pelo texto que chega.

### ⚠️ Colisão de headline a resolver
"Beleza que respeita quem você é" e os pilares Naturalidade / Precisão / Elegância
são **idênticos aos do site da Dra. Liz Pretto**, que também é cliente da casa.
Dois clientes com a mesma headline é um problema que aparece na primeira comparação.
Decisão pendente do Felipe.

---

## 5. Sistema visual

**Paleta (travada pelo cliente)**
`#fcfef5` porcelana · `#e9ffe1` menta · `#cdcfb7` sage · `#d6e6c3` folha · `#fafbe3` creme

Os cinco tons têm luminância ~95 e nenhum serve para texto. Foram derivados quatro
neutros da mesma família verde-musgo para garantir contraste WCAG:
`#232719` títulos (15,9:1) · `#454d3b` corpo (9,2:1) · `#626b55` legendas (5,0:1) ·
`#1b1f14` seções invertidas.

**Tipografia** — Cormorant Garamond (display) + Jost (interface). Escolha deliberada
para fugir do par Playfair/Inter, que já é padrão no nicho.

**Marca** — monograma TM redesenhado em SVG vetorial (`assets/logo-tm.svg`,
`assets/favicon.svg`). Herda `currentColor`, escala infinito, favicon nítido.

---

## 6. Pendências que travam a publicação

1. **Antes-e-depois em publicidade** é vedado pelo CFM (Res. 2.336/2023) e pelo CFO.
   A regra muda conforme o conselho da Thainan. Decidir antes de subir.
2. **Autorização por escrito** das 9 pacientes — o rodapé do bloco já afirma que existe.
3. **Nomes dos protocolos** ("Perfil Contínuo", "Sustentação Mandibular") são proposta.
   Validar antes de virarem ativo de marca.
4. **Registro profissional** no rodapé é obrigatório na publicidade de todos os conselhos.
