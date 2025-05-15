<cfcomponent>
	<cfprocessingdirective pageencoding = "utf-8">	
	<cfparam name = "dsnSNCI" default = "DBSNCI"> 
    <cffunction name="init">
        <cfreturn this>
    </cffunction>
	<!--- Este método revisores por ano e cod_se --->
	<cffunction  name="revisores" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cftransaction>
			<cfquery name="rsRevisor" datasource="DBSNCI">
				SELECT Usu_Matricula, Usu_Apelido
				FROM Usuarios
				WHERE trim(Usu_GrupoAcesso) = 'GESTORES' AND Usu_DR = '#codse#'
			</cfquery>
			<cfreturn rsRevisor>
		</cftransaction>
	</cffunction>  	
    <!--- Este método Nº das avaliações por ano/cod_se e Matricula inspetor --->
    <cffunction  name="avaliacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
        <cfargument name="codse" required="true">
        <cfargument name="matr" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
        <cftransaction>
            <cfquery name="rsavalia" datasource="DBSNCI">
				SELECT INP_NumInspecao,Und_Descricao,INP_DTConcluirRevisao,Usu_Matricula,Dir_Sigla
				FROM ((Inspecao 
				INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
				INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
				INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
				where
				Usu_Matricula='#matr#' AND
				INP_NumInspecao Like '%#ano#' AND 
				(INP_DTConcluirRevisao Between '#dtinic#' and '#dtfinal#') AND 
				INP_DTConcluirRevisao is not null
				ORDER BY INP_NumInspecao,Und_Descricao
            </cfquery>
            <cfreturn rsavalia>
        </cftransaction>
    </cffunction> 
	
	<!--- Este método inspetores por ano e cod_se --->
	<cffunction  name="gestao" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cfargument name="matrevisor" required="true">
		<cfargument name="aval" required="true">
		<cftransaction>
			<cfquery name="rsgestao" datasource="DBSNCI">
				SELECT RIP_NumInspecao, TUN_Descricao, format(INP_DTConcluirAvaliacao,'dd-MM-yyyy') as INPDTConcluirAvaliacao, format(INP_RevisorDTInic,'dd-MM-yyyy HH:mm:ss') as INPRevisorDTInic, max(format(RIP_DtUltAtu,'dd-MM-yyyy HH:mm:ss')) AS ripdtultatu, format(INP_DTConcluirRevisao,'dd-MM-yyyy') as INPDTConcluirRevisao 
				FROM (((Inspecao INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
				INNER JOIN Unidades ON RIP_Unidade = Und_Codigo) INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo) 
				INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login
				WHERE (((Usu_Matricula)='#matrevisor#'))
				GROUP BY RIP_NumInspecao, TUN_Descricao, INP_DTConcluirAvaliacao, INP_RevisorDTInic, INP_DTConcluirRevisao
				HAVING (((RIP_NumInspecao) Like '%#ano#') AND ((INP_DTConcluirRevisao) Between '#dtinic#' and '#dtfinal#') AND (INP_DTConcluirRevisao is not null))
				<cfif aval neq 't'>
					and RIP_NumInspecao='#aval#'
				</cfif>
				ORDER BY RIP_NumInspecao
			</cfquery>
			<cfreturn rsgestao>
		</cftransaction>
	</cffunction>  	  	
</cfcomponent>