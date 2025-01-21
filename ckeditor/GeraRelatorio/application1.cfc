<!------------------------------------------------------------------>
<!---@Nome: --->
<!---@Descrição: --->
<!---@Data: --->
<!---@Autor: Sandro Mendes - GESIT/SSAD----------------------------->
<!------------------------------------------------------------------>


<cfcomponent>

<cfset this.name= "applicationDSN">

<cfset this.clientManagement=false>
<cfset this.sessionManagement=true>

<cffunction name= "onApplicationStart" returnType= "boolean" output="false">
		<cfset Application.DSN = "DBSNCI">
		<cfreturn true>
</cffunction>

</cfcomponent>