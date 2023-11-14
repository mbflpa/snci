<!--- vers�o anterior --->
<cfif frmano lte 2022>
	<cflocation url="Rel_Indicadores_Solucao_2022.cfm?se=#se#&Submit1=Confirmar&dtlimit=#dtlimit#&anoexerc=#frmano#">
</cfif> 
<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<!---    <cfoutput>#se#  === #anoexerc#  === #dtlimit#<br></cfoutput>
 <CFSET GIL = GIL>   --->    
<cfsetting requesttimeout="10000"> 
<!--- <cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif> --->
<!--- <cfset dsn_inspecao = 'DBSNCI'> --->
<cfset BaseUnid = ''>
<cfset BaseInsp = ''>
<cfset Basegrupo = ''>
<cfset BaseItem = ''>

<!--- <cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp  where Andt_TipoRel = 2 and Andt_AnoExerc = '#anoexerc#' and andt_CodSE = '#se#'
</cfquery>  --->    
<!---  --->
<!---
<cfset auxdthoje = CreateDate(year(now()),month(now()),day(now()))>
<cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp 
   where Andt_dtultatu < #auxdthoje# and Andt_AnoExerc = '#anoexerc#'
</cfquery>  
--->
<!--- <cfoutput>dtlimit: #dtlimit#<br /> </cfoutput> --->
<cfset dtlimit = CreateDate(year(dtlimit),month(dtlimit),day(dtlimit))>
<!--- <cfoutput>dtlimit: #dtlimit#<br /> </cfoutput> --->
<cfset aux_mes = 1> 
<cfloop condition="#aux_mes# lte int(month(dtlimit))">
	<cfif aux_mes is 1>
	  <cfset dtini = CreateDate(year(dtlimit),1,1)>
	  <cfset dtfim = CreateDate(year(dtlimit),1,31)>
	<cfelseif aux_mes is 2>
		<cfif int(year(dtlimit)) mod 4 is 0>
		   <cfset dtfim = CreateDate(year(dtlimit),2,29)>
		<cfelse>
		   <cfset dtfim = CreateDate(year(dtlimit),2,28)>
		</cfif>
		<cfset dtini = CreateDate(year(dtlimit),2,1)>				
	<cfelseif aux_mes is 3>
		   <cfset dtini = CreateDate(year(dtlimit),3,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),3,31)>
	<cfelseif aux_mes is 4>
		   <cfset dtini = CreateDate(year(dtlimit),4,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),4,30)>		
	<cfelseif aux_mes is 5>
		   <cfset dtini = CreateDate(year(dtlimit),5,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),5,31)>		
	<cfelseif aux_mes is 6>
		   <cfset dtini = CreateDate(year(dtlimit),6,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),6,30)>		
	<cfelseif aux_mes is 7>
		   <cfset dtini = CreateDate(year(dtlimit),7,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),7,31)>		
	<cfelseif aux_mes is 8>
		   <cfset dtini = CreateDate(year(dtlimit),8,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),8,31)>		
	<cfelseif aux_mes is 9>
		   <cfset dtini = CreateDate(year(dtlimit),9,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),9,30)>		
	<cfelseif aux_mes is 10>
		   <cfset dtini = CreateDate(year(dtlimit),10,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),10,31)>		
	<cfelseif aux_mes is 11>
		   <cfset dtini = CreateDate(year(dtlimit),11,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),11,30)>		
	<cfelse>
		   <cfset dtini = CreateDate(year(dtlimit),12,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),12,31)>		
	</cfif>
	<cfoutput>
<!--- 	dtini#dtini# dtfim#dtfim# dtlimit: #dtlimit#
	<cfset gil = gil>   --->
		<cfquery name="rsVazio" datasource="#dsn_inspecao#">
		   select Andt_CodSE from Andamento_Temp 
		   where Andt_CodSE  = '#se#' and Andt_TipoRel = 2 and Andt_AnoExerc = '#year(dtfim)#' and Andt_Mes = #month(dtfim)#
		</cfquery>		
	</cfoutput>	
 	<cfif rsVazio.recordcount lte 0>
		<!--- COMPOR O SLNC COM OS PENDENTES E TRATAMENTOS DO MES --->
		<!--- SOMENTE DAS UNIDADES PROPRIAS --->
		<!--- CALCULAR OS DIAS �TEIS ENTRE A DTA NO STATUS 14-NR ATE O �LTIMO DIA DO M�S DT_REFERENCIA --->
			
		<cfinclude template="INDICADORES_MES.CFM"> 
		<cfquery name="rsSLNC" datasource="#dsn_inspecao#">
		SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
WHERE (((Pos_Situacao_Resp) In (2,4,5,8,20,15,16,18,19,23)) AND ((Und_TipoUnidade)<>12 And (Und_TipoUnidade)<>16))
ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>

		<cfoutput query="rsSLNC">
			<cfset SalvarSN = 'S'>
			<cfquery name="rs14" datasource="#dsn_inspecao#">
				SELECT And_DtPosic, And_HrPosic
				FROM Andamento
				WHERE And_Unidade = '#rsSLNC.Pos_Unidade#' AND 
				And_NumInspecao = '#rsSLNC.Pos_Inspecao#' AND 
				And_NumGrupo = #rsSLNC.Pos_NumGrupo# AND 
				And_NumItem = #rsSLNC.Pos_NumItem# AND 
				And_Situacao_Resp = 14 and And_DtPosic >= #dt30diasuteis14NR#
			</cfquery>
			 <cfif rs14.recordcount gt 0> 
				<cfset SalvarSN = 'N'>
			</cfif> 
			<cfif SalvarSN is 'S'>
			   <cfset AndtDPosic = CreateDate(year(rsSLNC.Pos_DtPosic),month(rsSLNC.Pos_DtPosic),day(rsSLNC.Pos_DtPosic))>
			   <cfset AndtHPosic = rsSLNC.andHrPosic>
			   <cfset auxsta = rsSLNC.Pos_Situacao_Resp>
			   <cfquery name="rsExiste" datasource="#dsn_inspecao#">
						select Andt_Insp 
						from Andamento_Temp 
						where Andt_AnoExerc = '#year(dtlimit)#' and
						Andt_Mes = #month(dtlimit)# and
						Andt_Insp = '#rsSLNC.Pos_Inspecao#' and
						Andt_Unid = '#rsSLNC.Pos_Unidade#' and
						Andt_Grp = #rsSLNC.Pos_NumGrupo# and 
						Andt_Item = #rsSLNC.Pos_NumItem# and 
						Andt_DPosic = #AndtDPosic# and
						Andt_HPosic = '#AndtHPosic#' and
						Andt_Resp = #auxsta# and
						Andt_TipoRel = 2
				</cfquery>			
			     <cfif rsExiste.recordcount lte 0>
					<!--- ponto pode ser salvo para compor SLNC --->
							<cfset PosDtPosic = CreateDate(year(rsSLNC.Pos_DtPosic),month(rsSLNC.Pos_DtPosic),day(rsSLNC.Pos_DtPosic))>
							<cfset AndtHPosic = TimeFormat(now(),"hh:mm:ssss")> 
							<cfset AndtCodSE = left(rsSLNC.Pos_Unidade,2)>
							<cfset auxsta = rsSLNC.Pos_Situacao_Resp>
							<cfset auxantes = 0>
							<cfif rsSLNC.Pos_Sit_Resp_Antes gt 0>
								<cfset auxantes = rsSLNC.Pos_Situacao_Resp>
							</cfif>							
							<cfquery datasource="#dsn_inspecao#">
							insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsSLNC.Pos_Inspecao#', '#rsSLNC.Pos_Unidade#', #rsSLNC.Pos_NumGrupo#, #rsSLNC.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rsSLNC.Und_TipoUnidade#, 0, 0, '#rsSLNC.pos_username#', CONVERT(char, GETDATE(), 120), '#rsSLNC.Pos_Area#', '#trim(rsSLNC.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, 'NN', 2, '#auxantes#', #rsSLNC.Pos_PontuacaoPonto#, '#rsSLNC.Pos_ClassificacaoPonto#')
							</cfquery>	
					</cfif>					
			</cfif>
		</cfoutput>
		<!--- COMPOR O SLNC COM OS solucionados do M�s --->
		<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, Pos_Sit_Resp_Antes
FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
WHERE Pos_Situacao_Resp = 3 
ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
		</cfquery>

		<cfoutput query="rs3SO">
		  		<!--- <cfset auxsta_antes = rs3SO.Pos_Sit_Resp_Antes> --->
		       <!---  <cfif auxsta_antes is 0 or auxsta_antes is ''> --->
					<cfset PosDtPosic = CreateDate(year(rs3SO.Pos_DtPosic),month(rs3SO.Pos_DtPosic),day(rs3SO.Pos_DtPosic))>
					<cfset AndtHPosic = rs3SO.andHrPosic>
					<cfset AndtCodSE = left(rs3SO.Pos_Unidade,2)>
					<cfset auxsta = rs3SO.Pos_Situacao_Resp>
					
					<cfset auxsta_antes = 'F'>
					<cfquery datasource="#dsn_inspecao#" name="rsunid">
						SELECT Und_Codigo FROM Unidades WHERE Und_Codigo = '#rs3SO.Pos_Area#'
					</cfquery>
					<cfif rsunid.recordcount gt 0>
						<cfset auxsta_antes = 1>
					</cfif>
					<cfif auxsta_antes is 'F'>
						<!--- <cfquery datasource="#dsn_inspecao#" name="rsreop">
							SELECT Rep_Codigo FROM Reops WHERE Rep_Codigo = '#rs3SO.Pos_Area#' and Rep_Status = 'A'
						</cfquery>	 --->	
						<cfquery datasource="#dsn_inspecao#" name="rsreop">
							SELECT Rep_Codigo FROM Reops WHERE Rep_Codigo = '#rs3SO.Pos_Area#'
						</cfquery>							
					
						<cfif rsreop.recordcount gt 0>
							<cfset auxsta_antes = 7>
						</cfif>
					</cfif>
					<cfif auxsta_antes is 'F'>
						<!--- <cfquery datasource="#dsn_inspecao#" name="rsarea">
							SELECT Ars_Codigo FROM Areas WHERE Ars_Codigo = '#rs3SO.Pos_Area#' and Ars_Status = 'A'
						</cfquery> --->	
						<cfquery datasource="#dsn_inspecao#" name="rsarea">
							SELECT Ars_Codigo FROM Areas WHERE Ars_Codigo = '#rs3SO.Pos_Area#'
						</cfquery>							
					
						<cfif rsarea.recordcount gt 0>
							<cfset auxsta_antes = 6>
						</cfif>
					</cfif>
					<cfif auxsta_antes is 'F'>
						<cfquery datasource="#dsn_inspecao#" name="rsse">
							SELECT Dir_Sto FROM Diretoria WHERE Dir_Sto = '#rs3SO.Pos_Area#'
						</cfquery>								
					
						<cfif rsse.recordcount gt 0>
							<cfset auxsta_antes = 22>
						</cfif>
					</cfif>
				<!--- </cfif>	 --->			
				<cfquery datasource="#dsn_inspecao#">
					insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rs3SO.Pos_Inspecao#', '#rs3SO.Pos_Unidade#', #rs3SO.Pos_NumGrupo#, #rs3SO.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rs3SO.Und_TipoUnidade#, 0, 0, '#rs3SO.pos_username#', CONVERT(char, GETDATE(), 120), '#rs3SO.Pos_Area#', '#trim(rs3SO.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, 'NN', 2, '#auxsta_antes#', #rs3SO.Pos_PontuacaoPonto#, '#rs3SO.Pos_ClassificacaoPonto#')
				</cfquery>	
		</cfoutput>
    </cfif> 
    <cfset aux_mes = aux_mes + 1> 
</cfloop>

<cfoutput>
<!--- ROTINA  --->
<!--- VALIDAR PONTOS NA TABELA: Andamento_Temp  --->
<!--- GRUPOS E ITENS N�O PERMITIDOS  --->
<cfquery name="rsGRIT" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area
FROM Andamento_Temp 
WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=2 AND Andt_Mes = #month(dtlimit)#
</cfquery>
<cfloop query="rsGRIT">
	<cfset auxgrp = rsGRIT.Andt_Grp>
	<cfset auxitm = rsGRIT.Andt_Item>
	<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
		<cfquery datasource="#dsn_inspecao#">
		   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
		   WHERE Andt_Unid='#rsGRIT.Andt_Unid#' AND 
		   Andt_Insp='#rsGRIT.Andt_Insp#' AND 
		   Andt_Grp=#rsGRIT.Andt_Grp# AND 
		   Andt_Item=#rsGRIT.Andt_Item#
		</cfquery>		
	</cfif>
</cfloop>			
<!--- FIM ROTINA  ---> 
		
<!--- ROTINA  --->
<!--- POS_NOMEAREA N�O PERMITIDOS  --->
 <cfquery name="AndtArea" datasource="#dsn_inspecao#">
	SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area, Andt_PosClassificacaoPonto, Andt_Unid
	FROM Andamento_Temp 
	WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=2 AND Andt_Mes = #month(dtlimit)# 
</cfquery>
<cfloop query="AndtArea">
	<cfquery name="rsNegar" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla 
		FROM Areas 
		WHERE Ars_Codigo = '#AndtArea.Andt_Area#' and 
		(Ars_Sigla Like '%CCOP/SCIA%' Or 
		Ars_Sigla Like '%CCOP/SCOI%' Or 
		Ars_Sigla Like '%GCOP/CCOP%' Or
		Ars_Sigla Like '%GSOP/CSEC%' Or 
		Ars_Sigla Like '%CORR%' Or 
		Ars_Sigla Like '%GCOP/SGCIN%' Or 
		Ars_Sigla Like '%GAAV/SGSEC%' OR 
		Ars_Sigla Like '%/SCORG%')
	</cfquery>
	<cfset AndtPosClassificacaoPonto = trim(ucase(AndtArea.Andt_PosClassificacaoPonto))>
	<cfif rsNegar.recordcount gt 0 or (AndtPosClassificacaoPonto eq 'LEVE' and Andt_Unid neq 12)> 
		<cfquery datasource="#dsn_inspecao#">
		   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
		   WHERE Andt_Unid='#AndtArea.Andt_Unid#' AND 
		   Andt_Insp='#AndtArea.Andt_Insp#' AND 
		   Andt_Grp=#AndtArea.Andt_Grp# AND 
		   Andt_Item=#AndtArea.Andt_Item#
		</cfquery>	
	</cfif>			 	
</cfloop>
<!--- FIM ROTINA  ---> 

 <cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp 
   where Andt_Prazo = 'EX'
</cfquery>  
<cflocation url="Rel_Indicadores_Solucao1.cfm?se=#se#&Submit1=Confirmar&dtlimit=#dateformat(dtlimit,"yyyy/mm/dd")#&anoexerc=#year(dtLimit)#"> 
</cfoutput>