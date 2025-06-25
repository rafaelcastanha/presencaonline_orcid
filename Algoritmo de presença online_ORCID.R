#Este programa consome a API pública do ORCID: https://pub.orcid.org/v3.0/{orcid}/record

#A partir desta API, são extraídos e organizados dados relativos à presença online do pesquisador.

#O programa extrai os seguintes dados: ORCID IDs, Nome, País, Websites & social links e Other ID.

#Utilizando os dados oriundos dos Websites & social links, extrai o domínio de cada website ou rede social.

#Estes dados permitem gerar os seguintes resultados:
  #Tabela de dados gerais: tabela com dados brutos contendo ORCID IDs, Nome, País, Websites & social links, links dos websites, domínio dos websites, Outros ID e links dos Outros ID.
  #Tabela de dados sumarizados: similar à tabela de dados gerais, porém com dados únicos e aglutinados.
  #Tabela dupla entre País e Domínio: tabela cruzada entre os países de origem e domínios dos Websites & social links.
  #Rede (grafo) de presença online: grafo de coocorrência entre as plataformas (domínios) presentes nos perfís dos pesquisadores.

{
  
suppressWarnings({
    
    #instale as bibliotecas se necessário
    
    #install.packages(xml2)
    #install.packages(httr)
    #install.packages(stringr)
    #install.packages(stringi)
    #install.packages(igraph)
    #install.packages(dplyr)
    #install.packages(visNetwork)
    #install.packages(tidyr)
    #install.packages(openxlsx)
    
library(xml2)
library(httr)
library(stringr)
library(stringi)
library(igraph)
library(dplyr)
library(visNetwork)
library(tidyr)
library(openxlsx)
    
print("Selecione seu conjunto de ORCID iDs")
    
orcids<-unique(read.table(file.choose(), sep='\t', header = F)) 
    
print("Aguarde...O programa está extraíndo e organizando os dados")
    
#Constrói urls a partir da lista de ORCID
    
for (i in orcids){
      
orcid_links<-paste0("https://pub.orcid.org/v3.0/",i,"/record") #API publica ORCID
      
}
    
#Variáveis Vazias
    
total<-character()
total_2<-character()
rede<-character()
links<-character()
outros_id<-character()
outros_link<-character()
nome_orcid<-character()
pais<-character()
id_aux<-character()
    
#Identificação dos outros identificadores (Others ID)
    
for (i in orcid_links){
      
#Leitura dos xml e conversão para lista
      
xml_list<-read_xml(i)
      
xml_list<-as_list(xml_list) 
      
total_links_ex<-length(xml_list$record$person$`external-identifiers`)
      
total_2<-append(total_2, total_links_ex)
      
  for (i in 2:max(total_2)){
        
#Extração dos Outros IDs
        
  if (!is.null(xml_list$record$person$`external-identifiers`[i]$`external-identifier`$`external-id-type`)) {
  site_outro <- xml_list$record$person$`external-identifiers`[i]$`external-identifier`$`external-id-type`
  } else {
          
  site_outro <- NA}
        
  if (!is.null(xml_list$record$person$`external-identifiers`[i]$`external-identifier`$`external-id-url`)) {
  site_link <- xml_list$record$person$`external-identifiers`[i]$`external-identifier`$`external-id-url`
  } else {
          
  site_link <- NA}
        
  outros_id <- as.character(append(outros_id, site_outro))  
  outros_link<- as.character(append(outros_link, site_link))
        
  id1<-xml_list$record$`orcid-identifier`$path[[1]]
  id_aux<-as.character(append(id_aux, id1))
        
}}
    
df_inicial<-unique(data.frame(ORCID_IDs = id_aux, Nome = NA, País = NA, Mídia = NA, links = NA, Domínio = NA, Outros_ID = outros_id, Link_Outros_ID = outros_link))
    
remove(xml_list, id1, id_aux)
    
id_aux<-character()
id_aux2<-character()
    
# Identificação do total de links de web site e midias sociais
    
for (i in orcid_links){
      
xml_list<-read_xml(i)
      
xml_list<-as_list(xml_list) 
      
      total_links<-length(xml_list$record$person$`researcher-urls`) 
      
      total<-append(total, total_links)
      
# Extração de web site e midias sociais
      
  for (i in 2:max(total)){
        
  if(!is.null(xml_list$record$person$`researcher-urls`[i]$`researcher-url`$`url-name`)){
  site_nome<-xml_list$record$person$`researcher-urls`[i]$`researcher-url`$`url-name`
  }else{
  site_nome<-NA }  
        
  if(!is.null(xml_list$record$person$`researcher-urls`[i]$`researcher-url`$url)){  
  site_link<-xml_list$record$person$`researcher-urls`[i]$`researcher-url`$url
  }else{
  site_link<-NA}
      
  rede<-as.character(append(rede, site_nome))
  links<-as.character(append(links, site_link))
        
  id1<-xml_list$record$`orcid-identifier`$path[[1]]
  id_aux<-as.character(append(id_aux, id1))
      
}  
      
 #Extração dos nomes dos pesquisadores
      
 for (i in xml_list) {    
        
 nome<-paste0(xml_list$record$person$name$`given-names`," ",xml_list$record$person$name$`family-name`)
 nome_orcid<-append(nome_orcid, nome)
        
 id2<-xml_list$record$`orcid-identifier`$path[[1]]
 id_aux2<-as.character(append(id_aux2, id2))
        
} }
    
df_sec<-data.frame(ORCID_IDs = id_aux, Nome = NA, País = NA, Mídia = rede, links = links, Domínio = NA, Outros_ID = NA, Link_Outros_ID = NA)  

remove(xml_list, id1, id_aux, id_aux2)
   
#País de Origem
    
pais<-character()
    
for (i in orcid_links){
      
xml_doc<-read_xml(i)
      
ns <- xml_ns(xml_doc)
      
#Extração dos países dos pesquisadores  
      
pais_extract<-xml_text(xml_find_first(xml_doc, ".//common:country", ns = ns))

pais<-append(pais, pais_extract)

}
    
pais[is.na(pais)]<-"Sem registro"
    
df_ter<-data.frame(ORCID_IDs = orcids$V1, Nome = nome_orcid, País = pais, Mídia = NA, links = NA, Domínio = NA, Outros_ID = NA, Link_Outros_ID = NA)
    
#Criando Dataframe para visualização

sites_clean <- gsub("^https?://(www\\.|www2\\.|app\\.)?|/.*$", "", links)
sites_clean <- sub("\\..*", "", sites_clean)

df_sec$Domínio<-sites_clean

df<-rbind(df_inicial,df_sec,df_ter)

#Ajustes para melhor visualização dos Dataframes
    
df<- df%>%
group_by(ORCID_IDs) %>%
fill(Nome, .direction = "downup") %>%
ungroup()
    
df<- df%>%
group_by(ORCID_IDs) %>%
fill(País, .direction = "downup") %>%
ungroup()
    
df<-unique(df)
    
df$Mídia[is.na(df$Mídia)] <- "" 
df$Outros_ID[is.na(df$Outros_ID)] <- ""
    
df <- df %>%
mutate(across(Mídia:Link_Outros_ID, ~ replace_na(., ""))) %>%  # Substituir NA por ""
group_by(Nome) %>%
mutate(has_pais = any(País != "NA" & País != "")) %>%  # Verifica se o nome já tem país preenchido
ungroup() %>%
filter(!(País == "NA" & Mídia == "" & links == "" & Domínio == "" & Outros_ID == "" & Link_Outros_ID == "" & has_pais))
    
df<-df[-9]
    
df<-unique(df)
    
df <- df %>%
group_by(ORCID_IDs) %>%
arrange(desc(Outros_ID != ""), .by_group = TRUE) %>%
ungroup()
    
df<-unique(df)
    
df <- df %>%
group_by(Nome) %>%
filter(!(n() > 1 & Mídia == "" & links == "" & Domínio == "" & Outros_ID == "" & Link_Outros_ID == "")) %>%
ungroup()
    
### Dataframe Geral ###
    
df_geral<-df
remove(df)
colnames(df_geral)[1]<-"ORCID IDs"
colnames(df_geral)[4]<-"Website & social links"
colnames(df_geral)[5]<-"Links - Website & social links"
colnames(df_geral)[7]<-"Outros ID"
colnames(df_geral)[8]<-"Links - Outros ID"

#######
    
####### Dataframe Agregate para tabela sumarizada
    
df_final <- aggregate(
cbind(Domínio, df_geral$`Outros ID`) ~ df_geral$`ORCID IDs` + Nome, 
data = df_geral, 
      FUN = function(x) paste(unique(x[x != ""]), collapse = "; ")
)

df_final[df_final==""]<-"Sem presença online"
colnames(df_final)[1]<-"ORCID_IDs"
colnames(df_final)[4]<-"Outros ID"
  
df_final<-unique(merge(df_final, df_ter[, c("ORCID_IDs", "País")], by = "ORCID_IDs", all.x = TRUE))

df_final<-df_final %>% select(ORCID_IDs, Nome, País, everything())
    
colnames(df_final)[1]<-"ORCID IDs"

###### DataFrame Sumarizado

colnames(df_geral)[6]<-"Domínio (Plataforma)"    
df_sum<-df_final
remove(df_final)
colnames(df_sum)[4]<-"Domínio (Plataforma)"

#######
    
#Tabela dupla pais x rede
    
tab<-table(df_geral$`Domínio (Plataforma)`,df_geral$País)[-1,]
    
#######
    
cat("\n As tabelas com dados gerais, dados sumarizados e o cruzamento entre plataforma e país foram geradas \n\n",
        "Acesse: df_geral, df_sum e tab")
    
read_aux<-readline("Deseja gerar a rede de presença online? (S/N): ")
    
    
if (read_aux == "S" | read_aux == "s") {
      
      
#######
      
#GERANDO REDE DE ENTRE DOMÍNIOS (Coocorrência)
      
b4<-strsplit(as.character(df_sum$`Domínio (Plataforma)`), split = "; " , fixed = FALSE)
  
b5<-as.data.frame(do.call(cbind, b4))
  
#Ajuste para stack
  
b6<-stack(b5)
  
#Matriz de coocorrência
  
mtx<-table(stack(b5))
  
mtx[mtx>1]<-1
  
mtx_co<-mtx%*%t(mtx) 
  
diag(mtx_co)<-0
  
#Rede igraph
  
rede_co<-graph_from_adjacency_matrix(mtx_co, weighted = T, mode = "undirected")
  
#Oede visNetwork
  
vis_co<-toVisNetworkData(rede_co)
  
#Organizacao da rede
  
node_co<-data.frame("id"=vis_co$nodes$id, "label"=vis_co$nodes$label)
links_co<-as.data.frame(vis_co$edges) 
colnames(links_co)[3]<-'width'
  
#Rede VIS
    
vis<-visNetwork(node_co, links_co) %>% 
     visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
     visIgraphLayout(layout ="layout_with_fr")
      
print(vis) 
      
save<-readline("Deseja salvar as tabelas e a rede de presença online? (S/N): ")
      
if (save == "S" | save == "s") {
        
#salvando arquivos
        
#Salva XLSX Dados Gerais, Dados Sumarizados e Tabela País X Rede

links_co2<-links_co
colnames(links_co2)[1]<-"Plataforma"
colnames(links_co2)[2]<-"Plataforma"
colnames(links_co2)[3]<-"Coocorrência"
  
          
write.xlsx(list("Dados Gerais"=df_geral, "Dados Sumarizados"=df_sum, 
                "Tabela País x Plataforma"=tab, "Coocorrência entre Plataformas"=links_co2), file = "presenca_online.xlsx")
        
#Salva rede em HTML

visSave(graph=visNetwork(node_co, links_co) %>%
        visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
        visIgraphLayout(layout = "layout_with_fr"), "rede de presenca online.html")
        
print("A planilha com os dados e a rede de presença online foram salvos em seu diretório padrão")
        
} } else {
        
        
save2<-readline("Deseja salvar as tabelas geradas (S/N): ")
        
if (save2 == "S" | save2 =="s"){
          
write.xlsx(list("Dados Gerais"=df_geral, "Dados Sumarizados"=df_sum, 
                "Tabela País x Plataforma"=tab), file = "presenca_online.xlsx")
          
print("A planilha com os dados foram salvos em seu diretório padrão")  

cat("\n Para visualização de dados execute:\n\n",
    
    "df_geral: dados gerais\n",
    "df_sum: dados sumarizados\n",
    "tab: tabela cruzada entre países e redes\n",
    "vis: rede de presença online entre ORCID e Rede\n")
          
} else {
          
cat("Para visualização de dados execute:\n\n",
              
"df_geral: dados gerais\n",
"df_sum: dados sumarizados\n",
"tab: tabela cruzada entre países e plataformas\n",
"vis: rede de presença online entre ORCID e Rede\n")
}
        
}
    
})
  
}
