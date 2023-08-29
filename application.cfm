<!--- <cfapplication name="conteudo" sessionmanagement="yes" clientmanagement="yes" sessiontimeout="#createtimespan(0,0,45,0)#" applicationtimeout="120"> --->
<cfapplication 
name="conteudo" 
sessionmanagement="Yes" 
clientmanagement="Yes" 
sessiontimeout="#createtimespan(0,2,0,0)#" 
applicationtimeout="#createtimespan(0,0,0,59)#">
<cfinclude template="parametros.cfm"> 
<!--- 
<cfset dsn_inspecao = 'DBSNCI'> --->