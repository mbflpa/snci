<cfsetting requesttimeout="15000">

<!--- <cfoutput>
<cfsetting requesttimeout="15000">
<cfset dtini = CreateDate(2022,4,1)>		
<cfset dtfim = CreateDate(2022,4,30)>
<!--- <cfquery name="rsBaseABR" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_DTEnvio, Andt_Area, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_RespAnt, Andt_Status_Antes, Andt_Area_Antes, Andt_NomeArea_Antes, Andt_Status_Apos, Andt_Area_Apos, Andt_NomeArea_Apos
FROM Andamento_Temp_Abril_2022
where Andt_DPosic between #dtini# and #dtfim#
ORDER BY Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
</cfquery> --->
<cfquery name="rsBaseSLNC" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Resp, Andt_Prazo, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_DTEnvio, Andt_Area, Andt_NomeOrgCondutor, Andt_DTRefer, Andt_RespAnt
FROM Andamento_Temp
WHERE Andt_AnoExerc = '2022' AND Andt_TipoRel = 2 AND Andt_Mes = 4 and Andt_DPosic between #dtini# and #dtfim# 
</cfquery>

<cfloop query="rsBaseSLNC">
	<!--- mes anterior a abril  --->
	<cfset AndtDPosicbase = CreateDate(year(rsBaseSLNC.Andt_DPosic),month(rsBaseSLNC.Andt_DPosic),day(rsBaseSLNC.Andt_DPosic))>
	<cfset AndtHPosicbase = rsBaseSLNC.Andt_HPosic>
	<cfquery name="rsAbril" datasource="#dsn_inspecao#">
		  SELECT And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, And_Area, And_username, Und_TipoUnidade
		  FROM Unidades INNER JOIN Andamento ON Und_Codigo = And_Unidade
		  WHERE And_Unidade = '#rsBaseSLNC.Andt_Unid#' AND 
		  And_NumInspecao = '#rsBaseSLNC.Andt_Insp#' AND 
		  And_NumGrupo = #rsBaseSLNC.Andt_Grp# AND
		  And_NumItem = #rsBaseSLNC.Andt_Item# AND 
		  (And_DtPosic between #dtini# and #dtfim#) 
		  ORDER BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic 
	</cfquery>
	<cfloop query="rsAbril">
	   <cfset rsAbrildtposic = CreateDate(year(rsAbril.And_DtPosic),month(rsAbril.And_DtPosic),day(rsAbril.And_DtPosic))>
	   <cfset rsAbrilHPosic = rsAbril.And_HrPosic>
	   <cfquery datasource="#dsn_inspecao#" name="rsExiste">
			SELECT Andt_AnoExerc
			FROM Andamento_Temp
			WHERE Andt_Unid = '#rsAbril.And_Unidade#' AND 
		    Andt_Insp = '#rsAbril.And_NumInspecao#' AND 
		    Andt_Grp = #rsAbril.And_NumGrupo# AND
		    Andt_Item = #rsAbril.And_NumItem# AND 
		    Andt_DPosic = #rsAbrildtposic# and 
			Andt_HPosic = '#rsAbril.And_HrPosic#'
			ORDER BY Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item	   
	   </cfquery>
	   <cfif rsExiste.recordcount lte 0> 
	      <cfquery datasource="#dsn_inspecao#">
		 insert into Andamento_Temp (Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_Area, Andt_DTRefer) values ('2022',1,'#rsBaseSLNC.Andt_CodSE#',4,'#rsAbril.And_Unidade#','#rsAbril.And_NumInspecao#', #rsAbril.And_NumGrupo#, #rsAbril.And_NumItem#, #rsAbrildtposic#, '#rsAbrilHPosic#', #rsAbril.And_Situacao_Resp#,'#rsAbril.And_username#', #rsAbril.Und_TipoUnidade#, 0, CONVERT(char, GETDATE(), 120), 0, '#rsAbril.And_Area#', #dtfim#)
		  </cfquery>
	    </cfif> 
	
	</cfloop>
</cfloop> 
final de abril<br />


<!--- valores de maio --->
<!--- <cfset dtini = CreateDate(2022,5,1)>		
<cfset dtiniabr = CreateDate(2022,4,1)>		
<cfset dtfimabr = CreateDate(2022,4,30)>

<cfquery name="rsBaseMaio" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_DTEnvio, Andt_Area, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_RespAnt, Andt_Status_Antes, Andt_Area_Antes, Andt_NomeArea_Antes, Andt_Status_Apos, Andt_Area_Apos, Andt_NomeArea_Apos
FROM Andamento_Temp_Abril_2022
where Andt_DPosic >= #dtini# 
ORDER BY Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item
</cfquery>
<cfloop query="rsBaseMaio">
	<!--- mes anterior a abril  --->
 	<cfset dtposicmaio = CreateDate(year(rsBaseMaio.Andt_DPosic),month(rsBaseMaio.Andt_DPosic),day(rsBaseMaio.Andt_DPosic))>
	<cfquery name="rsAbr2" datasource="#dsn_inspecao#">
		  SELECT And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, And_Area, And_username, Und_TipoUnidade
		  FROM Unidades INNER JOIN Andamento ON Und_Codigo = And_Unidade
		  WHERE And_Unidade = '#rsBaseMaio.Andt_Unid#' AND 
		  And_NumInspecao = '#rsBaseMaio.Andt_Insp#' AND 
		  And_NumGrupo = #rsBaseMaio.Andt_Grp# AND
		  And_NumItem = #rsBaseMaio.Andt_Item# AND 
		  And_DtPosic between #dtini# and #dtposicmaio# 
		  ORDER BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic 
	</cfquery> 
	<cfif rsAbr2.recordcount gt 0>
		<cfloop query="rsAbr2">
		   <cfset rsAbrildtposic2 = CreateDate(year(rsAbr2.And_DtPosic),month(rsAbr2.And_DtPosic),day(rsAbr2.And_DtPosic))>
 		   <cfquery datasource="#dsn_inspecao#" name="rsExiste2">
				SELECT Andt_AnoExerc
				FROM Andamento_Temp_Abril_2022
				WHERE Andt_Unid = '#rsAbr2.And_Unidade#' AND 
			  Andt_Insp = '#rsAbr2.And_NumInspecao#' AND 
			  Andt_Grp = #rsAbr2.And_NumGrupo# AND
			  Andt_Item = #rsAbr2.And_NumItem# AND 
			  Andt_DPosic = #rsAbrildtposic2# and Andt_HPosic = '#rsAbr2.And_HrPosic#' and Andt_Resp = #rsAbr2.And_Situacao_Resp# and Andt_TipoRel <> 3
				ORDER BY Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item	   
		   </cfquery>
		   <cfif rsExiste2.recordcount lte 0> 
			  <cfquery datasource="#dsn_inspecao#">
			 insert into Andamento_Temp_Abril_2022 (Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_Area, Andt_DTRefer) values ('2022',1,'#rsBaseMaio.Andt_CodSE#',4,'#rsAbr2.And_Unidade#','#rsAbr2.And_NumInspecao#', #rsAbr2.And_NumGrupo#, #rsAbr2.And_NumItem#, #rsAbrildtposic#, '#rsAbr2.And_HrPosic#', #rsAbr2.And_Situacao_Resp#,'#rsAbr2.And_username#', #rsAbr2.Und_TipoUnidade#,0, CONVERT(char, GETDATE(), 120), 0, '#rsAbr2.And_Area#',#dtfimabr#)
			  </cfquery>
		   </cfif> 
		
		</cfloop>
	<cfelse>
		<!---  --->
		<cfquery name="rsAntesAbr" datasource="#dsn_inspecao#">
			  SELECT top 1 And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, And_Area, And_username, Und_TipoUnidade
			  FROM Andamento INNER JOIN Unidades ON And_Unidade = Und_Codigo 
			  WHERE And_Unidade = '#rsBaseMaio.Andt_Unid#' AND 
			  And_NumInspecao = '#rsBaseMaio.Andt_Insp#' AND 
			  And_NumGrupo = #rsBaseMaio.Andt_Grp# AND
			  And_NumItem = #rsBaseMaio.Andt_Item# AND 
			  And_DtPosic < #dtiniabr# 
			  ORDER BY And_DtPosic desc, And_HrPosic desc 
		</cfquery>
		<cfif rsAntesAbr.recordcount gt 0>
		   <cfset antesAbrildtposic = CreateDate(year(rsAntesAbr.And_DtPosic),month(rsAntesAbr.And_DtPosic),day(rsAntesAbr.And_DtPosic))>
		   <cfquery name="rsExiste2" datasource="#dsn_inspecao#" >
				SELECT Andt_AnoExerc
				FROM Andamento_Temp_Abril_2022
				WHERE Andt_Unid = '#rsAntesAbr.And_Unidade#' AND 
				Andt_Insp = '#rsAntesAbr.And_NumInspecao#' AND 
				Andt_Grp = #rsAntesAbr.And_NumGrupo# AND
				Andt_Item = #rsAntesAbr.And_NumItem# AND 
				Andt_DPosic = #antesAbrildtposic# and 
				Andt_HPosic = '#rsAntesAbr.And_HrPosic#' and 
				Andt_Resp = #rsAntesAbr.And_Situacao_Resp# and Andt_TipoRel <> 3
				ORDER BY Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item	   
		   </cfquery>
		   	<cfif rsExiste2.recordcount lte 0> 
			  <cfquery datasource="#dsn_inspecao#">
			 insert into Andamento_Temp_Abril_2022 (Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_Area, Andt_DTRefer) values ('2022',1,'#rsBaseMaio.Andt_CodSE#',4,'#rsAntesAbr.And_Unidade#','#rsAntesAbr.And_NumInspecao#', #rsAntesAbr.And_NumGrupo#, #rsAntesAbr.And_NumItem#, #antesAbrildtposic#, '#rsAntesAbr.And_HrPosic#', #rsAntesAbr.And_Situacao_Resp#,'#rsAntesAbr.And_username#', #rsAntesAbr.Und_TipoUnidade#,0, CONVERT(char, GETDATE(), 120), 0, '#rsAntesAbr.And_Area#',#dtfimabr#)
			  </cfquery>
 		   </cfif> 
		  </cfif>
	</cfif>
</cfloop>  --->
<!---  --->
<!--- final de maio<br />


<!--- ATUALIZAR 3-SO ANTES --->
<cfquery name="rs3SO" datasource="#dsn_inspecao#">
SELECT Andt_RespAnt, Andt_AnoExerc, Andt_TipoRel, Andt_CodSE, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp
FROM Andamento_Temp
WHERE Andt_AnoExerc = '2022' AND Andt_TipoRel = 2 AND Andt_Mes = 4 AND Andt_Resp = 3
</cfquery>
<cfloop query="rs3SO">	
    <cfset rsMesDT = CreateDate(year(rs3SO.Andt_DPosic),month(rs3SO.Andt_DPosic),day(rs3SO.Andt_DPosic))>
	<cfquery name="rsAntes" datasource="#dsn_inspecao#"> 
		SELECT TOP 1 And_Area, And_Situacao_Resp
		FROM Andamento 
		where And_Unidade = '#rs3SO.Andt_Unid#' AND 
		And_NumInspecao = '#rs3SO.Andt_Insp#' AND 
		And_NumGrupo = #rs3SO.Andt_Grp# AND
		And_NumItem = #rs3SO.Andt_Item# AND
		And_DtPosic <= #rsMesDT# and
		And_Situacao_Resp not in (0,9,10,11,12,13,21,24,25,26,27,28,29,51,30,3)
		ORDER BY And_DtPosic DESC, And_HrPosic DESC
	</cfquery>	
	<cfset rsAntesResp = rsAntes.And_Situacao_Resp>
	<cfset auxarea = rsAntes.And_Area> 
	<cfquery name="rsNegar" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla 
		FROM Areas 
		WHERE Ars_Codigo = '#auxarea#' and 
		(Ars_Sigla Like '%CCOP/SCIA%' Or 
		Ars_Sigla Like '%CCOP/SCOI%' Or 
		Ars_Sigla Like '%GSOP/CSEC%' Or 
		Ars_Sigla Like '%CORR%')
	</cfquery>
	<cfif rsNegar.recordcount lte 0>
		<cfquery name="rs3SO" datasource="#dsn_inspecao#">
			update Andamento_Temp SET Andt_RespAnt = #rsAntesResp#, Andt_Area = '#auxarea#'
			WHERE Andt_AnoExerc = '2022' AND Andt_TipoRel = 2 AND Andt_CodSE = '#rs3SO.Andt_CodSE#' AND Andt_Mes = 4 AND Andt_Resp = 3
		</cfquery>
	<cfelse>
		<cfquery name="rs3SO" datasource="#dsn_inspecao#">
			update Andamento_Temp SET Andt_RespAnt = #rsAntesResp#, Andt_Area = '#auxarea#'
			WHERE Andt_AnoExerc = '2022' AND Andt_TipoRel = 2 AND Andt_CodSE = '#rs3SO.Andt_CodSE#' AND Andt_Mes = 4 AND Andt_Resp = 3
		</cfquery>	
	</cfif>
</cfloop> --->
</cfoutput> --->
<cfset dtlimit = CreateDate(2022,5,31)>
<cfset dtini = CreateDate(2022,5,1)>		
<cfset dtfim = CreateDate(2022,5,31)>

<!--- <cfquery name="rsSE" datasource="#dsn_inspecao#">
SELECT Dir_Codigo, Dir_Sigla FROM Diretoria
WHERE Dir_Codigo <> '01'
ORDER BY Dir_Codigo
</cfquery> --->

<!--- feriados nacionais do mês a ser salvado --->
<cfquery name="rsFer" datasource="#dsn_inspecao#">
   SELECT Fer_Data FROM FeriadoNacional 
   where Fer_Data between #dtini# and #dtfim#
   order by Fer_Data
</cfquery>
<!--- <cfloop query="rsSE"> --->
<cfquery name="rs_3Sol" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade
	FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp = 3 and Pos_DtPosic between #dtini# and #dtfim# and left(Pos_Unidade,2) = '#se#'
</cfquery>


<cfquery name="rs_14_PEND_TRAT" datasource="#dsn_inspecao#">
	SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Situacao_Resp, Pos_Situacao, pos_dtultatu, pos_username, Pos_Area, Pos_NomeArea, Und_TipoUnidade
	FROM ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
	WHERE Pos_Situacao_Resp In (14,2,4,5,8,15,16,18,19,20,23) and left(Pos_Unidade,2) = '#se#'
</cfquery>

<cfset auxdtnova = CreateDate(year(now()),month(now()),day(now()))>
<cfoutput query="rs_14_PEND_TRAT">
	<cfset SalvarSN = 'S'>
	<cfset auxgrp = rs_14_PEND_TRAT.Pos_NumGrupo>
	<cfset auxitm = rs_14_PEND_TRAT.Pos_NumItem>
	<!--- extrair os antigos 99 --->
	<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
		<cfset SalvarSN = 'N'>
	</cfif>
	<cfif SalvarSN is 'S'>
		<!--- extrair atividades ligadas ao %CCOP/SCIA% ; %CCOP/SCOI%; %GSOP/CSEC% e %CORR%--->
		<cfquery name="rsNegar" datasource="#dsn_inspecao#">
			SELECT Ars_Sigla 
			FROM Areas 
			WHERE Ars_Codigo = '#rs_14_PEND_TRAT.Pos_Area#' and 
			(Ars_Sigla Like '%CCOP/SCIA%' Or 
			Ars_Sigla Like '%CCOP/SCOI%' Or 
			Ars_Sigla Like '%GSOP/CSEC%' Or 
			Ars_Sigla Like '%CORR%' Or 
			Ars_Sigla Like '%GCOP/SGCIN%' Or 
			Ars_Sigla Like '%%GAAV/SGSEC%')
		</cfquery>
		<cfif rsNegar.recordcount gt 0>
		   <cfset SalvarSN = 'N'>
		</cfif>

		<cfif SalvarSN is 'S'>
			<!--- Salvar os status rs_14_PEND_TRAT para o PRCI tipo rel=1--->
			<cfset PosDtPosic = CreateDate(year(rs_14_PEND_TRAT.Pos_DtPosic),month(rs_14_PEND_TRAT.Pos_DtPosic),day(rs_14_PEND_TRAT.Pos_DtPosic))>
			<cfset AndtHPosic = right(rs_14_PEND_TRAT.pos_dtultatu,10)>
			<cfset AndtCodSE = left(rs_14_PEND_TRAT.Pos_Unidade,2)>
			<cfset auxsta = rs_14_PEND_TRAT.Pos_Situacao_Resp>
			<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
			   <cfset AndtPrazo = 'DP'>
			<cfelse>
			   <cfset AndtPrazo = 'FP'>
			</cfif>
			<cfquery datasource="#dsn_inspecao#">
				insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt) values ('#year(dtlimit)#', #month(dtlimit)#, '#rs_14_PEND_TRAT.Pos_Inspecao#', '#rs_14_PEND_TRAT.Pos_Unidade#', #rs_14_PEND_TRAT.Pos_NumGrupo#, #rs_14_PEND_TRAT.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rs_14_PEND_TRAT.Und_TipoUnidade#, 0, 0, '#rs_14_PEND_TRAT.pos_username#', CONVERT(char, GETDATE(), 120), '#rs_14_PEND_TRAT.Pos_Area#', '#trim(rs_14_PEND_TRAT.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, '')
			</cfquery>   
			
			<!--- Salvar SLNC tiporel=2 --->
			<cfif rs_14_PEND_TRAT.Und_TipoUnidade eq 12 or rs_14_PEND_TRAT.Und_TipoUnidade eq 16 or auxsta eq 14>
			   <cfset SalvarSN = 'N'>
			</cfif>
			
			<cfif SalvarSN is 'S'>
					<cfquery name="rs14" datasource="#dsn_inspecao#">
						SELECT And_DtPosic
						FROM Andamento
						WHERE And_Unidade = '#rs_14_PEND_TRAT.Pos_Unidade#' AND 
						And_NumInspecao = '#rs_14_PEND_TRAT.Pos_Inspecao#' AND 
						And_NumGrupo = #rs_14_PEND_TRAT.Pos_NumGrupo# AND 
						And_NumItem = #rs_14_PEND_TRAT.Pos_NumItem# AND 
						And_Situacao_Resp = 14 
					</cfquery>
					<!--- contar se passaram 30 dias uteis do status 14-NR até a datafim --->
					<cfif rs14.recordcount lte 0>
					unidade: #rs_14_PEND_TRAT.Pos_Unidade#  insp: #rs_14_PEND_TRAT.Pos_Inspecao#  Grupo :#rs_14_PEND_TRAT.Pos_NumGrupo#   Item = #rs_14_PEND_TRAT.Pos_NumItem#   			#rs14.And_DtPosic#<br />
						<cfset auxddcor = 5>
					<cfelse>
						<cfset auxddcor = DateDiff("d", rs14.And_DtPosic, #dtfim#)>
					</cfif>
					
					<cfif auxddcor lte 30>
					  <cfset SalvarSN = 'N'>
					</cfif>
					<cfif SalvarSN is 'S'>
					    <cfset auxdtnova = DateAdd("d", 1, #rs14.And_DtPosic#)>
						<cfset nCont = 1>
						<cfset dsusp = 0>
						<cfloop condition="nCont lte #auxddcor#"> 
							<cfset vDiaSem = DayOfWeek(auxdtnova)>
							<cfif (vDiaSem neq 1) and (vDiaSem neq 7)>
								<cfif rsFer.recordcount gt 0> 
										<cfloop query="rsFer">
											<cfif dateformat(rsFer.Fer_Data,"YYYYMMDD") eq dateformat(auxdtnova,"YYYYMMDD")>
												<cfset dsusp = dsusp + 1>
											</cfif>
										</cfloop> 
								</cfif>
						    </cfif>
							<cfif (vDiaSem eq 1) or (vDiaSem eq 7)> 
							  <cfset dsusp = dsusp + 1>
							 </cfif> 
							<cfset auxdtnova = DateAdd("d", 1, #auxdtnova#)>
							<cfset nCont = nCont + 1> 
						</cfloop> 
						<cfset auxddrest = (auxddcor - dsusp)>
						<cfif auxddrest lte 30>
					  		<cfset SalvarSN = 'N'>
						</cfif>
						<!--- ponto pode ser salvo como SLNC --->
						<cfif SalvarSN is 'S'>
								<cfset PosDtPosic = CreateDate(year(rs_14_PEND_TRAT.Pos_DtPosic),month(rs_14_PEND_TRAT.Pos_DtPosic),day(rs_14_PEND_TRAT.Pos_DtPosic))>
								<cfset AndtHPosic = right(rs_14_PEND_TRAT.pos_dtultatu,10)>
								<cfset AndtCodSE = left(rs_14_PEND_TRAT.Pos_Unidade,2)>
								<cfset auxsta = rs_14_PEND_TRAT.Pos_Situacao_Resp>
							    <cfquery datasource="#dsn_inspecao#">
												insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt) values ('#year(dtlimit)#', #month(dtlimit)#, '#rs_14_PEND_TRAT.Pos_Inspecao#', '#rs_14_PEND_TRAT.Pos_Unidade#', #rs_14_PEND_TRAT.Pos_NumGrupo#, #rs_14_PEND_TRAT.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rs_14_PEND_TRAT.Und_TipoUnidade#, 0, 0, '#rs_14_PEND_TRAT.pos_username#', CONVERT(char, GETDATE(), 120), '#rs_14_PEND_TRAT.Pos_Area#', '#trim(rs_14_PEND_TRAT.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, 'NN', 2, '')
								</cfquery>	 					
						
						</cfif>
					</cfif>
			
			
			
			</cfif>
			
			
		</cfif>
	</cfif>
	<!--- PREENCHER TABELA DE BACKUP DA PARECERUNIDADE DO 1º DIA UTIL PARA ParecerUnidade_prci_slnc --->
	<cfset PosDtPosic = CreateDate(year(rs_14_PEND_TRAT.Pos_DtPosic),month(rs_14_PEND_TRAT.Pos_DtPosic),day(rs_14_PEND_TRAT.Pos_DtPosic))>
	<cfset posdtultatu = CreateDate(year(rs_14_PEND_TRAT.pos_dtultatu),month(rs_14_PEND_TRAT.pos_dtultatu),day(rs_14_PEND_TRAT.pos_dtultatu))>
	<cfset auxsta = rs_14_PEND_TRAT.Pos_Situacao_Resp>
 	<cfquery datasource="#dsn_inspecao#">
		insert into ParecerUnidade_prci_slnc (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea) values ('#rs_14_PEND_TRAT.Pos_Unidade#', '#rs_14_PEND_TRAT.Pos_Inspecao#', #rs_14_PEND_TRAT.Pos_NumGrupo#, #rs_14_PEND_TRAT.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rs_14_PEND_TRAT.Pos_Situacao#', '#rs_14_PEND_TRAT.pos_username#', '#rs_14_PEND_TRAT.Pos_Area#', '#rs_14_PEND_TRAT.Pos_NomeArea#')
	</cfquery>	 
</cfoutput>
<!--- 
 ***************************************************************** 
 salvar os solucionados como SNLC  TIPOREL = 2 
 ***************************************************************** 
 --->
<cfoutput query="rs_3Sol">
	<cfset SalvarSN = 'S'>
	<cfset auxgrp = rs_3Sol.Pos_NumGrupo>
	<cfset auxitm = rs_3Sol.Pos_NumItem>
	<!--- extrair os antigos 99 --->
	<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
		<cfset SalvarSN = 'N'>
	</cfif>
	<cfif SalvarSN is 'S'>
		<!--- extrair atividades ligadas ao %CCOP/SCIA% ; %CCOP/SCOI%; %GSOP/CSEC% e %CORR%--->
		<cfquery name="rsNegar" datasource="#dsn_inspecao#">
			SELECT Ars_Sigla 
			FROM Areas 
			WHERE Ars_Codigo = '#rs_3Sol.Pos_Area#' and 
			(Ars_Sigla Like '%CCOP/SCIA%' Or 
			Ars_Sigla Like '%CCOP/SCOI%' Or 
			Ars_Sigla Like '%GSOP/CSEC%' Or 
			Ars_Sigla Like '%CORR%')
		</cfquery>
		<cfif rsNegar.recordcount gt 0>
		   <cfset SalvarSN = 'N'>
		</cfif>

		<cfif SalvarSN is 'S'>
			<!--- Salvar SLNC tiporel=2 --->
			<cfif rs_3Sol.Und_TipoUnidade eq 12 or rs_3Sol.Und_TipoUnidade eq 16>
			   <cfset SalvarSN = 'N'>
			</cfif>
			
			<cfif SalvarSN is 'S'>
						<!--- ponto pode ser salvo como SLNC --->
								<cfset PosDtPosic = CreateDate(year(rs_3Sol.Pos_DtPosic),month(rs_3Sol.Pos_DtPosic),day(rs_3Sol.Pos_DtPosic))>
								<cfset AndtHPosic = right(rs_3Sol.pos_dtultatu,10)>
								<cfset AndtCodSE = left(rs_3Sol.Pos_Unidade,2)>
								<cfset auxsta = rs_3Sol.Pos_Situacao_Resp>
								<cfquery datasource="#dsn_inspecao#">
									insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt) values ('#year(dtlimit)#', #month(dtlimit)#, '#rs_3Sol.Pos_Inspecao#', '#rs_3Sol.Pos_Unidade#', #rs_3Sol.Pos_NumGrupo#, #rs_3Sol.Pos_NumItem#, #PosDtPosic#, '#AndtHPosic#', #auxsta#, #rs_3Sol.Und_TipoUnidade#, 0, 0, '#rs_3Sol.pos_username#', CONVERT(char, GETDATE(), 120), '#rs_3Sol.Pos_Area#', '#trim(rs_3Sol.Pos_NomeArea)#', '#AndtCodSE#', #dtfim#, 'NN', 2, '')
								</cfquery>						
			</cfif>
		</cfif>
	</cfif>
<!--- 
 ***************************************************************** 
 salvar os solucionados como SNLC  TIPOREL = 2 
 ***************************************************************** 
 --->	
<cfset PosDtPosic = CreateDate(year(rs_3Sol.Pos_DtPosic),month(rs_3Sol.Pos_DtPosic),day(rs_3Sol.Pos_DtPosic))>
<cfset posdtultatu = CreateDate(year(rs_3Sol.pos_dtultatu),month(rs_3Sol.pos_dtultatu),day(rs_3Sol.pos_dtultatu))>
<cfset auxsta = rs_3Sol.Pos_Situacao_Resp> 
    <cfquery datasource="#dsn_inspecao#">
		insert into ParecerUnidade_prci_slnc (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, pos_dtultatu, Pos_Situacao_Resp, Pos_Situacao, pos_username, Pos_Area, Pos_NomeArea) values ('#rs_3Sol.Pos_Unidade#', '#rs_3Sol.Pos_Inspecao#', #rs_3Sol.Pos_NumGrupo#, #rs_3Sol.Pos_NumItem#, #PosDtPosic#, #posdtultatu#, #auxsta#, '#rs_3Sol.Pos_Situacao#', '#rs_3Sol.pos_username#', '#rs_3Sol.Pos_Area#', '#rs_3Sol.Pos_NomeArea#')
	</cfquery>	 
</cfoutput>
<!--- </cfloop> --->

<!--- 
 ***************************************************************** 
 realizar busca na andamento para compor o PRCI  TIPOREL = 1 
 ***************************************************************** 
 --->
<cfquery name="rsPrci" datasource="#dsn_inspecao#">
SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Resp, Andt_Mes, Andt_CodSE, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_user, Andt_tpunid, Andt_DiasCor, Andt_dtultatu, Andt_Uteis, Andt_DTEnvio, Andt_Area, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer, Andt_RespAnt
FROM Andamento_Temp
WHERE (Andt_AnoExerc = '2022' AND Andt_TipoRel = 1 AND Andt_Resp <> 14 AND Andt_Mes =5) OR (Andt_AnoExerc = '2022' AND Andt_TipoRel = 2 AND Andt_Resp =3 AND Andt_Mes = 5)
</cfquery>

<cfoutput query="rsPrci">
	<cfset AndtDPosic = CreateDate(year(rsPrci.Andt_DPosic),month(rsPrci.Andt_DPosic),day(rsPrci.Andt_DPosic))>
    <cfquery name="rsAndam" datasource="#dsn_inspecao#">
		SELECT And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
		FROM Andamento
		WHERE (And_DtPosic between #dtini# and #AndtDPosic#) AND And_HrPosic < '#rsPrci.Andt_HPosic#' and
		(And_Situacao_Resp In (2,4,5,8,15,16,18,19,20,23)) and 
        And_NumInspecao = '#rsPrci.Andt_Insp#' and 
		And_Unidade = '#rsPrci.Andt_Unid#' and 
		And_NumGrupo= #rsPrci.Andt_Grp# and 
		And_NumItem= #rsPrci.Andt_Item#
		order by And_DtPosic, And_HrPosic
	</cfquery> 

<!---  --->
    <CFLOOP query="rsPrci">
	<cfset AndDtPosic = CreateDate(year(rsAndam.And_DtPosic),month(rsAndam.And_DtPosic),day(rsAndam.And_DtPosic))>
	<cfset AndHrPosic = rsAndam.And_HrPosic>
	<cfset AndtCodSE = left(rsAndam.And_Unidade,2)>
	<cfset auxsta = rsAndam.And_Situacao_Resp>
	<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
	   <cfset AndtPrazo = 'DP'>
	<cfelse>
	   <cfset AndtPrazo = 'FP'>
	</cfif>

	<cfquery datasource="#dsn_inspecao#">
		insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsAndam.And_NumInspecao#', '#rsAndam.And_Unidade#', #rsAndam.And_NumGrupo#, #rsAndam.And_NumItem#, #AndDtPosic#, '#AndHrPosic#', #auxsta#, #rsPrci.Andt_tpunid#, 0, 0, '#rsAndam.And_username#', #AndDtPosic#, '#rsAndam.And_Area#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1)
	</cfquery>  
</CFLOOP>
<!---  --->

</cfoutput>