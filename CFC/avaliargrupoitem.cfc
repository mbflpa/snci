<cfcomponent>
	<cfprocessingdirective pageencoding = "utf-8">	
	<cfparam name = "dsnSNCI" default = "DBSNCI"> 
    <cffunction name="init">
        <cfreturn this>
    </cffunction>
	<cffunction name="contaravaliador" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numinspecao" required="true">
        <cftry>			
			<cfquery name="rsqtd" datasource="DBSNCI">
				SELECT distinct IPT_MatricInspetor,RIP_NumInspecao FROM Inspetor_Inspecao 
				LEFT JOIN Resultado_Inspecao ON (IPT_NumInspecao = RIP_NumInspecao) AND (IPT_MatricInspetor = RIP_MatricAvaliador)
				where  IPT_NumInspecao='#numinspecao#'
			</cfquery>

            <cfcatch type="any">
                <cfset ret = 0>  
            </cfcatch>
        </cftry>
        <cfreturn rsqtd>
    </cffunction>	
    <cffunction name="grupoitemreanalise" access="remote" returntype="any">
		<cfargument name="grpacesso" required="true">
        <cfargument name="numinspecao" required="true">
        <cfargument name="grp" required="true">
        <cfargument name="itm" required="true">
		<cfargument name="respondereanalise" required="true">
		<cfargument name="textoinicial" required="true">	
		
        <cftry>			
			<cfquery name="qAcesso" datasource="DBSNCI">
				select Usu_login, Usu_Apelido, Usu_LotacaoNome
				from usuarios 
				where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
			</cfquery>
			<cfset maskcgiusu = ucase(trim(qAcesso.Usu_login))>
			<cfif left(maskcgiusu,8) eq 'EXTRANET'>
				<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
			<cfelse>
				<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
			</cfif>	
		
			<!--- Update na tabela Resultado_Inspecao--->
			<cfquery name="rsreanalise" datasource="DBSNCI">
				select RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor
				from Resultado_Inspecao 
				where RIP_NumInspecao = '#numinspecao#' and RIP_NumGrupo = #grp# and RIP_NumItem = #itm#
			</cfquery>
			<cfset auxcrit = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #textoinicial# & CHR(13) & #respondereanalise# & CHR(13)  &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qAcesso.Usu_Apelido) & '\' & Trim(qAcesso.Usu_LotacaoNome) & CHR(13) & '--------------------------------------------------------------------------------------------------' & CHR(13) & #rsreanalise.RIP_Critica_Inspetor#>
			<cfquery datasource="DBSNCI">
				UPDATE Resultado_Inspecao set 
				RIP_Recomendacao = 'R'
				, RIP_Critica_Inspetor='#auxcrit#'
				<cfif grpacesso eq 'GESTORES'>
					, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
					, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
				</cfif>	  			
				where RIP_NumInspecao = '#numinspecao#' and RIP_NumGrupo = #grp# and RIP_NumItem = #itm#
			</cfquery>
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Inspecao SET INP_AvaliacaoAtiva = 'S'
				WHERE INP_NumInspecao='#numinspecao#'
			</cfquery>	
			<cfset ret = 'Alteração realizada com sucesso!'> 		
            <cfcatch type="any">
                <cfset ret = 'Alteração Falhou!'>  
            </cfcatch>
        </cftry>
        <cfreturn #ret#>
    </cffunction>	
    <cffunction  name="respostareanalise" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numinspecao" required="true">
        <cfargument name="grupo" required="true">
        <cfargument name="item" required="true">  
        <cftransaction>
            <cfquery name="rsrespostareanalise" datasource="DBSNCI">
				SELECT RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor
				FROM Resultado_Inspecao
				where RIP_NumInspecao = '#numinspecao#' and RIP_NumGrupo = #grupo# and RIP_NumItem = #item#
            </cfquery>
            <cfreturn rsrespostareanalise>
        </cftransaction>
    </cffunction> 	
	<cffunction  name="reincidenciafechadoaval" access="remote" ReturnFormat="json" returntype="any">
		<cfargument name="posinsp" required="true">
		<cfargument name="grupo" required="true">
        <cfargument name="item" required="true">
        <cftransaction>
            <cfquery name="rsAval" datasource="DBSNCI">
				SELECT 
				Itn_Descricao,
				Grp_Descricao,
				Itn_Pontuacao,
				Itn_Classificacao,
				RIP_Resposta,
				Fun_Nome,
				RIP_NumInspecao,
				RIP_COMENTARIO,
				RIP_Recomendacoes,
				Pos_Situacao_Resp,
				STO_Descricao,
				Pos_Parecer
				FROM ((((Resultado_Inspecao 
				INNER JOIN Unidades ON RIP_Unidade = Und_Codigo) 
				INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)) 
				INNER JOIN Itens_Verificacao ON (convert(char(4),Rip_Ano) = Itn_Ano) and (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo))
				INNER JOIN Grupos_Verificacao ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)) 
				INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric AND RIP_MatricAvaliador = Fun_Matric 
				INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)
				INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
				WHERE RIP_NumInspecao ='#posinsp#' and RIP_NumGrupo = #grupo# and RIP_NumItem = #item# 
			</cfquery>
            <cfreturn rsAval>
        </cftransaction>
    </cffunction>		
    <cffunction  name="reincidenciafechado" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numinspecao" required="true">
		<cfargument name="codunid" required="true">
		<cfargument name="Itnreincidentes" required="true">
		<cfset grp=''>
		<cfset itm=''>
		<cfset grpitmsql='Pos_Unidade is null'>
		<cfloop index="index" list="#itnreincidentes#">
			<cfset grpitm = Replace(index,'_',',',"All")>
			<cfset grp = left(grpitm,find(",",grpitm)-1)>
			<cfset itm = mid(grpitm,(find(",",grpitm) + 1),len(grpitm))>
			<cfif grpitmsql eq 'Pos_Unidade is null'>
				<cfset grpitmsql = "Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
			<cfelse>
				<cfset grpitmsql = #grpitmsql# & " or Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
			</cfif>
			<cfset grp=''>
			<cfset itm=''>
		</cfloop> 
		<cfset anolimit = (year(now()) - 2)>
        <cftransaction>
            <cfquery name="rsreincfechado" datasource="DBSNCI">
				SELECT top 1 Pos_Inspecao,Pos_NumGrupo,Pos_NumItem
				FROM ParecerUnidade 
				WHERE Pos_Inspecao <> '#numinspecao#' 
				AND Pos_Unidade = '#codunid#' AND (#grpitmsql#)
				and Pos_Situacao_Resp in(3,25,26,27,29) and RIGHT(Pos_Inspecao,4) >= #anolimit#
				order by right(Pos_Inspecao,4) desc
            </cfquery>
            <cfreturn rsreincfechado>
        </cftransaction>
    </cffunction> 		
    <cffunction  name="reincidenciaemaberto" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numinspecao" required="true">
		<cfargument name="codunid" required="true">
		<cfargument name="Itnreincidentes" required="true">
		<cfset grp=''>
		<cfset itm=''>
		<cfset grpitmsql='Pos_Unidade is null'>
		<cfloop index="index" list="#itnreincidentes#">
			<cfset grpitm = Replace(index,'_',',',"All")>
			<cfset grp = left(grpitm,find(",",grpitm)-1)>
			<cfset itm = mid(grpitm,(find(",",grpitm) + 1),len(grpitm))>
			<cfif grpitmsql eq 'Pos_Unidade is null'>
				<cfset grpitmsql = "Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
			<cfelse>
				<cfset grpitmsql = #grpitmsql# & " or Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
			</cfif>
			<cfset grp=''>
			<cfset itm=''>
		</cfloop> 
		<cfset anolimit = (year(now()) - 2)>
        <cftransaction>
            <cfquery name="rsreincaberto" datasource="DBSNCI">
				SELECT top 2 Pos_Inspecao, Grp_Descricao, Itn_Descricao, format(Pos_DtPosic,'dd-MM-yyyy') as Pos_DtPosic, format(Pos_DtPrev_Solucao,'dd-MM-yyyy') as Pos_DtPrev_Solucao, STO_Descricao, RIP_Comentario,Pos_NumGrupo,Pos_NumItem
				FROM (((Inspecao 
				INNER JOIN ParecerUnidade ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
				INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
				INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
				INNER JOIN (Itens_Verificacao INNER JOIN Grupos_Verificacao ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade) AND (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo)
				INNER JOIN  Resultado_Inspecao ON (Pos_NumItem = RIP_NumItem) AND (Pos_NumGrupo = RIP_NumGrupo) AND (Pos_Inspecao = RIP_NumInspecao) AND (Pos_Unidade = RIP_Unidade)
				WHERE (Pos_Inspecao <> '#numinspecao#') and (RIP_Unidade ='#codunid#') and (#grpitmsql#) and Pos_Situacao_Resp in(1,6,7,17,22,2,4,5,8,20,15,16,18,19,23) and (convert(char(4),RIP_Ano)=Itn_Ano) and rip_ano >= #anolimit#
				order by right(Pos_Inspecao,4) 
            </cfquery>
            <cfreturn rsreincaberto>
        </cftransaction>
    </cffunction> 	
    <cffunction  name="dbgrpitmitemverificacao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numinspecao" required="true">
        <cfargument name="grupo" required="true">
        <cfargument name="item" required="true">  
        <cftransaction>
            <cfquery name="rsgrpitmavaliar" datasource="DBSNCI">
				SELECT top 1 RIP_Falta, RIP_Sobra, RIP_EmRisco,Itn_PreRelato, Itn_OrientacaoRelato, Itn_Manchete, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem,Itn_Norma
				FROM (Inspecao 
				INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
				INNER JOIN Unidades ON (RIP_Unidade = Und_Codigo) 
				INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (convert(char(4),RIP_Ano) = Itn_Ano) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade))
				WHERE 
				RIP_NumInspecao='#numinspecao#' AND 
                RIP_NumGrupo=#grupo# AND 
                RIP_NumItem=#item# 
            </cfquery>
            <cfreturn rsgrpitmavaliar>
        </cftransaction>
    </cffunction> 	
    <cffunction  name="dbgrpitmresultadoinspecao" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numinspecao" required="true">
        <cfargument name="grupo" required="true">
        <cfargument name="item" required="true">  
        <cftransaction>
            <cfquery name="rsgrpitmavaliar" datasource="DBSNCI">
				SELECT RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_Comentario, RIP_Recomendacoes, RIP_Manchete, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem
				FROM (Inspecao 
				INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
				INNER JOIN Unidades ON (RIP_Unidade = Und_Codigo) 
				INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (convert(char(4),RIP_Ano) = Itn_Ano) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade))
				WHERE 
				RIP_NumInspecao='#numinspecao#' AND 
                RIP_NumGrupo=#grupo# AND 
                RIP_NumItem=#item# 
            </cfquery>
            <cfreturn rsgrpitmavaliar>
        </cftransaction>
    </cffunction> 

	<cffunction  name="anexos" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="numaval" required="true">  
		<cfargument name="codunid" required="true">
		<cfargument name="grupo" required="true">
        <cfargument name="item" required="true">
		  
        <cftransaction>
            <cfquery name="rsAnexos" datasource="DBSNCI">
				SELECT Ane_Caminho,Ane_Codigo
				FROM Anexos
				WHERE  Ane_NumInspecao = '#numaval#' AND Ane_Unidade = '#codunid#' AND Ane_NumGrupo = #grupo# AND Ane_NumItem = #item#
				order by Ane_Codigo
            </cfquery>
            <cfreturn rsAnexos>
        </cftransaction>
    </cffunction>	
	<cffunction  name="avaliacaogrupoitmantes" access="remote" ReturnFormat="json" returntype="any">
        <cfargument name="ano" required="true">  
		<cfargument name="codunid" required="true">
		<cfargument name="grupo" required="true">
        <cfargument name="item" required="true">
        <cftransaction>
            <cfquery name="rsAvalantes" datasource="DBSNCI">
				SELECT top 1 
				Itn_Descricao,
				Grp_Descricao,
				Itn_Pontuacao,
				Itn_Classificacao,
				RIP_Resposta,
				Fun_Nome,
				RIP_NumInspecao,
				RIP_COMENTARIO,
				RIP_Recomendacoes
				FROM ((((Resultado_Inspecao 
				INNER JOIN Unidades ON RIP_Unidade = Und_Codigo) 
				INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)) 
				INNER JOIN Itens_Verificacao ON (convert(char(4),Rip_Ano) = Itn_Ano) and (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo))
				INNER JOIN Grupos_Verificacao ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)) 
				INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric AND RIP_MatricAvaliador = Fun_Matric 
				INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)
				INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
				WHERE (RIP_Unidade ='#codunid#' and 
				RIP_NumGrupo = #grupo# and RIP_NumItem = #item# and 
				Rip_Ano <> #ano#)
				order by RIP_NumInspecao desc
			</cfquery>
            <cfreturn rsAvalantes>
        </cftransaction>
    </cffunction>				   	
</cfcomponent>