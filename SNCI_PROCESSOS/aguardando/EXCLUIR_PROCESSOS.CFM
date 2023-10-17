
<cfprocessingdirective pageencoding = "utf-8">	

<cfset taskName = "EnviaEmailMarcelo"> <!-- Nome da tarefa -->
<cfschedule
  action="update"
  task="#taskName#"
  operation="httprequest"
  url="http://desenvolvimentope/snci/snci_processos/aguardando/executaSQL.cfm"
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