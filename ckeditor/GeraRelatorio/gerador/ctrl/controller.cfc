<!------------------------------------------------------------------>
<!---@Nome: Controlador para reletórios ---------------------------->
<!---@Descrição: --->
<!---@Data: 07/07/2010 --------------------------------------------->
<!---@Autor: Sandro Mendes - GESIT/SSAD----------------------------->
<!------------------------------------------------------------------>

<cfcomponent>

	<cffunction name="geraRelatorio" access="public" returntype="query">

	<cfset var qryRelatorio = ''>
	<cfinclude template="../../../parametros.cfm">

	   <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosRelatorio" returnvariable="qryRelatorio">
		    <cfinvokeargument name="id" value="#Form.id#">
	  </cfinvoke>

	   <cfreturn qryRelatorio>

	  <cfreturn qGrav>

	</cffunction>


	<cffunction name="geraPapelTrabalho" access="public" returntype="query">

	<cfset var qryPapelTrabalho = ''>
	<cfinclude template="../../../parametros.cfm">

	   <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadospapeltrabalho" returnvariable="qryPapelTrabalho">
		    <cfinvokeargument name="id" value="#Form.id#">
	  </cfinvoke>

	   <cfreturn qryPapelTrabalho>

	  <cfreturn qGrav>

	</cffunction>


   <cffunction name="geraRelatoriodata" access="public" returntype="query">

    <cfset var qryRelatorio = ''>
	<cfinclude template="../../../parametros.cfm">

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosRelatorio" returnvariable="qryRelatorio">
		    <cfinvokeargument name="dtini" value="#Form.dtini#">
		    <cfinvokeargument name="dtfim" value="#Form.dtfim#">
			<cfinvokeargument name="tipo" value="#Form.tipo#">
			<cfinvokeargument name="objetivo" value="#Form.objetivo#">
	  </cfinvoke>

		<cfreturn qryRelatorio>

		<cfreturn qGrav>


	</cffunction>


   <cffunction name="geraRelatorioarea" access="public" returntype="query">

    <cfset var qryRelatorio = ''>
	<cfinclude template="../../../parametros.cfm">

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosRelatorio" returnvariable="qryRelatorio">
		    <cfinvokeargument name="area" value="#Form.area#">
			<cfinvokeargument name="dtini" value="#Form.dtini#">
		    <cfinvokeargument name="dtfim" value="#Form.dtfim#">
			<cfinvokeargument name="tipo" value="#Form.tipo#">
	  </cfinvoke>

		<cfreturn qryRelatorio>

		<cfreturn qGrav>

	</cffunction>


	 <cffunction name="geraRelatorioUnidadearea" access="public" returntype="query">

    <cfset var qryRelatorio = ''>
	<cfinclude template="../../../parametros.cfm">

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosRelatorio" returnvariable="qryRelatorio">
		    <cfinvokeargument name="area" value="#Form.area#">
			<cfinvokeargument name="situacao" value="#Form.situacao#">
	  </cfinvoke>

		<cfreturn qryRelatorio>

		<cfreturn qGrav>

	</cffunction>

 <cffunction name="geraMatriculaInspetor" access="public" returntype="query">
	<cfset var qryInspetor = ''>
	<cfinclude template="../../../parametros.cfm">

	<cftry>

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosInspetor" returnvariable="qryInspetor">
		    <cfinvokeargument name="id" value="#Form.id#">
	  </cfinvoke>

		<cfreturn qryInspetor>

	   <cfcatch>
         <cfdump var="#cfcatch#">
         <cfabort>

       </cfcatch>

	 </cftry>
  </cffunction>

  <cffunction name="geraMatriculaData" access="public" returntype="query">

	<cfset var qryInspetor = ''>
	<cfinclude template="../../../parametros.cfm">

	<cftry>

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosInspetor" returnvariable="qryInspetor">
		    <cfinvokeargument name="dtini" value="#Form.dtini#">
		    <cfinvokeargument name="dtfim" value="#Form.dtfim#">
			<cfinvokeargument name="tipo" value="#Form.tipo#">
			<cfinvokeargument name="objetivo" value="#Form.objetivo#">
	  </cfinvoke>

		<cfreturn qryInspetor>

	   <cfcatch>
         <cfdump var="#cfcatch#">
         <cfabort>

       </cfcatch>

	 </cftry>
  </cffunction>
  <cffunction name="geraAnexoNumero" access="public" returntype="query">
  <cfargument name="vNumInspecao" required="yes" type="string">
  <cfargument name="vNumGrupo" required="yes" type="string">
  <cfargument name="vNumItem" required="yes" type="string">

	<cfset var qryAnexos = ''>
	<cfinclude template="../../../parametros.cfm">

	<cftry>

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaAnexos" returnvariable="qryAnexos">
		    <cfinvokeargument name="id" value="#vNumInspecao#">
			<cfinvokeargument name="grupo" value="#vNumGrupo#">
			<cfinvokeargument name="item" value="#vNumItem#">
	  </cfinvoke>

		<cfreturn qryAnexos>

	   <cfcatch>
         <cfdump var="#cfcatch#">
         <cfabort>
       </cfcatch>
	 </cftry>
  </cffunction>


  <cffunction name="geraInspetor" access="public" returntype="query">
  <cfargument name="vdataini" required="yes" type="string">
  <cfargument name="vdatafim" required="yes" type="string">

	<cfset var qryInspetores = ''>
	 <cfinclude template="../../../parametros.cfm">

	<cftry>
	   <!--- <cfdump var="#vdatafim#">
       <cfabort> --->

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaInspetor" returnvariable="qryInspetores">
		    <cfinvokeargument name="dataini" value="#vdataini#">
			<cfinvokeargument name="datafim" value="#vdatafim#">
	  </cfinvoke>

	 <!---  <cfdump var="#qryInspetores#">
       <cfabort> --->
		<cfreturn qryInspetores>

	   <cfcatch>
         <cfdump var="#cfcatch#">
         <cfabort>
       </cfcatch>
	</cftry>
  </cffunction>
  <cffunction name="geraCoordenador" access="public" returntype="query">
  <cfargument name="vdataini" required="yes" type="string">
  <cfargument name="vdatafim" required="yes" type="string">

	<cfset var qryCoordenadores = ''>
	 <cfinclude template="../../../parametros.cfm">

	<cftry>
	   <!--- <cfdump var="#vdatafim#">
       <cfabort> --->

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaCoordenador" returnvariable="qryCoordenadores">
		    <cfinvokeargument name="dataini" value="#vdataini#">
			<cfinvokeargument name="datafim" value="#vdatafim#">
	  </cfinvoke>

	 <!---  <cfdump var="#qryInspetores#">
       <cfabort> --->
		<cfreturn qryCoordenadores>
	   <cfcatch>
         <cfdump var="#cfcatch#">
         <cfabort>
       </cfcatch>
	</cftry>
  </cffunction>

  <!--- <cffunction name="geraRelatoriogrupo" access="public" returntype="query">

    <cfset var qryRelatorio = ''>
	<cfinclude template="../../../parametros.cfm">

	  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.cfc.model"
		  method="listaDadosRelatorio" returnvariable="qryRelatorio">
		    <cfinvokeargument name="dtini" value="#Form.dtini#">
		    <cfinvokeargument name="dtfim" value="#Form.dtfim#">
			<cfinvokeargument name="tipo" value="#Form.tipo#">
			<cfinvokeargument name="objetivo" value="#Form.objetivo#">
	  </cfinvoke>

		<cfreturn qryRelatorio>

		<cfdump var="#qryRelatorio#">
       <cfabort>

		<cfreturn qGrav>

	</cffunction>   --->
</cfcomponent>