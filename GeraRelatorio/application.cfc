<!------------------------------------------------------------------>
<!---@Nome: --->
<!---@Descrição: --->
<!---@Data: --->
<!---@Autor: Sandro Mendes - GESIT/SSAD----------------------------->
<!------------------------------------------------------------------>


<cfcomponent>

<cfset this.name= "applicationSNCI">

<cfset this.clientManagement=false>
<cfset this.sessionManagement=true>
<cfset this.sessionTimeout= CreateTimeSpan(0,0,30,0)>

<cffunction name= "onApplicationStart" returnType= "boolean" output="false">
		<cfset Application.DSN = "DBSNCI">
		<cfreturn true>
</cffunction>

</cfcomponent>