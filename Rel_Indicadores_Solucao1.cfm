
<cfprocessingdirective pageEncoding ="utf-8"/> 
<!---   <cfoutput>se:#se#&dtlimit:#dtlimit# anoexerc:#anoexerc#<br></cfoutput> 
<CFSET GIL = GIL>   --->
<cfsetting requesttimeout="15000"> 
<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#se#'
</cfquery>
<cfset auxfilta = #qAcesso.Dir_Descricao#>
<cfset auxfiltb = 'SE/' & #qAcesso.Dir_Sigla#>

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css.css" rel="stylesheet" type="text/css">
<script language="javascript">
//=============================

function listar(a,b,c,d,e){
	document.formx.lis_se.value=a;
	document.formx.lis_grpace.value=b;
    document.formx.lis_mes.value=c;
	document.formx.lis_soluc.value=d;
	document.formx.lis_outros.value=e;
	document.formx.submit(); 
}
</script>

</head>
<body>
<form action="" method="post" target="_blank" name="form1">
<cfset BaseUnid = ''>
<cfset BaseInsp = ''>
<cfset Basegrupo = ''>
<cfset BaseItem = ''>
<!--- Grupo Unidade --->
<cfset UN_JAN_TOT = 0>
<cfset UN_FEV_TOT = 0>
<cfset UN_MAR_TOT = 0>
<cfset UN_ABR_TOT = 0>
<cfset UN_MAI_TOT = 0>
<cfset UN_JUN_TOT = 0>
<cfset UN_JUL_TOT = 0>
<cfset UN_AGO_TOT = 0>
<cfset UN_SET_TOT = 0>
<cfset UN_OUT_TOT = 0>
<cfset UN_NOV_TOT = 0>
<cfset UN_DEZ_TOT = 0>
<cfset Uni_Total = 0>
<cfset Acum_UN = 0>
<!--- Solucionados por Unidades --->
<cfset Soluc_Tot_Jan_UN = 0>
<cfset Soluc_Tot_Fev_UN = 0>
<cfset Soluc_Tot_Mar_UN = 0>
<cfset Soluc_Tot_Abr_UN = 0>
<cfset Soluc_Tot_Mai_UN = 0>
<cfset Soluc_Tot_Jun_UN = 0>
<cfset Soluc_Tot_Jul_UN = 0>
<cfset Soluc_Tot_Ago_UN = 0>
<cfset Soluc_Tot_Set_UN = 0>
<cfset Soluc_Tot_Out_UN = 0>
<cfset Soluc_Tot_Nov_UN = 0>
<cfset Soluc_Tot_Dez_UN = 0>

<!--- AREAS --->
<cfset GE_JAN_TOT = 0>
<cfset GE_FEV_TOT = 0>
<cfset GE_MAR_TOT = 0>
<cfset GE_ABR_TOT = 0>
<cfset GE_MAI_TOT = 0>
<cfset GE_JUN_TOT = 0>
<cfset GE_JUL_TOT = 0>
<cfset GE_AGO_TOT = 0>
<cfset GE_SET_TOT = 0>
<cfset GE_OUT_TOT = 0>
<cfset GE_NOV_TOT = 0>
<cfset GE_DEZ_TOT = 0>
<cfset Ger_Total = 0> 
<cfset Acum_GE = 0>
<!--- Solucionados por GERENCIAS --->
<cfset Soluc_Tot_Jan_GE = 0>
<cfset Soluc_Tot_Fev_GE = 0>
<cfset Soluc_Tot_Mar_GE = 0>
<cfset Soluc_Tot_Abr_GE = 0>
<cfset Soluc_Tot_Mai_GE = 0>
<cfset Soluc_Tot_Jun_GE = 0>
<cfset Soluc_Tot_Jul_GE = 0>
<cfset Soluc_Tot_Ago_GE = 0>
<cfset Soluc_Tot_Set_GE = 0>
<cfset Soluc_Tot_Out_GE = 0>
<cfset Soluc_Tot_Nov_GE = 0>
<cfset Soluc_Tot_Dez_GE = 0>

<!--- subordnadores --->
<cfset SB_JAN_TOT = 0>
<cfset SB_FEV_TOT = 0>
<cfset SB_MAR_TOT = 0>
<cfset SB_ABR_TOT = 0>
<cfset SB_MAI_TOT = 0>
<cfset SB_JUN_TOT = 0>
<cfset SB_JUL_TOT = 0>
<cfset SB_AGO_TOT = 0>
<cfset SB_SET_TOT = 0>
<cfset SB_OUT_TOT = 0>
<cfset SB_NOV_TOT = 0>
<cfset SB_DEZ_TOT = 0>
<cfset Sub_Total = 0>
<cfset Acum_SB = 0>
<!--- Solucionados por sUBORDINADORES --->
<cfset Soluc_Tot_Jan_SB = 0>
<cfset Soluc_Tot_Fev_SB = 0>
<cfset Soluc_Tot_Mar_SB = 0>
<cfset Soluc_Tot_Abr_SB = 0>
<cfset Soluc_Tot_Mai_SB = 0>
<cfset Soluc_Tot_Jun_SB = 0>
<cfset Soluc_Tot_Jul_SB = 0>
<cfset Soluc_Tot_Ago_SB = 0>
<cfset Soluc_Tot_Set_SB = 0>
<cfset Soluc_Tot_Out_SB = 0>
<cfset Soluc_Tot_Nov_SB = 0>
<cfset Soluc_Tot_Dez_SB = 0>

<!--- superintendencia --->
<cfset SU_JAN_TOT = 0>
<cfset SU_FEV_TOT = 0>
<cfset SU_MAR_TOT = 0>
<cfset SU_ABR_TOT = 0>
<cfset SU_MAI_TOT = 0>
<cfset SU_JUN_TOT = 0>
<cfset SU_JUL_TOT = 0>
<cfset SU_AGO_TOT = 0>
<cfset SU_SET_TOT = 0>
<cfset SU_OUT_TOT = 0>
<cfset SU_NOV_TOT = 0>
<cfset SU_DEZ_TOT = 0>
<cfset Sup_Total = 0> 
<cfset Acum_SU = 0>
<!--- Solucionados por SUPERINTENDENTES --->
<cfset Soluc_Tot_Jan_SU = 0>
<cfset Soluc_Tot_Fev_SU = 0>
<cfset Soluc_Tot_Mar_SU = 0>
<cfset Soluc_Tot_Abr_SU = 0>
<cfset Soluc_Tot_Mai_SU = 0>
<cfset Soluc_Tot_Jun_SU = 0>
<cfset Soluc_Tot_Jul_SU = 0>
<cfset Soluc_Tot_Ago_SU = 0>
<cfset Soluc_Tot_Set_SU = 0>
<cfset Soluc_Tot_Out_SU = 0>
<cfset Soluc_Tot_Nov_SU = 0>
<cfset Soluc_Tot_Dez_SU = 0>

<!--- Solucionados --->
<cfset Soluc_Tot_Jan = 0>
<cfset Soluc_Tot_Fev = 0>
<cfset Soluc_Tot_Mar = 0>
<cfset Soluc_Tot_Abr = 0>
<cfset Soluc_Tot_Mai = 0>
<cfset Soluc_Tot_Jun = 0>
<cfset Soluc_Tot_Jul = 0>
<cfset Soluc_Tot_Ago = 0>
<cfset Soluc_Tot_Set = 0>
<cfset Soluc_Tot_Out = 0>
<cfset Soluc_Tot_Nov = 0>
<cfset Soluc_Tot_Dez = 0>
<cfset Soluc_Geral = 0> 
<!--- <cfset MetSLNCAcumPeriodo = 0> --->
<cfset SomaSolucionado = 0>
<!---  <cfset dtlimit = CreateDate(2021,02,28)>  --->
<!--- Criar linha de metas --->
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_Codigo, Met_Ano, Met_Mes, Met_SE_STO, Met_SLNC, Met_PRCI, Met_EFCI, Met_DGCI, Met_SLNC_Acum, Met_PRCI_Acum, Met_EFCI_Acum, Met_SLNC
	FROM Metas
	WHERE Met_Codigo='#se#' and Met_Ano = #anoexerc# and Met_Mes = 1
</cfquery>
<!--- criação dos meses por SE --->
<!--- <cfoutput>
#int(month(now()) - 1)#<br>
#int(month(dtlimit))#<br>
#day(now())#<br>
<cfset gil=gil>
</cfoutput>  --->
<cfset nCont = 1>

<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and day(now()) lte 10>
	<cfloop condition="nCont lte int(month(dtlimit))">
		<cfset metprci = trim(rsMetas.Met_PRCI)>
		<cfset metslnc = trim(rsMetas.Met_SLNC)>
		<cfset metdgci = trim(rsMetas.Met_DGCI)>

		<cfquery datasource="#dsn_inspecao#" name="rsCrMes">
			SELECT Met_Ano
			FROM Metas
			WHERE Met_Codigo ='#se#' AND Met_Ano = #anoexerc# AND Met_Mes = #nCont#
		</cfquery>	
		<cfif rsCrMes.recordcount lte 0>		
			<cfquery datasource="#dsn_inspecao#">
				insert into Metas (Met_Codigo,Met_Ano,Met_Mes,Met_SE_STO, Met_SLNC,Met_SLNC_Mes,Met_SLNC_Acum,Met_SLNC_AcumPeriodo,Met_PRCI,Met_PRCI_Mes,Met_PRCI_Acum,Met_PRCI_AcumPeriodo,Met_DGCI,Met_DGCI_Mes,Met_DGCI_Acum,Met_DGCI_AcumPeriodo) 
				values ('#se#',#year(dtlimit)#,#nCont#,'#rsMetas.Met_SE_STO#','#metslnc#','#metslnc#','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0')
			</cfquery>  
		</cfif>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Metas SET Met_SLNC='#metslnc#',Met_SLNC_Mes='#metslnc#'
			WHERE Met_Codigo = '#se#' and Met_Ano = #anoexerc# and Met_Mes = #nCont#
		</cfquery> 		
		<cfset nCont = nCont + 1>
	</cfloop>
</cfif>
<cfset metslnc = trim(rsMetas.Met_SLNC)>

<!--- fim criar linhas de metas --->
<cfset cont_mes = 1> 
<cfloop condition="#cont_mes# lte int(month(dtlimit))">  
	<cfif cont_mes is 1>
	  <cfset dtini = CreateDate(year(dtlimit),1,1)>
	  <cfset dtfim = CreateDate(year(dtlimit),1,31)>
	<cfelseif cont_mes is 2>
		<cfif int(year(dtlimit)) mod 4 is 0>
		   <cfset dtfim = CreateDate(year(dtlimit),2,29)>
		<cfelse>
		   <cfset dtfim = CreateDate(year(dtlimit),2,28)>
		</cfif>
		<cfset dtini = CreateDate(year(dtlimit),2,1)>				
	<cfelseif cont_mes is 3>
		   <cfset dtini = CreateDate(year(dtlimit),3,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),3,31)>
	<cfelseif cont_mes is 4>
		   <cfset dtini = CreateDate(year(dtlimit),4,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),4,30)>		
	<cfelseif cont_mes is 5>
		   <cfset dtini = CreateDate(year(dtlimit),5,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),5,31)>		
	<cfelseif cont_mes is 6>
		   <cfset dtini = CreateDate(year(dtlimit),6,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),6,30)>		
	<cfelseif cont_mes is 7>
		   <cfset dtini = CreateDate(year(dtlimit),7,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),7,31)>		
	<cfelseif cont_mes is 8>
		   <cfset dtini = CreateDate(year(dtlimit),8,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),8,31)>		
	<cfelseif cont_mes is 9>
		   <cfset dtini = CreateDate(year(dtlimit),9,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),9,30)>		
	<cfelseif cont_mes is 10>
		   <cfset dtini = CreateDate(year(dtlimit),10,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),10,31)>		
	<cfelseif cont_mes is 11>
		   <cfset dtini = CreateDate(year(dtlimit),11,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),11,30)>		
	<cfelse>
		   <cfset dtini = CreateDate(year(dtlimit),12,1)>		
		   <cfset dtfim = CreateDate(year(dtlimit),12,31)>		
	</cfif>
<cfset rs3SO_UN = 0>
<cfset rs3SO_GE = 0>
<cfset rs3SO_SB = 0>
<cfset rs3SO_SU = 0>		
	<cfquery name="rs3SO" datasource="#dsn_inspecao#">
		SELECT Andt_AnoExerc, Andt_Mes, Andt_DTRefer, Andt_Resp, Andt_RespAnt
		FROM Andamento_Temp
		WHERE (Andt_AnoExerc = '#anoexerc#') AND  (Andt_Mes = #cont_mes#) AND (Andt_Resp=3) and (Andt_TipoRel = 2) and (Andt_CodSE =  '#se#')
	</cfquery> 

	<cfloop query="rs3SO">
<!--- 	<cfoutput>
	SELECT Andt_AnoExerc, Andt_Mes, Andt_DTRefer, Andt_Resp, Andt_RespAnt
		FROM Andamento_Temp
		WHERE (Andt_AnoExerc = '#anoexerc#') AND  (Andt_Mes = #cont_mes#) AND (Andt_Resp=3) and (Andt_TipoRel = 2) and (Andt_CodSE =  '#se#')
	</cfoutput>
	<cfset gil = gil> --->
	        <cfset auxStantes = rs3SO.Andt_RespAnt>
			<cfif (auxStantes is 1 or auxStantes is 17 or auxStantes is 2 or auxStantes is 15 or auxStantes is 18 or auxStantes is 20)>
				<cfset rs3SO_UN = rs3SO_UN + 1>
			</cfif>
			<cfif auxStantes is 6 or auxStantes is 5 or auxStantes is 19>
				<cfset rs3SO_GE = rs3SO_GE + 1>
			</cfif>
			<cfif auxStantes is 7 or auxStantes is 4 or auxStantes is 16>
				<cfset rs3SO_SB= rs3SO_SB + 1>
			</cfif>
			<cfif auxStantes is 22 or auxStantes is 8 or auxStantes is 23>
				<cfset rs3SO_SU = rs3SO_SU + 1>
			</cfif>	
			<cfswitch expression="#cont_mes#">
			   <cfcase value="1">
					<cfset Soluc_Tot_Jan_UN = rs3SO_UN>
					<cfset Soluc_Tot_Jan_GE = rs3SO_GE>
					<cfset Soluc_Tot_Jan_SB = rs3SO_SB>
					<cfset Soluc_Tot_Jan_SU = rs3SO_SU>	
			   </cfcase>
			   <cfcase value="2">
 					<cfset Soluc_Tot_Fev_UN = rs3SO_UN>
					<cfset Soluc_Tot_Fev_GE = rs3SO_GE>
					<cfset Soluc_Tot_Fev_SB = rs3SO_SB>
					<cfset Soluc_Tot_Fev_SU = rs3SO_SU>	
			   </cfcase>
			   <cfcase value="3">
					<cfset Soluc_Tot_Mar_UN = rs3SO_UN>
					<cfset Soluc_Tot_Mar_GE = rs3SO_GE>
					<cfset Soluc_Tot_Mar_SB = rs3SO_SB>
					<cfset Soluc_Tot_Mar_SU = rs3SO_SU>	
			   </cfcase>
			   <cfcase value="4">
					<cfset Soluc_Tot_Abr_UN = rs3SO_UN>
					<cfset Soluc_Tot_Abr_GE = rs3SO_GE>
					<cfset Soluc_Tot_Abr_SB = rs3SO_SB>
					<cfset Soluc_Tot_Abr_SU = rs3SO_SU>						
			   </cfcase>	
			   <cfcase value="5">
					<cfset Soluc_Tot_Mai_UN = rs3SO_UN>
					<cfset Soluc_Tot_Mai_GE = rs3SO_GE>
					<cfset Soluc_Tot_Mai_SB = rs3SO_SB>
					<cfset Soluc_Tot_Mai_SU = rs3SO_SU>	
			   </cfcase>
			   <cfcase value="6">
					<cfset Soluc_Tot_Jun_UN = rs3SO_UN>
					<cfset Soluc_Tot_Jun_GE = rs3SO_GE>
					<cfset Soluc_Tot_Jun_SB = rs3SO_SB>
					<cfset Soluc_Tot_Jun_SU = rs3SO_SU>					
			   </cfcase>
			   <cfcase value="7">
					<cfset Soluc_Tot_Jul_UN = rs3SO_UN>
					<cfset Soluc_Tot_Jul_GE = rs3SO_GE>
					<cfset Soluc_Tot_Jul_SB = rs3SO_SB>
					<cfset Soluc_Tot_Jul_SU = rs3SO_SU>							
			   </cfcase>
			   <cfcase value="8">
					<cfset Soluc_Tot_Ago_UN = rs3SO_UN>
					<cfset Soluc_Tot_Ago_GE = rs3SO_GE>
					<cfset Soluc_Tot_Ago_SB = rs3SO_SB>
					<cfset Soluc_Tot_Ago_SU = rs3SO_SU>									
			   </cfcase>
			   <cfcase value="9">
					<cfset Soluc_Tot_Set_UN = rs3SO_UN>
					<cfset Soluc_Tot_Set_GE = rs3SO_GE>
					<cfset Soluc_Tot_Set_SB = rs3SO_SB>
					<cfset Soluc_Tot_Set_SU = rs3SO_SU>								
			   </cfcase>
			   <cfcase value="10">
					<cfset Soluc_Tot_Out_UN = rs3SO_UN>
					<cfset Soluc_Tot_Out_GE = rs3SO_GE>
					<cfset Soluc_Tot_Out_SB = rs3SO_SB>
					<cfset Soluc_Tot_Out_SU = rs3SO_SU>	
			   </cfcase>
			   <cfcase value="11">
					<cfset Soluc_Tot_Nov_UN = rs3SO_UN>
					<cfset Soluc_Tot_Nov_GE = rs3SO_GE>
					<cfset Soluc_Tot_Nov_SB = rs3SO_SB>
					<cfset Soluc_Tot_Nov_SU = rs3SO_SU>				
			   </cfcase>
			   <cfcase value="12">
					<cfset Soluc_Tot_Dez_UN = rs3SO_UN>
					<cfset Soluc_Tot_Dez_GE = rs3SO_GE>
					<cfset Soluc_Tot_Dez_SB = rs3SO_SB>
					<cfset Soluc_Tot_Dez_SU = rs3SO_SU>				
			   </cfcase>						   							   					   
      	</cfswitch>	
	</cfloop>		
		
<!---  --->
<cfset Soluc_Geral_UN = int(Soluc_Tot_Jan_UN + Soluc_Tot_Fev_UN + Soluc_Tot_Mar_UN + Soluc_Tot_Abr_UN + Soluc_Tot_Mai_UN + Soluc_Tot_Jun_UN + Soluc_Tot_Jul_UN + Soluc_Tot_Ago_UN + Soluc_Tot_Set_UN + Soluc_Tot_Out_UN + Soluc_Tot_Nov_UN + Soluc_Tot_Dez_UN)>
<cfset Soluc_Geral_GE = int(Soluc_Tot_Jan_GE + Soluc_Tot_Fev_GE + Soluc_Tot_Mar_GE + Soluc_Tot_Abr_GE + Soluc_Tot_Mai_GE + Soluc_Tot_Jun_GE + Soluc_Tot_Jul_GE + Soluc_Tot_Ago_GE + Soluc_Tot_Set_GE + Soluc_Tot_Out_GE + Soluc_Tot_Nov_GE + Soluc_Tot_Dez_GE)>	  
<cfset Soluc_Geral_SB = int(Soluc_Tot_Jan_SB + Soluc_Tot_Fev_SB + Soluc_Tot_Mar_SB + Soluc_Tot_Abr_SB + Soluc_Tot_Mai_SB + Soluc_Tot_Jun_SB + Soluc_Tot_Jul_SB + Soluc_Tot_Ago_SB + Soluc_Tot_Set_SB + Soluc_Tot_Out_SB + Soluc_Tot_Nov_SB + Soluc_Tot_Dez_SB)>	  	  
<cfset Soluc_Geral_SU = int(Soluc_Tot_Jan_SU + Soluc_Tot_Fev_SU + Soluc_Tot_Mar_SU + Soluc_Tot_Abr_SU + Soluc_Tot_Mai_SU + Soluc_Tot_Jun_SU + Soluc_Tot_Jul_SU + Soluc_Tot_Ago_SU + Soluc_Tot_Set_SU + Soluc_Tot_Out_SU + Soluc_Tot_Nov_SU + Soluc_Tot_Dez_SU)>	  	  	  


<!--- exibicao em tela --->
<cfquery name="rsBaseB" datasource="#dsn_inspecao#">
	SELECT Andt_Unid as UNID, Andt_Insp as INSP, Andt_Grp as Grupo, Andt_Item as Item, Andt_DPosic, Andt_HPosic, Andt_Resp, Andt_tpunid, Andt_DiasCor, Andt_Uteis, Andt_Mes, Andt_Prazo
	FROM Andamento_Temp 
	WHERE (Andt_AnoExerc = '#anoexerc#') AND  (Andt_Mes = month(#dtfim#)) AND (Andt_Resp <> 3) and (Andt_TipoRel = 2) and (Andt_CodSE =  '#se#')
	order by Andt_Mes
</cfquery>
<!--- <cfoutput>#dtfim#<br></cfoutput>  --->	
<!--- <cfset gil = gil> --->
<cfloop query="rsBaseB">
<!--- 	baseB;#rsBaseB.Andt_Mes#;#rsBaseB.UNID#;#rsBaseB.INSP#;#rsBaseB.Grupo#;#rsBaseB.Item#;#rsBaseB.Andt_Resp#;#rsBaseB.Andt_tpunid#;#dateformat(rsBaseB.Andt_DPosic,"dd/mm/yyyy")#;#rsBaseB.Andt_HPosic#;#rsBaseB.Andt_DiasCor#;;;;;;;<br> 								 --->
	<cfset aux_mes = rsBaseB.Andt_Mes>
	<cfset tpunid = rsBaseB.Andt_tpunid>
	<cfset rsMes_status = rsBaseB.Andt_Resp>
<!---  	<cfif rsBaseB.Andt_DiasCor gt 30>
		<cfset dduteis = rsBaseB.Andt_DiasCor>
	<cfelse>
		<cfset dduteis = rsBaseB.Andt_Uteis>	
	</cfif>  --->
	 
	<!--- unidade  e Terceiros --->
	<!--- <cfif (tpunid neq 12) and (rsMes_status is 1 or rsMes_status is 2 or rsMes_status is 14 or rsMes_status is 15)> --->
	<cfif (rsMes_status is 2 or rsMes_status is 15 or rsMes_status is 18 or rsMes_status is 20)>
	
		  <cfswitch expression="#cont_mes#">
			   <cfcase value="1">
					  <cfset UN_JAN_TOT = UN_JAN_TOT + 1>
			   </cfcase>
			   <cfcase value="2">
					  <cfset UN_FEV_TOT = UN_FEV_TOT + 1>
			   </cfcase>
			   <cfcase value="3">
			          <cfset UN_MAR_TOT = UN_MAR_TOT + 1>
			   </cfcase>
			   <cfcase value="4">
					  <cfset UN_ABR_TOT = UN_ABR_TOT + 1>
			   </cfcase>	
			   <cfcase value="5">
					  <cfset UN_MAI_TOT = UN_MAI_TOT + 1>
			   </cfcase>
			   <cfcase value="6">
					  <cfset UN_JUN_TOT = UN_JUN_TOT + 1>
			   </cfcase>
			   <cfcase value="7">
					  <cfset UN_JUL_TOT = UN_JUL_TOT + 1>						   
			   </cfcase>
			   <cfcase value="8">
					  <cfset UN_AGO_TOT = UN_AGO_TOT + 1>
			   </cfcase>
			   <cfcase value="9">
					  <cfset UN_SET_TOT = UN_SET_TOT + 1>
			   </cfcase>
			   <cfcase value="10">
					  <cfset UN_OUT_TOT = UN_OUT_TOT + 1>
			   </cfcase>
			   <cfcase value="11">
					  <cfset UN_NOV_TOT = UN_NOV_TOT + 1>
			   </cfcase>
			   <cfcase value="12">
					  <cfset UN_DEZ_TOT = UN_DEZ_TOT + 1>
			   </cfcase>						   							   					   
	      </cfswitch>
	</cfif>
			<!--- AREAS --->
	<cfif rsMes_status is 5 or rsMes_status is 19>
<!--- 	#rsBaseB.Andt_Resp#<br> --->
			<cfswitch expression="#aux_mes#">
			   <cfcase value="1">
					  <cfset GE_JAN_TOT = GE_JAN_TOT + 1>
			   </cfcase>
			   <cfcase value="2">
					  <cfset GE_FEV_TOT = GE_FEV_TOT + 1>
			   </cfcase>
			   <cfcase value="3">
			          <cfset GE_MAR_TOT = GE_MAR_TOT + 1>
			   </cfcase>
			   <cfcase value="4">
					  <cfset GE_ABR_TOT = GE_ABR_TOT + 1>
			   </cfcase>	
			   <cfcase value="5">
					  <cfset GE_MAI_TOT = GE_MAI_TOT + 1>
			   </cfcase>
			   <cfcase value="6">
					  <cfset GE_JUN_TOT = GE_JUN_TOT + 1>
			   </cfcase>
			   <cfcase value="7">
					  <cfset GE_JUL_TOT = GE_JUL_TOT + 1>						   
			   </cfcase>
			   <cfcase value="8">
					  <cfset GE_AGO_TOT = GE_AGO_TOT + 1>
			   </cfcase>
			   <cfcase value="9">
					  <cfset GE_SET_TOT = GE_SET_TOT + 1>
			   </cfcase>
			   <cfcase value="10">
					  <cfset GE_OUT_TOT = GE_OUT_TOT + 1>
			   </cfcase>
			   <cfcase value="11">
					  <cfset GE_NOV_TOT = GE_NOV_TOT + 1>
			   </cfcase>
			   <cfcase value="12">
					  <cfset GE_DEZ_TOT = GE_DEZ_TOT + 1>
			   </cfcase>						   							   					   
	      	</cfswitch>			  
	  </cfif>				  
	  <cfif rsMes_status is 4 or rsMes_status is 16>
		  <cfswitch expression="#aux_mes#">
			   <cfcase value="1">
					  <cfset SB_JAN_TOT = SB_JAN_TOT + 1>
			   </cfcase>
			   <cfcase value="2">
					  <cfset SB_FEV_TOT = SB_FEV_TOT + 1>
			   </cfcase>
			   <cfcase value="3">
			          <cfset SB_MAR_TOT = SB_MAR_TOT + 1>
			   </cfcase>
			   <cfcase value="4">
					  <cfset SB_ABR_TOT = SB_ABR_TOT + 1>
			   </cfcase>	
			   <cfcase value="5">
					  <cfset SB_MAI_TOT = SB_MAI_TOT + 1>
			   </cfcase>
			   <cfcase value="6">
					  <cfset SB_JUN_TOT = SB_JUN_TOT + 1>
			   </cfcase>
			   <cfcase value="7">
					  <cfset SB_JUL_TOT = SB_JUL_TOT + 1>						   
			   </cfcase>
			   <cfcase value="8">
					  <cfset SB_AGO_TOT = SB_AGO_TOT + 1>
			   </cfcase>
			   <cfcase value="9">
					  <cfset SB_SET_TOT = SB_SET_TOT + 1>
			   </cfcase>
			   <cfcase value="10">
					  <cfset SB_OUT_TOT = SB_OUT_TOT + 1>
			   </cfcase>
			   <cfcase value="11">
					  <cfset SB_NOV_TOT = SB_NOV_TOT + 1>
			   </cfcase>
			   <cfcase value="12">
					  <cfset SB_DEZ_TOT = SB_DEZ_TOT + 1>
			   </cfcase>						   							   					   
	      </cfswitch>
	  </cfif>	
      <cfif rsMes_status is 8 or rsMes_status is 23>					
		  <cfswitch expression="#aux_mes#">
			   <cfcase value="1">
					  <cfset SU_JAN_TOT = SU_JAN_TOT + 1>
			   </cfcase>
			   <cfcase value="2">
					  <cfset SU_FEV_TOT = SU_FEV_TOT + 1>
			   </cfcase>
			   <cfcase value="3">
			          <cfset SU_MAR_TOT = SU_MAR_TOT + 1>
			   </cfcase>
			   <cfcase value="4">
					  <cfset SU_ABR_TOT = SU_ABR_TOT + 1>
			   </cfcase>	
			   <cfcase value="5">
					  <cfset SU_MAI_TOT = SU_MAI_TOT + 1>
			   </cfcase>
			   <cfcase value="6">
					  <cfset SU_JUN_TOT = SU_JUN_TOT + 1>
			   </cfcase>
			   <cfcase value="7">
					  <cfset SU_JUL_TOT = SU_JUL_TOT + 1>						   
			   </cfcase>
			   <cfcase value="8">
					  <cfset SU_AGO_TOT = SU_AGO_TOT + 1>
			   </cfcase>
			   <cfcase value="9">
					  <cfset SU_SET_TOT = SU_SET_TOT + 1>
			   </cfcase>
			   <cfcase value="10">
					  <cfset SU_OUT_TOT = SU_OUT_TOT + 1>
			   </cfcase>
			   <cfcase value="11">
					  <cfset SU_NOV_TOT = SU_NOV_TOT + 1>
			   </cfcase>
			   <cfcase value="12">
					  <cfset SU_DEZ_TOT = SU_DEZ_TOT + 1>
			   </cfcase>						   							   					   
	      </cfswitch>

      </cfif>
	</cfloop>	  
	<cfset cont_mes = cont_mes + 1>		 
</cfloop>		

<!---  --->
<!--- #UN_JAN_TOT#  #UN_FEV_TOT#  #UN_MAR_TOT# #UN_ABR_TOT# #UN_MAI_TOT# #UN_JUN_TOT#<br> --->
<cfset Uni_Total = int(UN_JAN_TOT + UN_FEV_TOT + UN_MAR_TOT + UN_ABR_TOT + UN_MAI_TOT + UN_JUN_TOT + UN_JUL_TOT + UN_AGO_TOT + UN_SET_TOT + UN_OUT_TOT + UN_NOV_TOT + UN_DEZ_TOT)>
<cfset Ger_Total = int(GE_JAN_TOT + GE_FEV_TOT + GE_MAR_TOT + GE_ABR_TOT + GE_MAI_TOT + GE_JUN_TOT + GE_JUL_TOT + GE_AGO_TOT + GE_SET_TOT + GE_OUT_TOT + GE_NOV_TOT + GE_DEZ_TOT)>
<cfset Sub_Total = int(SB_JAN_TOT + SB_FEV_TOT + SB_MAR_TOT + SB_ABR_TOT + SB_MAI_TOT + SB_JUN_TOT + SB_JUL_TOT + SB_AGO_TOT + SB_SET_TOT + SB_OUT_TOT + SB_NOV_TOT + SB_DEZ_TOT)>
<cfset Sup_Total = int(SU_JAN_TOT + SU_FEV_TOT + SU_MAR_TOT + SU_ABR_TOT + SU_MAI_TOT + SU_JUN_TOT + SU_JUL_TOT + SU_AGO_TOT + SU_SET_TOT + SU_OUT_TOT + SU_NOV_TOT + SU_DEZ_TOT)>
<!--- jan:#UN_JAN_TOT#  qtd:#Uni_Total# --->
<!--- <CFSET GIL = GIL> --->
<!---  --->
<cfset auxtit = "SE: " & #qAcesso.Dir_codigo# & "-" & #qAcesso.Dir_Sigla#>
<cfset MesAC = 'Resultado do Periodo'>  
  <table width="39%" border="1" align="center" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="17"><div align="center" class="titulo1"><strong>#auxfilta#</strong></div></td>
      </tr>

	        <tr>
	          <td colspan="17">&nbsp;</td>
      </tr>
	        <tr>
	          <td colspan="17"><div align="center">
	            <p><span class="titulo1"><strong>Solu&Ccedil;&Atilde;o de N&Atilde;o Conformidades (SLNC)</strong></span></p>
	            </div></td>
      </tr>
	  	        <tr>
	          <td colspan="17">&nbsp;</td>
      </tr>



<!--- UNIDADES --->		
<cfif Uni_Total neq 0>	       
      <tr class="exibir">
	      <td colspan="17" class="titulos"><div align="center">Unidades</div></td>
      </tr>
	  <tr class="exibir">
        <td width="10%"><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
		<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
        <td width="10%"><div align="center">%</div></td>
        <td class="exibir">&nbsp;</td></tr>
	  <CFIF aux_mes gte 1>
        <tr class="exibir">
        <td><div align="center"><strong>JAN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jan_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_JAN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jan_UN neq 0>
			<cfset Per = left((Soluc_Tot_Jan_UN/(UN_JAN_TOT + Soluc_Tot_Jan_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>

        <td><div align="center"><strong>#(UN_JAN_TOT + Soluc_Tot_Jan_UN)#</strong></div></td>
       <td><div align="center">#NumberFormat(Per,999.0)#</div></td> 	
		<cfset Acum_UN = Acum_UN + UN_JAN_TOT>
		<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',1,<cfoutput>#Soluc_Tot_Jan_UN#</cfoutput>,<cfoutput>#UN_JAN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div>		 </td>	
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 2>
        <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Fev_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_FEV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>		
		<cfif Soluc_Tot_Fev_UN neq 0>
			<cfset Per = left((Soluc_Tot_Fev_UN/(UN_FEV_TOT + Soluc_Tot_Fev_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
				
        <td><div align="center"><strong>#(UN_FEV_TOT + Soluc_Tot_Fev_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_FEV_TOT>
		<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',2,<cfoutput>#Soluc_Tot_FEV_UN#</cfoutput>,<cfoutput>#UN_FEV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div>		</td>	
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 3>
        <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mar_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_MAR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mar_UN neq 0>
			<cfset Per = left((Soluc_Tot_Mar_UN/(UN_MAR_TOT + Soluc_Tot_Mar_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        
        <td><div align="center"><strong>#(UN_MAR_TOT + Soluc_Tot_Mar_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_MAR_TOT>
		<td width="19%" class="exibir"><div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',3,<cfoutput>#Soluc_Tot_MAR_UN#</cfoutput>,<cfoutput>#UN_MAR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
		</div></td>			
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 4>
        <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Abr_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_ABR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Abr_UN neq 0>
			<cfset Per = left((Soluc_Tot_Abr_UN/(UN_ABR_TOT + Soluc_Tot_Abr_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>			
        		
        <td><div align="center"><strong>#(UN_ABR_TOT + Soluc_Tot_Abr_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_ABR_TOT>
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',4,<cfoutput>#Soluc_Tot_ABR_UN#</cfoutput>,<cfoutput>#UN_ABR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div>			</td>		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 5>
        <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mai_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_MAI_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mai_UN neq 0>
			<cfset Per = left((Soluc_Tot_Mai_UN/(UN_MAI_TOT + Soluc_Tot_Mai_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>				
        
        <td><div align="center"><strong>#(UN_MAI_TOT + Soluc_Tot_Mai_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_MAI_TOT>
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',5,<cfoutput>#Soluc_Tot_MAI_UN#</cfoutput>,<cfoutput>#UN_MAI_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>	
		  </tr>
	  </CFIF>
	  <CFIF aux_mes gte 6>
        <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jun_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_JUN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jun_UN neq 0>
			<cfset Per = left((Soluc_Tot_Jun_UN/(UN_JUN_TOT + Soluc_Tot_Jun_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(UN_JUN_TOT + Soluc_Tot_Jun_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_JUN_TOT>

			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',6,<cfoutput>#Soluc_Tot_JUN_UN#</cfoutput>,<cfoutput>#UN_JUN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 7>
        <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jul_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_JUL_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jul_UN neq 0>
			<cfset Per = left((Soluc_Tot_Jul_UN/(UN_JUL_TOT + Soluc_Tot_Jul_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(UN_JUL_TOT + Soluc_Tot_Jul_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_JUL_TOT>
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',7,<cfoutput>#Soluc_Tot_JUL_UN#</cfoutput>,<cfoutput>#UN_JUL_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>		
		</tr>
      </CFIF>
	  <CFIF aux_mes gte 8>
        <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Ago_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_AGO_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Ago_UN neq 0>
			<cfset Per = left((Soluc_Tot_Ago_UN/(UN_AGO_TOT + Soluc_Tot_Ago_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(UN_AGO_TOT + Soluc_Tot_Ago_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_AGO_TOT>
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',8,<cfoutput>#Soluc_Tot_AGO_UN#</cfoutput>,<cfoutput>#UN_AGO_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>			
		</tr>
	   </CFIF>
      <CFIF aux_mes gte 9>
        <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Set_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_SET_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Set_UN neq 0>
			<cfset Per = left((Soluc_Tot_Set_UN/(UN_SET_TOT + Soluc_Tot_Set_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>
        
        <td><div align="center"><strong>#(UN_SET_TOT + Soluc_Tot_Set_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_SET_TOT>
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',9,<cfoutput>#Soluc_Tot_SET_UN#</cfoutput>,<cfoutput>#UN_SET_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>			
		</tr>
	  </CFIF>
      <CFIF aux_mes gte 10>
        <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Out_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_OUT_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Out_UN neq 0>
			<cfset Per = left((Soluc_Tot_Out_UN/(UN_OUT_TOT + Soluc_Tot_Out_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(UN_OUT_TOT + Soluc_Tot_Out_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_OUT_TOT>	
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',10,<cfoutput>#Soluc_Tot_OUT_UN#</cfoutput>,<cfoutput>#UN_OUT_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>			
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 11>
        <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Nov_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_NOV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Nov_UN neq 0>
			<cfset Per = left((Soluc_Tot_Nov_UN/(UN_NOV_TOT + Soluc_Tot_Nov_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(UN_NOV_TOT + Soluc_Tot_Nov_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_NOV_TOT>
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',11,<cfoutput>#Soluc_Tot_NOV_UN#</cfoutput>,<cfoutput>#UN_NOV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 12>
        <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Dez_UN#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif UN_DEZ_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Dez_UN neq 0>
			<cfset Per = left((Soluc_Tot_Dez_UN/(UN_DEZ_TOT + Soluc_Tot_Dez_UN)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(UN_DEZ_TOT + Soluc_Tot_Dez_UN)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_UN = Acum_UN + UN_DEZ_TOT>
		<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'un',12,<cfoutput>#Soluc_Tot_DEZ_UN#</cfoutput>,<cfoutput>#UN_DEZ_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>		
		</tr>
	  </CFIF>
	  <tr class="exibir">
        <td colspan="17"><hr></td>
      </tr>
		<cfset Acum_UN = (Acum_UN + Soluc_Geral_UN)>
		<cfset Acum_Per_UN = 0> 
		<cfif Acum_UN gt 0>
		  <cfset Acum_Per_UN = NumberFormat(((Soluc_Geral_UN/Acum_UN) * 100),999.0)>
		</cfif>		
  	   <tr class="tituloC">
        <td class="red_titulo"><div align="center">#MesAC#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Soluc_Geral_UN#</strong></div></td>
        <td class="red_titulo"><div align="center">#Acum_UN#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Acum_Per_UN#</strong>
          </div></td>

		 <td class="red_titulo">
		   <div align="center">
		     <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'un',0,<cfoutput>#Soluc_Geral_UN#</cfoutput>,<cfoutput>#(Acum_UN-Soluc_Geral_UN)#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar(Todos)</button>
           </div></td>
		</tr>	
</cfif>		

<!--- AREAS --->		
<cfif Ger_Total neq 0>
      <tr class="exibir">
	      <td colspan="17" class="titulos"><div align="center"><strong>Gerências Regionais e Áreas de Suporte</strong></div></td>
      </tr>
      <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
		<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
        <td width="10%"><div align="center">%</div></td>
        <td class="exibir">&nbsp;</td></tr>
     
      </tr>
	  <CFIF aux_mes gte 1>
        <tr class="exibir">
        <td><div align="center"><strong>JAN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jan_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_JAN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jan_GE neq 0>
			<cfset Per = left((Soluc_Tot_Jan_GE/(GE_JAN_TOT + Soluc_Tot_Jan_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>
        
        <td><div align="center"><strong>#(GE_JAN_TOT + Soluc_Tot_Jan_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_JAN_TOT>	        
		<td width="19%" class="exibir"><div align="center">
			<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',1,<cfoutput>#Soluc_Tot_Jan_GE#</cfoutput>,<cfoutput>#GE_JAN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
		</div></td>				

		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 2>
        <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Fev_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_FEV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Fev_GE neq 0>
			<cfset Per = left((Soluc_Tot_Fev_GE/(GE_FEV_TOT + Soluc_Tot_Fev_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(GE_FEV_TOT + Soluc_Tot_Fev_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_FEV_TOT>	        
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',2,<cfoutput>#Soluc_Tot_FEV_GE#</cfoutput>,<cfoutput>#GE_FEV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 3>
        <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mar_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_MAR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mar_GE neq 0>
			<cfset Per = left((Soluc_Tot_Mar_GE/(GE_MAR_TOT + Soluc_Tot_Mar_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        
        <td><div align="center"><strong>#(GE_MAR_TOT + Soluc_Tot_Mar_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_MAR_TOT>	        
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',3,<cfoutput>#Soluc_Tot_MAR_GE#</cfoutput>,<cfoutput>#GE_MAR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				

		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 4>
        <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Abr_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_ABR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Abr_GE neq 0>
			<cfset Per = left((Soluc_Tot_Abr_GE/(GE_ABR_TOT + Soluc_Tot_Abr_GE)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        	
        <td><div align="center"><strong>#(GE_ABR_TOT + Soluc_Tot_Abr_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_ABR_TOT>	        
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',4,<cfoutput>#Soluc_Tot_ABR_GE#</cfoutput>,<cfoutput>#GE_ABR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 5>
        <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mai_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_MAI_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mai_GE neq 0>
			<cfset Per = left((Soluc_Tot_Mai_GE/(GE_MAI_TOT + Soluc_Tot_Mai_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        
        <td><div align="center"><strong>#(GE_MAI_TOT + Soluc_Tot_Mai_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_MAI_TOT>	        
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',5,<cfoutput>#Soluc_Tot_MAI_GE#</cfoutput>,<cfoutput>#GE_MAI_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				

		  </tr>
	  </CFIF>
	  <CFIF aux_mes gte 6>
        <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jun_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_JUN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jun_GE neq 0>
			<cfset Per = left((Soluc_Tot_Jun_GE/(GE_JUN_TOT + Soluc_Tot_Jun_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(GE_JUN_TOT + Soluc_Tot_Jun_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_JUN_TOT>	        		

			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',6,<cfoutput>#Soluc_Tot_JUN_GE#</cfoutput>,<cfoutput>#GE_JUN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				

		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 7>
        <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jul_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_JUL_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jul_GE neq 0>
			<cfset Per = left((Soluc_Tot_Jul_GE/(GE_JUL_TOT + Soluc_Tot_Jul_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(GE_JUL_TOT + Soluc_Tot_Jul_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_JUL_TOT>	         		

			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',7,<cfoutput>#Soluc_Tot_JUL_GE#</cfoutput>,<cfoutput>#GE_JUL_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
      </CFIF>
	  <CFIF aux_mes gte 8>
        <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Ago_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_AGO_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Ago_GE neq 0>
			<cfset Per = left((Soluc_Tot_Ago_GE/(GE_AGO_TOT + Soluc_Tot_Ago_GE)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        	
        <td><div align="center"><strong>#(GE_AGO_TOT + Soluc_Tot_Ago_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_AGO_TOT>	        	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',8,<cfoutput>#Soluc_Tot_AGO_GE#</cfoutput>,<cfoutput>#GE_AGO_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	   </CFIF>
      <CFIF aux_mes gte 9>
        <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Set_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_SET_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Set_GE neq 0>
			<cfset Per = left((Soluc_Tot_Set_GE/(GE_SET_TOT + Soluc_Tot_Set_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        <td><div align="center"><strong>#(GE_SET_TOT + Soluc_Tot_Set_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_SET_TOT>	        	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',9,<cfoutput>#Soluc_Tot_SET_GE#</cfoutput>,<cfoutput>#GE_SET_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
      <CFIF aux_mes gte 10>
        <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Out_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_OUT_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Out_GE neq 0>
			<cfset Per = left((Soluc_Tot_Out_GE/(GE_OUT_TOT + Soluc_Tot_Out_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
       		
        <td><div align="center"><strong>#(GE_OUT_TOT + Soluc_Tot_Out_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_OUT_TOT>	        
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',10,<cfoutput>#Soluc_Tot_OUT_GE#</cfoutput>,<cfoutput>#GE_OUT_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 11>
        <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Nov_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_NOV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Nov_GE neq 0>
			<cfset Per = left((Soluc_Tot_Nov_GE/(GE_NOV_TOT + Soluc_Tot_Nov_GE)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(GE_NOV_TOT + Soluc_Tot_Nov_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_NOV_TOT>	        	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',11,<cfoutput>#Soluc_Tot_NOV_GE#</cfoutput>,<cfoutput>#GE_NOV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 12>
        <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Dez_GE#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif GE_DEZ_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Dez_GE neq 0>
			<cfset Per = left((Soluc_Tot_Dez_GE/(GE_DEZ_TOT + Soluc_Tot_Dez_GE)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        	
        <td><div align="center"><strong>#(GE_DEZ_TOT + Soluc_Tot_Dez_GE)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_GE = Acum_GE + GE_DEZ_TOT>	        	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',12,<cfoutput>#Soluc_Tot_DEZ_GE#</cfoutput>,<cfoutput>#GE_DEZ_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <tr class="exibir">
        <td colspan="17"><hr></td>
      </tr>
		<cfset Acum_GE = (Acum_GE + Soluc_Geral_GE)>
		<cfset Acum_Per_GE = 0> 
		<cfif Acum_GE gt 0>
		  <!--- <cfset Acum_Per_GE = left(Soluc_Geral_GE/(Acum_GE) * 100,4)> --->
		  <cfset Acum_Per_GE = NumberFormat(((Soluc_Geral_GE/Acum_GE) * 100),999.0)>
		</cfif>			
  	   <tr class="tituloC">
        <td class="red_titulo"><div align="center">#MesAC#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Soluc_Geral_GE#</strong></div></td>
        <td class="red_titulo"><div align="center">#Acum_GE#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Acum_Per_GE#</strong>
          </div></td>


			<td class="red_titulo">
			  <div align="center"><span class="titulos">
			    <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'ge',0,<cfoutput>#Soluc_Geral_GE#</cfoutput>,<cfoutput>#(Acum_GE-Soluc_Geral_GE)#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>
		        Listar(Todos)</button>
		      </span></div></td>

		</tr>	  
</cfif>		

<!--- SUBORDINADORES --->		
<cfif Sub_Total neq 0>

	  <tr class="exibir">
	      <td colspan="17" class="titulos"><div align="center">Órgãos Subordinadores</div></td>
      </tr>
 	  <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
		<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
        <td width="10%"><div align="center">%</div></td>
        <td class="exibir">&nbsp;</td></tr>
    
      </tr>
	  <CFIF aux_mes gte 1>
        <tr class="exibir">
        <td><div align="center"><strong>JAN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jan_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_JAN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jan_SB neq 0>
			<cfset Per = left((Soluc_Tot_Jan_SB/(SB_JAN_TOT + Soluc_Tot_Jan_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        
        <td><div align="center"><strong>#(SB_JAN_TOT + Soluc_Tot_Jan_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_JAN_TOT>	                
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',1,<cfoutput>#Soluc_Tot_JAN_SB#</cfoutput>,<cfoutput>#SB_JAN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	 <CFIF aux_mes gte 2>
        <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Fev_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_FEV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Fev_SB neq 0>
			<cfset Per = left((Soluc_Tot_Fev_SB/(SB_FEV_TOT + Soluc_Tot_Fev_SB)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        	
        <td><div align="center"><strong>#(SB_FEV_TOT + Soluc_Tot_Fev_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_FEV_TOT>		
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',2,<cfoutput>#Soluc_Tot_FEV_SB#</cfoutput>,<cfoutput>#SB_FEV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 3>
        <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mar_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_MAR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mar_SB neq 0>
			<cfset Per = left((Soluc_Tot_Mar_SB/(SB_MAR_TOT + Soluc_Tot_Mar_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>
        
        <td><div align="center"><strong>#(SB_MAR_TOT + Soluc_Tot_Mar_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_MAR_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',3,<cfoutput>#Soluc_Tot_MAR_SB#</cfoutput>,<cfoutput>#SB_MAR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 4>
        <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Abr_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_ABR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Abr_SB neq 0>
			<cfset Per = left((Soluc_Tot_Abr_SB/(SB_ABR_TOT + Soluc_Tot_Abr_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_ABR_TOT + Soluc_Tot_Abr_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_ABR_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',4,<cfoutput>#Soluc_Tot_ABR_SB#</cfoutput>,<cfoutput>#SB_ABR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 5>
        <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mai_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_MAI_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mai_SB neq 0>
			<cfset Per = left((Soluc_Tot_Mai_SB/(SB_MAI_TOT + Soluc_Tot_Mai_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        
        <td><div align="center"><strong>#(SB_MAI_TOT + Soluc_Tot_Mai_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_MAI_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',5,<cfoutput>#Soluc_Tot_MAI_SB#</cfoutput>,<cfoutput>#SB_MAI_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		  </tr>
	  </CFIF>
	  <CFIF aux_mes gte 6>
        <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jun_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_JUN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jun_SB neq 0>
			<cfset Per = left((Soluc_Tot_Jun_SB/(SB_JUN_TOT + Soluc_Tot_Jun_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_JUN_TOT + Soluc_Tot_Jun_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_JUN_TOT>	
 		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',6,<cfoutput>#Soluc_Tot_JUN_SB#</cfoutput>,<cfoutput>#SB_JUN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 7>
        <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jul_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_JUL_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jul_SB neq 0>
			<cfset Per = left((Soluc_Tot_Jul_SB/(SB_JUL_TOT + Soluc_Tot_Jul_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_JUL_TOT + Soluc_Tot_Jul_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_JUL_TOT>	
  		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',7,<cfoutput>#Soluc_Tot_JUL_SB#</cfoutput>,<cfoutput>#SB_JUL_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
      </CFIF>
	  <CFIF aux_mes gte 8>
        <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Ago_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_AGO_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Ago_SB neq 0>
			<cfset Per = left((Soluc_Tot_Ago_SB/(SB_AGO_TOT + Soluc_Tot_Ago_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_AGO_TOT + Soluc_Tot_Ago_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_AGO_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',8,<cfoutput>#Soluc_Tot_AGO_SB#</cfoutput>,<cfoutput>#SB_AGO_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	   </CFIF>
      <CFIF aux_mes gte 9>
        <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Set_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_SET_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Set_SB neq 0>
			<cfset Per = left((Soluc_Tot_Set_SB/(SB_SET_TOT + Soluc_Tot_Set_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        
        <td><div align="center"><strong>#(SB_SET_TOT + Soluc_Tot_Set_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_SET_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',9,<cfoutput>#Soluc_Tot_SET_SB#</cfoutput>,<cfoutput>#SB_SET_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
      <CFIF aux_mes gte 10>
        <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Out_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_OUT_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Out_SB neq 0>
			<cfset Per = left((Soluc_Tot_Out_SB/(SB_OUT_TOT + Soluc_Tot_Out_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_OUT_TOT + Soluc_Tot_Out_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_OUT_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',10,<cfoutput>#Soluc_Tot_OUT_SB#</cfoutput>,<cfoutput>#SB_OUT_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 11>
        <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Nov_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_NOV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Nov_SB neq 0>
			<cfset Per = left((Soluc_Tot_Nov_SB/(SB_NOV_TOT + Soluc_Tot_Nov_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_NOV_TOT + Soluc_Tot_Nov_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_NOV_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',11,<cfoutput>#Soluc_Tot_NOV_SB#</cfoutput>,<cfoutput>#SB_NOV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 12>
        <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Dez_SB#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_DEZ_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Dez_SB neq 0>
			<cfset Per = left((Soluc_Tot_Dez_SB/(SB_DEZ_TOT + Soluc_Tot_Dez_SB)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        		
        <td><div align="center"><strong>#(SB_DEZ_TOT + Soluc_Tot_Dez_SB)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SB =  Acum_SB + SB_DEZ_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',12,<cfoutput>#Soluc_Tot_DEZ_SB#</cfoutput>,<cfoutput>#SB_DEZ_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <tr class="exibir">
        <td colspan="17"><hr></td>
      </tr>
		<cfset Acum_SB = (Acum_SB + Soluc_Geral_SB)>
		<cfset Acum_Per_SB = 0> 
		<cfif Acum_SB gt 0>
			<!--- <cfset Acum_Per_SB = left(Soluc_Geral_SB/(Acum_SB) * 100,4)>  --->
			<cfset Acum_Per_SB = NumberFormat(((Soluc_Geral_SB/Acum_SB) * 100),999.0)>
		</cfif>

  	   <tr class="tituloC">
        <td class="red_titulo"><div align="center">#MesAC#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Soluc_Geral_SB#</strong></div></td>
        <td class="red_titulo"><div align="center">#Acum_SB#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Acum_Per_SB#</strong>
          </div></td>
		 
			<td class="red_titulo">
			  <div align="center"><span class="titulos">
			    <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'sb',0,<cfoutput>#Soluc_Geral_SB#</cfoutput>,<cfoutput>#(Acum_SB-Soluc_Geral_SB)#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>
		        Listar(Todos)</button>
		      </span></div></td>
		
		</tr>		  
</cfif>	
<!--- SUPERINTENDENTES --->		
<cfif Sup_Total neq 0>
      <tr class="exibir">
	      <td colspan="17" class="titulos"><div align="center">Superintendência</div></td>
      </tr>
 	  <tr class="exibir">
        <td><div align="center"><strong>M&Ecirc;S</strong></div></td>
        <td width="30%"><div align="center"><strong>Quantidade (Solucionados)</strong></div></td> 
		<td width="16%"><div align="center"><strong>Total (*)</strong></div></td>
        <td width="10%"><div align="center">%</div></td>
        <td class="exibir">&nbsp;</td></tr>
      </tr>

	  <CFIF aux_mes gte 1> 
        <tr class="exibir">
        <td><div align="center"><strong>JAN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jan_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SB_JAN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jan_SU neq 0>
	        <cfset Per = left((Soluc_Tot_Jan_SU/(SU_JAN_TOT + Soluc_Tot_Jan_SU)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>
        <td><div align="center"><strong>#(SU_JAN_TOT + Soluc_Tot_Jan_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = SU_JAN_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',1,<cfoutput>#Soluc_Tot_JAN_SU#</cfoutput>,<cfoutput>#SU_JAN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF> 
	<CFIF aux_mes gte 2> 
        <tr class="exibir">
        <td><div align="center"><strong>FEV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Fev_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_FEV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Fev_SU neq 0>
	        <cfset Per = left((Soluc_Tot_Fev_SU/(SU_FEV_TOT + Soluc_Tot_Fev_SU)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>
        	
        <td><div align="center"><strong>#(SU_FEV_TOT + Soluc_Tot_Fev_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_FEV_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',2,<cfoutput>#Soluc_Tot_FEV_SU#</cfoutput>,<cfoutput>#SU_FEV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	</CFIF> 
	<CFIF aux_mes gte 3> 
        <tr class="exibir">
        <td><div align="center"><strong>MAR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mar_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_MAR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Mar_SU neq 0>
        	<cfset Per = left((Soluc_Tot_Mar_SU/(SU_MAR_TOT + Soluc_Tot_Mar_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>
        <td><div align="center"><strong>#(SU_MAR_TOT + Soluc_Tot_Mar_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_MAR_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',3,<cfoutput>#Soluc_Tot_MAR_SU#</cfoutput>,<cfoutput>#SU_MAR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	</CFIF>
	<CFIF aux_mes gte 4> 
        <tr class="exibir">
        <td><div align="center"><strong>ABR</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Abr_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_ABR_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>		
		<cfif Soluc_Tot_Abr_SU neq 0>
        	<cfset Per = left((Soluc_Tot_Abr_SU/(SU_ABR_TOT + Soluc_Tot_Abr_SU)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>		
	
        <td><div align="center"><strong>#(SU_ABR_TOT + Soluc_Tot_Abr_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_ABR_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',4,<cfoutput>#Soluc_Tot_ABR_SU#</cfoutput>,<cfoutput>#SU_ABR_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	</CFIF>
	<CFIF aux_mes gte 5> 
        <tr class="exibir">
        <td><div align="center"><strong>MAI</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Mai_SU#</strong></div></td>
        <cfset habunidsn = ''>
		<cfif SU_MAI_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif> 
		<cfif Soluc_Tot_Mai_SU neq 0>
        	<cfset Per = left((Soluc_Tot_Mai_SU/(SU_MAI_TOT + Soluc_Tot_Mai_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>			
        <td><div align="center"><strong>#(SU_MAI_TOT + Soluc_Tot_Mai_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_MAI_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',5,<cfoutput>#Soluc_Tot_MAI_SU#</cfoutput>,<cfoutput>#SU_MAI_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		  </tr>
	</CFIF> 
	<CFIF aux_mes gte 6> 
        <tr class="exibir">
        <td><div align="center"><strong>JUN</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jun_SU#</strong></div></td>
        <cfset habunidsn = ''>
		<cfif SU_JUN_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jun_SU neq 0>
        	<cfset Per = left((Soluc_Tot_Jun_SU/(SU_JUN_TOT + Soluc_Tot_Jun_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>				
        <td><div align="center"><strong>#(SU_JUN_TOT + Soluc_Tot_Jun_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_JUN_TOT>
 		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',6,<cfoutput>#Soluc_Tot_JUN_SU#</cfoutput>,<cfoutput>#SU_JUN_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
	
		</tr>
	</CFIF> 
    <CFIF aux_mes gte 7> 
        <tr class="exibir">
        <td><div align="center"><strong>JUL</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Jul_SU#</strong></div></td>
        <cfset habunidsn = ''>
		<cfif SU_JUL_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Jul_SU neq 0>
			<cfset Per = left((Soluc_Tot_Jul_SU/(SU_JUL_TOT + Soluc_Tot_Jul_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>		
        <td><div align="center"><strong>#(SU_JUL_TOT + Soluc_Tot_Jul_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_JUL_TOT> 		
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',7,<cfoutput>#Soluc_Tot_JUL_SU#</cfoutput>,<cfoutput>#SU_JUL_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
       </CFIF>
	   <CFIF aux_mes gte 8>  
        <tr class="exibir">
        <td><div align="center"><strong>AGO</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Ago_SU#</strong></div></td>
        <cfset habunidsn = ''>
		<cfif SU_AGO_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Ago_SU neq 0>
			<cfset Per = left((Soluc_Tot_Ago_SU/(SU_AGO_TOT + Soluc_Tot_Ago_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>				
        <td><div align="center"><strong>#(SU_AGO_TOT + Soluc_Tot_Ago_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_AGO_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',8,<cfoutput>#Soluc_Tot_AGO_SU#</cfoutput>,<cfoutput>#SU_AGO_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
      </CFIF> 
      <CFIF aux_mes gte 9> 
        <tr class="exibir">
        <td><div align="center"><strong>SET</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Set_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_SET_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Set_SU neq 0>
			<cfset Per = left((Soluc_Tot_Set_SU/(SU_SET_TOT + Soluc_Tot_Set_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>	
        
        <td><div align="center"><strong>#(SU_SET_TOT + Soluc_Tot_Set_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_SET_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',9,<cfoutput>#Soluc_Tot_SET_SU#</cfoutput>,<cfoutput>#SU_SET_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
	
		</tr>
	  </CFIF>
      <CFIF aux_mes gte 10> 
        <tr class="exibir">
        <td><div align="center"><strong>OUT</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Out_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_OUT_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Out_SU neq 0>
			<cfset Per = left((Soluc_Tot_Out_SU/(SU_OUT_TOT + Soluc_Tot_Out_SU)) * 100,4)>
		<cfelse>
			<cfset Per = 0>

		</cfif>			
        		
        <td><div align="center"><strong>#(SU_OUT_TOT + Soluc_Tot_Out_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_OUT_TOT>
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',10,<cfoutput>#Soluc_Tot_OUT_SU#</cfoutput>,<cfoutput>#SU_OUT_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 11> 
        <tr class="exibir">
        <td><div align="center"><strong>NOV</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Nov_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_NOV_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Nov_SU neq 0>
			<cfset Per = left((Soluc_Tot_Nov_SU/(SU_NOV_TOT + Soluc_Tot_Nov_SU)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>			
        	
        <td><div align="center"><strong>#(SU_NOV_TOT + Soluc_Tot_Nov_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_NOV_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',11,<cfoutput>#Soluc_Tot_NOV_SU#</cfoutput>,<cfoutput>#SU_NOV_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <CFIF aux_mes gte 12> 
        <tr class="exibir">
        <td><div align="center"><strong>DEZ</strong></div></td>
        <td><div align="center"><strong>#Soluc_Tot_Dez_SU#</strong></div></td>
		<cfset habunidsn = ''>
		<cfif SU_DEZ_TOT eq 0>
			<cfset habunidsn = 'disabled'>
		</cfif>
		<cfif Soluc_Tot_Dez_SU neq 0>
			<cfset Per = left((Soluc_Tot_Dez_SU/(SU_DEZ_TOT + Soluc_Tot_Dez_SU)) * 100,4)>	
		<cfelse>
			<cfset Per = 0>

		</cfif>			
        		
        <td><div align="center"><strong>#(SU_DEZ_TOT + Soluc_Tot_Dez_SU)#</strong></div></td>
        <td><div align="center">#NumberFormat(Per,999.0)#</div></td>
		<cfset Acum_SU = Acum_SU + SU_DEZ_TOT>	
		
			<td width="19%" class="exibir"><div align="center">
				<button type="button" class="botao" onClick="listar(<cfoutput>#se#</cfoutput>,'su',12,<cfoutput>#Soluc_Tot_DEZ_SU#</cfoutput>,<cfoutput>#SU_DEZ_TOT#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>Listar</button>
			</div></td>				
		
		</tr>
	  </CFIF>
	  <tr class="exibir">
        <td colspan="17"><hr></td>
      </tr>
		<cfset Acum_SU = (Acum_SU + Soluc_Geral_SU)>
		<cfset Acum_Per_SU = 0> 
		<cfif Acum_SU gt 0>
			<!--- <cfset Acum_Per_SU = left(Soluc_Geral_SU/(Acum_SU) * 100,4)>  --->
			<cfset Acum_Per_SU = NumberFormat(((Soluc_Geral_SU/Acum_SU) * 100),999.0)>
		</cfif>		 
  	   <tr class="tituloC">
        <td class="red_titulo"><div align="center">#MesAC#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Soluc_Geral_SU#</strong></div></td>
        <td class="red_titulo"><div align="center">#Acum_SU#</div></td>
        <td class="red_titulo"><div align="center"><strong>#Acum_Per_SU#</strong>
          </div></td>
		 
			<td class="red_titulo">
			  <div align="center"><span class="titulos">
			    <button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'su',0,<cfoutput>#Soluc_Geral_SU#</cfoutput>,<cfoutput>#(Acum_SU-Soluc_Geral_SU)#</cfoutput>);" <cfoutput>#habunidsn#</cfoutput>>
		        Listar(Todos)</button>
		      </span></div></td>
			
		</tr>			  
</cfif>	 
      <tr class="exibir">
        <td colspan="17" class="titulos">&nbsp;</td>
      </tr>
  	   <tr class="tituloC">
	   			<td class="red_titulo"><div align="center"><strong>&nbsp;</strong></div></td>
				<td class="red_titulo"><div align="center">Listar Solucionados</div></td>
				<td class="red_titulo"><div align="center"><strong>&nbsp;</strong></div></td>
				<td class="red_titulo"><div align="center"><strong>&nbsp;</strong></div></td>
				<td class="red_titulo"><div align="center"><button type="button" class="titulos" onClick="listar(<cfoutput>#se#</cfoutput>,'geral',0,100,101);">Listar(Geral)</button></div></td>
		</tr>
      <tr class="exibir">
        <td colspan="17" class="titulos">&nbsp;</td>
      </tr>
  </table>

<!---
<CFOUTPUT>#se#  #anoexerc#   slnc: #rsMetas.Met_SLNC#</CFOUTPUT>
 <cfset gil = gil> --->
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
<cffile action="Append" file="#slocal##sarquivo#" output='SOLUÇÃO DE NÃO CONFORMIDADES (SLNC) - #auxfilta#' >
<!--- <cffile action="Append" file="#slocal##sarquivo#" output='Meta Mensal : (#rsMetas.Met_SLNC# %)' > --->
<cffile action="Append" file="#slocal##sarquivo#" output=';;A;B*;C**;D;E=((C*100)/D);'>
<cffile action="Append" file="#slocal##sarquivo#" output='SE;Mês;Quantidade (Solucionados);Total;% de SL do mês;Meta Mensal;% Em Relação à meta Mensal;Resultado'>

 <cfset auxRazao = rsMetas.Met_SLNC> 
<!---<cfset auxRazao = numberFormat((rsMetas.Met_SLNC/12),999.0)>--->

<table width="56%" border="1" align="center" cellpadding="0" cellspacing="0">

  <tr>
	<td colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></a></div></td>
</tr>
  <tr>
    <td colspan="23" class="titulos"><div align="center"><strong>SOLU&Ccedil;&Atilde;O DE N&Atilde;O CONFORMIDADES (SLNC) </strong></div></td>
  </tr>
  <!--- <tr>
    <td colspan="23" class="titulos">Meta Anual : (#rsMetas.Met_SLNC# %)</td>
  </tr> --->
  <tr>
    <td colspan="23" class="exibir"><div align="center"></div></td>
  </tr>
  <tr class="exibir">
    <td colspan="12"><div align="center"></div>      <div align="center"></div>        <div align="center"></div></td>
	<!--- <cfset totgeral = rsitem.recordcount> --->
    </tr>
<tr class="exibir">
      <td colspan="2">&nbsp;</td>
      <td><div align="center">A</div></td>
      <td><div align="center">B*</div></td>
      <td><div align="center">C**</div></td>
   <!---    <td><div align="center">D</div></td> --->
<!---       <td><div align="center">E</div></td> --->
      <td><div align="center">D</div></td>
      <td><div align="center">E = ((C * 100)/D) </div></td>
      <td>&nbsp;</td>
    </tr>
  <tr class="exibir">
    <td width="4%" rowspan="2" valign="middle"><div align="center"><strong>SE</strong></div></td>
    <td width="7%" rowspan="2" valign="middle"><div align="center"><strong>Mês</strong></div></td>
    <td class="exibir"><div align="center"><strong>Quantidade (Solucionados)</strong></div>      
    <div align="center"></div><div align="center"></div></td>
    <td width="7%" class="exibir"><div align="center"><strong>Total</strong></div></td>
    <td width="8%" class="exibir"><div align="center"><strong>% de SL do mês </strong></div></td>
    <td width="10%" class="exibir"><div align="center"><strong>Meta<br>Mensal</strong> </div></td>
    <td width="14%" class="exibir"><div align="center"><strong>Em relação à Meta Mensal</strong> </div></td>
    <td width="16%" class="exibir"><div align="center"><strong>Resultado</strong> </div></td>
  </tr>
    <tr class="exibir">
    <td colspan="11" class="exibir"><div align="center" class="titulos"></div>      <div align="center" class="titulos"></div>      <div align="center" class="titulos"></div></td>
    </tr>
<CFSET sg = qAcesso.Dir_Sigla>
<CFSET TOTJAN = 0>
<CFSET TOTFEV = 0>
<CFSET TOTMAR = 0>
<CFSET TOTABR = 0>
<CFSET TOTMAI = 0>
<CFSET TOTJUN = 0>
<CFSET TOTJUL = 0>
<CFSET TOTAGO = 0>
<CFSET TOTSET = 0>
<CFSET TOTOUT = 0>
<CFSET TOTNOV = 0>
<CFSET TOTDEZ = 0>
<CFSET colbano = 0>
<CFSET colcano = 0>
<cfset mesbase = int(cont_mes - 1)>

<!--- JAN --->	
 <cfif (UN_JAN_TOT gt 0) or (GE_JAN_TOT gt 0) or (SB_JAN_TOT gt 0) or (SU_JAN_TOT gt 0)>
	<cfset TOTJAN = NumberFormat((UN_JAN_TOT + GE_JAN_TOT + SB_JAN_TOT + SU_JAN_TOT),999)>
	<cfset Soluc_Tot_Jan = NumberFormat((Soluc_Tot_Jan_UN + Soluc_Tot_Jan_GE + Soluc_Tot_Jan_SB + Soluc_Tot_Jan_SU),999)>	 
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
    <cfset ResTot = NumberFormat((TOTJAN + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>   
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Jan> 
    <tr class="exibir">
	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>JAN</strong></div></td>
    <td width="14%" class="exibir"><div align="center"><strong>#Soluc_Tot_Jan#</strong></div></td>
	<cfset colB = NumberFormat((TOTJAN + Soluc_Tot_Jan),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
	<cfset colC = NumberFormat(((Soluc_Tot_Jan/colB) * 100),999.0)>	
	<td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
    <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
    </tr>
	<cfset  auxultmes = 1>
	<!--- <cfset MetSLNCAcumPeriodo  = NumberFormat((SomaSolucionado/colD) * 100,999.0)>--->
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
	
	<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#'  WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 1
		</cfquery> 
	</cfif>		
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;JAN;#Soluc_Tot_Jan#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif>
<!--- FEV --->
 <cfif (UN_FEV_TOT gt 0) or (GE_FEV_TOT gt 0) or (SB_FEV_TOT gt 0) or (SU_FEV_TOT gt 0)>
	<cfset TOTFEV = NumberFormat((UN_FEV_TOT + GE_FEV_TOT + SB_FEV_TOT + SU_FEV_TOT),999)>
	<cfset Soluc_Tot_Fev = NumberFormat((Soluc_Tot_Fev_UN + Soluc_Tot_Fev_GE + Soluc_Tot_Fev_SB + Soluc_Tot_Fev_SU),999)>
		
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTFEV + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Fev> 
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>FEV</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Fev#</strong></div></td>
	<cfset colB = NumberFormat((TOTFEV + Soluc_Tot_Fev),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
	<cfset colC = NumberFormat(((Soluc_Tot_Fev/colB) * 100),999.0)>
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 2>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
		<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10>
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 2
	  </cfquery> 
	</cfif>			  
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;FEV;#Soluc_Tot_Fev#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif>
<!--- MAR --->
 <cfif (UN_MAR_TOT gt 0) or (GE_MAR_TOT gt 0) or (SB_MAR_TOT gt 0) or (SU_MAR_TOT gt 0)>
	<cfset TOTMAR = NumberFormat(UN_MAR_TOT + GE_MAR_TOT + SB_MAR_TOT + SU_MAR_TOT,999)>
	<cfset Soluc_Tot_Mar = NumberFormat((Soluc_Tot_Mar_UN + Soluc_Tot_Mar_GE + Soluc_Tot_Mar_SB + Soluc_Tot_Mar_SU),999)>
   	
   
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTMAR + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Mar> 

  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>MAR</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Mar#</strong></div></td>
	<cfset colB = NumberFormat((TOTMAR + Soluc_Tot_Mar),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>	
    <cfset colC = NumberFormat(((Soluc_Tot_Mar/colB) * 100),999.0)>		
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>	
  </tr>
  <cfset  auxultmes = 3>
<!---   <cfset MetSLNCAcumPeriodo  = NumberFormat((SomaSolucionado/colD) * 100,999.0)>
<cfset MetSLNCAcumPeriodo = trim(MetSLNCAcumPeriodo)> --->
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
		<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10>
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 3
	  </cfquery>
	</cfif>			     
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;MAR;#Soluc_Tot_Mar#;#colB#;#colC#;#ColD#;#ColE#;#resultado#'>  
 </cfif> 
<!--- ABR --->
 <cfif (UN_ABR_TOT gt 0) or (GE_ABR_TOT gt 0) or (SB_ABR_TOT gt 0) or (SU_ABR_TOT gt 0)>
	<cfset TOTABR = NumberFormat((UN_ABR_TOT + GE_ABR_TOT + SB_ABR_TOT + SU_ABR_TOT),999)>
	<cfset Soluc_Tot_Abr = NumberFormat((Soluc_Tot_Abr_UN + Soluc_Tot_Abr_GE + Soluc_Tot_Abr_SB + Soluc_Tot_Abr_SU),999)>		
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTABR + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Abr> 	

  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>ABR</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Abr#</strong></div></td>
	<cfset colB = NumberFormat((TOTABR + Soluc_Tot_Abr),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Abr/colB) * 100),999.0)>	
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>			
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  
  <cfset  auxultmes = 4>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)> 
 		<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 4
	  </cfquery> 
	</cfif>			    
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;ABR;#Soluc_Tot_Abr#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif> 
<!--- MAI --->
 <cfif (UN_MAI_TOT gt 0) or (GE_MAI_TOT gt 0) or (SB_MAI_TOT gt 0) or (SU_MAI_TOT gt 0)>
	<cfset TOTMAI = NumberFormat((UN_MAI_TOT + GE_MAI_TOT + SB_MAI_TOT + SU_MAI_TOT),999)>
	<cfset Soluc_Tot_Mai = NumberFormat((Soluc_Tot_Mai_UN + Soluc_Tot_Mai_GE + Soluc_Tot_Mai_SB + Soluc_Tot_Mai_SU),999)>		
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTMAI + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Mai> 	
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>MAI</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Mai#</strong></div></td>
	<cfset colB = NumberFormat((TOTMAI + Soluc_Tot_Mai),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Mai/colB) * 100),999.0)>
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 5>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)>
    	<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 5
		</cfquery>
    </cfif> 	  
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;MAI;#Soluc_Tot_Mai#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
  </cfif>  
<!--- JUN --->
 <cfif (UN_JUN_TOT gt 0) or (GE_JUN_TOT gt 0) or (SB_JUN_TOT gt 0) or (SU_JUN_TOT gt 0)>
	<cfset TOTJUN = NumberFormat((UN_JUN_TOT + GE_JUN_TOT + SB_JUN_TOT + SU_JUN_TOT),999)>
	<cfset Soluc_Tot_Jun = NumberFormat((Soluc_Tot_Jun_UN + Soluc_Tot_Jun_GE + Soluc_Tot_Jun_SB + Soluc_Tot_Jun_SU),999)>	
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTJUN + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Jun> 	
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>JUN</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Jun#</strong></div></td>
	<cfset colB = NumberFormat((TOTJUN + Soluc_Tot_Jun),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Jun/colB) * 100),999.0)>	    
	<td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 6>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)>
	<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 6
	  </cfquery>  
	</cfif>			   
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;JUN;#Soluc_Tot_Jun#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif> 
 <!--- JUL --->	
 <cfif (UN_JUL_TOT gt 0) or (GE_JUL_TOT gt 0) or (SB_JUL_TOT gt 0) or (SU_JUL_TOT gt 0)>
	<cfset TOTJUL = NumberFormat((UN_JUL_TOT + GE_JUL_TOT + SB_JUL_TOT + SU_JUL_TOT),999)>
	<cfset Soluc_Tot_Jul = NumberFormat((Soluc_Tot_Jul_UN + Soluc_Tot_Jul_GE + Soluc_Tot_Jul_SB + Soluc_Tot_Jul_SU),999)>		
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTJUL + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Jul> 
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>JUL</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Jul#</strong></div></td>
	<cfset colB = NumberFormat((TOTJUL + Soluc_Tot_Jul),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Jul/colB) * 100),999.0)>	
    <td><div align="center">#colC#</div></td>
    <cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 7>
  <cfset MetSLNCAcumPeriodo  = NumberFormat((SomaSolucionado/colD) * 100,999.0)>
<cfset MetSLNCAcumPeriodo = trim(MetSLNCAcumPeriodo)>
		<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
		<cfquery datasource="#dsn_inspecao#">
		UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 7
		</cfquery> 
	</cfif>		  
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;JUL;#Soluc_Tot_Jul#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif>
<!--- AGO --->
 <cfif (UN_AGO_TOT gt 0) or (GE_AGO_TOT gt 0) or (SB_AGO_TOT gt 0) or (SU_AGO_TOT gt 0)>
	<cfset TOTAGO = NumberFormat((UN_AGO_TOT + GE_AGO_TOT + SB_AGO_TOT + SU_AGO_TOT),999)>
	<cfset Soluc_Tot_Ago = NumberFormat((Soluc_Tot_Ago_UN + Soluc_Tot_Ago_GE + Soluc_Tot_Ago_SB + Soluc_Tot_Ago_SU),999)>	
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTAGO + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Ago> 				
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>AGO</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Ago#</strong></div></td>
	<cfset colB = NumberFormat((TOTAGO + Soluc_Tot_Ago),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Ago/colB) * 100),999.0)>	
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>		
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 8>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)>
 	<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 8
	  </cfquery> 
 </cfif>			   
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;AGO;#Soluc_Tot_Ago#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif>
<!--- SET --->
 <cfif (UN_SET_TOT gt 0) or (GE_SET_TOT gt 0) or (SB_SET_TOT gt 0) or (SU_SET_TOT gt 0)>
	<cfset TOTSET = NumberFormat((UN_SET_TOT + GE_SET_TOT + SB_SET_TOT + SU_SET_TOT),999)>
	<cfset Soluc_Tot_Set = NumberFormat((Soluc_Tot_Set_UN + Soluc_Tot_Set_GE + Soluc_Tot_Set_SB + Soluc_Tot_Set_SU),999)>	
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTSET + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Set>	
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>SET</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Set#</strong></div></td>
	<cfset colB = NumberFormat((TOTSET + Soluc_Tot_Set),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Set/colB) * 100),999.0)>		
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>			
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 9>
  <cfset MetSLNCAcumPeriodo  = NumberFormat((SomaSolucionado/colD) * 100,999.0)>
<cfset MetSLNCAcumPeriodo = trim(MetSLNCAcumPeriodo)>
		<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10>   
		<cfquery datasource="#dsn_inspecao#">
		UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 9
		</cfquery>  
	</cfif>		  
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;SET;#Soluc_Tot_Set#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif> 
<!--- OUT --->
 <cfif (UN_OUT_TOT gt 0) or (GE_OUT_TOT gt 0) or (SB_OUT_TOT gt 0) or (SU_OUT_TOT gt 0)>
	<cfset TOTOUT = NumberFormat((UN_OUT_TOT + GE_OUT_TOT + SB_OUT_TOT + SU_OUT_TOT),999)>
	<cfset Soluc_Tot_Out = NumberFormat((Soluc_Tot_Out_UN + Soluc_Tot_Out_GE + Soluc_Tot_Out_SB + Soluc_Tot_Out_SU),999)>	
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTOUT + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>	
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Out>
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>OUT</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Out#</strong></div></td>
	<cfset colB = NumberFormat((TOTOUT + Soluc_Tot_Out),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
	<cfset colC = NumberFormat(((Soluc_Tot_Out/colB) * 100),999.0)>		
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
	<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 10>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)>
 		<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 10
	  </cfquery>
	</cfif>			     
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;OUT;#Soluc_Tot_Out#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif> 
<!--- NOV --->
 <cfif (UN_NOV_TOT gt 0) or (GE_NOV_TOT gt 0) or (SB_NOV_TOT gt 0) or (SU_NOV_TOT gt 0)>
	<cfset TOTNOV = NumberFormat((UN_NOV_TOT + GE_NOV_TOT + SB_NOV_TOT + SU_NOV_TOT),999)>
	<cfset Soluc_Tot_Nov = NumberFormat((Soluc_Tot_Nov_UN + Soluc_Tot_Nov_GE + Soluc_Tot_Nov_SB + Soluc_Tot_Nov_SU),999)>		
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTNOV + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Nov>		  
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>NOV</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Nov#</strong></div></td>
	<cfset colB = NumberFormat((TOTNOV + Soluc_Tot_Nov),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
    <cfset colC = NumberFormat(((Soluc_Tot_Nov/colB) * 100),999.0)>	
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
	<td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 11>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)>
    	<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 11
	  </cfquery>   
	</cfif>			  
    <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;NOV;#Soluc_Tot_Nov#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>  
 </cfif>  
<!--- DEZ --->
 <cfif (UN_DEZ_TOT gt 0) or (GE_DEZ_TOT gt 0) or (SB_DEZ_TOT gt 0) or (SU_DEZ_TOT gt 0)>
	<cfset TOTDEZ = NumberFormat((UN_DEZ_TOT + GE_DEZ_TOT + SB_DEZ_TOT + SU_DEZ_TOT),999)>
	<cfset Soluc_Tot_Dez = NumberFormat((Soluc_Tot_Dez_UN + Soluc_Tot_Dez_GE + Soluc_Tot_Dez_SB + Soluc_Tot_Dez_SU),999)>				  
    <cfset Soluc_Geral = NumberFormat((Soluc_Tot_Jan + Soluc_Tot_Fev + Soluc_Tot_Mar + Soluc_Tot_Abr + Soluc_Tot_Mai + Soluc_Tot_Jun + Soluc_Tot_Jul + Soluc_Tot_Ago + Soluc_Tot_Set + Soluc_Tot_Out + Soluc_Tot_Nov + Soluc_Tot_Dez),999)>
 	<cfset ResTot = NumberFormat((TOTDEZ + Soluc_Geral),999)>
	<cfset ResPer = NumberFormat(((Soluc_Geral/ResTot) * 100),999.0)>
	<cfset SomaSolucionado = SomaSolucionado + Soluc_Tot_Dez>
  <tr class="exibir">
  	<td><div align="center"><strong>#sg#</strong></div></td>
    <td><div align="center"><strong>DEZ</strong></div></td>
    <td><div align="center"><strong>#Soluc_Tot_Dez#</strong></div></td>
	<cfset colB = NumberFormat((TOTDEZ + Soluc_Tot_Dez),999)>
	<cfset colbano = colbano + colb>
    <td><div align="center"><strong>#colB#</strong></div></td>
	<cfset colC = NumberFormat(((Soluc_Tot_Dez/colB) * 100),999.0)>	
    <td><div align="center">#colC#</div></td>
	<cfset ColD = metslnc>    
	<td><div align="center">#ColD#</div></td>
	<CFSET ColE = numberFormat(((colC * 100)/ColD),999.0)>
    <td><div align="center">#ColE#</div></td>
	<cfif ColC gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif ColC eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>		
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
  <cfset  auxultmes = 12>
	<cfset colcano = colcano + colC>
	<cfset acumper = NumberFormat((colcano/auxultmes),999.0)>
   	<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and auxultmes eq #month(dtlimit)# and day(now()) lte 10> 
	  <cfquery datasource="#dsn_inspecao#">
	   UPDATE Metas SET Met_SLNC_Acum = '#colC#', Met_SLNC_AcumPeriodo = '#acumper#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = 12
	  </cfquery>
	</cfif>			     
  <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;DEZ;#Soluc_Tot_Dez#;#colB#;#colC#;#colD#;#ColE#;#resultado#'>
 </cfif>
 
 <cfset colcano = NumberFormat(((Soluc_Geral/colbano) * 100),999.0)>	
 <cfset ColD = metslnc> 
 <CFSET ColE = numberFormat(((colcano * 100)/ColD),999.0)>
<tr class="titulos">
    <td><div align="center" class="red_titulo"><strong>#sg#</strong></div></td>  
    <td class="red_titulo"><div align="center"><strong>Geral</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#Soluc_Geral#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#colbano#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#colcano#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#ColD#</strong></div></td>
    <td><div align="center" class="red_titulo"><strong>#ColE#</strong></div></td>

   <cfif colcano gt ColD>
		<cfset resultado = "ACIMA DO ESPERADO">
		<cfset auxcor = "##33CCFF">
   <cfelseif colcano eq ColD>		
		<cfset resultado = "DENTRO DO ESPERADO">
		<cfset auxcor = "##339900">
    <cfelse>
		<cfset resultado = "ABAIXO DO ESPERADO">
		<cfset auxcor = "##FF3300">
	</cfif>	
    <td bgcolor="#auxcor#"><div align="center"><strong>#resultado#</strong></div></td>
  </tr>
 <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;Geral;#Soluc_Geral#;#colbano#;#colcano#;#colD#;#ColE#;#resultado#'>
  <tr class="exibir">
    <td colspan="12" class="exibir"><strong>Legenda: </strong></td>
  </tr>
   <cffile action="Append" file="#slocal##sarquivo#" output='Legenda:'>
  <tr class="exibir">
    <td colspan="12"><strong>* Total B - Soma ((pendentes + tratamento com mais de  30(trinta) dias úteis  da liberação dos pontos) + ( solucionados do m&ecirc;s)) </strong></td>
  </tr>
  <cffile action="Append" file="#slocal##sarquivo#" output='* Total B - Soma ((pendentes + tratamento com mais de  30(trinta) dias úteis  da liberação dos pontos) + ( solucionados do mês)) ' >
  <tr class="exibir">
    <td colspan="12"><strong>** % de SL do m&ecirc;s = ((A/B) * 100) </strong></td>
  </tr>
   <cffile action="Append" file="#slocal##sarquivo#" output='** % de SL do mês = A/B * 100'>  

    <tr class="exibir">
    <td colspan="12"><p><strong>SL = SOLUCIONADO <br></strong></p>
      </td>
<cfif ucase(trim(qUsuario.Usu_GrupoAcesso)) eq 'GESTORMASTER' and day(now()) lte 10> 
  <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_SLNC_AcumPeriodo = '#colcano#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)# and Met_Mes = #auxultmes#
  </cfquery>
</cfif>  	  
  <cffile action="Append" file="#slocal##sarquivo#" output='SL = SOLUCIONADO'>    	  	  
    <!---     <td colspan="2"><input name="Submit1" type="submit" class="botao" id="Submit1" value="+Detalhes"></td> --->
  </tr>
</table>

<input name="se" type="hidden" value="#se#">


<!--- fim exibicao --->
</form>
<form name="formx" method="post" action="Rel_Indicadores_Solucao2.cfm" target="_blank">
    <input name="lis_anoexerc" type="hidden" value="#anoexerc#">
	<input name="lis_se" type="hidden" value="#se#">
	<input name="lis_mes" type="hidden" value="">
	<input name="lis_soluc" type="hidden" value="">
	<input name="lis_outros" type="hidden" value="">
	<input name="lis_grpace" type="hidden" value="">
</form>
  <cfinclude template="rodape.cfm">
</body>
</html>
</cfoutput>
