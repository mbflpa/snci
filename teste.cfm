<cfset inicio = GetTickCount()>
  
<cfset inst = "#createobject("component","CFIDE.adminapi.runtime")#">
<--- <cfobject action="CREATE" type="JAVA" class="java.net.InetAddress" name="maq">
<cfset variables.instancia = inst.getinstancename()>
<cfset variables.servername=maq.localhost.gethostname()>
<cfset variables.serverip = maq.localhost.getHostAddress()>
---!>
<html>
  <head>
    <title>TESTE CF</title>
  </head>
  <body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <table width="280" height="100" border="1" align="left" cellpadding="2" cellspacing="0" bordercolor="#003366">
      <tr> 
	  	<td>Data/Hora: <b><cfoutput>#now()#</cfoutput></b><br>
        	Server: <b><cfoutput>#servername# (#serverip#)</cfoutput></b><br>
        	Instância: <b><cfoutput>#instancia#</cfoutput></b>
        </td>
	  </tr>
    </table>
   </body>
</html>
<cfset fim = GetTickCount()>
<cfset tempoExecucao = fim-inicio>
<font color="#ff0000"><b>Tempo de execução da página:&nbsp;</b><cfoutput>#tempoExecucao#</cfoutput>&nbsp;&nbsp;milisegundos</font>

