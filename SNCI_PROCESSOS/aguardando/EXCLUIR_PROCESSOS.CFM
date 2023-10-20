
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