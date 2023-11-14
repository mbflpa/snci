<cfapplication 
name="conteudo" 
sessionmanagement="Yes" 
clientmanagement="Yes" 
sessiontimeout="#createtimespan(0,0,45,0)#" 
applicationtimeout="#createtimespan(0,0,30,0)#">
    
<cfinclude template="parametros.cfm"> 
