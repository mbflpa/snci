<cfsetting requesttimeout="15000">
<cfprocessingdirective pageEncoding ="utf-8"/>
<cfoutput>
<!---   dtlimit#dtlimit#<br> 
<CFSET GIL = GIL>   --->
<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<!--- <cfif UCASE(TRIM(qUsuario.Usu_GrupoAcesso)) EQ 'GESTORMASTER'>
	 <!--- <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES SLNC EM MANUTENCAO!"> --->
<cfelse>
  <cfif day(now()) lte 6 and (int(month(dtlimit)) gt int(month(now())))>
		
  </cfif> 
</cfif>  --->
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<!---  <cfoutput>#se#  === #anoexerc#  === #dtlimit#<br></cfoutput>
 <CFSET GIL = GIL>   --->
<cfset total=0>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#se#'
</cfquery>
<cfset auxfilta = #qAcesso.Dir_Descricao#>
<cfset auxfiltb = 'SE/' & #qAcesso.Dir_Sigla#>
</cfoutput>
<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css.css" rel="stylesheet" type="text/css">
<script language="javascript">

//=============================

function listar(a,b,c,d){
	document.formx.lis_se.value=a;
	document.formx.lis_grpace.value=b;
    document.formx.lis_mes.value=c;
    document.formx.lis_ano.value=d;
	document.formx.submit(); 
}

</script>
<link href="css.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
.style1 {font-weight: bold}
-->
</style>
</head>
<body>
<form action="itens_Gestao_Andamento2.cfm" method="post" target="_blank" name="form1">
<cfset BaseUnid = ''>
<cfset BaseInsp = ''>
<cfset Basegrupo = ''>
<cfset BaseItem = ''>
<!--- Grupo Unidade --->
<cfset UN_JAN_DP = 0>
<cfset UN_JAN_FP = 0>
<cfset UN_JAN_TOT = 0>

<cfset UN_FEV_DP = 0>
<cfset UN_FEV_FP = 0>
<cfset UN_FEV_TOT = 0>

<cfset UN_MAR_DP = 0>
<cfset UN_MAR_FP = 0>
<cfset UN_MAR_TOT = 0>

<cfset UN_ABR_DP = 0>
<cfset UN_ABR_FP = 0>
<cfset UN_ABR_TOT = 0>

<cfset UN_MAI_DP = 0>
<cfset UN_MAI_FP = 0>
<cfset UN_MAI_TOT = 0>

<cfset UN_JUN_DP = 0>
<cfset UN_JUN_FP = 0>
<cfset UN_JUN_TOT = 0>

<cfset UN_JUL_DP = 0>
<cfset UN_JUL_FP = 0>
<cfset UN_JUL_TOT = 0>
<!---  --->
<cfset UN_AGO_DP = 0>
<cfset UN_AGO_FP = 0>
<cfset UN_AGO_TOT = 0>

<cfset UN_SET_DP = 0>
<cfset UN_SET_FP = 0>
<cfset UN_SET_TOT = 0>

<cfset UN_OUT_DP = 0>
<cfset UN_OUT_FP = 0>
<cfset UN_OUT_TOT = 0>

<cfset UN_NOV_DP = 0>
<cfset UN_NOV_FP = 0>
<cfset UN_NOV_TOT = 0>

<cfset UN_DEZ_DP = 0>
<cfset UN_DEZ_FP = 0>
<cfset UN_DEZ_TOT = 0>

<!--- AREAS --->
<cfset GE_JAN_DP = 0>
<cfset GE_JAN_FP = 0>
<cfset GE_JAN_TOT = 0>

<cfset GE_FEV_DP = 0>
<cfset GE_FEV_FP = 0>
<cfset GE_FEV_TOT = 0>

<cfset GE_MAR_DP = 0>
<cfset GE_MAR_FP = 0>
<cfset GE_MAR_TOT = 0>

<cfset GE_ABR_DP = 0>
<cfset GE_ABR_FP = 0>
<cfset GE_ABR_TOT = 0>

<cfset GE_MAI_DP = 0>
<cfset GE_MAI_FP = 0>
<cfset GE_MAI_TOT = 0>

<cfset GE_JUN_DP = 0>
<cfset GE_JUN_FP = 0>
<cfset GE_JUN_TOT = 0>

<cfset GE_JUL_DP = 0>
<cfset GE_JUL_FP = 0>
<cfset GE_JUL_TOT = 0>
<!---  --->
<cfset GE_AGO_DP = 0>
<cfset GE_AGO_FP = 0>
<cfset GE_AGO_TOT = 0>

<cfset GE_SET_DP = 0>
<cfset GE_SET_FP = 0>
<cfset GE_SET_TOT = 0>

<cfset GE_OUT_DP = 0>
<cfset GE_OUT_FP = 0>
<cfset GE_OUT_TOT = 0>

<cfset GE_NOV_DP = 0>
<cfset GE_NOV_FP = 0>
<cfset GE_NOV_TOT = 0>

<cfset GE_DEZ_DP = 0>
<cfset GE_DEZ_FP = 0>
<cfset GE_DEZ_TOT = 0>
<!--- subordnadores --->
<cfset SB_JAN_DP = 0>
<cfset SB_JAN_FP = 0>
<cfset SB_JAN_TOT = 0>

<cfset SB_FEV_DP = 0>
<cfset SB_FEV_FP = 0>
<cfset SB_FEV_TOT = 0>

<cfset SB_MAR_DP = 0>
<cfset SB_MAR_FP = 0>
<cfset SB_MAR_TOT = 0>

<cfset SB_ABR_DP = 0>
<cfset SB_ABR_FP = 0>
<cfset SB_ABR_TOT = 0>

<cfset SB_MAI_DP = 0>
<cfset SB_MAI_FP = 0>
<cfset SB_MAI_TOT = 0>

<cfset SB_JUN_DP = 0>
<cfset SB_JUN_FP = 0>
<cfset SB_JUN_TOT = 0>

<cfset SB_JUL_DP = 0>
<cfset SB_JUL_FP = 0>
<cfset SB_JUL_TOT = 0>
<!---  --->
<cfset SB_AGO_DP = 0>
<cfset SB_AGO_FP = 0>
<cfset SB_AGO_TOT = 0>

<cfset SB_SET_DP = 0>
<cfset SB_SET_FP = 0>
<cfset SB_SET_TOT = 0>

<cfset SB_OUT_DP = 0>
<cfset SB_OUT_FP = 0>
<cfset SB_OUT_TOT = 0>

<cfset SB_NOV_DP = 0>
<cfset SB_NOV_FP = 0>
<cfset SB_NOV_TOT = 0>

<cfset SB_DEZ_DP = 0>
<cfset SB_DEZ_FP = 0>
<cfset SB_DEZ_TOT = 0>
<!--- superintendencia --->
<cfset SU_JAN_DP = 0>
<cfset SU_JAN_FP = 0>
<cfset SU_JAN_TOT = 0>

<cfset SU_FEV_DP = 0>
<cfset SU_FEV_FP = 0>
<cfset SU_FEV_TOT = 0>

<cfset SU_MAR_DP = 0>
<cfset SU_MAR_FP = 0>
<cfset SU_MAR_TOT = 0>

<cfset SU_ABR_DP = 0>
<cfset SU_ABR_FP = 0>
<cfset SU_ABR_TOT = 0>

<cfset SU_MAI_DP = 0>
<cfset SU_MAI_FP = 0>
<cfset SU_MAI_TOT = 0>

<cfset SU_JUN_DP = 0>
<cfset SU_JUN_FP = 0>
<cfset SU_JUN_TOT = 0>

<cfset SU_JUL_DP = 0>
<cfset SU_JUL_FP = 0>
<cfset SU_JUL_TOT = 0>
<!---  --->
<cfset SU_AGO_DP = 0>
<cfset SU_AGO_FP = 0>
<cfset SU_AGO_TOT = 0>

<cfset SU_SET_DP = 0>
<cfset SU_SET_FP = 0>
<cfset SU_SET_TOT = 0>

<cfset SU_OUT_DP = 0>
<cfset SU_OUT_FP = 0>
<cfset SU_OUT_TOT = 0>

<cfset SU_NOV_DP = 0>
<cfset SU_NOV_FP = 0>
<cfset SU_NOV_TOT = 0>

<cfset SU_DEZ_DP = 0>
<cfset SU_DEZ_FP = 0>
<cfset SU_DEZ_TOT = 0>
<!--- UNIDADES --->
<cfset Unid_Tot_Jan = 0>
<cfset Unid_Tot_Fev = 0>
<cfset Unid_Tot_Mar = 0>
<cfset Unid_Tot_Abr = 0>
<cfset Unid_Tot_Mai = 0>
<cfset Unid_Tot_Jun = 0>
<cfset Unid_Tot_Jul = 0>
<cfset Unid_Tot_Ago = 0>
<cfset Unid_Tot_Set = 0>
<cfset Unid_Tot_Out = 0>
<cfset Unid_Tot_Nov = 0>
<cfset Unid_Tot_Dez = 0>
<cfset Unid_Tot_DP = 0>
<cfset Unid_Tot_FP = 0>
<cfset Uni_Total = 0> 

<!--- Gerentes - AREAS --->
<cfset Ger_Tot_Jan = 0>
<cfset Ger_Tot_Fev = 0>
<cfset Ger_Tot_Mar = 0>
<cfset Ger_Tot_Abr = 0>
<cfset Ger_Tot_Mai = 0>
<cfset Ger_Tot_Jun = 0>
<cfset Ger_Tot_Jul = 0>
<cfset Ger_Tot_Ago = 0>
<cfset Ger_Tot_Set = 0>
<cfset Ger_Tot_Out = 0>
<cfset Ger_Tot_Nov = 0>
<cfset Ger_Tot_Dez = 0>
<cfset Ger_Tot_DP = 0>
<cfset Ger_Tot_FP = 0>
<cfset Ger_Total = 0> 
<!--- SUBORDINADORES --->
<cfset Sub_Tot_Jan = 0>
<cfset Sub_Tot_Fev = 0>
<cfset Sub_Tot_Mar = 0>
<cfset Sub_Tot_Abr = 0>
<cfset Sub_Tot_Mai = 0>
<cfset Sub_Tot_Jun = 0>
<cfset Sub_Tot_Jul = 0>
<cfset Sub_Tot_Ago = 0>
<cfset Sub_Tot_Set = 0>
<cfset Sub_Tot_Out = 0>
<cfset Sub_Tot_Nov = 0>
<cfset Sub_Tot_Dez = 0>
<cfset Sub_Tot_DP = 0>
<cfset Sub_Tot_FP = 0>
<cfset Sub_Total = 0> 
<!--- superintendentes --->
<cfset Sup_Tot_Jan = 0>
<cfset Sup_Tot_Fev = 0>
<cfset Sup_Tot_Mar = 0>
<cfset Sup_Tot_Abr = 0>
<cfset Sup_Tot_Mai = 0>
<cfset Sup_Tot_Jun = 0>
<cfset Sup_Tot_Jul = 0>
<cfset Sup_Tot_Ago = 0>
<cfset Sup_Tot_Set = 0>
<cfset Sup_Tot_Out = 0>
<cfset Sup_Tot_Nov = 0>
<cfset Sup_Tot_Dez = 0>
<cfset Sup_Tot_DP = 0>
<cfset Sup_Tot_FP = 0>
<cfset Sup_Total = 0> 
<cfset SomaDPAnual = 0> 
<cfset SomaDPFPAnual = 0> 


<!---   <cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp where Andt_TipoRel = 1
</cfquery> --->     
<!---  --->

<cfset auxdthoje = CreateDate(year(now()),month(now()),day(now()))>
<!--- <cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp 
   where Andt_dtultatu < #auxdthoje# 
</cfquery> --->
<!--- <cfquery name="rsVazio" datasource="#dsn_inspecao#">
   select Andt_user from Andamento_Temp 
   where (Andt_CodSE  = '#se#') and Andt_TipoRel = 1 and Andt_AnoExerc = '#year(dtlimit)#' and Andt_Mes = '#month(dtlimit)#'
</cfquery> --->

<!---  --->
<cfset DT_MARCO_INI = CreateDate(anoexerc,01,01)>
<cfset dtPosicAntes = CreateDate(anoexerc,month(now()),day(now()))>
<cfset dtPosicAtual = CreateDate(anoexerc,month(now()),day(now()))>
<!--- <cfset dtlimit = CreateDate(year(dtlimit),month(dtlimit),day(dtlimit))> --->
<!--- <cfoutput>#dtlimit#</cfoutput>
<cfset gil = gil>   --->

<!--- <cfset aux_mes = month(DT_MARCO_INI)> --->
<!--- Acao;meses;unid;inps;grp;item;rsMes_Status;tpunid;rsMesdata;rsMeshora;rsMes_dias;diasuteis;dtresp;horaresp;RespStatus;rsRejdata;rsRejHora;rsRejStatus --->
<cfset aux_mes = 1> 
<!--- <cfoutput>#dtlimit#</cfoutput>
<cfset gil = gil>   --->
<!--- Criar linha de metas --->
<cfoutput>
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum
		FROM Metas
		WHERE Met_Codigo='#se#' and Met_Ano = #anoexerc# and Met_Mes = 1
	</cfquery>
	<!--- Criar linha de metas --->
	<cfquery name="rsMetas" datasource="#dsn_inspecao#">
		SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum
		FROM Metas
		WHERE Met_Codigo='#se#' and Met_Ano = #anoexerc# and Met_Mes = 1
	</cfquery>
</cfoutput>
<!--- criação dos meses por SE --->
<cfset nCont = 1>
<cfloop condition="nCont lte int(month(dtlimit))">
	<cfset metprci = trim(numberFormat(rsMetas.Met_PRCI,999.0))>
	<cfset metslnc = rsMetas.Met_SLNC>
	<!--- <cfset metdgci = numberFormat(((metslnc * 0.6) + (metprci * 0.4)),999.0)> --->
	<cfset metdgci = rsMetas.Met_DGCI>
	<cfset metslncmes = numberFormat(((metslnc / 12) * nCont),999.0)>
	<cfset metdgcimes = numberFormat(((metslncmes * 0.6) + (metprci * 0.4)),999.0)>
  <cfquery datasource="#dsn_inspecao#" name="rsCrMes">
	  SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum
	  FROM Metas
	  WHERE Met_Codigo ='#se#' AND Met_Ano = #anoexerc# AND Met_Mes = #nCont#
  </cfquery>	
  <cfif rsCrMes.recordcount lte 0>	
<!---  	
		<cfquery datasource="#dsn_inspecao#">
		 insert into Metas (Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_PRCI, Met_SLNC, Met_DGCI, Met_PRCI_Mes, Met_SLNC_Mes, Met_DGCI_Mes, Met_PRCI_Acum, Met_SLNC_Acum, Met_DGCI_Acum, Met_PRCI_AcumPeriodo, Met_SLNC_AcumPeriodo, Met_DGCI_AcumPeriodo) 
		  values ('#se#', #year(dtlimit)#, #nCont#, '#rsMetas.Met_SE_STO#', '#metprci#', '#metslnc#', '#metdgci#', '#metprci#', '#metslncmes#', '#metdgcimes#', '0.0', '0.0', '0.0', '0.0', '0.0', '0.0')
		</cfquery>  
--->		   
  </cfif>
	<cfif nCont eq 1>
<!---	
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Metas SET Met_DGCI='#metdgci#', Met_PRCI_Mes='#metprci#', Met_SLNC_Mes='#metslncmes#', Met_DGCI_Mes = '#metdgcimes#'
			WHERE Met_Codigo = '#se#' and Met_Ano = #anoexerc# and Met_Mes = 1
		</cfquery>  
--->				
	</cfif>  
  <cfset nCont = nCont + 1>
</cfloop>
<!--- <cfset dtlimit = 31/03/2022> --->
<!--- fim criar linhas de metas --->
<cfset dtlimit = CreateDate(anoexerc,12,31)>
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
 
		<cfquery name="rsVazio" datasource="#dsn_inspecao#">
			select Andt_user from Andamento_Temp 
			where (Andt_CodSE  = '#se#') and Andt_TipoRel = 1 and Andt_AnoExerc = '#year(dtfim)#' and Andt_Mes = '#month(dtfim)#'
		</cfquery>
		<cfif rsVazio.recordcount lte 0>
		 <!---    <cfinclude template="INDICADORES_MES.CFM"> --->
			<!--- rotina 3 --->
			<!--- COMPOR O PRCI COM OS 14-NR, PENDENTES E TRATAMENTOS DO MES --->
			<!--- TODAS UNIDADES --->
			<cfquery name="rsPRCIa" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
		FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
		WHERE Pos_Situacao_Resp In (14,2,4,5,8,20,15,16,18,19,23) 
		ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
			</cfquery>
			 <cfoutput query="rsPRCIa">
					<cfset AndtDPosic = CreateDate(year(rsPRCIa.Pos_DtPosic),month(rsPRCIa.Pos_DtPosic),day(rsPRCIa.Pos_DtPosic))>
					<cfset AndtHPosic = rsPRCIa.andHrPosic>
					<cfset AndtCodSE = left(rsPRCIa.Pos_Unidade,2)>
					<cfset auxsta = rsPRCIa.Pos_Situacao_Resp>			
					<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
					   <cfset AndtPrazo = 'DP'>
					<cfelse>
					   <cfset AndtPrazo = 'FP'>
					</cfif>		
					<!--- garantir a inclusão para PRCI --->
					<!--- <cfquery datasource="#dsn_inspecao#">
						insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_NomeOrgCondutor, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsPRCIa.Pos_Inspecao#', '#rsPRCIa.Pos_Unidade#', #rsPRCIa.Pos_NumGrupo#, #rsPRCIa.Pos_NumItem#, #AndtDPosic#, '#AndtHPosic#', #auxsta#, #rsPRCIa.Und_TipoUnidade#, 0, 0, '#rsPRCIa.pos_username#', CONVERT(char, GETDATE(), 120), '#rsPRCIa.Pos_Area#', '#rsPRCIa.Pos_NomeArea#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsPRCIa.Pos_PontuacaoPonto#, '#rsPRCIa.Pos_ClassificacaoPonto#')
					</cfquery> --->
					<!--- FAZER BUSCAS POR outras possíveis ocorrências(PEND/TRAT) na andamento dentro do MêS para PRCI --->
					<cfquery name="rsPENDTRAT" datasource="#dsn_inspecao#">
						SELECT And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
						FROM Andamento
						WHERE And_Unidade = '#rsPRCIa.Pos_Unidade#' AND 
						And_NumInspecao = '#rsPRCIa.Pos_Inspecao#' AND 
						And_NumGrupo = #rsPRCIa.Pos_NumGrupo# AND 
						And_NumItem = #rsPRCIa.Pos_NumItem# AND 
						And_Situacao_Resp in (2,4,5,8,20,15,16,18,19,23) and And_DtPosic between #dtini# and #dtfim#
						order by And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic
					</cfquery>
					<cfloop query="rsPENDTRAT">
						<cfset AndtDPosic = CreateDate(year(rsPENDTRAT.And_DtPosic),month(rsPENDTRAT.And_DtPosic),day(rsPENDTRAT.And_DtPosic))>
						<cfset AndtHPosic = rsPENDTRAT.And_HrPosic>
						<cfset AndtCodSE = left(rsPRCIa.Pos_Unidade,2)>
						<cfset auxsta = rsPENDTRAT.And_Situacao_Resp>			
						<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
						   <cfset AndtPrazo = 'DP'>
						<cfelse>
						   <cfset AndtPrazo = 'FP'>
						</cfif>
			
						<cfquery name="rsExiste" datasource="#dsn_inspecao#">
							select Andt_Insp 
							from Andamento_Temp 
							where Andt_AnoExerc = '#year(dtlimit)#' and
							Andt_Mes = #month(dtlimit)# and
							Andt_Insp = '#rsPRCIa.Pos_Inspecao#' and
							Andt_Unid = '#rsPRCIa.Pos_Unidade#' and
							Andt_Grp = #rsPRCIa.Pos_NumGrupo# and 
							Andt_Item = #rsPRCIa.Pos_NumItem# and 
							Andt_DPosic = #AndtDPosic# and
							Andt_HPosic = '#AndtHPosic#' and
							Andt_Resp = #auxsta# and
							Andt_TipoRel = 1
						</cfquery>			
						 <cfif rsExiste.recordcount lte 0>
								<!---  <cfquery datasource="#dsn_inspecao#">
								insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsPRCIa.Pos_Inspecao#', '#rsPRCIa.Pos_Unidade#', #rsPRCIa.Pos_NumGrupo#, #rsPRCIa.Pos_NumItem#, #AndtDPosic#, '#AndtHPosic#', #auxsta#, #rsPRCIa.Und_TipoUnidade#, 0, 0, '#rsPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsPENDTRAT.And_Area#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsPRCIa.Pos_PontuacaoPonto#, '#rsPRCIa.Pos_ClassificacaoPonto#')
								</cfquery> ---> 
						 </cfif>
					</cfloop>
			</cfoutput> 
			
			<!--- fim rotina 3  --->
		
			<!--- ROTINA 4 --->
			<!--- COMPOR O PRCI com possíveis redundantes do mês dos PENDENTES E TRATAMENTOS DO MES copiados da parecerunidade QUE PERTENÇAM AO MÊS --->
			<!--- TODAS UNIDADES --->
			<cfquery name="rsPRCI4" datasource="#dsn_inspecao#">
					SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
			FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp In (2,4,5,8,20,15,16,18,19,23) AND Pos_DtPosic between #dtini# and #dtfim# 
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
			</cfquery>
			<cfoutput query="rsPRCI4">
				<cfset AndtDPosic = CreateDate(year(rsPRCI4.Pos_DtPosic),month(rsPRCI4.Pos_DtPosic),day(rsPRCI4.Pos_DtPosic))>
				<cfset AndtHPosic = rsPRCI4.andHrPosic>
			<!--- FAZER BUSCAS POR outras possíveis ocorrências(PEND/TRAT) na andamento dentro do MêS para PRCI --->
				<cfquery name="rsPENDTRAT" datasource="#dsn_inspecao#">
					SELECT And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
					FROM Andamento
					WHERE And_Unidade = '#rsPRCI4.Pos_Unidade#' AND 
					And_NumInspecao = '#rsPRCI4.Pos_Inspecao#' AND 
					And_NumGrupo = #rsPRCI4.Pos_NumGrupo# AND 
					And_NumItem = #rsPRCI4.Pos_NumItem# AND 
					And_Situacao_Resp in (2,4,5,8,20,15,16,18,19,23) and And_DtPosic between #dtini# and #AndtDPosic# AND 
					And_HrPosic <> '#AndtHPosic#'
					order by And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic
				</cfquery>
				<cfloop query="rsPENDTRAT">
					<cfset AndtDPosic = CreateDate(year(rsPENDTRAT.And_DtPosic),month(rsPENDTRAT.And_DtPosic),day(rsPENDTRAT.And_DtPosic))>
					<cfset AndtHPosic = rsPENDTRAT.And_HrPosic>
					<cfset AndtCodSE = left(rsPRCI4.Pos_Unidade,2)>
					<cfset auxsta = rsPENDTRAT.And_Situacao_Resp>			
					<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
					   <cfset AndtPrazo = 'DP'>
					<cfelse>
					   <cfset AndtPrazo = 'FP'>
					</cfif>
			
					<cfquery name="rsExiste" datasource="#dsn_inspecao#">
						select Andt_Insp 
						from Andamento_Temp 
						where Andt_AnoExerc = '#year(dtlimit)#' and
						Andt_Mes = #month(dtlimit)# and
						Andt_Insp = '#rsPRCI4.Pos_Inspecao#' and
						Andt_Unid = '#rsPRCI4.Pos_Unidade#' and
						Andt_Grp = #rsPRCI4.Pos_NumGrupo# and 
						Andt_Item = #rsPRCI4.Pos_NumItem# and 
						Andt_DPosic = #AndtDPosic# and
						Andt_HPosic = '#AndtHPosic#' and
						Andt_Resp = #auxsta# and
						Andt_TipoRel = 1
					</cfquery>			
			   		<cfif rsExiste.recordcount lte 0>
						<!---  <cfquery datasource="#dsn_inspecao#">
						insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsPRCI4.Pos_Inspecao#', '#rsPRCI4.Pos_Unidade#', #rsPRCI4.Pos_NumGrupo#, #rsPRCI4.Pos_NumItem#, #AndtDPosic#, '#AndtHPosic#', #auxsta#, #rsPRCIa.Und_TipoUnidade#, 0, 0, '#rsPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsPENDTRAT.And_Area#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, 0, #rsPRCI4.Pos_PontuacaoPonto#, '#rsPRCI4.Pos_ClassificacaoPonto#')
						</cfquery>  --->
					</cfif>
				</cfloop>
			</cfoutput>
			<!--- FIM ROTINA 4 ---> 
		 	<!--- ROTINA 5 --->
		 	<!--- OBTER NA ANDAMENTO POSSÍVEIS STATUS (14-NR, PEND OU TRAT) PARA COMPOR PRCI  DOS PONTOS TRAZIDOS DA PARECERUNIDADE(RESPOSTAS, SO, CS, PI, OC, RV AP, RC, NC, 
	 BX, EA, EC e TP --->
			<cfquery name="rsPRCI5" datasource="#dsn_inspecao#">
				SELECT Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_DtPrev_Solucao, pos_dtultatu, pos_username, Pos_Situacao_Resp, Pos_Situacao, Pos_Area, Pos_NomeArea, Und_TipoUnidade, pos_dtultatu, andHrPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
			FROM SLNCPRCIDCGIMES INNER JOIN Unidades ON Pos_Unidade = Und_Codigo
			WHERE Pos_Situacao_Resp In (3,1,6,7,17,22,9,10,12,13,21,24,25,26,27,28,29,30) AND Pos_DtPosic between #dtini# and #dtfim#
			ORDER BY Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic
			</cfquery>
			<cfoutput query="rsPRCI5">
				<cfset AndtDPosic = CreateDate(year(rsPRCI5.Pos_DtPosic),month(rsPRCI5.Pos_DtPosic),day(rsPRCI5.Pos_DtPosic))>
				<cfset AndtHPosic = rsPRCI5.andHrPosic>
				<cfquery name="rsNRPENDTRAT" datasource="#dsn_inspecao#">
					SELECT And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area
					FROM Andamento
					WHERE And_Unidade = '#rsPRCI5.Pos_Unidade#' AND 
					And_NumInspecao = '#rsPRCI5.Pos_Inspecao#' AND 
					And_NumGrupo = #rsPRCI5.Pos_NumGrupo# AND 
					And_NumItem = #rsPRCI5.Pos_NumItem# AND 
					And_Situacao_Resp in (14,2,4,5,8,20,15,16,18,19,23) and And_DtPosic between #dtini# and #AndtDPosic# AND 
					And_HrPosic <> '#AndtHPosic#'
					order by And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic
				</cfquery>
				<cfloop query="rsNRPENDTRAT">
					<cfset AndtDPosic = CreateDate(year(rsNRPENDTRAT.And_DtPosic),month(rsNRPENDTRAT.And_DtPosic),day(rsNRPENDTRAT.And_DtPosic))>
					<cfset AndtHPosic = rsNRPENDTRAT.And_HrPosic>
					<cfset AndtCodSE = left(rsPRCI5.Pos_Unidade,2)>
					<cfset auxsta = rsNRPENDTRAT.And_Situacao_Resp>			
					<cfif auxsta eq 14 or auxsta eq 15 or auxsta eq 16 or auxsta eq 18 or auxsta eq 19 or auxsta eq 23>
					   <cfset AndtPrazo = 'DP'>
					<cfelse>
					   <cfset AndtPrazo = 'FP'>
					</cfif>
			
					<cfquery name="rsExisteb" datasource="#dsn_inspecao#">
						select Andt_Insp 
						from Andamento_Temp 
						where Andt_AnoExerc = '#year(dtlimit)#' and
						Andt_Mes = #month(dtlimit)# and
						Andt_Insp = '#rsPRCI5.Pos_Inspecao#' and
						Andt_Unid = '#rsPRCI5.Pos_Unidade#' and
						Andt_Grp = #rsPRCI5.Pos_NumGrupo# and 
						Andt_Item = #rsPRCI5.Pos_NumItem# and 
						Andt_DPosic = #AndtDPosic# and
						Andt_HPosic = '#AndtHPosic#' and
						Andt_Resp = #auxsta# and
						Andt_TipoRel = 1
					</cfquery>			
			        <cfif rsExisteb.recordcount lte 0>
						 <!--- <cfquery datasource="#dsn_inspecao#">
						insert into Andamento_Temp (Andt_AnoExerc, Andt_Mes, Andt_Insp, Andt_Unid, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_user, Andt_dtultatu, Andt_Area, Andt_CodSE, Andt_DTRefer, Andt_Prazo, Andt_TipoRel, Andt_RespAnt, Andt_PosPontuacaoPonto, Andt_PosClassificacaoPonto) values ('#year(dtlimit)#', #month(dtlimit)#, '#rsPRCI5.Pos_Inspecao#', '#rsPRCI5.Pos_Unidade#', #rsPRCI5.Pos_NumGrupo#, #rsPRCI5.Pos_NumItem#, #AndtDPosic#, '#AndtHPosic#', #auxsta#, #rsPRCI5.Und_TipoUnidade#, 0, 0, '#rsNRPENDTRAT.And_username#', CONVERT(char, GETDATE(), 120), '#rsNRPENDTRAT.And_Area#', '#AndtCodSE#', #dtfim#, '#AndtPrazo#', 1, '', #rsPRCI5.Pos_PontuacaoPonto#, '#rsPRCI5.Pos_ClassificacaoPonto#')
						</cfquery>  --->
				    </cfif>
			   </cfloop>
		    </cfoutput> 
			<!--- FIM ROTINA 5 ---> 
		
			<!--- ROTINA 6 --->
			<!--- VALIDAR PONTOS NA TABELA: Andamento_Temp  --->
	    	<!--- GRUPOS E ITENS NÃO PERMITIDOS  --->
			<cfquery name="rsGRIT" datasource="#dsn_inspecao#">
			SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area
			FROM Andamento_Temp 
			WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=1 AND Andt_Mes = #month(dtlimit)#
			</cfquery>
			<cfoutput query="rsGRIT">
				<cfset auxgrp = rsGRIT.Andt_Grp>
				<cfset auxitm = rsGRIT.Andt_Item>
				<cfif (auxgrp is 9 and auxitm is 9) or (auxgrp is 29 and auxitm is 4) or (auxgrp is 68 and auxitm is 3) or (auxgrp is 96 and auxitm is 3) or (auxgrp is 122 and auxitm is 3) or (auxgrp is 209 and auxitm is 3) or (auxgrp is 241 and auxitm is 3) or (auxgrp is 308 and auxitm is 3) or (auxgrp is 278 and auxitm is 2) or (auxgrp is 337 and auxitm is 2)>
					<!--- <cfquery datasource="#dsn_inspecao#">
					   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
					   WHERE Andt_Unid='#rsGRIT.Andt_Unid#' AND 
					   Andt_Insp='#rsGRIT.Andt_Insp#' AND 
					   Andt_Grp=#rsGRIT.Andt_Grp# AND 
					   Andt_Item=#rsGRIT.Andt_Item#
					</cfquery>	 --->	
	        	</cfif>
			</cfoutput>			
			<!--- FIM ROTINA 6 ---> 
		
			<!--- ROTINA 7 --->
			<!--- POS_NOMEAREA NÃO PERMITIDOS  --->
			 <cfquery name="AndtArea" datasource="#dsn_inspecao#">
				SELECT Andt_AnoExerc, Andt_TipoRel, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_Resp, Andt_Area
				FROM Andamento_Temp 
				WHERE Andt_AnoExerc ='#year(dtlimit)#' AND Andt_TipoRel=1 AND Andt_Mes = #month(dtlimit)# 
			</cfquery>
			<cfoutput query="AndtArea">
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
            	<cfif rsNegar.recordcount gt 0>
					<!--- <cfquery datasource="#dsn_inspecao#">
					   UPDATE Andamento_Temp SET Andt_Prazo = 'EX'
					   WHERE Andt_Unid='#AndtArea.Andt_Unid#' AND 
					   Andt_Insp='#AndtArea.Andt_Insp#' AND 
					   Andt_Grp=#AndtArea.Andt_Grp# AND 
					   Andt_Item=#AndtArea.Andt_Item#
				 	</cfquery> --->	
				</cfif>			 	
		</cfoutput>
		<!--- FIM ROTINA 7 ---> 
	</cfif>	

	<cfset aux_mes = aux_mes + 1>	
</cfloop>
<!--- </cfif> --->

<!--- integridade dados--->
<cfoutput>
<cfset aux_mes = 1> 
<!--- <cfoutput>#dtlimit#</cfoutput>
<cfset gil = gil> --->
<cfloop condition="#aux_mes# lte int(month(dtlimit))">
<!---      <cfif aux_mes lt int(month(now()))> --->
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
       <cfset aux_mes = aux_mes + 1>
</cfloop>
<!--- EXCLUIR 
<cfquery datasource="#dsn_inspecao#">
   delete from Andamento_Temp 
   where Andt_Prazo = 'EX'
</cfquery> 
--->
<!--- <cfoutput>dtlimit#dtlimit# dtini #dtini# dtfim #dtfim#</cfoutput>
<cfset gil = gil> --->
<!--- exibicao em tela --->
<cfif UCASE(TRIM(qUsuario.Usu_GrupoAcesso)) EQ 'GESTORMASTER'>
	<cfquery name="rsBaseB" datasource="#dsn_inspecao#">
		SELECT Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
		FROM Andamento_Temp 
		where (Andt_CodSE = '#se#' and Andt_TipoRel = 1 and Andt_AnoExerc = '#year(dtlimit)#')
	</cfquery>
<cfelse>
<!--- <cfset gil = gil> --->
	<cfquery name="rsBaseB" datasource="#dsn_inspecao#">
		SELECT Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
		FROM Andamento_Temp 
		where (Andt_CodSE = '#se#' and Andt_TipoRel = 1 and Andt_AnoExerc = '#year(dtlimit)#' and Andt_Mes <= '#month(dtlimit)#')
	</cfquery>
</cfif>

<cfloop query="rsBaseB">
<!--- 	baseB;#rsBaseB.Andt_Mes#;#rsBaseB.UNID#;#rsBaseB.INSP#;#rsBaseB.Grupo#;#rsBaseB.Item#;#rsBaseB.Andt_Resp#;#rsBaseB.Andt_tpunid#;#dateformat(rsBaseB.Andt_DPosic,"dd/mm/yyyy")#;#rsBaseB.Andt_HPosic#;#rsBaseB.Andt_DiasCor#;;;;;;;<br> 								 --->
	<cfset aux_mes = rsBaseB.Andt_Mes>
	<cfset tpunid = rsBaseB.Andt_tpunid>
	<cfset rsMes_status = rsBaseB.Andt_Resp>
	 
	<!--- unidade  e Terceiros--->
	<!--- <cfif (tpunid neq 12) and (rsMes_status is 1 or rsMes_status is 2 or rsMes_status is 14 or rsMes_status is 15)> --->
	<cfif (rsMes_status is 1 or rsMes_status is 17 or rsMes_status is 2 or rsMes_status is 14 or rsMes_status is 15 or rsMes_status is 18 or rsMes_status is 20)>
		  <cfif trim(Andt_Prazo) eq "DP"> 
			<cfset Unid_Tot_DP = Unid_Tot_DP + 1>
		  <cfelse> 
			<cfset Unid_Tot_FP = Unid_Tot_FP + 1>
<!--- UNID_DP;#rsBaseB.Andt_Mes#;#rsBaseB.UNID#;#rsBaseB.INSP#;#rsBaseB.Grupo#;#rsBaseB.Item#;#rsBaseB.Andt_Resp#;#rsBaseB.Andt_tpunid#;#dateformat(rsBaseB.Andt_DPosic,"dd/mm/yyyy")#;#rsBaseB.Andt_HPosic#;#rsBaseB.Andt_DiasCor#;;;;;;;<br> 								 --->
		  </cfif>
		  <cfswitch expression="#aux_mes#">
			   <cfcase value="1">
			   <!--- ========================================= --->
					  <cfset UN_JAN_TOT = UN_JAN_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset UN_JAN_DP = UN_JAN_DP + 1>
					  <cfelse>  
							<cfset UN_JAN_FP = UN_JAN_FP + 1>	
					  </cfif>								
				<!--- ====================================== --->
			   </cfcase>
			   <cfcase value="2">
					  <cfset UN_FEV_TOT = UN_FEV_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset UN_FEV_DP = UN_FEV_DP + 1>
					  <cfelse>  
							<cfset UN_FEV_FP = UN_FEV_FP + 1>	
					  </cfif>								
			   </cfcase>
			   <cfcase value="3">
			          <cfset UN_MAR_TOT = UN_MAR_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_MAR_DP = UN_MAR_DP + 1>
					  <cfelse>  
							<cfset UN_MAR_FP = UN_MAR_FP + 1>	
					  </cfif>							
			   </cfcase>
			   <cfcase value="4">
					  <cfset UN_ABR_TOT = UN_ABR_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_ABR_DP = UN_ABR_DP + 1>
					  <cfelse>  
							<cfset UN_ABR_FP = UN_ABR_FP + 1>	
					  </cfif>								
			   </cfcase>	
			   <cfcase value="5">
					  <cfset UN_MAI_TOT = UN_MAI_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_MAI_DP = UN_MAI_DP + 1>
					  <cfelse>  
							<cfset UN_MAI_FP = UN_MAI_FP + 1>	
					  </cfif>						
			   </cfcase>
			   <cfcase value="6">
					  <cfset UN_JUN_TOT = UN_JUN_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_JUN_DP = UN_JUN_DP + 1>
					  <cfelse>  
							<cfset UN_JUN_FP = UN_JUN_FP + 1>	
					  </cfif>							
			   </cfcase>
			   <cfcase value="7">
					  <cfset UN_JUL_TOT = UN_JUL_TOT + 1>						   
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset UN_JUL_DP = UN_JUL_DP + 1>
					  <cfelse>  
							<cfset UN_JUL_FP = UN_JUL_FP + 1>	
					  </cfif>							
			   </cfcase>
			   <cfcase value="8">
					  <cfset UN_AGO_TOT = UN_AGO_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset UN_AGO_DP = UN_AGO_DP + 1>
					  <cfelse>  
							<cfset UN_AGO_FP = UN_AGO_FP + 1>	
					  </cfif>									
			   </cfcase>
			   <cfcase value="9">
					  <cfset UN_SET_TOT = UN_SET_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset UN_SET_DP = UN_SET_DP + 1>
					  <cfelse>  
							<cfset UN_SET_FP = UN_SET_FP + 1>	
					  </cfif>								
			   </cfcase>
			   <cfcase value="10">
					  <cfset UN_OUT_TOT = UN_OUT_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_OUT_DP = UN_OUT_DP + 1>
					  <cfelse>  
							<cfset UN_OUT_FP = UN_OUT_FP + 1>	
					  </cfif>
			   </cfcase>
			   <cfcase value="11">
					  <cfset UN_NOV_TOT = UN_NOV_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_NOV_DP = UN_NOV_DP + 1>
					  <cfelse>  
							<cfset UN_NOV_FP = UN_NOV_FP + 1>	
					  </cfif>								
			   </cfcase>
			   <cfcase value="12">
					  <cfset UN_DEZ_TOT = UN_DEZ_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset UN_DEZ_DP = UN_DEZ_DP + 1>
					  <cfelse>  
							<cfset UN_DEZ_FP = UN_DEZ_FP + 1>	
					  </cfif>							
			   </cfcase>						   							   					   
	  </cfswitch>
	</cfif>
			<!--- AREAS --->
	<cfif rsMes_status is 6 or rsMes_status is 5 or rsMes_status is 19>
			  <cfif trim(Andt_Prazo) eq "DP">
					<cfset Ger_Tot_DP = Ger_Tot_DP + 1>
			  <cfelse> 
					<cfset Ger_Tot_FP = Ger_Tot_FP + 1>	
			  </cfif> 						  
			  <cfswitch expression="#aux_mes#">
				   <cfcase value="1">
					  <cfset GE_JAN_TOT = GE_JAN_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset GE_JAN_DP = GE_JAN_DP + 1>
					  <cfelse> 
							<cfset GE_JAN_FP = GE_JAN_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="2">
					  <cfset GE_FEV_TOT = GE_FEV_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset GE_FEV_DP = GE_FEV_DP + 1>
					  <cfelse> 
							<cfset GE_FEV_FP = GE_FEV_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="3">
					  <cfset GE_MAR_TOT = GE_MAR_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset GE_MAR_DP = GE_MAR_DP + 1>
					  <cfelse> 
							<cfset GE_MAR_FP = GE_MAR_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="4">
					  <cfset GE_ABR_TOT = GE_ABR_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset GE_ABR_DP = GE_ABR_DP + 1>
					  <cfelse> 
							<cfset GE_ABR_FP = GE_ABR_FP + 1>	
					  </cfif>
				   </cfcase>	
				   <cfcase value="5">
					  <cfset GE_MAI_TOT = GE_MAI_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset GE_MAI_DP = GE_MAI_DP + 1>
					  <cfelse> 
							<cfset GE_MAI_FP = GE_MAI_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="6">
					  <cfset GE_JUN_TOT = GE_JUN_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset GE_JUN_DP = GE_JUN_DP + 1>
					  <cfelse> 
							<cfset GE_JUN_FP = GE_JUN_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="7">
					  <cfset GE_JUL_TOT = GE_JUL_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset GE_JUL_DP = GE_JUL_DP + 1>
					  <cfelse> 
							<cfset GE_JUL_FP = GE_JUL_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="8">
					  <cfset GE_AGO_TOT = GE_AGO_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset GE_AGO_DP = GE_AGO_DP + 1>
					  <cfelse> 
							<cfset GE_AGO_FP = GE_AGO_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="9">
					  <cfset GE_SET_TOT = GE_SET_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset GE_SET_DP = GE_SET_DP + 1>
					  <cfelse> 
							<cfset GE_SET_FP = GE_SET_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="10">
					  <cfset GE_OUT_TOT = GE_OUT_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset GE_OUT_DP = GE_OUT_DP + 1>
					  <cfelse> 
							<cfset GE_OUT_FP = GE_OUT_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="11">
					  <cfset GE_NOV_TOT = GE_NOV_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP">
							<cfset GE_NOV_DP = GE_NOV_DP + 1>
					  <cfelse> 
							<cfset GE_NOV_FP = GE_NOV_FP + 1>	
					  </cfif>
				   </cfcase>
				   <cfcase value="12">
					  <cfset GE_DEZ_TOT = GE_DEZ_TOT + 1>
					  <cfif trim(Andt_Prazo) eq "DP"> 
							<cfset GE_DEZ_DP = GE_DEZ_DP + 1>
					  <cfelse> 
							<cfset GE_DEZ_FP = GE_DEZ_FP + 1>	
					  </cfif>
				   </cfcase>						   							   					   
        </cfswitch>
	  </cfif>				  
	  <cfif rsMes_status is 4 or rsMes_status is 7 or rsMes_status is 16>
		  <cfif trim(Andt_Prazo) eq "DP"> 
<!--- ORGAO_DP;#rsBaseB.Andt_Mes#;#rsBaseB.UNID#;#rsBaseB.INSP#;#rsBaseB.Grupo#;#rsBaseB.Item#;#rsBaseB.Andt_Resp#;#rsBaseB.Andt_tpunid#;#dateformat(rsBaseB.Andt_DPosic,"dd/mm/yyyy")#;#rsBaseB.Andt_HPosic#;#rsBaseB.Andt_DiasCor#;;;;;;;<br> 								 --->
				<cfset Sub_Tot_DP = Sub_Tot_DP + 1>
		  <cfelse> 
<!--- ORGAO_FP;#rsBaseB.Andt_Mes#;#rsBaseB.UNID#;#rsBaseB.INSP#;#rsBaseB.Grupo#;#rsBaseB.Item#;#rsBaseB.Andt_Resp#;#rsBaseB.Andt_tpunid#;#dateformat(rsBaseB.Andt_DPosic,"dd/mm/yyyy")#;#rsBaseB.Andt_HPosic#;#rsBaseB.Andt_DiasCor#;;;;;;;<br> 								 --->
				<cfset Sub_Tot_FP = Sub_Tot_FP + 1>	
		  </cfif>					  	
						 <!---  <cfset Sub_Total = Sub_Total + 1>	 --->
		  <cfswitch expression="#aux_mes#">
			   <cfcase value="1">
				  <cfset SB_JAN_TOT = SB_JAN_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP"> 
						<cfset SB_JAN_DP = SB_JAN_DP + 1>
				  <cfelse> 
						<cfset SB_JAN_FP = SB_JAN_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="2">
				  <cfset SB_FEV_TOT = SB_FEV_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_FEV_DP = SB_FEV_DP + 1>
				  <cfelse> 
						<cfset SB_FEV_FP = SB_FEV_FP + 1>	
				  </cfif>					  
			   </cfcase>
			   <cfcase value="3">
				  <cfset SB_MAR_TOT = SB_MAR_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_MAR_DP = SB_MAR_DP + 1>
				  <cfelse> 
						<cfset SB_MAR_FP = SB_MAR_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="4">
				  <cfset SB_ABR_TOT = SB_ABR_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_ABR_DP = SB_ABR_DP + 1>
				  <cfelse> 
						<cfset SB_ABR_FP = SB_ABR_FP + 1>	
				  </cfif>
			   </cfcase>	
			   <cfcase value="5">
				  <cfset SB_MAI_TOT = SB_MAI_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_MAI_DP = SB_MAI_DP + 1>
				  <cfelse> 
						<cfset SB_MAI_FP = SB_MAI_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="6">
				  <cfset SB_JUN_TOT = SB_JUN_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_JUN_DP = SB_JUN_DP + 1>
				  <cfelse> 
						<cfset SB_JUN_FP = SB_JUN_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="7">
				  <cfset SB_JUL_TOT = SB_JUL_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_JUL_DP = SB_JUL_DP + 1>
				  <cfelse> 
						<cfset SB_JUL_FP = SB_JUL_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="8">
				  <cfset SB_AGO_TOT = SB_AGO_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_AGO_DP = SB_AGO_DP + 1>
				  <cfelse> 
						<cfset SB_AGO_FP = SB_AGO_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="9">
				  <cfset SB_SET_TOT = SB_SET_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_SET_DP = SB_SET_DP + 1>
				  <cfelse> 
						<cfset SB_SET_FP = SB_SET_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="10">
				  <cfset SB_OUT_TOT = SB_OUT_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_OUT_DP = SB_OUT_DP + 1>
				  <cfelse> 
						<cfset SB_OUT_FP = SB_OUT_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="11">
				  <cfset SB_NOV_TOT = SB_NOV_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_NOV_DP = SB_NOV_DP + 1>
				  <cfelse> 
						<cfset SB_NOV_FP = SB_NOV_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="12">
				  <cfset SB_DEZ_TOT = SB_DEZ_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SB_DEZ_DP = SB_DEZ_DP + 1>
				  <cfelse> 
						<cfset SB_DEZ_FP = SB_DEZ_FP + 1>	
				  </cfif>
			   </cfcase>						   							   					   
          </cfswitch>	
      </cfif>	
      <cfif rsMes_status is 22 or rsMes_status is 8 or rsMes_status is 23>					
		  <cfif trim(Andt_Prazo) eq "DP"> 
				<cfset Sup_Tot_DP = Sup_Tot_DP + 1>
		  <cfelse> 
				<cfset Sup_Tot_FP = Sup_Tot_FP + 1>	
		  </cfif>							  
		  <!---  <cfset Sup_Total = Sup_Total + 1>	 --->				
		  <cfswitch expression="#aux_mes#">
			   <cfcase value="1">
				  <cfset SU_JAN_TOT = SU_JAN_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_JAN_DP = SU_JAN_DP + 1>
				  <cfelse> 
						<cfset SU_JAN_FP = SU_JAN_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="2">
				  <cfset SU_FEV_TOT = SU_FEV_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_FEV_DP = SU_FEV_DP + 1>
				  <cfelse> 
						<cfset SU_FEV_FP = SU_FEV_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="3">
				  <cfset SU_MAR_TOT = SU_MAR_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_MAR_DP = SU_MAR_DP + 1>
				  <cfelse> 
						<cfset SU_MAR_FP = SU_MAR_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="4">
				  <cfset SU_ABR_TOT = SU_ABR_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_ABR_DP = SU_ABR_DP + 1>
				  <cfelse> 
						<cfset SU_ABR_FP = SU_ABR_FP + 1>	
				  </cfif>
			   </cfcase>	
			   <cfcase value="5">
				  <cfset SU_MAI_TOT = SU_MAI_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_MAI_DP = SU_MAI_DP + 1>
				  <cfelse> 
						<cfset SU_MAI_FP = SU_MAI_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="6">
				  <cfset SU_JUN_TOT = SU_JUN_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_JUN_DP = SU_JUN_DP + 1>
				  <cfelse> 
						<cfset SU_JUN_FP = SU_JUN_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="7">
				  <cfset SU_JUL_TOT = SU_JUL_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_JUL_DP = SU_JUL_DP + 1>
				  <cfelse> 
						<cfset SU_JUL_FP = SU_JUL_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="8">
				  <cfset SU_AGO_TOT = SU_AGO_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_AGO_DP = SU_AGO_DP + 1>
				  <cfelse> 
						<cfset SU_AGO_FP = SU_AGO_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="9">
				  <cfset SU_SET_TOT = SU_SET_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_SET_DP = SU_SET_DP + 1>
				  <cfelse> 
						<cfset SU_SET_FP = SU_SET_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="10">
				  <cfset SU_OUT_TOT = SU_OUT_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_OUT_DP = SU_OUT_DP + 1>
				  <cfelse> 
						<cfset SU_OUT_FP = SU_OUT_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="11">
				  <cfset SU_NOV_TOT = SU_NOV_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_NOV_DP = SU_NOV_DP + 1>
				  <cfelse> 
						<cfset SU_NOV_FP = SU_NOV_FP + 1>	
				  </cfif>
			   </cfcase>
			   <cfcase value="12">
				  <cfset SU_DEZ_TOT = SU_DEZ_TOT + 1>
				  <cfif trim(Andt_Prazo) eq "DP">
						<cfset SU_DEZ_DP = SU_DEZ_DP + 1>
				  <cfelse> 
						<cfset SU_DEZ_FP = SU_DEZ_FP + 1>	
				  </cfif>
			   </cfcase>						   							   					   
         </cfswitch>
      </cfif>
</cfloop>
<!---  --->

<cfset Uni_Total = UN_JAN_TOT + UN_FEV_TOT + UN_MAR_TOT + UN_ABR_TOT + UN_MAI_TOT + UN_JUN_TOT + UN_JUL_TOT + UN_AGO_TOT + UN_SET_TOT + UN_OUT_TOT + UN_NOV_TOT + UN_DEZ_TOT>
<cfset Ger_Total = GE_JAN_TOT + GE_FEV_TOT + GE_MAR_TOT + GE_ABR_TOT + GE_MAI_TOT + GE_JUN_TOT + GE_JUL_TOT + GE_AGO_TOT + GE_SET_TOT + GE_OUT_TOT + GE_NOV_TOT + GE_DEZ_TOT>
<cfset Sub_Total = SB_JAN_TOT + SB_FEV_TOT + SB_MAR_TOT + SB_ABR_TOT + SB_MAI_TOT + SB_JUN_TOT + SB_JUL_TOT + SB_AGO_TOT + SB_SET_TOT + SB_OUT_TOT + SB_NOV_TOT + SB_DEZ_TOT>
<cfset Sup_Total = SU_JAN_TOT + SU_FEV_TOT + SU_MAR_TOT + SU_ABR_TOT + SU_MAI_TOT + SU_JUN_TOT + SU_JUL_TOT + SU_AGO_TOT + SU_SET_TOT + SU_OUT_TOT + SU_NOV_TOT + SU_DEZ_TOT>

<!---  --->
<cfset auxtit = "SE: " & #qAcesso.Dir_codigo# & "-" & #qAcesso.Dir_Sigla#>
  
  <table width="45%" border="1" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="17"><div align="center" class="titulo1"><strong>#auxfilta#</strong></div></td>
      </tr>

	        <tr>
	          <td colspan="17">&nbsp;</td>
      </tr>
	        <tr>
	          <td colspan="17"><div align="center"><span class="titulo1"><strong>Atendimento ao Prazo de Resposta do Controle Interno (PRCI)</strong></span></div></td>
      </tr>
	  	        <tr>
	          <td colspan="17">&nbsp;</td>
      </tr>

	        <tr>
        <td colspan="17"></td>
      </tr>
	       <tr class="exibir">
        <td colspan="17"><div align="center"></div>
            <div align="center"></div>
            <div align="center"></div>            <div align="center" class="style1">
            </div></td>
        </tr>

<!--- UNIDADES --->		
<cfif Uni_Total neq 0>	       
      <tr class="exibir">
	      <td colspan="7" class="titulos"><div align="center">Unidades</div></td>
      </tr>
      <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td width="21%"><div align="center"><strong>Dentro prazo</strong></div></td>
        <td width="13%"><div align="center">%(DP)</div></td>
        <td width="17%"><div align="center"><strong>Fora prazo</strong></div></td>
        <td width="13%"><div align="center">%(FP)</div></td>
        <td><div align="center"><strong>Total&nbsp;&nbsp;</strong></div></td>
        <td>&nbsp;</td>
        <td width="1%">      
      </tr>
	  <CFIF UN_JAN_TOT NEQ 0>
	   <cfset PerFP = left((UN_JAN_FP/UN_JAN_TOT) * 100,4)>
	   <cfset PerDP = left((UN_JAN_DP/UN_JAN_TOT) * 100,4)>
      <tr class="exibir">
         <td><div align="center"><strong>JAN</strong></div></td>
<!--- 		<td><div align="center"><strong><div align="center"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'un',1,<cfoutput>#year(dtlimit)#</cfoutput>);">Jan</button>
	     </div></div></td> --->
        <td><div align="center"><strong>#UN_JAN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_JAN_FP#</strong></div></td>
        <td><div align="center" class="red_titulo">#NumberFormat(PerFP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_JAN_TOT#</strong></div></td>
		<td width="13%" class="exibir"><div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',1,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
	  <CFIF UN_FEV_TOT NEQ 0>
	   <cfset PerDP = left((UN_FEV_DP/UN_FEV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_FEV_FP/UN_FEV_TOT) * 100,4)>
      <tr class="exibir">
        <td width="6%"><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#UN_FEV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_FEV_FP#</strong></div></td>
        <td><div align="center" class="red_titulo">#NumberFormat(PerFP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_FEV_TOT#</strong></div></td>
		<td class="exibir"><div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',2,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div>
			<td>
		</tr>
	  </CFIF>
	  <CFIF UN_MAR_TOT NEQ 0>
	   <cfset PerDP = left((UN_MAR_DP/UN_MAR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_MAR_FP/UN_MAR_TOT) * 100,4)>  
      <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#UN_MAR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_MAR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_MAR_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',3,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
	  <CFIF UN_ABR_TOT NEQ 0>
	   <cfset PerDP = left((UN_ABR_DP/UN_ABR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_ABR_FP/UN_ABR_TOT) * 100,4)>  	  
      <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#UN_ABR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_ABR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_ABR_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',4,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div>
			<td>
		</tr>
	  </CFIF>
	  <CFIF UN_MAI_TOT NEQ 0>
	   <cfset PerDP = left((UN_MAI_DP/UN_MAI_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_MAI_FP/UN_MAI_TOT) * 100,4)> 	  
      <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#UN_MAI_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_MAI_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_MAI_TOT#</strong></div></td>
				<td class="exibir">
				  <div align="center">
				    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',5,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			      </div>
		    <td>
		  </tr>
	  </CFIF>
	  <CFIF UN_JUN_TOT NEQ 0>
	   <cfset PerDP = left((UN_JUN_DP/UN_JUN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_JUN_FP/UN_JUN_TOT) * 100,4)> 	  
      <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#UN_JUN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_JUN_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_JUN_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',6,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
	  <CFIF UN_JUL_TOT NEQ 0>
	   <cfset PerDP = left((UN_JUL_DP/UN_JUL_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_JUL_FP/UN_JUL_TOT) * 100,4)> 		  
      <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#UN_JUL_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_JUL_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_JUL_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',7,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
      </CFIF>
	  <CFIF UN_AGO_TOT NEQ 0>
	   <cfset PerDP = left((UN_AGO_DP/UN_AGO_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_AGO_FP/UN_AGO_TOT) * 100,4)> 		  
	  <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#UN_AGO_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_AGO_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_AGO_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',8,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	   </CFIF>
      <CFIF UN_SET_TOT NEQ 0>
	   <cfset PerDP = left((UN_SET_DP/UN_SET_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_SET_FP/UN_SET_TOT) * 100,4)>	  
      <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#UN_SET_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_SET_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_SET_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',9,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
      <CFIF UN_OUT_TOT NEQ 0>
	   <cfset PerDP = left((UN_OUT_DP/UN_OUT_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_OUT_FP/UN_OUT_TOT) * 100,4)>	 	  
	  <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#UN_OUT_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_OUT_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_OUT_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',10,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
	  <CFIF UN_NOV_TOT NEQ 0>
	   <cfset PerDP = left((UN_NOV_DP/UN_NOV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_NOV_FP/UN_NOV_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#UN_NOV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_NOV_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_NOV_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',11,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
	  <CFIF UN_DEZ_TOT NEQ 0>
	   <cfset PerDP = left((UN_DEZ_DP/UN_DEZ_TOT) * 100,4)>	  
  	   <cfset PerFP = left((UN_DEZ_FP/UN_DEZ_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#UN_DEZ_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#UN_DEZ_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#UN_DEZ_TOT#</strong></div></td>
		<td class="exibir">
		  <div align="center">
		    <button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',12,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
		    </div><td>
		</tr>
	  </CFIF>
	  <cfset un_dp_soma = UN_JAN_DP + UN_FEV_DP + UN_MAR_DP + UN_ABR_DP + UN_MAI_DP + UN_JUN_DP + UN_JUL_DP + UN_AGO_DP + UN_SET_DP + UN_OUT_DP + UN_NOV_DP + UN_DEZ_DP>
	  <cfset un_fp_soma = UN_JAN_FP + UN_FEV_FP + UN_MAR_FP + UN_ABR_FP + UN_MAI_FP + UN_JUN_FP + UN_JUL_FP + UN_AGO_FP + UN_SET_FP + UN_OUT_FP + UN_NOV_FP + UN_DEZ_FP>
	  <tr class="exibir">
        <td colspan="7"><hr></td>
        <td>      
      </tr>
  	   <cfset PerDP = left((un_dp_soma/(un_dp_soma + un_fp_soma)) * 100,4)>	  
  	   <cfset PerFP = left((un_fp_soma/(un_dp_soma + un_fp_soma)) * 100,4)>	
	  <tr class="tituloC">
        <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#un_dp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#NumberFormat(PerDP,999.0)#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#un_fp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center">#NumberFormat(PerFP,999.0)#</div></td>
        <td class="red_titulo"><div align="center">
		    </div>
          <div align="center"><strong>#un_dp_soma + un_fp_soma#</strong>
          </div></td>
		<td class="red_titulo"><div align="center"><span class="titulos">
		    <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'un',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button>
		  </span></div></td>
		<td class="red_titulo">
		</tr>

</cfif>		

<!--- AREAS --->		
<cfif Ger_Total neq 0>
     <tr class="exibir">
	   <td colspan="7" class="titulos"><hr></td>
	   </tr>
	 <tr class="exibir">
	      <td colspan="7" class="titulos"><div align="center"> <strong> Ger&ecirc;ncias Regionais e &Aacute;reas de Suporte </strong> </div></td>
      </tr>
      <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td><div align="center"><strong>Dentro prazo</strong></div></td>
        <td><div align="center">%(DP)</div></td>
        <td><div align="center"><strong>Fora prazo</strong></div></td>
        <td><div align="center">%(FP)</div></td>
        <td><div align="center"><strong>Total&nbsp;&nbsp;</strong></div></td>
        <td>&nbsp;</td>
        <td>      
      </tr>
	  <CFIF GE_JAN_TOT NEQ 0>
	   <cfset PerDP = left((GE_JAN_DP/GE_JAN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_JAN_FP/GE_JAN_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>JAN</strong></div></td>
        <td><div align="center"><strong>#GE_JAN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_JAN_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_JAN_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',1,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>		
      </tr>
	  </CFIF>
	  <CFIF GE_FEV_TOT NEQ 0>
  	   <cfset PerDP = left((GE_FEV_DP/GE_FEV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_FEV_FP/GE_FEV_TOT) * 100,4)>
      <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#GE_FEV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_FEV_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_FEV_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',2,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_MAR_TOT NEQ 0>
  	   <cfset PerDP = left((GE_MAR_DP/GE_MAR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_MAR_FP/GE_MAR_TOT) * 100,4)>	  
      <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#GE_MAR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_MAR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_MAR_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',3,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_ABR_TOT NEQ 0>
	   <cfset PerDP = left((GE_ABR_DP/GE_ABR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_ABR_FP/GE_ABR_TOT) * 100,4)>	
      <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#GE_ABR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_ABR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_ABR_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',4,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_MAI_TOT NEQ 0>
	   <cfset PerDP = left((GE_MAI_DP/GE_MAI_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_MAI_FP/GE_MAI_TOT) * 100,4)>	  
      <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#GE_MAI_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_MAI_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_MAI_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',5,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_JUN_TOT NEQ 0>
	   <cfset PerDP = left((GE_JUN_DP/GE_JUN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_JUN_FP/GE_JUN_TOT) * 100,4)>	  
      <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#GE_JUN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_JUN_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_JUN_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',6,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_JUL_TOT NEQ 0>
	   <cfset PerDP = left((GE_JUL_DP/GE_JUL_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_JUL_FP/GE_JUL_TOT) * 100,4)>	  	  
      <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#GE_JUL_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_JUL_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_JUL_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',7,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_AGO_TOT NEQ 0>
	   <cfset PerDP = left((GE_AGO_DP/GE_AGO_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_AGO_FP/GE_AGO_TOT) * 100,4)>	  	  
      <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#GE_AGO_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_AGO_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_AGO_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',8,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_SET_TOT NEQ 0>
	   <cfset PerDP = left((GE_SET_DP/GE_SET_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_SET_FP/GE_SET_TOT) * 100,4)>	  	  
      <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#GE_SET_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_SET_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_SET_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',9,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_OUT_TOT NEQ 0>
	   <cfset PerDP = left((GE_OUT_DP/GE_OUT_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_OUT_FP/GE_OUT_TOT) * 100,4)>	  	  
      <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#GE_OUT_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_OUT_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_OUT_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',10,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_NOV_TOT NEQ 0>
	   <cfset PerDP = left((GE_NOV_DP/GE_NOV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_NOV_FP/GE_NOV_TOT) * 100,4)>	  
      <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#GE_NOV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_NOV_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_NOV_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',11,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr>
	  </CFIF>
	  <CFIF GE_DEZ_TOT NEQ 0>
	   <cfset PerDP = left((GE_DEZ_DP/GE_DEZ_TOT) * 100,4)>	  
  	   <cfset PerFP = left((GE_DEZ_FP/GE_DEZ_TOT) * 100,4)>	  	  
      <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#GE_DEZ_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#GE_DEZ_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#GE_DEZ_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',12,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
		<td>	
      </tr> 
	  </CFIF>
	  	  <tr class="tituloC">
	    <td colspan="7"><hr></td>
	    </tr>
	  <cfset ge_dp_soma = GE_JAN_DP + GE_FEV_DP + GE_MAR_DP + GE_ABR_DP + GE_MAI_DP + GE_JUN_DP + GE_JUL_DP + GE_AGO_DP + GE_SET_DP + GE_OUT_DP + GE_NOV_DP + GE_DEZ_DP>
	  <cfset ge_fp_soma = GE_JAN_FP + GE_FEV_FP + GE_MAR_FP + GE_ABR_FP + GE_MAI_FP + GE_JUN_FP + GE_JUL_FP + GE_AGO_FP + GE_SET_FP + GE_OUT_FP + GE_NOV_FP + GE_DEZ_FP>
	   <cfset PerDP = left((ge_dp_soma/(ge_dp_soma + ge_fp_soma)) * 100,4)>	  
	   <cfset PerFP = left((ge_fp_soma/(ge_dp_soma + ge_fp_soma)) * 100,4)>	
	  <tr class="tituloC">
        <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#ge_dp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#NumberFormat(PerDP,999.0)#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#ge_fp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center">#NumberFormat(PerFP,999.0)#</div></td>
        <td class="red_titulo"><div align="center">
		    </div>
          <div align="center"><strong>#ge_dp_soma + ge_fp_soma#</strong>
          </div></td>
		<td class="red_titulo"><div align="center"><span class="titulos">
		    <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button>
		  </span></div></td>
		<td class="red_titulo">
	  </tr>

</cfif>		

<!--- SUBORDINADORES --->		
<cfif Sub_Total neq 0>
<tr class="exibir">
	   <td colspan="7" class="titulos"><hr></td>
	   </tr>
	 <tr class="exibir">
	      <td colspan="7" class="titulos"><div align="center">&Oacute;rg&atilde;os Subordinadores</div></td>
      </tr>
      <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td><div align="center"><strong>Dentro prazo</strong></div></td>
        <td><div align="center">%(DP)</div></td>
        <td><div align="center"><strong>Fora prazo</strong></div></td>
        <td><div align="center">%(FP)</div></td>
        <td><div align="center"><strong>Total&nbsp;&nbsp;</strong></div></td>
        <td>&nbsp;</td>
        <td>      
      </tr>
	  <CFIF SB_JAN_TOT NEQ 0>
	   <cfset PerDP = left((SB_JAN_DP/SB_JAN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_JAN_FP/SB_JAN_TOT) * 100,4)>	  
		  <tr class="exibir">
			<td><div align="center"><strong>JAN</strong></div></td>
			<td><div align="center"><strong>#SB_JAN_DP#</strong></div></td>
			<td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
			<td><div align="center"><strong>#SB_JAN_FP#</strong></div></td>
			<td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
			<td><div align="center"><strong>#SB_JAN_TOT#</strong></div></td>
			<td class="exibir">
				<div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',1,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
				</div>
		  <td>
		  </tr>
	  </CFIF>
	  <CFIF SB_FEV_TOT NEQ 0>
	   <cfset PerDP = left((SB_FEV_DP/SB_FEV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_FEV_FP/SB_FEV_TOT) * 100,4)>	 	  
      <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#SB_FEV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_FEV_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_FEV_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',2,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_MAR_TOT NEQ 0>
	   <cfset PerDP = left((SB_MAR_DP/SB_MAR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_MAR_FP/SB_MAR_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#SB_MAR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_MAR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_MAR_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',3,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_ABR_TOT NEQ 0>
	   <cfset PerDP = left((SB_ABR_DP/SB_ABR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_ABR_FP/SB_ABR_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#SB_ABR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_ABR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_ABR_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',4,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_MAI_TOT NEQ 0>
	   <cfset PerDP = left((SB_MAI_DP/SB_MAI_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_MAI_FP/SB_MAI_TOT) * 100,4)>	
      <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#SB_MAI_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_MAI_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_MAI_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',5,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_JUN_TOT NEQ 0>
	   <cfset PerDP = left((SB_JUN_DP/SB_JUN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_JUN_FP/SB_JUN_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#SB_JUN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_JUN_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_JUN_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',6,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_JUL_TOT NEQ 0>
	   <cfset PerDP = left((SB_JAN_DP/SB_JUL_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_JAN_FP/SB_JUL_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#SB_JUL_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_JUL_DP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_JUL_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',7,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_AGO_TOT NEQ 0>
	   <cfset PerDP = left((SB_AGO_DP/SB_AGO_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_AGO_FP/SB_AGO_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#SB_AGO_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_AGO_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_AGO_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',8,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_SET_TOT NEQ 0>
	   <cfset PerDP = left((SB_SET_DP/SB_SET_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_SET_FP/SB_SET_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#SB_SET_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_SET_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_SET_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',9,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_OUT_TOT NEQ 0>
	   <cfset PerDP = left((SB_OUT_DP/SB_OUT_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_OUT_FP/SB_OUT_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#SB_OUT_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_OUT_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_OUT_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',10,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_NOV_TOT NEQ 0>
	   <cfset PerDP = left((SB_NOV_DP/SB_NOV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_NOV_FP/SB_NOV_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#SB_NOV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_NOV_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_NOV_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',11,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  <CFIF SB_DEZ_TOT NEQ 0>
	   <cfset PerDP = left((SB_DEZ_DP/SB_DEZ_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_DEZ_FP/SB_DEZ_TOT) * 100,4)>		  
      <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#SB_DEZ_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SB_DEZ_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SB_DEZ_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',12,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	  <td>
      </tr>
	  </CFIF>
	  	  <tr class="tituloC">
	    <td colspan="7"><hr></td>
	    </tr>
	  <cfset sb_dp_soma = SB_JAN_DP + SB_FEV_DP + SB_MAR_DP + SB_ABR_DP + SB_MAI_DP + SB_JUN_DP + SB_JUL_DP + SB_AGO_DP + SB_SET_DP + SB_OUT_DP + SB_NOV_DP + SB_DEZ_DP>
	  <cfset sb_fp_soma = SB_JAN_FP + SB_FEV_FP + SB_MAR_FP + SB_ABR_FP + SB_MAI_FP + SB_JUN_FP + SB_JUL_FP + SB_AGO_FP + SB_SET_FP + SB_OUT_FP + SB_NOV_FP + SB_DEZ_FP>
	   <cfset PerDP = left((sb_dp_soma/(sb_dp_soma + sb_fp_soma)) * 100,4)>	  
	   <cfset PerFP = left((sb_fp_soma/(sb_dp_soma + sb_fp_soma)) * 100,4)>		  
	  <tr class="tituloC">
        <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#sb_dp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#NumberFormat(PerDP,999.0)#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#sb_fp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center">#NumberFormat(PerFP,999.0)#</div></td>
        <td class="red_titulo"><div align="center"></div>
          <div align="center">
		    </div>
          <div align="center"><strong>#sb_dp_soma + sb_fp_soma#</strong>
          </div></td>
		<td class="red_titulo"><div align="center">
		  <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button>
		  </div></td>
		<td class="red_titulo">
	  </tr>
 
</cfif>	
<!--- SUPERINTENDENTES --->		
<cfif Sup_Total neq 0>
<tr class="exibir">
	   <td colspan="7" class="titulos"><hr></td>
	   </tr>
	 <tr class="exibir">
	      <td colspan="7" class="titulos"><div align="center">Superintend&ecirc;ncia</div></td>
      </tr>
      <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td><div align="center"><strong>Dentro prazo</strong></div></td>
        <td><div align="center">%(DP)</div></td>
        <td><div align="center"><strong>Fora prazo</strong></div></td>
        <td><div align="center">%(FP)</div></td>
        <td><div align="center"><strong>Total&nbsp;&nbsp;</strong></div></td>
        <td>&nbsp;</td>
        <td>      
      </tr>
	  <CFIF SU_JAN_TOT NEQ 0>
	   <cfset PerDP = left((SU_JAN_DP/SU_JAN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_JAN_FP/SU_JAN_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>JAN</strong></div></td>
        <td><div align="center"><strong>#SU_JAN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_JAN_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_JAN_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',1,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_FEV_TOT NEQ 0>
	   <cfset PerDP = left((SU_FEV_DP/SU_FEV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_FEV_FP/SU_FEV_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#SU_FEV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_FEV_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_FEV_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',2,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_MAR_TOT NEQ 0>
  	   <cfset PerDP = left((SU_MAR_DP/SU_MAR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_MAR_FP/SU_MAR_TOT) * 100,4)>		
      <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#SU_MAR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_MAR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_MAR_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',3,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_ABR_TOT NEQ 0>
	   <cfset PerDP = left((SU_ABR_DP/SU_ABR_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_ABR_FP/SU_ABR_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#SU_ABR_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_ABR_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_ABR_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',4,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_MAI_TOT NEQ 0>
	   <cfset PerDP = left((SU_MAI_DP/SU_MAI_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_MAI_FP/SU_MAI_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#SU_MAI_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_MAI_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_MAI_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',5,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_JUN_TOT NEQ 0>
  	   <cfset PerDP = left((SU_JUN_DP/SU_JUN_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_JUN_FP/SU_JUN_TOT) * 100,4)>		
      <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#SU_JUN_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_JUN_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_JUN_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',6,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_JUL_TOT NEQ 0>
	   <cfset PerDP = left((SU_JUL_DP/SU_JUL_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_JUL_FP/SU_JUL_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#SU_JUL_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_JUL_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_JUL_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',7,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_AGO_TOT NEQ 0>
	   <cfset PerDP = left((SU_AGO_DP/SU_AGO_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_AGO_FP/SU_AGO_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#SU_AGO_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_AGO_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_AGO_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',8,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_SET_TOT NEQ 0>
	   <cfset PerDP = left((SU_SET_DP/SU_SET_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_SET_FP/SU_SET_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#SU_SET_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_SET_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_SET_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',9,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_OUT_TOT NEQ 0>
	   <cfset PerDP = left((SU_OUT_DP/SU_OUT_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_OUT_FP/SU_OUT_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#SU_OUT_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_OUT_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_OUT_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',10,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_NOV_TOT NEQ 0>
	   <cfset PerDP = left((SU_NOV_DP/SU_NOV_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SU_NOV_FP/SU_NOV_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#SU_NOV_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_NOV_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_NOV_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',11,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
	  </CFIF>
	  <CFIF SU_DEZ_TOT NEQ 0>
	   <cfset PerDP = left((SB_DEZ_DP/SU_DEZ_TOT) * 100,4)>	  
  	   <cfset PerFP = left((SB_DEZ_FP/SU_DEZ_TOT) * 100,4)>			  
      <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#SU_DEZ_DP#</strong></div></td>
        <td><div align="center">#NumberFormat(PerDP,999.0)#</div></td>
        <td><div align="center"><strong>#SU_DEZ_FP#</strong></div></td>
        <td><div align="center"><span class="red_titulo">#NumberFormat(PerFP,999.0)#</span></div></td>
        <td><div align="center"><strong>#SU_DEZ_TOT#</strong></div></td>
		<td class="exibir">
			<div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',12,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar</button>
			</div>
	    <td>
      </tr>
      </tr>   
	  </CFIF>
	  	  <tr class="tituloC">
	    <td colspan="7"><hr></td>
	    </tr>
	  <cfset su_dp_soma = SU_JAN_DP + SU_FEV_DP + SU_MAR_DP + SU_ABR_DP + SU_MAI_DP + SU_JUN_DP + SU_JUL_DP + SU_AGO_DP + SU_SET_DP + SU_OUT_DP + SU_NOV_DP + SU_DEZ_DP>
	  <cfset su_fp_soma = SU_JAN_FP + SU_FEV_FP + SU_MAR_FP + SU_ABR_FP + SU_MAI_FP + SU_JUN_FP + SU_JUL_FP + SU_AGO_FP + SU_SET_FP + SU_OUT_FP + SU_NOV_FP + SU_DEZ_FP>
	   <cfset PerDP = left((su_dp_soma/(su_dp_soma + su_fp_soma)) * 100,4)>	  
	   <cfset PerFP = left((su_fp_soma/(su_dp_soma + su_fp_soma)) * 100,4)>		  
	  <tr class="tituloC">
        <td class="red_titulo"><div align="center"><strong>Total</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#su_dp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#NumberFormat(PerDP,999.0)#</strong></div></td>
        <td class="red_titulo"><div align="center"><strong>#su_fp_soma#</strong></div></td>
        <td class="red_titulo"><div align="center">#NumberFormat(PerFP,999.0)#</div></td>
        <td class="red_titulo"><div align="center">
		    </div>
          <div align="center"><strong>#su_dp_soma + su_fp_soma#</strong>
          </div></td>
		<td class="red_titulo"><div align="center"><span class="titulos">
		    <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'su',0,<cfoutput>#year(dtlimit)#</cfoutput>);">Listar(Todos)</button>
		  </span></div></td>
		<td class="red_titulo">
	  </tr>

</cfif>	 
      <tr class="exibir">
        <td colspan="7" class="titulos">&nbsp;</td>
      </tr>
  </table>
 
  <p></p>
<cfset FPPUNI = 0>
<cfset DPPUNI = 0>
<cfset FPPARE = 0>
<cfset DPPARE = 0>
<cfset FPPORG = 0>
<cfset DPPORG = 0>
<cfset FPPSUP = 0>
<cfset DPPSUP = 0>  
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT top 1 Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum
	FROM Metas
	WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)#
</cfquery>

  
<!--- <cfset metames = rsMetas.Met_PRCI> --->
<cfset metames = numberFormat(rsMetas.Met_PRCI,999.0)> 
<!---  --->
<!--- Criação do arquivo CSV --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
<cffile action="Append" file="#slocal##sarquivo#" output='Atendimento ao Prazo de Resposta do Controle Interno (PRCI)'>
<cffile action="Append" file="#slocal##sarquivo#" output=';;A;B;C;D;E;F;G = ((B * 100)/F);'>

<cffile action="Append" file="#slocal##sarquivo#" output='SE;MÊS;DENTROPRAZO;%(DP);FORAPRAZO;%(FP);TOTAL;METAMENSAL(%);RESULTADOEMRELAÇÃOÀMETA;RESULTADO'>
<!---  --->

<table width="59%" border="1" align="center" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></a></div></td>
</tr>
  <tr>
    <td colspan="17" class="exibir"><div align="center"> <strong> Atendimento ao Prazo de Resposta do Controle Interno (PRCI)</strong></div></td>
  </tr>
<!---   <tr>
    <td colspan="16" class="exibir"><div align="center"></div></td>
  </tr> --->

  <tr class="exibir">
    <td colspan="10"><div align="center"></div>      <div align="center"></div>        <div align="center"></div></td>
	<!--- <cfset totgeral = rsitem.recordcount> --->
    </tr>
  <tr class="exibir">
      <td width="3%" valign="middle"><div align="center">&nbsp;</div></td>
      <td width="4%" valign="middle"><div align="center">&nbsp;</div></td>
      <td class="exibir"><div align="center">A</div></td>
      <td class="exibir"><div align="center">B</div></td>
      <td class="exibir"><div align="center">C</div></td>
      <td class="exibir"><div align="center">D</div></td>
      <td class="exibir"><div align="center">E</div></td>
      <td class="exibir"><div align="center">F</div></td>
      <td class="exibir"><div align="center">G = ((B * 100)/F) </div></td>
      <td class="exibir">&nbsp;</td>
  </tr>

  <cfset auxsigl = qAcesso.Dir_Sigla>
  <tr class="exibir">
    <td width="3%" valign="middle"><div align="center"><strong>SE</strong></div></td>
    <td width="4%" valign="middle"><div align="center"><strong>MÊS</strong></div></td>
    <td class="exibir"><div align="center"><strong>DENTRO DO PRAZO(DP)</strong></div>      <div align="center"></div>      <div align="center"></div></td>
    <td class="exibir"><div align="center">%(DP)</div></td>
    <td class="exibir"><div align="center"><strong> FORA DO PRAZO(FP)</strong></div>      
      <div align="center"></div>      <div align="center"></div>      <div align="center"></div></td>
    <td class="exibir"><div align="center">%(FP)</div></td>
    <td width="9%" class="exibir"><div align="center"></div>      <div align="center"><strong>TOTAL</strong></div></td>
    <td width="12%" class="exibir"><div align="center"><strong> META MENSAL (%)</strong> </div></td>
    <td width="14%" class="exibir"><div align="center"><strong> RESULTADO EM RELA&Ccedil;&Atilde;O &Agrave; META (%) </strong></div></td>
    <td width="15%" class="exibir"><div align="center"><strong> RESULTADO </strong> </div></td>
  </tr>
    <tr class="exibir">
      <td colspan="17" valign="middle"><div align="center" class="titulos"></div>        <div align="center" class="titulos"></div>        <div align="center" class="titulos"></div></td>
      </tr>
<!--- JAN --->	
 <cfif (UN_JAN_DP gt 0) or (GE_JAN_DP gt 0) or (SB_JAN_DP gt 0) or (SU_JAN_DP gt 0) or (UN_JAN_FP gt 0) or (GE_JAN_FP gt 0) or (SB_JAN_FP gt 0) or (SU_JAN_FP gt 0)>
	<cfset TOTMES_DP = UN_JAN_DP + GE_JAN_DP + SB_JAN_DP + SU_JAN_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_JAN_FP + GE_JAN_FP + SB_JAN_FP + SU_JAN_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)> 
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>	
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>
    <td><div align="center"><strong>JAN</strong></div></td>
    <td width="12%" class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td width="8%" class="exibir"><div align="center">#PerDP#</div></td>
    <td width="15%" class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td width="8%" class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<!--- <cfset ResultMeta = (PerDP - metames)> --->
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 1>
   <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)> 
<!---   
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 1
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;JAN;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>

<!--- FEV --->
 <cfif (UN_FEV_DP gt 0) or (GE_FEV_DP gt 0) or (SB_FEV_DP gt 0) or (SU_FEV_DP gt 0) or (UN_FEV_FP gt 0) or (GE_FEV_FP gt 0) or (SB_FEV_FP gt 0) or (SU_FEV_FP gt 0)>
	<cfset TOTMES_DP = UN_FEV_DP + GE_FEV_DP + SB_FEV_DP + SU_FEV_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_FEV_FP + GE_FEV_FP + SB_FEV_FP + SU_FEV_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>
    <td><div align="center"><strong>FEV</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 2>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
     <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 2
  </cfquery> 
--->
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;FEV;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>
<!--- MAR --->
 <cfif (UN_MAR_DP gt 0) or (GE_MAR_DP gt 0) or (SB_MAR_DP gt 0) or (SU_MAR_DP gt 0) or (UN_MAR_FP gt 0) or (GE_MAR_FP gt 0) or (SB_MAR_FP gt 0) or (SU_MAR_FP gt 0)>
	<cfset TOTMES_DP = UN_MAR_DP + GE_MAR_DP + SB_MAR_DP + SU_MAR_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_MAR_FP + GE_MAR_FP + SB_MAR_FP + SU_MAR_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>
	<td><div align="center"><strong>MAR</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 3>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
      <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 3
  </cfquery> 
--->
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;MAR;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>
<!--- ABR --->
 <cfif (UN_ABR_DP gt 0) or (GE_ABR_DP gt 0) or (SB_ABR_DP gt 0) or (SU_ABR_DP gt 0) or (UN_ABR_FP gt 0) or (GE_ABR_FP gt 0) or (SB_ABR_FP gt 0) or (SU_ABR_FP gt 0)>
	<cfset TOTMES_DP = UN_ABR_DP + GE_ABR_DP + SB_ABR_DP + SU_ABR_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_ABR_FP + GE_ABR_FP + SB_ABR_FP + SU_ABR_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>ABR</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 4>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 4
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;ABR;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif> 
<!--- MAI --->
 <cfif (UN_MAI_DP gt 0) or (GE_MAI_DP gt 0) or (SB_MAI_DP gt 0) or (SU_MAI_DP gt 0) or (UN_MAI_FP gt 0) or (GE_MAI_FP gt 0) or (SB_MAI_FP gt 0) or (SU_MAI_FP gt 0)>
	<cfset TOTMES_DP = UN_MAI_DP + GE_MAI_DP + SB_MAI_DP + SU_MAI_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_MAI_FP + GE_MAI_FP + SB_MAI_FP + SU_MAI_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>MAI</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 5>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 5
  </cfquery> 
--->  
    <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;MAI;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>
 </cfif>  
<!--- JUN --->
 <cfif (UN_JUN_DP gt 0) or (GE_JUN_DP gt 0) or (SB_JUN_DP gt 0) or (SU_JUN_DP gt 0) or (UN_JUN_FP gt 0) or (GE_JUN_FP gt 0) or (SB_JUN_FP gt 0) or (SU_JUN_FP gt 0)>
	<cfset TOTMES_DP = UN_JUN_DP + GE_JUN_DP + SB_JUN_DP + SU_JUN_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_JUN_FP + GE_JUN_FP + SB_JUN_FP + SU_JUN_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>JUN</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 6>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 6
  </cfquery> 
--->
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;JUN;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif> 
 <!--- JUL --->	
 <cfif (UN_JUL_DP gt 0) or (GE_JUL_DP gt 0) or (SB_JUL_DP gt 0) or (SU_JUL_DP gt 0) or (UN_JUL_FP gt 0) or (GE_JUL_FP gt 0) or (SB_JUL_FP gt 0) or (SU_JUL_FP gt 0)>
	<cfset TOTMES_DP = UN_JUL_DP + GE_JUL_DP + SB_JUL_DP + SU_JUL_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_JUL_FP + GE_JUL_FP + SB_JUL_FP + SU_JUL_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>JUL</strong></div></td>
    <td width="12%" class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td width="8%" class="exibir"><div align="center">#PerDP#</div></td>
    <td width="15%" class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td width="8%" class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 7>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 7
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;JUL;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif>
<!--- AGO --->
 <cfif (UN_AGO_DP gt 0) or (GE_AGO_DP gt 0) or (SB_AGO_DP gt 0) or (SU_AGO_DP gt 0) or (UN_AGO_FP gt 0) or (GE_AGO_FP gt 0) or (SB_AGO_FP gt 0) or (SU_AGO_FP gt 0)>
	<cfset TOTMES_DP = UN_AGO_DP + GE_AGO_DP + SB_AGO_DP + SU_AGO_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_AGO_FP + GE_AGO_FP + SB_AGO_FP + SU_AGO_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>AGO</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 8>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 8
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;AGO;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>  
 </cfif>
<!--- SET --->
 <cfif (UN_SET_DP gt 0) or (GE_SET_DP gt 0) or (SB_SET_DP gt 0) or (SU_SET_DP gt 0) or (UN_SET_FP gt 0) or (GE_SET_FP gt 0) or (SB_SET_FP gt 0) or (SU_SET_FP gt 0)>
	<cfset TOTMES_DP = UN_SET_DP + GE_SET_DP + SB_SET_DP + SU_SET_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_SET_FP + GE_SET_FP + SB_SET_FP + SU_SET_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>SET</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 9>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 9
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;SET;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif> 
<!--- OUT --->
 <cfif (UN_OUT_DP gt 0) or (GE_OUT_DP gt 0) or (SB_OUT_DP gt 0) or (SU_OUT_DP gt 0) or (UN_OUT_FP gt 0) or (GE_OUT_FP gt 0) or (SB_OUT_FP gt 0) or (SU_OUT_FP gt 0)>
	<cfset TOTMES_DP = UN_OUT_DP + GE_OUT_DP + SB_OUT_DP + SU_OUT_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_OUT_FP + GE_OUT_FP + SB_OUT_FP + SU_OUT_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>OUT</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 10>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 10
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;OUT;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif> 
<!--- NOV --->
 <cfif (UN_NOV_DP gt 0) or (GE_NOV_DP gt 0) or (SB_NOV_DP gt 0) or (SU_NOV_DP gt 0) or (UN_NOV_FP gt 0) or (GE_NOV_FP gt 0) or (SB_NOV_FP gt 0) or (SU_NOV_FP gt 0)>
	<cfset TOTMES_DP = UN_NOV_DP + GE_NOV_DP + SB_NOV_DP + SU_NOV_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_NOV_FP + GE_NOV_FP + SB_NOV_FP + SU_NOV_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>NOV</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 11>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 11
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;NOV;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif>  
<!--- DEZ --->
 <cfif (UN_DEZ_DP gt 0) or (GE_DEZ_DP gt 0) or (SB_DEZ_DP gt 0) or (SU_DEZ_DP gt 0) or (UN_DEZ_FP gt 0) or (GE_DEZ_FP gt 0) or (SB_DEZ_FP gt 0) or (SU_DEZ_FP gt 0)>
	<cfset TOTMES_DP = UN_DEZ_DP + GE_DEZ_DP + SB_DEZ_DP + SU_DEZ_DP>
	<cfset SomaDPAnual = SomaDPAnual + TOTMES_DP> 
	<cfset TOTMES_FP = UN_DEZ_FP + GE_DEZ_FP + SB_DEZ_FP + SU_DEZ_FP>
	<cfset SomaDPFPAnual = SomaDPFPAnual + (TOTMES_DP + TOTMES_FP)>
	<cfset PerDP = NumberFormat((TOTMES_DP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>		  
	<cfset PerFP = numberFormat((TOTMES_FP/(TOTMES_DP + TOTMES_FP)) * 100,999.0)>
  <tr class="exibir">
    <td><div align="center"><strong>#auxsigl#</strong></div></td>  
    <td><div align="center"><strong>DEZ</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP#</strong></div></td>
    <td class="exibir"><div align="center">#PerDP#</div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_FP#</strong></div></td>
    <td class="red_titulo"><div align="center"><strong>#PerFP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#TOTMES_DP + TOTMES_FP#</strong></div></td>
    <td class="exibir"><div align="center"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center">#ResultMeta#</div></td>
	<cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 12>
  <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)>
<!---  
 <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_Acum = '#PerDP#', met_prci_acumperiodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 12
  </cfquery> 
--->  
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;DEZ;#TOTMES_DP#;#PerDP#;#TOTMES_FP#;#PerFP#;#(TOTMES_DP + TOTMES_FP)#;#metames#;#ResultMeta#;#resultado#'>    
 </cfif>    
<!---  --->
	<cfset totgerDP = Unid_Tot_DP + Ger_Tot_DP + Sub_Tot_DP + Sup_Tot_DP>
	<cfset totgerFP = Unid_Tot_FP + Ger_Tot_FP + Sub_Tot_FP + Sup_Tot_FP>
	
	<cfset TOTGER = Uni_Total + Ger_Total + Sub_Total + Sup_Total>
<!--- 	<cfset TOTGER = 1> --->
    <cfset PerDP = numberFormat((totgerDP/(TOTGER)) * 100,999.0)>	
	<cfset PerFP = numberFormat((totgerFP/(TOTGER)) * 100,999.0)>
<!---  --->
  <tr class="titulos">
    <td><div align="center" class="red_titulo"><strong>#auxsigl#</strong></div></td>  
    <td class="red_titulo"><div align="left"><strong>Geral</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#totgerDP#</strong></div></td>
    <td><div align="center" class="red_titulo">#PerDP#</div></td>
    <td><div align="center" class="red_titulo"><strong>#totgerFP#</strong></div></td>
    <td><div align="center" class="red_titulo">#PerFP#</div></td>
    <td><div align="center" class="red_titulo"><strong>#TOTGER#</strong></div></td>
    <td class="exibir"><div align="center" class="red_titulo"><strong>#metames#</strong></div></td> 
	<CFSET ResultMeta = numberFormat(((PerDP * 100)/metames),999.0)>
    <td class="exibir"><div align="center" class="red_titulo">#ResultMeta#</div></td>
	    <cfif PerDP gt metames>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif PerDP eq metames>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>

   <cfset metprciacumperiodo = NumberFormat((SomaDPAnual/SomaDPFPAnual)* 100,999.0)> 
<!---   
 <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_PRCI_AcumPeriodo = '#metprciacumperiodo#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = #auxultmes#
  </cfquery>  
--->
  <cffile action="Append" file="#slocal##sarquivo#" output='#auxsigl#;Geral;#totgerDP#;#PerDP#;#totgerFP#;#PerFP#;#TOTGER#;#metames#;#ResultMeta#;#resultado#'>

<!---   <tr class="exibir">
    <td colspan="6">&nbsp;</td>
  </tr>
 --->
  <tr class="exibir">
    <td colspan="10"><strong>Legenda:</strong></td>
    <!---     <td colspan="2"><input name="Submit1" type="submit" class="botao" id="Submit1" value="+Detalhes"></td> --->
  </tr>
<!--- <cffile action="Append" file="#slocal##sarquivo#" output='Obs.: Prazo de Resposta para o Controle Interno : 10(dez) dias úteis.'> --->
  <tr class="exibir">
    <td colspan="10"><strong> * TOTAL (E) - É o somatório dos itens respondidos (Dentro do Prazo (DP) + Fora do Prazo (FP))</strong></td>
  </tr>
  <tr class="exibir">
    <td colspan="10"><strong> ** %DP (B) =(( A/E) * 100</strong>) </td>
  </tr>
  <tr class="exibir">
    <td colspan="10"><strong> *** Resultado em Rela&ccedil;&atilde;o &agrave; Meta (G) = ((B * 100)/F)</strong> </td>
  </tr>
  <tr class="exibir">
    <td colspan="10"><strong> DP = Dentro do Prazo</strong> </td>
  </tr>
</table>
<cffile action="Append" file="#slocal##sarquivo#" output='Legenda:'>
<cffile action="Append" file="#slocal##sarquivo#" output='* Total (E) - É o somatório dos itens respondidos Dentro do Prazo (DP) + Fora do Prazo (FP)'>
<cffile action="Append" file="#slocal##sarquivo#" output='** %DP (B) = ((A/E) * 100)'>
<cffile action="Append" file="#slocal##sarquivo#" output='*** Resultado em Relação à Meta (G) = ((B * 100)/F'>
<cffile action="Append" file="#slocal##sarquivo#" output='DP = Dentro do Prazo'>

<input name="se" type="hidden" value="#se#">


<!--- fim exibicao --->
</form>
<form name="formx" method="POST" action="itens_Gestao_Andamento1.cfm" target="_blank">
	<input name="lis_se" type="hidden" value="#se#">
	<input name="lis_mes" type="hidden" value="">
	<input name="lis_grpace" type="hidden" value="">
	<input name="lis_ano" type="hidden" value="">
</form>
  <cfinclude template="rodape.cfm">
 </cfoutput> 
</body>
</html>
 
