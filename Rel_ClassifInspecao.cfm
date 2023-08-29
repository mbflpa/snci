<!---  <cfoutput>#se# dtlimit:#dtlimit#<br> </cfoutput> --->
<!--- <cfprocessingdirective pageEncoding ="utf-8"/> --->
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
function validaForm() {
//alert('submit ok');
//alert('valor : ' + document.form1.tpunid.value);
//alert(document.form1.acao.value);
if (document.form1.acao.value != 'Filtro')
   {
    if (document.form1.frmcodunid.value == 'N'){return false;}
    document.form1.action="alterar_dados_unidade.cfm";
  //  document.form1.submit();
	}
else
   {
   document.form1.action="Rel_ClassifInspecao.cfm";
   document.form1.submit();
   }
}
function voltar(){
       document.formvolta.submit();
    }
</script>
<style type="text/css">
<!--
.style1 {font-weight: bold}
.style2 {font-weight: bold}
.style3 {font-weight: bold}
-->
</style>
</head>
<body>
<!---  --->
<cfset dtlimit = '31/12/2021'>
<cfoutput>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_codigo = '#se#'
</cfquery>
<CFSET sg = qAcesso.Dir_Sigla>

<cfset DT_MARCO_INI = CreateDate(year(dtlimit),01,01)>

 <cfquery datasource="#dsn_inspecao#" name="rsInsp">
	SELECT INP_NumInspecao, Dir_Sigla, INP_Unidade, Und_Descricao, INP_DtFimInspecao
	FROM (Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
	WHERE Dir_Sigla = '#se#' AND INP_DtFimInspecao >= #DT_MARCO_INI#
	ORDER BY INP_NumInspecao
</cfquery>  
</cfoutput>	
<cfoutput query="rsInsp">
<!--- #INP_NumInspecao# #Dir_Sigla# #INP_Unidade# #Und_Descricao# #INP_DtFimInspecao#<br> --->
    <cfset auxtotC = 0>
    <cfset auxtotN = 0>
    <cfset auxtotPontos = 0>		 
	<cfquery datasource="#dsn_inspecao#" name="rsResult">
		SELECT RIP_Resposta
		FROM Resultado_Inspecao
		WHERE RIP_Unidade = '#rsInsp.INP_Unidade#' AND RIP_NumInspecao = '#rsInsp.INP_NumInspecao#'
	</cfquery>
	<cfset auxtotPontos = rsResult.recordcount>
	<cfloop query="rsResult">
	  <cfif ucase(trim(rsResult.RIP_Resposta)) eq 'C'>
	     <cfset auxtotC = auxtotC + 1>
	<!---  <cfoutput>#auxtotC#</cfoutput><br>	 --->	 
	  <cfelseif ucase(trim(rsResult.RIP_Resposta)) eq 'N'>
		 <cfset auxtotN = auxtotN + 1>
<!--- 	  <cfoutput>#auxtotC#</cfoutput><br>		 ---> 
	  </cfif>
	</cfloop>

	<cfquery datasource="#dsn_inspecao#" name="rsExiste">
		SELECT CLUN_SiglaSE
		FROM Classif_Unidades
		WHERE CLUN_Inspecao = '#rsInsp.INP_NumInspecao#'
	</cfquery>
	<cfif rsExiste.recordcount lte 0>
		<cfquery datasource="#dsn_inspecao#">
			insert into Classif_Unidades (CLUN_Inspecao, CLUN_SiglaSE, CLUN_NomeUnidade, CLUN_QtdConformes, CLUN_QtdNConformes, CLUN_TotalPontos, CLUN_DTAvaliacao)	values ('#rsInsp.INP_NumInspecao#', '#rsInsp.Dir_Sigla#', '#rsInsp.Und_Descricao#', #auxtotC#, #auxtotN#, #auxtotPontos#, #rsInsp.INP_DtFimInspecao#)
		</cfquery>	
	</cfif>

</cfoutput>

<!---  --->


<!--- <cfset dtlimit = CreateDate(year(dtlimit),month(dtlimit),day(dtlimit))> --->
<cfquery name="rsSiglaSE" datasource="#dsn_inspecao#">
  SELECT Dir_codigo, Dir_Sigla, Dir_Descricao FROM Diretoria WHERE Dir_Codigo = '#se#'
</cfquery>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset auxfiltro = #rsSiglaSE.Dir_Descricao#>

<!--- <cfquery datasource="#dsn_inspecao#" name="rsTipoUnid">
	SELECT Und_CodDiretoria, Und_TipoUnidade, TUN_Descricao
	FROM ((Classif_Unidades INNER JOIN Inspecao ON CLUN_Inspecao = INP_NumInspecao) 
	INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
	INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
	WHERE CLUN_Pontuacao Is Not Null
	GROUP BY Und_CodDiretoria, Und_TipoUnidade, TUN_Descricao
	HAVING Und_CodDiretoria = '#se#'
</cfquery> --->
 <cfset dtini = CreateDate(year(dtlimit),month(dtlimit),1)>		
 <cfset dtfim = CreateDate(year(dtlimit),month(dtlimit),day(dtlimit))>
<cfquery datasource="#dsn_inspecao#" name="rsTipoUnid">
	SELECT Und_CodDiretoria, Und_TipoUnidade, TUN_Descricao
	FROM Classif_Unidades INNER JOIN Unidades ON CLUN_CodUnid = Und_Codigo
	INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
	WHERE CLUN_Pontuacao Is Not Null and (CLUN_DTAvaliacao Between #dtini# And #dtfim#)
	GROUP BY Und_CodDiretoria, Und_TipoUnidade, TUN_Descricao
	HAVING Und_CodDiretoria = '#se#'
</cfquery>
<cfinclude template="cabecalho.cfm">
<form name="form1" method="post" onSubmit="return validaForm()">
<input name="dtlimit" type="hidden" value="<cfoutput>#dtlimit#</cfoutput>">
<!--- Criação do arquivo CSV --->
<cfoutput>
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivoxls = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
<!---  --->
<!--- <cfquery datasource="#dsn_inspecao#" name="rsXLS">
	SELECT INP_Unidade, Und_CodDiretoria, Und_TipoUnidade, CLUN_Inspecao, CLUN_SiglaSE, CLUN_NomeUnidade, CLUN_Pontuacao, CLUN_PontuacaoMax, CLUN_TXNConforme, CLUN_Classificacao, CLUN_QtdConformes, CLUN_QtdNConformes, CLUN_TotalPontos, convert(char,CLUN_DTAvaliacao,103) as CLUNDTAvaliacao
	FROM (Classif_Unidades INNER JOIN Inspecao ON CLUN_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo
	WHERE Und_CodDiretoria = '#se#' 
	order by CLUN_DTAvaliacao, Und_CodDiretoria, Und_TipoUnidade
</cfquery> --->
<cfquery datasource="#dsn_inspecao#" name="rsXLS">
   SELECT CLUN_CodUnid, Und_CodDiretoria, Und_TipoUnidade, CLUN_Inspecao, CLUN_SiglaSE, CLUN_NomeUnidade, CLUN_Pontuacao, CLUN_PontuacaoMax, CLUN_TXNConforme, CLUN_Classificacao, CLUN_QtdConformes, CLUN_QtdNConformes, CLUN_TotalPontos, convert(char,CLUN_DTAvaliacao,103) as CLUNDTAvaliacao
	FROM (Classif_Unidades INNER JOIN Unidades ON CLUN_CodUnid = Und_Codigo) 
	WHERE Und_CodDiretoria = '#se#' and (CLUN_DTAvaliacao Between #dtini# And #dtfim#)
	order by CLUN_DTAvaliacao, Und_CodDiretoria, Und_TipoUnidade
</cfquery>	
<cfdirectory name="qList" filter="*.xls" sort="name desc" directory="#slocal#">
  	<cfloop query="qList">
		   <cfif len(name) eq 23>
			<cfif (left(name,8) lt left(sdata,8))>
			  <cffile action="delete" file="#slocal##name#">
			</cfif>
		  </cfif>
	</cfloop>

<cfif Month(Now()) eq 1>
  <cfset vANO = Year(Now()) - 1>
<cfelse>
  <cfset vANO = Year(Now())>
</cfif>

<cfset objPOI = CreateObject(
    "component",
    "Excel"
    ).Init()
    />

<cfset data = now() - 1>
	 <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & sarquivoxls ),
    Query = rsXLS,            
	ColumnList = "CLUN_SiglaSE,CLUN_NomeUnidade,CLUN_Inspecao,CLUN_Classificacao,CLUN_Pontuacao,CLUN_PontuacaoMax,CLUN_TXNConforme,CLUN_QtdConformes,CLUN_QtdNConformes,CLUN_TotalPontos,CLUNDTAvaliacao",
	ColumnNames = "SE,Descrição Unidade,Nº Relatório,Classificação,Pontuação da Unidade,Soma de Pontuação Max da Unidade,% Taxa de Não Conformidade,Itens Conforme,Itens Não Conforme,Qtde Total de Itens,Dt. Avaliação",
	SheetName = "ClassificUnidades"
    ) />
</cfoutput>	
<!---  --->
<div align="center">
<!--- 	<cfif isDefined("Form.tpunid") and Form.tpunid neq "">
	 <tr>
      <td colspan="8" class="titulo1"><cfinclude template="cabecalho.cfm"></td>
    </tr>
	</cfif> --->
  <table width="65%" height="45" border="0" class="exibir">

    <tr>
      <td colspan="12">&nbsp;</td>
    </tr>
      <tr>
        <td colspan="12"><div align="center" class="titulo1"><cfoutput>#auxfiltro#</cfoutput></div></td>
      </tr>
      <tr>
        <td colspan="12"><div align="right"><a href="Fechamento/<cfoutput>#sarquivoxls#</cfoutput>"><img src="icones/excel.jpg" width="50" height="22" border="0"></a></div></td>
      </tr>
      <tr>
      <td colspan="12" class="titulo1"><div align="center">Tipos Unidades</div></td>
      </tr>	  

      <td colspan="12"><table width="1225" border="0">
<!---         <tr>
          <td><span class="titulo1">SE: <cfoutput>#se# - #rsSiglaSE.Dir_Sigla#</cfoutput></span></div></td>
          </tr> --->
      </table></td>
      <tr>
        <td colspan="12" class="titulos"><hr></td>
    </tr>
    <tr>
      <td colspan="12">
<!--- 	   <table width="99%" border="0" class="exibir">
	   <tr>
	   <td colspan="13" class="titulos">Filtrar por:</td>
	   </tr>
	   <tr>
	  <cfoutput query="rsTipoUnid">
       <td><div align="center">
	  <cfset ntam = len(#trim(TUN_Descricao)#)>
	  <cfset ntam = 20 - ntam>
	  <cfset strnome = RepeatString(" ", ntam / 2) & trim(TUN_Descricao) & RepeatString(" ", ntam / 2)>
	    <div align="left">
	      <input name="#Und_TipoUnidade#" type="button" class="exibir" onClick="document.form1.acao.value='Filtro'; document.form1.tpunid.value=this.name; validaForm()" value="#strnome#">
	      </div>
	  </div>
	  </td>
	  </cfoutput>  
	  </tr>
	  </table>  --->
 <table width="95%" border="0" class="exibir">
	 
	   
	   <tr>
	   <td colspan="8" class="titulos">Filtrar por:</td>
	   </tr>
	   <cfset qtdcol = 0>
	   <tr>
	  <cfoutput query="rsTipoUnid">
       
	  <cfset ntam = len(#trim(TUN_Descricao)#)>
	  <cfset ntam = 14 - ntam>
	  <!--- <cfset strnome = RepeatString(" ", ntam / 2) & trim(TUN_Descricao) & RepeatString(" ", ntam / 2)> --->
	  
	  <cfset strnome = RepeatString(" ", ntam / 2) & left(trim(TUN_Descricao),14) & RepeatString(" ", ntam / 2)>
	  <cfif qtdcol gte 10>
		  <tr> 
		  </tr> 
		  <cfset qtdcol = 0>
	  </cfif>
		 <td><div align="center">
	    <div align="left">
	      <input name="#Und_TipoUnidade#" type="button" class="exibir" onClick="document.form1.acao.value='Filtro'; document.form1.tpunid.value=this.name; validaForm()" value="#strnome#">
	      </div>
	    </div>
	  </td>
	  
	  <cfset qtdcol = qtdcol + 1>
	  </cfoutput>
	  </tr>
	  </table> 	  
	  </td>
    </tr>

	<cfif isDefined("Form.tpunid") and Form.tpunid neq "">
<!--- 	  <cfquery datasource="#dsn_inspecao#" name="qUnidade">
	SELECT INP_Unidade, Und_CodDiretoria, Und_TipoUnidade, CLUN_Inspecao, CLUN_SiglaSE, CLUN_NomeUnidade, CLUN_Pontuacao, CLUN_PontuacaoMax, CLUN_TXNConforme, CLUN_Classificacao, CLUN_QtdConformes, CLUN_QtdNConformes, CLUN_TotalPontos, CLUN_DTAvaliacao
	FROM (Classif_Unidades INNER JOIN Inspecao ON CLUN_Inspecao = INP_NumInspecao) INNER JOIN Unidades ON INP_Unidade = Und_Codigo
	WHERE Und_CodDiretoria = '#se#' AND Und_TipoUnidade = #Form.tpunid#
	order by CLUN_DTAvaliacao, Und_CodDiretoria, Und_TipoUnidade
      </cfquery> --->
	  <cfquery datasource="#dsn_inspecao#" name="qUnidade">
	SELECT CLUN_CodUnid, Und_CodDiretoria, Und_TipoUnidade, CLUN_Inspecao, CLUN_SiglaSE, CLUN_NomeUnidade, CLUN_Pontuacao, CLUN_PontuacaoMax, CLUN_TXNConforme, CLUN_Classificacao, CLUN_QtdConformes, CLUN_QtdNConformes, CLUN_TotalPontos, CLUN_DTAvaliacao
	FROM (Classif_Unidades INNER JOIN Unidades ON CLUN_CodUnid = Und_Codigo)
	WHERE Und_CodDiretoria = '#se#' AND Und_TipoUnidade = #Form.tpunid# and (CLUN_DTAvaliacao Between #dtini# And #dtfim#)
	order by CLUN_DTAvaliacao, Und_CodDiretoria, Und_TipoUnidade
      </cfquery>

        <tr>
          <td colspan="12"><hr></td>
        </tr>
      <tr>
        <td colspan="12"><div align="right"><a href="Fechamento/<cfoutput><!--- #sarquivo# ---></cfoutput>"><!--- <img src="icones/excel.jpg" width="50" height="22" border="0"> ---></a></div></td>
      </tr>
      <tr>
        <td colspan="12"><div align="center" class="exibir"><span class="titulo1"><strong>Efic&Aacute;cia de Controle Interno das Unidades Operacionais (EFCI)</strong> </span></div></td>
      </tr>
        <tr>
          <td colspan="12"><hr></td>
        </tr>
<tr bgcolor="#CECED1" class="exibir">
	    <td width="40" height="27" class="titulos style1"><div align="center">SE</div>
        <div align="center"></div></td>
        <td width="260" class="titulos"><div align="center"><strong>Descri&ccedil;&atilde;o Unidade </strong></div></td>
        <td width="103" class="titulos"><div align="center"><strong>N&ordm; Relat&oacute;rio </strong></div></td>
		<td width="131" class="titulos"><div align="left"><strong>Classifica&ccedil;&atilde;o</strong></div></td>
         <td width="105" class="exibir"><div align="center"><strong><em>Pontua&ccedil;&atilde;o da Unidade </em></strong></div></td>
        <td width="128" class="exibir"><div align="center"><strong><em>Soma de Pontua&ccedil;&atilde;o Max da Unidade </em></strong></div></td>
        <td width="77" class="exibir"><div align="center"><strong><em>% Taxa de N&atilde;o Conformidade</em></strong></div></td>
        <td width="128" class="exibir"><div align="center"><strong>Itens Conforme </strong></div></td>
        <td width="135" class="exibir"><div align="center"><strong>Itens N&atilde;o Conforme </strong></div></td>
        <td width="69" class="exibir"><div align="center"><strong>Qtde Total de Itens </strong></div></td>
        <td width="59" class="titulos style2"><div align="center">Dt. Avalia&ccedil;&atilde;o 
        </div>
        <div align="center"></div>          <div align="center"></div>        <div align="center"></div></td>
        <!---         <td width="7%" class="titulos"><div align="center">Prazo</div></td> --->
      </tr>
<!--- 	<tr>
      <td colspan="8">&nbsp;</td>
      </tr> --->
<cfset scor = "FFFFFF">
<cfoutput query="qUnidade">	  
 <!---  --->
<tr bgcolor="#scor#" class="exibir">
	    <cfset colse = CLUN_SiglaSE>
	    <td><div align="center">#colse#</div></td>
	    <td><span class="style1">#CLUN_NomeUnidade#</span></td>
	    <td><div align="center"><span class="style1">#CLUN_Inspecao#</span></div></td>
	    <td><div align="left">#CLUN_Classificacao#</div></td>
	   <td><div align="center">#CLUN_Pontuacao#</div></td>
	    <td><div align="center">#CLUN_PontuacaoMax#</div></td>
		<cfset colmax = numberFormat((CLUN_TXNConforme * 100),'__.0')>
		<td><div align="center">#colmax#</div></td>
	    <!--- <td><div align="center">#left((CLUN_TXNConforme * 100),4)#</div></td> --->
		<td><div align="center">#CLUN_QtdConformes#</div></td>
		<td><div align="center">#CLUN_QtdNConformes#</div></td>
		<cfset pontos = CLUN_TotalPontos>
		<td><div align="center">#pontos#</div></td> 
		<cfset dtaval = dateformat(CLUN_DTAvaliacao,"dd/mm/yyyy")> 
	    <td><div align="center">#dtaval#</div></td>
</tr>	
<!---  --->
  <cfif scor eq "FFFFFF">
  	<cfset scor = "CECED1">
  <cfelse>
   	<cfset scor = "FFFFFF">
  </cfif>
    </cfoutput>
    <tr>
      <td colspan="11">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="11"><table width="407" align="center">
        <tr bgcolor="#CCCCCC" class="titulos">
          <td width="202" class="titulosClaros"><div align="center"><strong>Taxa de N&atilde;o Conformidade (TNC) </strong></div></td>
          <td width="193"><div align="center"><strong>Classifica&ccedil;&atilde;o</strong></div></td>
        </tr>
        <tr>
          <td bgcolor="#FF4242" class="titulos"><div align="center">TNC &gt; 50%</div></td>
          <td class="titulos"><div align="center">Controle ineficaz.</div></td>
        </tr>
        <tr>
          <td bgcolor="#FF9966" class="titulos"><div align="center">20% &lt; TNC &lt;= 50%</div></td>
          <td class="titulos"><div align="center">Controle pouco eficaz.</div></td>
        </tr>
        <tr>
          <td bgcolor="#FFFF00" class="titulos"><div align="center">10% &lt; TNC &lt;= 20%</div></td>
          <td class="titulos"><div align="center">Controle de efic&aacute;cia mediana. </div></td>
        </tr>
        <tr>
          <td bgcolor="#009900" class="titulos"><div align="center">5% &lt; TNC &lt;= 10%</div></td>
          <td class="titulos"><div align="center">Controle eficaz. </div></td>
        </tr>
        <tr>
          <td bgcolor="#0066FF" class="titulos"><div align="center">TNC &lt;= 5%</div></td>
          <td class="titulos"><div align="center">Controle plenamente eficaz. </div></td>
        </tr>
      </table></td>
      </tr> 
	      <tr>
      <td colspan="11">&nbsp;</td>
    </tr>
<!--- <td width="241"></tr> --->

<cfelse>
	  <tr>
	    <td colspan="11">&nbsp;</td>
	    </tr>
	  <tr>
	    <td colspan="11">&nbsp;</td>
      </tr>

	  <tr bgcolor="#FFB546">
      <td colspan="8"><div align="center" class="texto_help">
          <label><strong>Selecione o tipo de unidade.</strong></label>
      </div></td>
     </tr>
	</cfif>
 </table>
</div>
<cfquery name="rsMetas" datasource="#dsn_inspecao#">
	SELECT Met_EFCI
	FROM Metas
	WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)#
</cfquery>
<cfset auxRazao = (rsMetas.Met_EFCI/12)>
<!--- Criação do arquivo CSV --->
<!--- <cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'> --->
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>
<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
<cffile action="Append" file="#slocal##sarquivo#" output='#auxfiltro#'>
<cffile action="Append" file="#slocal##sarquivo#" output='EFICÁCIA DE CONTROLE INTERNO DAS UNIDADES OPERACIONAIS (EFCI)'>
<cffile action="Append" file="#slocal##sarquivo#" output=';;;;Meta Anual:(#rsMetas.Met_EFCI#)'>
<cffile action="Append" file="#slocal##sarquivo#" output=';;;Classificação obtida na avaliação;;Total;%;;;'>
<cffile action="Append" file="#slocal##sarquivo#" output='SE;Mês;Avaliado no Mês;Avaliado Acumulativo;Plenamente Eficaz(PE);Eficaz(E);PE + E(por mês);PE + E(mês);Distribuição Meta Acumulativa Mensal;Resultado Acumulado(%);Resultado em relação à meta;Resultado'>

<table width="67%" border="1" align="center" cellpadding="0" cellspacing="0">
<!---   <tr>
    <td colspan="22" class="exibir"><div align="center"><strong>RESUMO CONSOLIDADO DOS MESES &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Exerc&iacute;cio: #anoexerc# </strong></div></td>
  </tr> --->
  <tr>
  <td colspan="25" class="exibir">
  	  <table width="100%" border="0">
        <tr>
          <td width="94%" bgcolor="#FFFFCA" onClick="window.open('abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Relevancia_Itens_Verificacao.PDF','_blank')"><a href="#">
            <div class="titulo2"><strong>Clique aqui - Pontua&Ccedil;&Atilde;o de Relev&Acirc;ncia dos Itens de Verifica&Ccedil;&Atilde;o</strong></div>
          </a></td>
          <td width="6%"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="35" height="40" border="0"></a></div></td>
        </tr>
      </table>
	</td>
</tr>
  <tr>
    <td colspan="25" class="titulos"><div align="center"><span class="exibir"><span class="titulo1"><strong>Efic&Aacute;cia de Controle Interno das Unidades Operacionais (EFCI)</strong></span></span></div></td>
  </tr>
  <tr>
    <td colspan="25" class="titulos">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="25" class="titulos"><div align="center">Meta Anual : (<cfoutput>#rsMetas.Met_EFCI#</cfoutput>%)</div></td>
  </tr>
  <tr>
    <td colspan="25" class="exibir">&nbsp;</td>
  </tr>
 <!---   <tr>
    <td class="exibir"><div align="center">A</div></td>
    <td class="exibir"><div align="center">B</div></td>
    <td class="exibir"><div align="center">C</div></td>
    <td class="exibir"><div align="center">D = (D + C) </div></td>
    <td class="exibir"><div align="center">E</div></td>
    <td class="exibir"><div align="center">F</div></td>
    <td class="exibir"><div align="center">G = (E + F)</div></td>
    <td class="exibir"><div align="center">H = (G/C)*100 </div></td>
    <td class="exibir"><div align="center">I</div></td>
    <td class="exibir"><div align="center">J = (soma(G1..Gla)/D)*100 </div></td>
    <td width="8%" colspan="14" class="exibir"><div align="center">K (entre J e I) </div></td>
    </tr>  --->
  <tr class="exibir">
    <td colspan="14"><div align="center"></div>      <div align="center"></div>        <div align="center"></div></td>
	<!--- <cfset totgeral = rsitem.recordcount> --->
    </tr>

  <tr align="center" valign="middle" class="exibir">
    <td width="4%" rowspan="3"><div align="center"><strong>SE</strong></div></td>
    <td width="6%" rowspan="3"><strong>M&ecirc;s</strong></td>
    <td width="7%" rowspan="2" class="exibir"><div align="center"><strong>Avaliado no M&ecirc;s</strong></div>      
      <div align="center"></div>      <div align="center"></div></td>
    <td width="9%" rowspan="2" class="exibir"><div align="center"><strong>Avaliado Acumulativo </strong></div></td>
    <td colspan="2" class="exibir"><div align="center"></div>      
      <div align="center"><strong> Classifica&ccedil;&atilde;o obtida na Avalia&ccedil;&atilde;o &nbsp;&nbsp;&nbsp; </strong> </div></td>
    <td width="7%" class="exibir"><div align="center"><strong>Total </strong> </div></td>
    <td width="7%" class="exibir"><div align="center"><strong>% </strong> </div></td>
    <td width="10%" rowspan="2" class="exibir"><div align="center"><strong> </strong>
      <DIV align=center><STRONG>Distribui&ccedil;&atilde;o Meta Acumulativa Mensal</STRONG> </DIV> 
      </div></td>
    <td width="9%" rowspan="2" class="exibir"><div align="center"><strong> Resultado Acumulado (%) </strong></div></td>
    <td width="11%" rowspan="2" class="exibir style3"><div align="center"></div>      
      <div align="center">Resultado em rela&ccedil;&atilde;o &agrave; meta (%) </div></td>
    <td width="14%" rowspan="2" class="exibir"><strong>Resultado</strong></td>
  </tr>
  <tr class="exibir">
    <td width="8%" class="exibir"><div align="center"><strong>Plenamente Eficaz (PE) </strong></div></td>
    <td width="8%"><div align="center"><strong> Eficaz (E) </strong></div></td>
    <td width="7%" class="exibir"><div align="center"><strong>PE + E <br>
      (por m&ecirc;s) </strong></div></td>
    <td width="7%"><div align="center"><strong>PE + E <br>
    (por m&ecirc;s) </strong></div></td>
  </tr>
    <tr class="exibir">
    <td colspan="13" class="exibir"><div align="center" class="titulos"></div>      <div align="center" class="titulos"></div>      <div align="center" class="titulos"></div></td>
    </tr>
	<tr class="exibir">
      <td><div align="center">&nbsp;</div></td>
      <td><div align="center">&nbsp;</div></td>
      <td><div align="center">A</div></td>
      <td><div align="center">B</div></td>
      <td><div align="center">C</div></td>
      <td><div align="center">D</div></td>
      <td><div align="center">E = C + D </div></td>
      <td><div align="center">F = E/B </div></td>
      <td><div align="center">G</div></td>
      <td><div align="center">H</div></td>
      <td><div align="center">I = ((H*100)/G)</div></td>
      <td><div align="center">Entre(ColH e ColG)</div></td>
	</tr>
<!---  --->	
<cfoutput>
<cfset aux_mes = 1>
<cfset colA = 0>
<cfset colB = 0>
<cfset colC = 0> 
<cfset colD = 0>
<cfset colE = 0>
<cfset colF = 0>
<cfset colG = 0>
<cfset colH = 0>
<cfset colI = 0>
<cfset colJ = 0>
<cfset Crp = 0>
<cfset Erp = 0>
<cfset Frp = 0>
<cfset Grp = 0>
<cfset Hrp = 0>
<cfset scor = "FFFFFF">

<cfloop condition="#aux_mes# lte int(month(dtlimit))">
        <cfif aux_mes is 1>
		  <cfset colMes = "Jan">
		  <cfset dtini = CreateDate(year(dtlimit),1,1)>
		  <cfset dtfim = CreateDate(year(dtlimit),1,31)>
		<cfelseif aux_mes is 2>
		<cfset colMes = "Fev">	
				<cfif int(year(dtlimit)) mod 4 is 0>
				   <cfset dtfim = CreateDate(year(dtlimit),2,29)>
				<cfelse>
				   <cfset dtfim = CreateDate(year(dtlimit),2,28)>
				</cfif>
		        <cfset dtini = CreateDate(year(dtlimit),2,1)>				
		<cfelseif aux_mes is 3>
		       <cfset dtini = CreateDate(year(dtlimit),3,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),3,31)>
			   <cfset colMes = "Mar">	
		<cfelseif aux_mes is 4>
		       <cfset dtini = CreateDate(year(dtlimit),4,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),4,30)>
			   <cfset colMes = "Abr">		
		<cfelseif aux_mes is 5>
		       <cfset dtini = CreateDate(year(dtlimit),5,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),5,31)>	
			   <cfset colMes = "Mai">	
		<cfelseif aux_mes is 6>
		       <cfset dtini = CreateDate(year(dtlimit),6,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),6,30)>		
			   <cfset colMes = "Jun">
		<cfelseif aux_mes is 7>
		       <cfset dtini = CreateDate(year(dtlimit),7,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),7,31)>
			   <cfset colMes = "Jul">		
		<cfelseif aux_mes is 8>
		       <cfset colMes = "Ago">
		       <cfset dtini = CreateDate(year(dtlimit),8,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),8,31)>		
		<cfelseif aux_mes is 9>
		       <cfset colMes = "Set">
		       <cfset dtini = CreateDate(year(dtlimit),9,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),9,30)>		
		<cfelseif aux_mes is 10>
		       <cfset dtini = CreateDate(year(dtlimit),10,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),10,31)>
			   <cfset colMes = "Out">		
		<cfelseif aux_mes is 11>
		       <cfset dtini = CreateDate(year(dtlimit),11,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),11,30)>	
			   <cfset colMes = "Nov">	
		<cfelse>
			   <cfset colMes = "Dez">
		       <cfset dtini = CreateDate(year(dtlimit),12,1)>		
			   <cfset dtfim = CreateDate(year(dtlimit),12,31)>		
		</cfif>
<!---  --->
<!--- #dtini# fff #dtfim#mmmm  #se# --->
	<!--- <cfquery name="rsCla" datasource="#dsn_inspecao#">
		SELECT CLUN_Inspecao, CLUN_DTAvaliacao, CLUN_Classificacao
		FROM (Classif_Unidades 
		INNER JOIN Inspecao ON CLUN_Inspecao = INP_NumInspecao) 
		INNER JOIN Unidades ON INP_Unidade = Und_Codigo
		WHERE (CLUN_DTAvaliacao Between #dtini# And #dtfim#) AND Und_CodDiretoria = '#se#'
	</cfquery> --->
<cfquery name="rsCla" datasource="#dsn_inspecao#">
SELECT CLUN_Inspecao, CLUN_DTAvaliacao, CLUN_Classificacao 
FROM (Classif_Unidades INNER JOIN Unidades ON CLUN_CodUnid = Und_Codigo) 
WHERE (CLUN_DTAvaliacao Between #dtini# And #dtfim#) AND Und_CodDiretoria = '#se#'
	</cfquery>	
<!--- 	SELECT CLUN_Inspecao, CLUN_DTAvaliacao, CLUN_Classificacao
		FROM (Classif_Unidades 
		INNER JOIN Inspecao ON CLUN_Inspecao = INP_NumInspecao) 
		INNER JOIN Unidades ON INP_Unidade = Und_Codigo
		WHERE (CLUN_DTAvaliacao Between #dtini# And #dtfim#) AND Und_CodDiretoria = '#se#' <br> --->
<!--- INP_Unidade, Und_CodDiretoria, Und_TipoUnidade, CLUN_Inspecao, CLUN_SiglaSE, CLUN_NomeUnidade, CLUN_Pontuacao, CLUN_PontuacaoMax, CLUN_TXNConforme, , CLUN_QtdConformes, CLUN_QtdNConformes, CLUN_TotalPontos, CLUN_DTAvaliacao	 --->
    <cfset scor = "FFFFFF">
	<!--- <cfoutput>colA#colA#   colB#colB#</cfoutput> --->
	<cfif rsCla.recordcount lte 0>
		<cfset colA = 0>
		<cfset colB = colB + colA>
		<cfset colC = 0>
		<cfset colD = 0>
		<cfset colE = 0>
		<cfset colF = 0>
		<!--- <cfset colH = numberFormat((Grp/colB) * 100,'__.0')> --->
		<cfset colG = numberFormat(aux_mes * auxRazao,'__.0')>
		<cfif colH gt colG>
			<cfset colJ = "ACIMA DO ESPERADO">
			<cfset scor = "##33CCFF">
		<cfelseif colH eq colG>		
		   <!---  #colF# eq #colG#<br>	 --->	
			<cfset colJ = "DENTRO DO ESPERADO">
			<cfset scor = "##339900">
		<cfelse>
		  <!---   #colF# lt #colG#<br>	 --->	
			<cfset colJ = "ABAIXO DO ESPERADO">
			<cfset scor = "##FF3300">
		</cfif>
	<cfelse>  
	    <cfset colC = 0>
		<cfset colD = 0> 
	    <cfloop query="rsCla">
		   <cfif left(trim(CLUN_Classificacao),1) eq 1>
		      <cfset colC = colC + 1>
		   <cfelseif left(trim(CLUN_Classificacao),1) eq 2>
		      <cfset colD = colD + 1>
		   </cfif>
		</cfloop>
		<cfset colA = rsCla.recordcount>
		<cfset Crp = Crp + colA>
		
		<cfset Erp = Erp + colC>
		<cfset Frp = Frp + colD>
		
		<cfset colB = colB + colA>
		<cfset colE = (colC + colD)>
		<!--- <cfif colE is 0><cfset colE = 0></cfif> --->
		<cfset Grp = Grp + colE>
		
		<cfset colF = numberFormat(((colE/colA) * 100),'__.0')>	
		<!--- <cfset Hrp = Hrp + colF> --->
		<cfset colH = numberFormat((Grp/colB) * 100,'__.0')>
		<!--- <cfset colH = numberFormat(colH + ((colE/colB) * 100),'__.0')> --->
	    <cfset colG = numberFormat(aux_mes * auxRazao,'__.0')>
		<!--- colH:#colH# colG:#colG#<br> --->
		<cfif colH gt colG>
			<cfset colJ = "ACIMA DO ESPERADO">
			<cfset scor = "##33CCFF">
		<cfelseif colH eq colG>		
		   <!---  #colF# eq #colG#<br>	 --->	
			<cfset colJ = "DENTRO DO ESPERADO">
			<cfset scor = "##339900">
		<cfelse>
		  <!---   #colF# lt #colG#<br>	 --->	
			<cfset colJ = "ABAIXO DO ESPERADO">
			<cfset scor = "##FF3300">
		</cfif>	

    </cfif>	
    
    <tr class="exibir">
    <td><div align="center">#sg#</div></td>
	<td><div align="center">#colMes#</div></td>
    <td><div align="center">#colA#</div></td>
    <td><div align="center">#colB#</div></td>
    <td><div align="center">#colC#</div></td>
	<td><div align="center">#colD#</div></td>
    <td><div align="center">#colE#</div></td>
	<!--- <cfset colF = numberFormat(colF,'__.0')> --->
    <td><div align="center">#colF#</div></td>
    <cfset colG = numberFormat(aux_mes * auxRazao,'__.0')> 
    <td><div align="center">#colG#</div></td>
	<!--- <cfif colH is 0>
		<cfset colH2 = 0>
	<cfelse>
		<cfset colH2 = ColH>	
	</cfif> --->
    <td><div align="center">#colH#</div></td>
 	<cfset colI = numberFormat(((colH * 100)/ColG),'__.0')>	
    <td><div align="center">#colI#</div></td>
    <td bgcolor="#scor#"><div align="center">#colJ#</div></td>
    </tr>
	 <cfset aux_mes = aux_mes + 1>
	 <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;#colMes#;#colA#;#colB#;#colC#;#colD#;#colE#;#colF#;#colG#;#colH#;#colI#;#colJ#'>
 </cfloop> 
 <cfif Crp eq 0> 
	<cfset Hrp = 0>
 <cfelse> 
	<cfset Hrp = numberFormat(((Grp / Crp) * 100),'__.0')>	 
</cfif>
  
  <tr class="red_titulo">
    <td><div align="center">#sg#</div></td>
	<td><div align="center">Geral</div></td>
	<td><div align="center">#Crp#</div></td>
	<td><div align="center">&nbsp;</div></td>
	<td><div align="center">#Erp#</div></td>
    <td><div align="center">#Frp#</div></td>
    <td><div align="center">#Grp#</div></td>
    <td><div align="center">#Hrp#</div></td>
    <td><div align="center">&nbsp;</div></td>
    <td><div align="center">&nbsp;</div></td>
	<td colspan="2"><div align="center">&nbsp;</div></td>
  </tr>
  <cfif scor eq "FFFFFF">
  	<cfset scor = "CECED1">
  <cfelse>
   	<cfset scor = "FFFFFF">
  </cfif>
	 <cffile action="Append" file="#slocal##sarquivo#" output='#sg#;Geral;#Crp#;;#Erp#;#Frp#;#Grp#;#Hrp#;;;'>  
</cfoutput>
<!---   <cfquery datasource="#dsn_inspecao#">
   UPDATE Metas SET Met_EFCI_Acum = '#Hrp#' WHERE Met_Codigo='#se#' and Met_Ano = #year(dtlimit)#
  </cfquery> --->
  <tr class="exibir">
    <td colspan="14">Legenda:</td>
  </tr>
  <tr class="exibir">
    <td colspan="14"> A = Total de unidades avaliadas no m&ecirc;s</td>
  </tr>
  <tr class="exibir">
    <td colspan="14">B = Total geral de unidades avaliadas nos per&iacute;odos (A1+A2+A3+A4....) </td>
  </tr>
  <tr class="exibir">
    <td colspan="14"> H (Resultado Acumulado (%)) = Total PE + E acumulado at&eacute; per&iacute;odo de refer&ecirc;ncia (E1+E2+E3+...)/Avaliado Acumulativo do per&iacute;odo (B)</td>
  </tr> 
<cffile action="Append" file="#slocal##sarquivo#" output='Legenda:'> 
<cffile action="Append" file="#slocal##sarquivo#" output='* Meses sem resultado = não houve avaliação no período '>  
<cffile action="Append" file="#slocal##sarquivo#" output='** Resultado Acumulado = Total PE + E acumulado até período de referência/Total Avaliado no Período'>  
 </table>
     <input name="tpunid" id="tpunid" type="hidden" value="">
	 <input name="codigo" id="codigo" type="hidden"value="">
	 <input name="acao" id="acao" type="hidden"value="">
	 <input name="se" type="hidden" value="<cfoutput>#se#</cfoutput>">
	 <input name="dtini" type="hidden" value="<cfoutput>#dtini#</cfoutput>">
	 <input name="dtfim" type="hidden" value="<cfoutput>#dtfim#</cfoutput>">
</form>
<form name="formvolta" method="post" action="">
  <input name="sacao" type="hidden" id="sacao" value="voltar">
  <input name="se" type="hidden" value="<cfoutput>#se#</cfoutput>">
</form>

</body>
</html>
