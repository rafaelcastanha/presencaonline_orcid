# Código em linguagem R para extração e visualização da presença online de pesquisadores com registro na base ORCID. 

Este programa consome a API pública do ORCID: *https://pub.orcid.org/v3.0/{orcid}/record*

- A partir desta API, são extraídos e organizados dados relativos à presença online do pesquisador.
- O programa extrai os seguintes dados: ORCID IDs, Nome, País, Websites & social links e Other ID.
- Utilizando os dados oriundos dos Websites & social links, extrai o domínio de cada website ou rede social

Estes dados permitem gerar os seguintes resultados:

1) Tabela de dados gerais: tabela com dados brutos contendo ORCID IDs, Nome, País, Websites & social links, links dos websites, domínio dos websites, Outros ID e links dos Outros ID.
2) Tabela de dados sumarizados: similar à tabela de dados gerais, porém com dados únicos e aglutinados.
3) Tabela dupla entre País e Domínio: tabela cruzada entre os países de origem e domínios dos Websites & social links.
4) Rede (grafo) de presença online: grafo relacionando cada ORCID ID aos respectivos domínios de Websites & social links.

Arquivo para teste

Conjunto de 1000 ORCID iDs composto pelos 200 primeiros resultados de busca no site da ORCID (orcid.org) das cinco universidades brasileiras mais bem ranqueadas no Scimago Institution Ranking 2025: Universidade de São Paulo (USP), Universidade de Campinas (UNICAMP), Universidade Estadual Paulista (UNESP), Universidade Federal de Minas Gerais (UFMG) e Universidade Federal do Rio de Janeiro (UFRJ). Buscou-se pela sigla de cada uma das universidades para gerar o conjunto com os 200 primeiros resultados de cada busca, gerando uma lista de 1000 Orcid iDs.

*Este programa é utilizado no estudo "Algoritmo para análise de presença online de pesquisadores da base ORCID" apresentado e publicado nos anais do VIII Workshop de Informação, Dados e Tecnologia (WIDaT)*
