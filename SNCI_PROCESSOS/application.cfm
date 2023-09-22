<cfprocessingdirective pageencoding = "utf-8">
<!--- <cfapplication name="conteudo" sessionmanagement="yes" clientmanagement="yes" sessiontimeout="#createtimespan(0,0,45,0)#" applicationtimeout="120"> --->
<cfapplication 
name="conteudo" 
sessionmanagement="Yes" 
clientmanagement="Yes" 
sessiontimeout="#createtimespan(0,1,0,0)#" 
applicationtimeout="#createtimespan(0,6,0,0)#">
<cfinclude template="parametros.cfm"> 
