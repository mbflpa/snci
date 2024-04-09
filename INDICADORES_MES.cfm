<cfif month(dtini) eq '01'>
	<cfset dtinimesant = (year(dtini) - 1) & '-12-01'>
<cfelse>
	<cfset dtinimesant = year(dtini) & '-' & (month(dtini) - 1) & '-01'>	
</cfif>
<!---
 <cfoutput>
 #se#  === #anoexerc#  === #dtlimit#<br>
 dtini: #dtini#   dtfim: #dtfim# dtinimesant: #dtinimesant#<br>
 			SELECT Fer_Data FROM FeriadoNacional 
		where Fer_Data between '#dateformat(dtinimesant,"YYYY-MM-DD")#' and '#dateformat(dtfim,"YYYY-MM-DD")#'
		order by Fer_Data
 <cfset gil = gil> 
 </cfoutput>
--->
	<cfquery name="rsFer" datasource="#dsn_inspecao#">
		SELECT Fer_Data FROM FeriadoNacional 
		where Fer_Data between '#dtinimesant#' and '#dateformat(dtfim,"YYYY-MM-DD")#'
		order by Fer_Data
	</cfquery>

	<!---  --->
    <cfset dt14limitprci_slnc  = #dtini#>
	<cfset nCont = 0>
	<cfset dsusp = 0>
	<cfloop condition="nCont lte 9"> 
		<cfset dt14limitprci_slnc  = DateAdd("d", -1, #dt14limitprci_slnc#)>	
		<cfset vDiaSem = DayOfWeek(dt14limitprci_slnc )>
		<cfif (vDiaSem neq 1) and (vDiaSem neq 7)>
			<cfif rsFer.recordcount gt 0> 
					<cfloop query="rsFer">
						<cfif dateformat(rsFer.Fer_Data,"YYYYMMDD") eq dateformat(dt14limitprci_slnc ,"YYYYMMDD")>
							<cfset nCont = nCont - 1>
						</cfif>
					</cfloop> 
			</cfif>
		<cfelse>
			<cfif (vDiaSem eq 1) or (vDiaSem eq 7)> 
			  <cfset nCont = nCont - 1>
			 </cfif> 
		</cfif>
		<cfset nCont = nCont + 1> 
	</cfloop> 
<!---   
data limite para SLNC 30(trinta) dias uteis da liberação 
<cfset dt14limit30dslnc = #dtfim#>
<cfset nCont = 1>
<cfset dsusp = 0>
<cfloop condition="nCont lte 30"> 
<cfset vDiaSem = DayOfWeek(dt30diasuteis14NR)>
<cfif (vDiaSem neq 1) and (vDiaSem neq 7)>
<cfif rsFer.recordcount gt 0> 
<cfloop query="rsFer">
<cfif dateformat(rsFer.Fer_Data,"YYYYMMDD") eq dateformat(dt30diasuteis14NR,"YYYYMMDD")>
<cfset nCont = nCont - 1>
</cfif>
</cfloop> 
</cfif>
<cfelse>
<cfif (vDiaSem eq 1) or (vDiaSem eq 7)> 
<cfset nCont = nCont - 1>
</cfif> 
</cfif>
<cfset dt30diasuteis14NR = DateAdd("d", -1, #dt30diasuteis14NR#)>
<cfset nCont = nCont + 1> 
</cfloop> 
--->
<!---
 <cfoutput>data marco inicio:#DTLIMITST14NR # time format: #TimeFormat(now(),"hh:mm:ssss")#</cfoutput>	
<cfset gil = gil> 
	  --->
<!---    <cfif rotina eq 0>  --->
	   <!--- VALIDAR PONTOS NA TABELA: SLNCPRCIDCGIMES  --->
	   <!--- GRUPOS E ITENS NÃO PERMITIDOS  --->
	    <cfquery name="rsGRPITEM" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp
			FROM SLNCPRCIDCGIMES 
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<cfoutput query="rsGRPITEM">
			<cfset auxgrp = rsGRPITEM.Pos_NumGrupo>
			<cfset auxitm = rsGRPITEM.Pos_NumItem>
			<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
				<cfquery datasource="#dsn_inspecao#">
				   UPDATE SLNCPRCIDCGIMES SET Pos_Situacao_Resp = 10000
				   WHERE Pos_Unidade='#rsGRPITEM.Pos_Unidade#' AND 
				   Pos_Inspecao='#rsGRPITEM.Pos_Inspecao#' AND 
				   Pos_NumGrupo=#rsGRPITEM.Pos_NumGrupo# AND 
				   Pos_NumItem=#rsGRPITEM.Pos_NumItem#
				 </cfquery>		
	        </cfif>
		</cfoutput>
<!--- <cfoutput>linha 228 GRUPOS E ITENS N�O PERMITIDOS ok</cfoutput><br>	 --->	   
	   <!--- FAZER AJUSTES DE CAMPOS NA TABELA: SLNCPRCIDCGIMES  --->
	   <!--- NO CAMPO POS_NOMEAREA NA TABELA: SLNCPRCIDCGIMES  --->
	   <cfquery name="rsPosNArea" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp
			FROM SLNCPRCIDCGIMES 
			WHERE Pos_Situacao_Resp In (14,3,2,4,5,8,20,15,16,18,19,23) AND (Pos_NomeArea is null or Pos_Area is null)
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<cfoutput query="rsPosNArea">
			<cfset PosNomeArea = ''>
			<cfset PosArea = rsPosNArea.Pos_Area>
			<cfset auxSitu = rsPosNArea.Pos_Situacao_Resp>
			<!--- unidades --->
		    <cfif  (auxSitu is 14) or (auxSitu is 2)  or (auxSitu is 15) or (auxSitu is 18) or (auxSitu is 20)>
				<cfif len(trim(PosArea)) lte 0>
					<cfset PosArea = rsPosNArea.Pos_Unidade>
				</cfif>
				<cfquery name="rsNomeUnid" datasource="#dsn_inspecao#">
					SELECT Und_Descricao
					FROM Unidades
					WHERE Und_Codigo = '#PosArea#'
				</cfquery>
			    <cfset  PosNomeArea = rsNomeUnid.Und_Descricao>
			</cfif>
			<!--- superintendente --->
		    <cfif  (auxSitu is 8) or (auxSitu is 23)>
				<cfquery name="rsNomeSE" datasource="#dsn_inspecao#">
					SELECT Dir_Sto, Dir_Descricao 
					FROM Diretoria 
					WHERE (((Dir_Codigo)= left(rsPosNArea.Pos_Unidade,2)
				</cfquery>
				<cfset PosArea = rsNomeSE.Dir_Sto>
			    <cfset PosNomeArea = rsNomeSE.Dir_Descricao>
			</cfif>
			<!--- subordinadores --->
		    <cfif  (auxSitu is 4) or (auxSitu is 16)>
			    <cfif len(trim(PosArea)) lte 0>
					<cfquery name="rsNomeUnid" datasource="#dsn_inspecao#">
						SELECT Und_CodReop
						FROM Unidades
						WHERE Und_Codigo = '#rsPosNArea.Pos_Unidade#'
					</cfquery>
					<cfset PosArea = rsNomeUnid.Und_CodReop>
				</cfif>
				<cfquery name="rsReop" datasource="#dsn_inspecao#">
					SELECT Rep_Nome 
					FROM Reops 
					WHERE Rep_Codigo = '#PosArea#'
				</cfquery>
			    <cfset PosNomeArea = rsReop.Rep_Nome>
			</cfif>
			<!--- AREAS --->
		    <cfif  (auxSitu is 5) or (auxSitu is 19)>
				<cfquery name="rsArea" datasource="#dsn_inspecao#">
					SELECT Ars_Descricao 
					FROM Areas 
					WHERE Ars_Codigo = '#PosArea#'
				</cfquery>
			    <cfset PosNomeArea = rsArea.Ars_Descricao>
			</cfif>
		</cfoutput>
<!--- <cfoutput>linha 290 ajustea CAMPO POS_NOMEAREA ok</cfoutput><br> --->			
		<!---  --->
		<!--- POS_NOMEAREA NÃO PERMITIDOS  --->
		 <cfquery name="rsPosNmArea" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp
			FROM SLNCPRCIDCGIMES 
			where (Pos_NomeArea Like '%/CVCO%' or Pos_NomeArea Like '%CVCO/SCIA%' or Pos_NomeArea Like '%CCOP/SCIA%' Or Pos_NomeArea Like '%CVCO/SCOI%' Or Pos_NomeArea Like '%CCOP/SCOI%' Or Pos_NomeArea Like '%GCOP/SGCIN%' or Pos_NomeArea Like '%GSOP/CSEC' or Pos_NomeArea Like '%GAAV/SGSEC' Or Pos_NomeArea Like '%/CORR%' OR Pos_NomeArea Like '%/SCORG%')
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<cfoutput query="rsPosNmArea">
			<cfquery datasource="#dsn_inspecao#">
			   UPDATE SLNCPRCIDCGIMES SET Pos_Situacao_Resp = 11000 
			   WHERE Pos_Unidade='#rsPosNmArea.Pos_Unidade#' AND 
			   Pos_Inspecao='#rsPosNmArea.Pos_Inspecao#' AND 
			   Pos_NumGrupo=#rsPosNmArea.Pos_NumGrupo# AND 
			   Pos_NumItem=#rsPosNmArea.Pos_NumItem#
			 </cfquery>		
		</cfoutput>
		<!---  --->
<!--- <cfoutput>linha 309 POS_NOMEAREA N�O PERMITIDOS ok</cfoutput><br> --->	
<!---  --->
		<!--- obter campo HHMMSS da andamento para compor PRCI  --->

		 <cfquery name="rsAndHRPosic" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp, Pos_DtPosic
			FROM SLNCPRCIDCGIMES 
			WHERE Pos_Situacao_Resp < 5000
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
		<cfoutput query="rsAndHRPosic">
			<cfset PosDtPosic = CreateDate(year(rsAndHRPosic.Pos_DtPosic),month(rsAndHRPosic.Pos_DtPosic),day(rsAndHRPosic.Pos_DtPosic))>
			<cfquery name="rs14HH" datasource="#dsn_inspecao#">
				SELECT And_HrPosic
				FROM Andamento
				WHERE And_Unidade = '#rsAndHRPosic.Pos_Unidade#' AND 
				And_NumInspecao = '#rsAndHRPosic.Pos_Inspecao#' AND 
				And_NumGrupo = #rsAndHRPosic.Pos_NumGrupo# AND 
				And_NumItem = #rsAndHRPosic.Pos_NumItem# AND 
				And_Situacao_Resp = #rsAndHRPosic.Pos_Situacao_Resp# and And_DtPosic = #PosDtPosic#
			</cfquery>
			<cfset AndHrPosic = ''>
			<cfif rs14HH.recordcount gt 0>
			  <cfset AndHrPosic = TRIM(rs14HH.And_HrPosic)>
			</cfif>
			<cfif LEN(AndHrPosic) LTE 0>
			  <cfset AndHrPosic = TimeFormat(now(),"hh:mm:ssss")>
			</cfif>
	        <cfquery datasource="#dsn_inspecao#">
			   UPDATE SLNCPRCIDCGIMES SET andHrPosic = '#AndHrPosic#' 
			   WHERE Pos_Unidade='#rsAndHRPosic.Pos_Unidade#' AND 
			   Pos_Inspecao='#rsAndHRPosic.Pos_Inspecao#' AND 
			   Pos_NumGrupo=#rsAndHRPosic.Pos_NumGrupo# AND 
			   Pos_NumItem=#rsAndHRPosic.Pos_NumItem#
			 </cfquery>	
		</cfoutput>
 <!---   </cfif> --->
