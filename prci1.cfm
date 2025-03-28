<cfsetting requesttimeout="15000">
<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif len(form.lis_se) is 1>
	<cfset form.lis_se = 0 & form.lis_se>
</cfif>

<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>
<cfif grpacesso eq 'GESTORMASTER'>
	<cfset AndtMes = int(month(now()))>
<cfelse>
	<cfset AndtMes = int(month(now()) - 1)>
</cfif>
</cfoutput>	
<cfquery name="rsResumo" datasource="#dsn_inspecao#">
    SELECT Dir_Codigo, Dir_Sigla, Dir_Descricao, Andt_Unid, Und_Descricao, Andt_tpunid, TUN_Descricao, Andt_Mes, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic, Andt_Resp, STO_Descricao, Andt_Uteis, Andt_Area, Andt_DTEnvio, Andt_NomeOrgCondutor, Andt_Prazo, Andt_DTRefer 
	FROM (Tipo_Unidades INNER JOIN 
	((Andamento_Temp INNER JOIN Situacao_Ponto ON Andt_Resp = STO_Codigo) 
	INNER JOIN (Diretoria 
	INNER JOIN Unidades ON Dir_Codigo = Und_CodDiretoria) ON Andt_Unid = Und_Codigo) ON TUN_Codigo = Andt_tpunid) 
	WHERE Andt_CodSE ='#form.lis_se#' AND 
	<cfif form.lis_grpace is "un">
		Andt_Resp in (1,17,2,14,15,18,20)
	<cfelseif form.lis_grpace is "ge">
		Andt_Resp in (6,5,19)	
	<cfelseif form.lis_grpace is "sb">
		Andt_Resp in (7,4,16)			
	<cfelseif form.lis_grpace is "su">
		Andt_Resp in (8,22,23)				
	</cfif>
	<cfif form.lis_mes neq 0>
		and Andt_Mes = #form.lis_mes# 
	<cfelse>
		and Andt_Mes <= #AndtMes# 
	</cfif>		
	 	and Andt_TipoRel = 1 and Andt_AnoExerc = '#form.lis_ano#'
		order by Dir_Codigo, Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
</cfquery>	

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

 <cfif rsResumo.recordcount lte 0>
  Não Há dados a serem relatados para o período informado!<br>
  <input type="button" class="botao" onClick="window.close()" value="Fechar">
  <cfabort> 
</cfif> 

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#form.lis_se#'
</cfquery>
<cfset auxfiltro = #qAcesso.Dir_Descricao#>

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script language="javascript">

function valida_form(a,b) {
   document.frmResumo.frmse.value = a;
   document.frmResumo.frmano.value = b;   
   document.frmResumo.submit();
}

</script>
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<body>

<form action="prci2.cfm" method="get" target="_blank" name="frmResumo">
	<cfif form.lis_grpace is "un">
		<cfset grpace = "Unidades">
 		<cfset relgpac = "UNID">
	<cfelseif form.lis_grpace is "ge">
		<cfset grpace = "Gerencias Regionais e Areas de Suporte">
		<cfset relgpac = "GRAS">
	<cfelseif form.lis_grpace is "sb">
		<cfset grpace = "Orgaos Subordinadores">
		<cfset relgpac = "OSUB">
	<cfelseif form.lis_grpace is "su">
		<cfset grpace = "Superintendencia">
		<cfset relgpac = "SUPE">
	</cfif>
  <table width="90%" border="1" align="center" cellpadding="0" cellspacing="0">
  <cfoutput>
  <!--- Excluir arquivos anteriores ao dia atual --->
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset relmes = trim(form.lis_mes)>
<cfif len(relmes) is 1>
	<cfset relmes = 0 & relmes>
</cfif> 
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(form.lis_se)# & #relgpac# & #relmes# & '.xls'>
      <tr>
        <td colspan="12"><div align="center" class="titulo1">#auxfiltro#</div></td>
      </tr>
      <tr>
        <td colspan="12"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="22" border="0"></a></div></td>
      </tr>
      <tr>
        <td colspan="12"><div align="center" class="exibir"><span class="titulo1"><strong>Atendimento ao Prazo de Resposta do Controle Interno (PRCI)</strong></span></div></td>
      </tr>
	  <cfset auxqtd = rsResumo.recordcount>
      <tr>
        <td colspan="12" class="titulos">#grpace# &nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;(&nbsp;Ações de : Tratamentos,  Pendências e Não Respondido)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;        Qtd.:&nbsp;#auxqtd#
        <div align="right"></div></td>
		
      </tr>	  
</cfoutput>	  

	  <tr class="exibir">
	    <td width="2%" height="27" class="titulos"><div align="center">Mês</div>
	      <div align="center"></div></td>
        <td width="20%" class="titulos"><div align="left">Unidade</div>
        <div align="center"></div></td>
        <td width="18%" class="titulos">Órgão Condutor(*)</td>
        <td width="6%" class="titulos">Avaliação</td>
        <td width="5%" class="titulos"><div align="center">Grupo</div></td>
        <td width="4%" class="titulos"><div align="center">Item</div></td>
<!--- 		<cfif (form.lis_ano lte 2022) and (form.lis_mes lte 2)> --->
		<td width="5%" class="titulos">Fim Revisão</td>
        <td width="6%" class="titulos">Dt. Ação </td>
        <td width="17%" class="titulos"><div align="center">Tipo Ação</div></td>
        <td width="7%" class="titulos"><div align="center">Prazo(DP/FP)</div></td>
      </tr>
<cfoutput query="rsResumo">
<!---  --->
	<cfif Andt_Mes is 1>
		<cfset dtini = CreateDate(form.lis_ano,1,1)>
		<cfset dtfim = CreateDate(form.lis_ano,1,31)>
		<cfset mes = "Jan">
	<cfelseif Andt_Mes is 2>
		<cfif int(form.lis_ano) mod 4 is 0>
		   <cfset dtfim = CreateDate(form.lis_ano,2,29)>
		<cfelse>
		   <cfset dtfim = CreateDate(form.lis_ano,2,28)>
		</cfif>
		<cfset dtini = CreateDate(form.lis_ano,2,1)>	
		<cfset mes = "Fev">			
	<cfelseif Andt_Mes is 3>
		<cfset dtini = CreateDate(form.lis_ano,3,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,3,31)>
		<cfset mes = "Mar">			   
	<cfelseif Andt_Mes is 4>
		<cfset dtini = CreateDate(form.lis_ano,4,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,4,30)>
		<cfset mes = "Abr">			   		
	<cfelseif Andt_Mes is 5>
		<cfset dtini = CreateDate(form.lis_ano,5,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,5,31)>		
		<cfset mes = "Mai">			   
	<cfelseif Andt_Mes is 6>
		<cfset dtini = CreateDate(form.lis_ano,6,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,6,30)>	
		<cfset mes = "Jun">			   	
	<cfelseif Andt_Mes is 7>
		<cfset dtini = CreateDate(form.lis_ano,7,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,7,31)>	
		<cfset mes = "Jul">			   	
	<cfelseif Andt_Mes is 8>
		<cfset dtini = CreateDate(form.lis_ano,8,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,8,31)>	
		<cfset mes = "Ago">			   	
	<cfelseif Andt_Mes is 9>
		<cfset dtini = CreateDate(form.lis_ano,9,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,9,30)>		
		<cfset mes = "Set">			   
	<cfelseif Andt_Mes is 10>
		<cfset dtini = CreateDate(form.lis_ano,10,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,10,31)>	
		<cfset mes = "Out">			   	
	<cfelseif Andt_Mes is 11>
		<cfset dtini = CreateDate(form.lis_ano,11,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,11,30)>	
		<cfset mes = "Nov">			   	
	<cfelse>
		<cfset dtini = CreateDate(form.lis_ano,12,1)>		
		<cfset dtfim = CreateDate(form.lis_ano,12,31)>		
		<cfset mes = "Dez">			   
	</cfif>

	<tr class="exibir">
	    <td><div align="center">#mes#</div></td>
	    <td><span class="style1">#Und_Descricao#</span></td>
	    <td><span class="style1">#Andt_NomeOrgCondutor#</span></td>
	    <td>#Andt_Insp#</td>
		<cfset auxgrp = Andt_Grp>
	    <td><div align="center">#auxgrp#</div></td>
		<cfset auxit = Andt_Item>
	    <td><div align="center">#auxit#</div></td>
		<cfif len(Andt_DTEnvio) gte 8>
			<cfset dtenvio = dateformat(Andt_DTEnvio,"dd/mm/yyyy")>
			<cfset auxdtprev = CreateDate(year(Andt_DTEnvio),month(Andt_DTEnvio),day(Andt_DTEnvio))>
			<cfset auxdttopo = CreateDate(year(Andt_DPosic),month(Andt_DPosic),day(Andt_DPosic))>
		<cfelse>
			<cfset dtenvio = "---">		
			<cfset auxdtprev = CreateDate(year(Andt_DPosic),month(Andt_DPosic),day(Andt_DPosic))>
			<cfset auxdttopo = CreateDate(year(dtfim),month(dtfim),day(dtfim))>
		</cfif>
		<!--- inicio dias uteis 
		    <cfset  diascor = DateDiff( "d", auxdtprev, auxdttopo)> 
			<cfset nCont = 'S'>
			<cfset ddsupr = 0>
			<cfloop condition="nCont eq 'S'">
			   <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
			   <cfset vDiaSem = DayOfWeek(auxdtprev)>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
					<cfset ddsupr = ddsupr + 1>
				</cfif>
				<cfif dateformat(auxdtprev,"YYYYMMDD") GTE dateformat(auxdttopo,"YYYYMMDD")>
				  <cfset nCont = 'N'>
				</cfif>
			</cfloop>		
		 <CFSET DDUT = diascor - ddsupr> 	--->		
		<!--- fim dias uteis --->		
	    <td><div align="center">#dtenvio#</div></td>

		<cfset dtposic = dateformat(Andt_DPosic,"dd/mm/yyyy")>
	    <td><div align="center">#dtposic#</div></td>
	    <td><div align="left">#STO_Descricao#</div></td>
<!---	    <cfset dtfim = dateformat(dtfim,"dd/mm/yyyy")>
	    <td><div align="center">#dtfim#</div></td> --->
<!---		<CFSET DDUT = Andt_Uteis> --->
<!--- 		<cfif (form.lis_ano lte 2022) and (form.lis_mes lte 2)> --->
<!---	    <td><div align="center">#DDUT#</div></td> --->
<!--- 		<cfelse>
		<td width="5%"></td>
		</cfif>  --->
        <td><div align="center">#Andt_Prazo#</div></td>
</tr>	  
</cfoutput> 	
      <tr class="exibir">
        <td colspan="12" class="titulos">Prazo: DENTRO DO PRAZO (DP) ou FORA DO PRAZO(FP)</td>
      </tr>
      <tr class="exibir">
        <td colspan="12" class="titulos">(*) Órgão Condutor: Órgão responsável pelo cumprimento do prazo de resposta no momento do levantamento dos dados dessa Avaliação. </td>
      </tr>
      <tr class="exibir">
        <td colspan="12"><table width="1105" border="0">
          <tr>
            <td colspan="2"><hr></td>
          </tr>
          <tr>
            <td colspan="2"><p align="center" class="titulos"><strong> CRITÉRIOS DE MENSURAÇÃO </strong></p></td>
          </tr>
          <tr class="exibir">
            <td width="107" class="exibir"><strong> RESPOSTA </strong></td>
            <td width="988"><p> A MENSURAÇÃO do atendimento ao prazo de 10 dias úteis para o status <strong>Resposta</strong> é o resultado da subtração da Dt. ação com a Dt.  Envio. </p></td>
          </tr>
          <tr class="exibir">
            <td><strong> PENDENTE </strong></td>
            <td><p> A MENSURAÇÃO do atendimento ao prazo de 10 dias úteis para o status <strong>Pendente</strong> é o resultado da subtração da Data de Referência (último dia do mês) com a Dt. ação. </p></td>
          </tr>
          <tr class="exibir">
            <td><strong> TRATAMENTO </strong></td>
            <td><p> itens no status Em <strong>Tratamento </strong>estão dentro do prazo previsto pelo gestor em sua manifestação (Previsão de Solução). </p></td>
          </tr>
          <tr class="exibir">
            <td><span class="style1"><strong> NÂO RESPONDIDO </strong></span></td>
            <td> itens no status <strong>Não Respondido</strong> está dentro do prazo de resposta de 10 dias úteis. </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
      </tr>  
  </table>
    <input name="frmse" type="hidden" id="frmse">
    <input name="frmano" type="hidden" id="frmano">
</form>

<!--- <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'> --->

<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
  	<cfloop query="qList">
		   <cfif len(name) eq 23>
		   		<cfif (mid(name,14,4) is 'UNID') or (mid(name,14,4) is 'GRAS') OR (mid(name,14,4) is 'OSUB') OR (mid(name,14,4) is 'SUPE')>
					<cfif (left(name,8) lt left(sdata,8))>
					  <cffile action="delete" file="#slocal##name#">
					</cfif>
				</cfif>				
		  </cfif>
	</cfloop>
<cfoutput>	
<cftry>

<cfif Month(Now()) eq 1>
  <cfset vANO = form.lis_ano - 1>
<cfelse>
  <cfset vANO = form.lis_ano>
</cfif>
<cfset vANO = form.lis_ano>
<cfset objPOI = CreateObject(
    "component",
    "Excel"
    ).Init()
    />

<cfquery name="rsXLS" datasource="#dsn_inspecao#">
	SELECT CASE Andt_Mes 
            WHEN 1 then 'JAN'
			WHEN 2 then 'FEV'
            WHEN 3 then 'MAR'
			WHEN 4 then 'ABR'			 
            WHEN 5 then 'MAI'
			WHEN 6 then 'JUN'
            WHEN 7 then 'JUL'
			WHEN 8 then 'AGO'
            WHEN 9 then 'SET'
			WHEN 10 then 'OUT'
            WHEN 11 then 'NOV'
			else 'DEZ' end as Mes, Andt_Mes, Andt_Resp, Und_Descricao, Andt_NomeOrgCondutor, Andt_Insp, Andt_Grp, Andt_Item, convert(char,Andt_DTEnvio,103) as AndtDTEnvio, convert(char,Andt_DPosic,103) as AndtDPosic, STO_Descricao, Andt_Uteis, Andt_Prazo, convert(char,Andt_DTRefer,103) as AndtDTRefer
	FROM (Andamento_Temp INNER JOIN Situacao_Ponto ON Andt_Resp = STO_Codigo INNER JOIN Unidades ON Andt_Unid = Und_Codigo) 
	WHERE Und_CodDiretoria ='#form.lis_se#' AND 
	<cfif form.lis_grpace is "un">
		Andt_Resp in (1,14,2,15,17,18,20)
	<cfelseif form.lis_grpace is "ge">
		Andt_Resp in (6,5,19)	
	<cfelseif form.lis_grpace is "sb">
		Andt_Resp in (7,4,16)			
	<cfelseif form.lis_grpace is "su">
		Andt_Resp in (8,22,23)				
	</cfif>
	<cfif form.lis_mes neq 0>
		and Andt_Mes = #form.lis_mes#
	<cfelse>
		and Andt_Mes <= #AndtMes# 
	</cfif>
	 and Andt_TipoRel = 1 and Andt_AnoExerc = '#form.lis_ano#'
	order by Andt_Mes, Andt_Unid, Andt_Insp, Andt_Grp, Andt_Item, Andt_DPosic, Andt_HPosic
</cfquery>

<cfset data = now() - 1>
	 <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
    Query = rsXLS,            
	ColumnList = "Mes,Und_Descricao,Andt_NomeOrgCondutor,Andt_Insp,Andt_Grp,Andt_Item,AndtDTEnvio,AndtDPosic,STO_Descricao,Andt_Prazo",
	ColumnNames = "MÊS,UNIDADE,ÓRGÃO CONDUTOR,RELATÓRIO,GRUPO,ITEM,FIM REVISÃO,DT.AÇÃO,TIPO AÇÃO,PRAZO(DP/FP)",
	SheetName = "Prazo_Respostas"
    ) />

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>

</cftry>
  <cfinclude template="rodape.cfm">
 </cfoutput>
</body>
</html>
