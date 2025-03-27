<cfif FileExists(ExpandPath("./Application.cfc"))>
    <!--- Arquivo mantido apenas por compatibilidade. A aplicação agora utiliza Application.cfc --->
    <cfabort>
</cfif>