<cfcomponent displayname="Componentes SNCI" hint="modulo de permissões">

	<cffunction name="rsqArea" access="public" returntype="query">
		<cfset var qArea="">
		<cfquery name="qArea" datasource="DBSNCI">
		  SELECT TOP 1 '---' as Usu_GrupoAcesso FROM Usuarios  UNION 
		  SELECT DISTINCT RTRIM(LTRIM(Usu_GrupoAcesso)) as Usu_GrupoAcesso FROM Usuarios 
		  ORDER BY Usu_GrupoAcesso ASC
		</cfquery>
		<cfreturn qArea>
	</cffunction>
	
	<cffunction name="rsArea1" access="public" returntype="query">
		<cfset var Area1="">
		<cfquery name="Area1" datasource="DBSNCI">
		 SELECT DISTINCT Ars_Sigla, Ars_Codigo, Ars_Descricao
		 FROM Areas WHERE Ars_Status = 'A' AND (LEFT(Ars_Codigo,2) = '#arguments.sSEprinci#' or LEFT(Ars_Codigo,2) = '#arguments.sSEsubord#')
		 ORDER BY Ars_Codigo, Ars_Sigla
		</cfquery>
		<cfreturn Area1>
	</cffunction>
	
	<cffunction name="rsqSE" access="public" returntype="query">
		<cfset var qSE="">
		<cfquery name="qSE" datasource="DBSNCI">
		SELECT DISTINCT Dir_Codigo, Dir_Sigla
		 FROM Diretoria WHERE Dir_Status = 'A' AND (Dir_Codigo = '#arguments.sSEprinci#' or Dir_Codigo = '#arguments.sSEsubord#')
		 ORDER BY Dir_Codigo, Dir_Sigla
		</cfquery>
		<cfreturn qSE>
	</cffunction>
	
	<cffunction name="rsqCS" access="public" returntype="query">
		<cfset var qCS="">
		<cfquery name="qCS" datasource="DBSNCI">
		 SELECT DISTINCT Ars_Sigla, Ars_Codigo, Ars_Descricao FROM Areas
		 WHERE Ars_Status = 'A' AND LEFT(Ars_Codigo,2)= '01' ORDER BY Ars_Codigo, Ars_Sigla
		</cfquery>
		<cfreturn qCS>
	</cffunction>
	
	<cffunction name="rsqReop" access="public" returntype="query">
		<cfset var qReop="">
		<cfquery name="qReop" datasource="DBSNCI">
		SELECT Rep_Codigo, Rep_Nome, Rep_Sigla, Rep_CodDiretoria
		  FROM Reops WHERE Rep_Status = 'A' AND (Rep_CodDiretoria = '#arguments.sSEprinci#' or Rep_CodDiretoria = '#arguments.sSEsubord#')
		  order by Rep_CodDiretoria
		 </cfquery>
		<cfreturn qReop>
	</cffunction>
	
	<cffunction name="rsqUnidade" access="public" returntype="query">
		<cfset var qUnidade="">
		<cfquery name="qUnidade" datasource="DBSNCI">
		 SELECT DISTINCT Und_Codigo, Und_Descricao, Und_CodDiretoria
		 FROM Unidades WHERE Und_Status = 'A' AND (UND_CodDiretoria =  '#arguments.sSEprinci#' or UND_CodDiretoria = '#arguments.sSEsubord#')
		 ORDER BY Und_Descricao, Und_CodDiretoria 
		</cfquery>
		<!--- <cfdump var="#qUnidade#">--->
 		<cfreturn qUnidade>
	</cffunction>
	
	<cffunction name="rsqArea2" access="public" returntype="query">
		<cfset var qArea2="">
		<cfquery name="qArea2" datasource="DBSNCI">
		 SELECT DISTINCT Ars_Sigla, Ars_Codigo, Ars_Descricao
		 FROM Areas WHERE Ars_Status = 'A' AND Ars_Sigla Like '%GCOP%' AND (LEFT(Ars_Codigo,2) = '#arguments.sSEprinci#' or LEFT(Ars_Codigo,2) = '#arguments.sSEsubord#') ORDER BY Ars_Codigo, Ars_Sigla
		</cfquery>
		<cfreturn qArea2>
    </cffunction> 
	<cffunction name="rsqArea3" access="public" returntype="query">
		<cfset var qArea3="">
		<cfquery name="qArea3" datasource="DBSNCI">
		 SELECT Ars_Sigla, Ars_Codigo, Ars_Descricao
		 FROM Areas WHERE Ars_Status = 'A' AND Ars_Sigla Like '%dcint%' AND (LEFT(Ars_Codigo,2) = '#arguments.sSEprinci#' or LEFT(Ars_Codigo,2) = '#arguments.sSEsubord#') ORDER BY Ars_Codigo, Ars_Sigla
		</cfquery>
		<cfreturn qArea3>
    </cffunction>
    <cffunction name="rsgov" access="public" returntype="query">
		<cfset var qGov3="">
		<cfquery name="qGov3" datasource="DBSNCI">
		 SELECT Ars_Sigla, Ars_Codigo, Ars_Descricao
		 FROM Areas WHERE Ars_Status = 'A' AND (LEFT(Ars_Codigo,2) = '01') ORDER BY Ars_Codigo, Ars_Sigla
		</cfquery>
		<cfreturn qGov3>
    </cffunction>		
</cfcomponent>
