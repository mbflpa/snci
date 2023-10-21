
<cfprocessingdirective pageencoding = "utf-8">	
<cfset rotina = "http://#application.auxsite#/snci/snci_processos/aguardando/executaSQL.cfm">
<cfset taskName = "EnviaEmailMarcelo_#application.auxsite#"> <!-- Nome da tarefa -->
<cfschedule
  action="update"
  task="#taskName#"
  operation="httprequest"
  url="#rotina#"
  startDate="#dateFormat(now(), 'yyyy/mm/dd')#" 
  startTime="#timeFormat(now(), 'hh:mm tt')#" 
  interval="once"
  resolveURL="yes"
  path="E:/LogsCF/PE/"
  file="EnviaEmailMarcelo2.txt"
  publish="yes"
/>
<cfschedule action="list" result="taskQuery">
<cfdump var="#taskQuery#">

<cfobject component = "pc_cfcEmails" name = "pc_cfcEmails"/>
<cfinvoke component="#pc_cfcEmails#" method="EnviaEmails" returnVariable="sucessoEmail" 
    para = "marceloferreira@correios.com.br"
    copiaPara = "marceloferreira@correios.com.br"
    pronomeTratamento = "Senhor(a) Superintendente Estadual da SE/BA"
    texto = "Em cumprimento ao Plano Anual de Controle Interno – PACIN 2023, que 
            consolida o planejamento das ações a serem realizadas pelo Departamento de 
            Controle Interno – DCINT, encaminhamos o Relatório - SEI e seus respectivos 
            anexos, referentes à avaliação de controles no processo '0100012023', para conhecimento e adoção de providências nos termos 
            constantes dos aludidos documentos. 
            Considerando os resultados das análises e ORIENTAÇÕES/PROPOSTAS DE 
            MELHORIA” apresentadas no mencionado relatório, recomenda-se a essa 
            SE/BA a elaboração de plano de ação, com estabelecimento de 
            prazos e responsáveis, objetivando a implementação de melhorias no processo 
            avaliado. 
            O plano de ação deverá apresentar providências focadas nas “Situações 
            Encontradas registradas nos Anexos I, considerando as ORIENTAÇÕES para 
            Regularização citadas no Anexo III. O prazo de resposta inicial para este 
            Relatório é de 30 dias, a contar do recebimento deste. 
            Ressalta-se que a implementação do plano de ação será acompanhada pelo 
            CONTROLE INTERNO, e todas as ações implementadas deverão ser 
            evidenciadas (documentadas) por esse gestor, com a inserção das 
            comprovações no sistema SNCI Processos.
            Orientamos a acessar o link 
            http://intranetsistemaspe/snci/snci_processos/index.cfm, Tela 
            “Acompanhamento”, aba “Medidas / Orientações para regularização” e inserir 
            sua resposta. "
/>
<cfdump var = "#sucessoEmail#" >