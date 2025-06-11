<cfcomponent>
	<cfprocessingdirective pageencoding = "utf-8">	
	<cfparam name = "dsnSNCI" default = "DBSNCI"> 
    <cffunction name="init">
        <cfreturn this>
    </cffunction>
	<!---  --->
	<cffunction  name="mostraravaliacao" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cfargument name="aval" required="true">
		<cftransaction>
			<cfquery name="qAcesso" datasource="DBSNCI">
				SELECT Usu_GrupoAcesso,Usu_Coordena
				FROM Usuarios
				WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
			</cfquery>
			<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
			<cfquery name="rsgestao" datasource="DBSNCI">
				SELECT INP_NumInspecao, Und_Descricao, format(INP_DTConcluir_Despesas,'dd-MM-yyyy HH:mm:ss') as inpdtconcluirdespesas, Usu_Apelido, INP_ValorPrevisto, INP_AdiNoturno, INP_Deslocamento, INP_Diarias, INP_PassagemArea, INP_ReembVeicProprio, INP_RepousoRemunerado, INP_RessarcirEmpregado, INP_Outros
				FROM (Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
				INNER JOIN Usuarios ON INP_LoginGestor_Despesas = Usu_Login
				WHERE INP_DTConcluir_Despesas between '#dtinic#' and '#dtfinal#' 
				and Right(INP_NumInspecao,4)='#ano#' 
				<cfif codse neq 't'>
					and Und_CodDiretoria = '#codse#'
				</cfif>
				<cfif aval neq 't'>
					and INP_NumInspecao = '#aval#'
				</cfif>
				<cfif codse eq 't' and aval eq 't' and grpacesso eq 'GESTORES'>
					and Und_CodDiretoria in (#qAcesso.Usu_Coordena#)
				</cfif>
				ORDER BY Und_CodDiretoria, INP_NumInspecao
			</cfquery>
			<cfreturn rsgestao>
		</cftransaction>
	</cffunction>  	  	
	    <!--- --->
    <cffunction  name="despesasavaliacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
        <cfargument name="codse" required="true">	
        <cftransaction>
			<cfquery name="qAcesso" datasource="DBSNCI">
				SELECT Usu_GrupoAcesso,Usu_Coordena
				FROM Usuarios
				WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
			</cfquery>
			<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>			
            <cfquery name="rsavalia" datasource="DBSNCI">
				SELECT INP_NumInspecao, Und_Descricao
				FROM Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo
				WHERE INP_DTConcluir_Despesas between '#dtinic#' and '#dtfinal#' 
				AND Right(INP_NumInspecao,4)='#ano#'
				<cfif codse neq 't'>
					and Und_CodDiretoria = '#codse#'
				</cfif>
				<cfif codse eq 't' and grpacesso eq 'GESTORES'>
					and Und_CodDiretoria in (#qAcesso.Usu_Coordena#)
				</cfif>
				order by Und_CodDiretoria, INP_NumInspecao
            </cfquery>
            <cfreturn rsavalia>
        </cftransaction>
    </cffunction> 
	<cffunction  name="revisores" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cftransaction>
			<cfquery name="rsrevisores" datasource="DBSNCI">
			SELECT Usu_Matricula, Usu_Apelido
			FROM (Inspecao INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
			INNER JOIN Unidades ON INP_Unidade = Und_Codigo
			WHERE INP_DTConcluirRevisao Between '#dtinic#' And '#dtfinal#' 
			AND Und_CodDiretoria = '#codse#' 
			AND Right(INP_NumInspecao,4)='#ano#'
			GROUP BY Usu_Matricula, Usu_Apelido
			</cfquery>
			<cfreturn rsrevisores>
		</cftransaction>
	</cffunction>  
	<cffunction  name="avaliacao" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cfargument name="matr" required="true">
		<cftransaction>
			<cfquery name="rsavaliacao" datasource="DBSNCI">
				SELECT INP_NumInspecao, Trim(Und_Descricao) AS Und_Descricao, INP_DTConcluirRevisao, Usu_Matricula, Trim(Dir_Sigla) AS Dir_Sigla
				FROM ((Inspecao INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
				INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
				INNER JOIN Diretoria ON Usu_DR = Dir_Codigo
				WHERE INP_DTConcluirRevisao Between '#dtinic#' And '#dtfinal#'  
				AND Usu_Matricula ='#matr#' 
				AND Und_CodDiretoria = '#codse#' 
				AND Right(INP_NumInspecao,4)='#ano#'
				GROUP BY INP_NumInspecao, Trim(Und_Descricao), INP_DTConcluirRevisao, Usu_Matricula, Trim(Dir_Sigla)
				HAVING INP_DTConcluirRevisao Between '#dtinic#' And '#dtfinal#' 
				order by Dir_Sigla, INP_NumInspecao
			</cfquery>
			<cfreturn rsavaliacao>
		</cftransaction>
	</cffunction> 	
	<cffunction  name="gestao" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="ano" required="true">
		<cfargument name="dtinic" required="true">
		<cfargument name="dtfinal" required="true">
		<cfargument name="codse" required="true">
		<cfargument name="matrevisor" required="true">		
		<cfargument name="aval" required="true">		
		<cftransaction>
			<cfquery name="rsgestao" datasource="DBSNCI">
				SELECT INP_NumInspecao, Trim(TUN_Descricao) AS TUN_Descricao, format(INP_DTConcluirAvaliacao,'dd/MM/yyyy'), format(INP_RevisorDTInic,'dd/MM/yyyy, HH:MM'), max(format(RIP_DtUltAtu,'dd/MM/yyyy, HH:MM')) AS RIPDtUltAtu, format(INP_DTConcluirRevisao,'dd/MM/yyyy')
				FROM Inspecao INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login
				INNER JOIN Unidades ON INP_Unidade = Und_Codigo
				INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade) AND (INP_Unidade = RIP_Unidade)
				INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
				WHERE Usu_Matricula = '#matrevisor#' 
				AND Und_CodDiretoria = '#codse#' 
				<cfif aval neq 't'>
					and INP_NumInspecao = '#aval#'
				</cfif>
				AND Right(INP_NumInspecao,4)='#ano#'
				GROUP BY INP_NumInspecao, Trim(TUN_Descricao), INP_DTConcluirAvaliacao, INP_RevisorDTInic, INP_DTConcluirRevisao
				HAVING INP_DTConcluirRevisao Between '#dtinic#' And '#dtfinal#' 
			</cfquery>
			<cfreturn rsgestao>
		</cftransaction>
	</cffunction> 	
	
</cfcomponent>