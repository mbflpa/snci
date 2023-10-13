
<cfprocessingdirective pageencoding = "utf-8">	

<cfset taskName = "EnviaEmailTeste"> <!-- Nome da tarefa -->
<cfschedule
  action="update"
  task="#taskName#"
  operation="httprequest"
  url="http://desenvolvimentope/snci/snci_processos/aguardando/executaSQL.cfm"
  startDate="#dateFormat(now(), 'yyyy/mm/dd')#" 
  startTime="#timeFormat(now(), 'hh:mm tt')#" 
  interval="once"
  resolveURL="yes"
/>
<cfschedule action="list" result="taskQuery">
<cfdump var="#taskQuery#">