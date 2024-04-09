<cfprocessingdirective pageEncoding ="utf-8"/>
<!---  <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  --->    

	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao
		FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
		WHERE Usu_DR = '#form.se#'
	</cfquery>

	<cfquery name="rsUnidativ" datasource="#dsn_inspecao#">
	SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar, TUN_Descricao, INP_NumInspecao, INP_Modalidade, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Responsavel, INP_Situacao, Dir_Sigla
	FROM Unidades 
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
	INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
	INNER JOIN Inspecao ON Und_Codigo = INP_Unidade 
	WHERE 
	<cfif form.se neq 'Todos' or form.frmtipounid neq 'Todas' or trim(form.frmano) neq 'Todos'>
		 <cfif form.se neq 'Todos'>
			 Und_CodDiretoria = '#form.se#' and
		 </cfif>
		<cfif form.frmtipounid neq 'Todas'>
	 	    Und_TipoUnidade= #form.frmtipounid# and
		 </cfif>			
		<cfif trim(form.frmano) neq 'Todos'>
		    <!--- INP_NumInspecao Like '%#form.frmano#' and --->
			right(INP_NumInspecao,4) = '#form.frmano#' and
		</cfif>
	</cfif>
	Und_Status = 'A' and INP_Situacao <> 'CO'
	<cfif form.se eq 'Todos' and form.grupoacesso eq 'GESTORES'>
		and Und_CodDiretoria in(#form.usucoordena#)
	</cfif>
	ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao, INP_NumInspecao
	</cfquery>

	<cfquery name="rsUnidade" datasource="#dsn_inspecao#">
	SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar, TUN_Descricao, 
	INP_NumInspecao, INP_Modalidade, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Responsavel, Dir_Sigla
	FROM Unidades 
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
	INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
	INNER JOIN Inspecao ON Und_Codigo = INP_Unidade 
	WHERE 
	<cfif form.se neq 'Todos' or form.frmtipounid neq 'Todas' or trim(form.frmano) neq 'Todos'>
		 <cfif form.se neq 'Todos'>
			 Und_CodDiretoria = '#form.se#' and
		 </cfif>
		<cfif form.frmtipounid neq 'Todas'>
	 	    Und_TipoUnidade= #form.frmtipounid# and
		 </cfif>			
		<cfif trim(form.frmano) neq 'Todos'>
		    <!--- INP_NumInspecao Like '%#form.frmano#' and --->
			right(INP_NumInspecao,4) = '#form.frmano#' and
		</cfif>
	</cfif>
	Und_Status = 'A' and INP_Situacao = 'CO'
	<cfif form.se eq 'Todos' and form.grupoacesso eq 'GESTORES'>
		and Und_CodDiretoria in(#form.usucoordena#)
	</cfif>
	ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao, INP_NumInspecao
	</cfquery>
<cfoutput>	
<cfif form.grupoacesso is 'GESTORMASTER'>
	<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
	<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
	<cfset slocal = #diretorio# & 'Fechamento\'>
	<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #form.usumatricula# & '.csv'>
	
	
	<!--- Excluir arquivos anteriores ao dia atual --->
	<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
	<cfloop query="qList">
		<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq form.usumatricula)>
		  <cffile action="delete" file="#slocal##name#">
		</cfif>
	</cfloop>
	
 	<!--- gerar arquivo .csv --->
	<cfquery name="rsCSV" datasource="#dsn_inspecao#">
		SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade, Dir_Sigla, TUN_Descricao, Und_NomeGerente, convert(varchar,Und_Codigo,103) as unid  
		FROM Unidades 
		INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
		INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
		INNER JOIN Inspecao ON Und_Codigo = INP_Unidade 
		WHERE 
		 <cfif form.se neq 'Todos'>
			 Und_CodDiretoria = '#form.se#' and
		 </cfif>
		 <cfif form.frmtipounid neq 'Todas'>
	 	    Und_TipoUnidade= #form.frmtipounid# and
		 </cfif>
		 <cfif trim(form.frmano) neq 'Todos'>
			right(INP_NumInspecao,4) = '#form.frmano#' and
		</cfif>
		Und_Status = 'A'
		ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao
	</cfquery> 

   <cfif rsCSV.recordcount gt 0>		
	<cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
 	<cffile action="Append" file="#slocal##sarquivo#" output='UNIDADES ATIVAS PARA CADASTRO DE AVALIAÇÕES'>
	<cffile action="Append" file="#slocal##sarquivo#" output='SE;SIGLA;UNIDADE;DESCRIÇÃO UNIDADE;COD_TIPO;DESCRIÇÃO TIPO;GESTOR DA UNIDADE;EXEC_2018;EXEC_2019;EXEC_2020;EXEC_2021;EXEC_2022;EXEC_2023'>

	<cfloop query="rsCSV">
	<!---  --->
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#rsCSV.Und_Codigo#'
				ORDER BY Right(INP_NumInspecao,4)
			</cfquery>

            <cfset auxano2018 = ''>
			<cfset auxano2019 = ''>
			<cfset auxano2020 = ''>
			<cfset auxano2021 = ''>
			<cfset auxano2022 = ''>
			<cfset auxano2023 = ''>
			<cfset auxano2024 = ''>
			<cfset auxano2025 = ''>
			
			<cfloop query="rsAval">
			   <cfif #rsAval.ano# eq 2018><cfset auxano2018 = 2018></cfif>
			   <cfif #rsAval.ano# eq 2019><cfset auxano2019 = 2019></cfif>
			   <cfif #rsAval.ano# eq 2020><cfset auxano2020 = 2020></cfif>
			   <cfif #rsAval.ano# eq 2021><cfset auxano2021 = 2021></cfif>
			   <cfif #rsAval.ano# eq 2022><cfset auxano2022 = 2022></cfif>
			   <cfif #rsAval.ano# eq 2023><cfset auxano2023 = 2023></cfif>
			   <cfif #rsAval.ano# eq 2024><cfset auxano2024 = 2024></cfif>
			   <cfif #rsAval.ano# eq 2025><cfset auxano2025 = 2025></cfif>
			</cfloop>	
		
		<cffile action="Append" file="#slocal##sarquivo#" output="'#left(unid,2)#;#Dir_Sigla#;#unid#;#Und_Descricao#;#Und_TipoUnidade#;#TUN_Descricao#;#Und_NomeGerente#;#auxano2018#;#auxano2019#;#auxano2020#;#auxano2021#;#auxano2022#;#auxano2023#"> 
	</cfloop>
   </cfif>	
</cfif>
</cfoutput>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">

<script language="JavaScript" type="text/JavaScript">
<cfinclude template="mm_menu.js">
</script>
	</head>

<body onLoad="onsubmit="mensagem()">


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="91%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="8" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="8" class="exibir"><div align="center"><span class="titulo2"><strong class="titulo1">UNIDADES</strong> <span class="titulo1">AVALIADAS/A AVALIAR</span></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="8">&nbsp;</td>
          </tr>
	  
          <cfoutput>
            <tr valign="baseline">
              <td width="9%"><div align="left"><span class="titulos">Superintendência:</span></div></td>
              <td width="9%"><div align="left">
                <select name="dr" id="dr" class="form" disabled>
				 <cfif form.se eq 'Todos'>
				 	<option value="Todos" selected="selected">Todos</option>
					<cfset auxdesc = 'Todas SE´s'>
				 <cfelse>
				 <cfset auxsigla = qAcesso.Dir_Sigla>
                  <option selected="selected" value="#qAcesso.Usu_DR#">#auxsigla#</option>
				  <cfset auxdesc = qAcesso.Dir_Descricao>
				 </cfif> 
                </select>
              	</div>				</td>
              <td width="23%" class="exibir"><div align="left"><strong>#auxdesc#</strong></div></td>
              <td width="9%"><div align="right"><span class="titulos">Tipo de Unidade  :</span></div></td>
              <td width="9%"><div align="left">
			     <select name="frmtipounid" id="frmtipounid" class="form" disabled>
				 <cfif form.frmtipounid eq 'Todas'>
				 	<option value="Todas" selected="selected">Todas</option>
					<cfset auxdesctp = 'Todos os Tipos de Unidade'>
				 <cfelse>
				    <cfset auxsigla = rsUnidade.TUN_Descricao>
					<option selected="selected" value="#rsUnidade.Und_TipoUnidade#">#auxsigla#</option>
					<cfset auxdesctp = rsUnidade.TUN_Descricao>
				 </cfif>
                </select>
              </div></td>
              <td width="16%" class="exibir"><div align="left"><strong>#auxdesctp#</strong></div></td>
              <td width="10%"><div align="right"><span class="titulos">Exercício:</span></div></td>
              <td width="15%"><div align="left">
                <select name="frmano" id="frmano" class="form"" disabled>
                  <option value="#frmano#">#frmano#</option>
                </select>
              </div></td>
            </tr>
          </cfoutput>
        </table>
<form action="Pacin_Unidades_Avaliacao.cfm" method="post" target="_parent" name="form1">  
	  <table width="91%" border="0" align="center">
        <tr bgcolor="f7f7f7">
          <td colspan="19" align="center" bgcolor="f7f7f7">
			<cfif form.grupoacesso is 'GESTORMASTER'>
		  		<div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/csv.png" width="45" height="45" border="0"></a></div>
			</cfif>
		  </td>
        </tr>

<!----        --------------------------------- --->
<tr bgcolor="f7f7f7">
			<td colspan="19" align="center" bgcolor="#B4B4B4" class="titulo1">UNIDADES EM CADASTRO DE AVALIAÇÃO/ANDAMENTO/REVISÃO NO EXERCÍCIO DE: <cfoutput>#form.frmano#</cfoutput></td>
		</tr>
        <tr class="titulosClaro">
          <td colspan="25" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsUnidativ.recordcount#</cfoutput></td>
        </tr>
          <tr bgcolor="#CCCCCC" class="titulos">
            <td colspan="2" align="center">SE</td>
            <td align="center"><div align="left">Código</div></td>
            <td width="19%"><div align="left">Descrição</div></td>
            <td width="5%"><div align="left">Tipo</div></td>
            <td width="5%">Avaliação</td>
            <td width="5%">Modal</td>
            <td width="9%">Início Avaliação</td>
            <td width="8%">Final Avaliação</td>
            <td width="10%"><div align="center">Horas Avaliação</div></td>
			<td width="5%"><div align="center">Pontuação</div></td>
            <td width="15%"><div align="left">Gestor da Unidade</div></td>
            <td width="19%">Avaliações realizadas </td>
			<td width="5%">Status</td>
          </tr>
      <cfoutput query="rsUnidativ">
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#Und_Codigo#' 
				ORDER BY Right(INP_NumInspecao,4)
			</cfquery>
			
            <cfset auxano = ''>
			
			<cfloop query="rsAval">
			   <cfset auxano = auxano & ' ' & rsAval.ano>
			</cfloop>
		  	
			<cfset scor = 'f7f7f7'>		
			
			<cfif INP_Modalidade is 0>
			  <cfset modal = 'PRESENCIAL'>
			<cfelseif INP_Modalidade is 1>
			  <cfset modal = 'A DISTÂNICA'>
			<cfelse>
			  <cfset modal = 'MISTA'>			
			</cfif>
			<cfset UndCod = Und_Codigo>
			<cfset UndDesc = Und_Descricao>
			<cfset TUNDesc = TUN_Descricao>
			<cfset INPInsp = INP_NumInspecao>
			<cfset INPDtInic = dateformat(INP_DtInicInspecao,"dd/mm/yyyy")>
			<cfset INPDtFim = dateformat(INP_DtFimInspecao,"dd/mm/yyyy")>
			<cfset INPResp = INP_Responsavel>
						
          <tr bgcolor="#scor#" class="exibir">
            <td width="1%"><div align="left">#left(UndCod,2)#</div></td>
            <td width="2%"><div align="left">#Dir_Sigla#</div></td>
            <td width="2%">#UndCod#</td>
            <td width="10%">#UndDesc#</td>
            <td width="5%">#TUNDesc#</td>
            <td width="5%">#INPInsp#</td>
            <td width="5%">#modal#</td>
            <td width="9%">#INPDtInic#</td>
            <td width="8%">#INPDtFim#</td>
            <td width="10%"><div align="center">#INP_HrsInspecao#</div></td>
			<cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
			<td width="5%"><div align="center">#pontos#</div></td>
            <td width="15%"><div align="left">#INPResp#</div></td>
            <td width="19%">#auxano#</td>
			<td width="5%"><div align="center">#INP_Situacao#</div></td>
			
          </tr>

		  <cfif scor eq 'f7f7f7'>
		    <cfset scor = 'CCCCCC'>
		  <cfelse>
		    <cfset scor = 'f7f7f7'>
		  </cfif>
      </cfoutput>
        <tr bgcolor="f7f7f7">
          <td colspan="19" align="center" class="titulos"><hr></td>
        </tr>
        <tr>
          <td colspan="12">
              <div align="center">
			  <input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
          </div>
             <div align="right"></div></td>
        </tr>
        <tr>
          <td colspan="19" align="center" class="titulos"><hr></td>
        </tr>
<!---    -----------------------------------    --->
		<tr bgcolor="f7f7f7">
			<td colspan="19" align="center" bgcolor="#B4B4B4" class="titulo1">UNIDADES AVALIADAS NO EXERCÍCIO DE: <cfoutput>#form.frmano#</cfoutput></td>
		</tr>
        <tr class="titulosClaro">
          <td colspan="25" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsUnidade.recordcount#</cfoutput></td>
        </tr>
          <tr bgcolor="#CCCCCC" class="titulos">
            <td colspan="2" align="center">SE</td>
            <td align="center"><div align="left">Código</div></td>
            <td width="19%"><div align="left">Descrição</div></td>
            <td width="5%"><div align="left">Tipo</div></td>
            <td width="5%">Avaliação</td>
            <td width="5%">Modal</td>
            <td width="9%">Início Avaliação</td>
            <td width="8%">Final Avaliação</td>
            <td width="10%"><div align="center">Horas Avaliação</div></td>
			<td width="5%"><div align="center">Pontuação</div></td>
            <td width="15%"><div align="left">Gestor da Unidade</div></td>
            <td width="19%">Avaliações realizadas </td>
          </tr>
      <cfoutput query="rsUnidade">
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#Und_Codigo#' 
				ORDER BY Right(INP_NumInspecao,4)
			</cfquery>
			
            <cfset auxano = ''>
			
			<cfloop query="rsAval">
			   <cfset auxano = auxano & ' ' & rsAval.ano>
			</cfloop>
		  	
			<cfset scor = 'f7f7f7'>		
			
			<cfif INP_Modalidade is 0>
			  <cfset modal = 'PRESENCIAL'>
			<cfelseif INP_Modalidade is 1>
			  <cfset modal = 'A DISTÂNICA'>
			<cfelse>
			  <cfset modal = 'MISTA'>			
			</cfif>
			<cfset UndCod = Und_Codigo>
			<cfset UndDesc = Und_Descricao>
			<cfset TUNDesc = TUN_Descricao>
			<cfset INPInsp = INP_NumInspecao>
			<cfset INPDtInic = dateformat(INP_DtInicInspecao,"dd/mm/yyyy")>
			<cfset INPDtFim = dateformat(INP_DtFimInspecao,"dd/mm/yyyy")>
			<cfset INPResp = INP_Responsavel>
						
          <tr bgcolor="#scor#" class="exibir">
            <td width="1%"><div align="left">#left(UndCod,2)#</div></td>
            <td width="2%"><div align="left">#Dir_Sigla#</div></td>
            <td width="2%">#UndCod#</td>
            <td width="10%">#UndDesc#</td>
            <td width="5%">#TUNDesc#</td>
            <td width="5%">#INPInsp#</td>
            <td width="5%">#modal#</td>
            <td width="9%">#INPDtInic#</td>
            <td width="8%">#INPDtFim#</td>
            <td width="10%"><div align="center">#INP_HrsInspecao#</div></td>
			<cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
			<td width="5%"><div align="center">#pontos#</div></td>
            <td width="15%"><div align="left">#INPResp#</div></td>
            <td width="19%">#auxano#</td>
          </tr>

		  <cfif scor eq 'f7f7f7'>
		    <cfset scor = 'CCCCCC'>
		  <cfelse>
		    <cfset scor = 'f7f7f7'>
		  </cfif>
      </cfoutput>
        <tr bgcolor="f7f7f7">
          <td colspan="19" align="center" class="titulos"><hr></td>
        </tr>
        <tr>
          <td colspan="12">
              <div align="center">
			  <input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
          </div>
             <div align="right"></div></td>
        </tr>
        <tr>
          <td colspan="19" align="center" class="titulos"><hr></td>
        </tr>
<cfif form.frmano eq year(now())>
	<cfquery name="rsPRGNOTAval" datasource="#dsn_inspecao#">
		SELECT distinct Und_Codigo, Und_Descricao, Und_TipoUnidade, Und_NomeGerente, TUN_Descricao, Und_CodDiretoria, Und_Ano_Horas_Avaliar, Und_Ano_Pontos_Avaliar, Dir_Sigla
		FROM Unidades 
		INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
		INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
		WHERE
		<cfif form.se neq 'Todos' or form.frmtipounid neq 'Todas' or trim(form.frmano) neq 'Todos'>
			 <cfif form.se neq 'Todos'>
				 Und_CodDiretoria = '#form.se#' and
			 </cfif>
			<cfif form.frmtipounid neq 'Todas'>
				Und_TipoUnidade= '#form.frmtipounid#' and
		  </cfif>			
 			<cfif trim(form.frmano) neq 'Todos'>
				 Und_Ano_Avaliar = '#form.frmano#' and
			</cfif> 
		</cfif>
	    Und_Status = 'A'		
		<cfif form.se eq 'Todos' and form.grupoacesso eq 'GESTORES'>
		and Und_CodDiretoria in(#form.usucoordena#)
		</cfif>
		ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao 
	</cfquery> 

	<cfif rsPRGNOTAval.recordcount gt 0>
		 <tr bgcolor="f7f7f7">
			<td colspan="19" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
		</tr>
		<tr bgcolor="f7f7f7">
			<td colspan="19" align="center" bgcolor="#B4B4B4" class="titulo1">UNIDADES PROGRAMADAS E NÃO AVALIADAS NO EXERCÍCIO DE: <cfoutput>#form.frmano#</cfoutput></td>
		</tr>

		<tr class="titulosClaro">
			<td colspan="25" bgcolor="eeeeee" class="exibir">
		<table width="100%" border="0">
		<tr bgcolor="#CCCCCC" class="titulos">
			<td colspan="2" align="center">SE</td>
			<td align="center"><div align="left">Código</div></td>
			<td width="15%"><div align="left">Descrição</div></td>
			<td width="8%"><div align="left">Tipo</div></td>
			<td width="42%">Gestor da Unidade</td>
			<td width="4%"><div align="center">Horas</div></td>
			<td width="5%"><div align="center">Pontos</div></td>
			<td width="19%"><div align="center">Avaliações realizadas</div></td>
		</tr> 
<cfset auxtotreg = 0>		
<cfoutput query="rsPRGNOTAval">	
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT INP_DtInicInspecao, Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#rsPRGNOTAval.Und_Codigo#'
				ORDER BY Right(INP_NumInspecao,4) 
			</cfquery>
			<cfquery dbtype="query" name="rsExiste">
				SELECT INP_DtInicInspecao, ano
				FROM rsAval
				WHERE ano = '#form.frmano#'
			</cfquery>
            <cfset auxano = ''>
			<cfset listarSN = 'S'>
				
			<cfloop query="rsAval">
			   <cfset auxano = auxano & ' ' & rsAval.ano>
			   <cfif rsAval.ano eq '#form.frmano#'>
			   	<cfset listarSN = 'N'>
			   </cfif>
			</cfloop>	

		  	<cfset scor = 'f7f7f7'>		
<cfif listarSN eq 'S'>
	<cfset auxtotreg = auxtotreg + 1>
          <tr bgcolor="#scor#" class="exibir">
            <td width="1%">#left(Und_Codigo,2)#</td>
            <td width="2%">#Dir_Sigla#</td>
            <td width="2%">#Und_Codigo#</td>
            <td width="10%">#Und_Descricao#</td>
            <td width="8%">#TUN_Descricao#</td>
            <td width="42%">#Und_NomeGerente#</td>
			<cfset horas = Und_Ano_Horas_Avaliar>
            <td width="4%"><div align="center">#horas#</div></td>
			<cfset pontos = numberFormat(Und_Ano_Pontos_Avaliar,99.00)>
            <td width="5%"><div align="center">#pontos#</div></td>
            <td><div align="left">#auxano#</div></td>
            </tr>
            <cfif scor eq 'f7f7f7'>
              <cfset scor = 'CCCCCC'>
              <cfelse>
              <cfset scor = 'f7f7f7'>
            </cfif>	
</cfif>						
	</cfoutput>		
 		<tr class="titulosClaro">
			<td colspan="26" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #auxtotreg#</cfoutput></td>
		</tr> 		
		</table>	</td>
	</tr>
	<tr>
	  <td colspan="12">
		  <div align="center">
			<input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
	  </div>
		 <div align="right"></div></td>
	</tr>
	</cfif>
<!--- UNIDADES NÃO PROGRAMAS PARA O CORRENTE --->
 	<!--- <cfquery name="rsNotAvali" datasource="#dsn_inspecao#">
		SELECT distinct Und_Ano_Avaliar, Und_Codigo, Und_Descricao, Und_TipoUnidade, Und_NomeGerente, TUN_Descricao, Und_CodDiretoria
		FROM Unidades 
		INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
		INNER JOIN Inspecao ON Und_Codigo = INP_Unidade 
		WHERE
		<cfif form.se neq 'Todos' or form.frmtipounid neq 'Todas' or trim(form.frmano) neq 'Todos'>
			 <cfif form.se neq 'Todos'>
				 Und_CodDiretoria = '#form.se#' and
			 </cfif>
			<cfif form.frmtipounid neq 'Todas'>
				Und_TipoUnidade= '#form.frmtipounid#' and
			 </cfif>			
 			<cfif trim(form.frmano) neq 'Todos'>
				(Und_Ano_Avaliar Is Null Or Und_Ano_Avaliar < '#form.frmano#') and
			</cfif> 
		</cfif>
		Und_Status = 'A'
		<cfif form.se eq 'Todos' and form.grupoacesso eq 'GESTORES'>
			and Und_CodDiretoria in(#form.usucoordena#)
		</cfif>		
		ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao
	</cfquery>
	<cfif rsNotAvali.recordcount gt 0>
        <tr bgcolor="f7f7f7">
          <td colspan="17" align="center" bgcolor="f7f7f7" class="titulo1">&nbsp;</td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td colspan="17" align="center" bgcolor="#B4B4B4" class="titulo1">UNIDADES NÃO PROGRAMADAS NO EXERCÍCIO DE: <cfoutput>#form.frmano#</cfoutput></td>
          <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #right(CGI.REMOTE_USER,8)# & '.xls'>
    </tr>
        <tr class="titulosClaro">
          <td colspan="23" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsNotAvali.recordcount#</cfoutput></td>
        </tr>
        <tr class="titulosClaro">
          <td colspan="23" bgcolor="eeeeee" class="exibir">
		  <table width="98%" border="0">
          <tr bgcolor="#CCCCCC" class="titulos">
            <td align="center"><div align="center">Programada</div></td>
            <td align="center">Código</td>
            <td width="24%"><div align="left">Descrição</div></td>
            <td width="10%"><div align="left">Tipo</div></td>
            <td width="27%">Gestor da Unidade</td>
            <td width="27%"><div align="center">Avaliações realizadas</div></td>
            </tr>	
		<cfoutput query="rsNotAvali">	
			<cfquery name="rsAval" datasource="#dsn_inspecao#">		
				SELECT INP_DtInicInspecao, Right(INP_NumInspecao,4) as ano
				FROM Inspecao
				WHERE INP_Unidade = '#rsNotAvali.Und_Codigo#'
				ORDER BY Right(INP_NumInspecao,4) 
			</cfquery>
			<cfquery dbtype="query" name="rsExiste">
				SELECT INP_DtInicInspecao, ano
				FROM rsAval
				WHERE ano = '#form.frmano#'
			</cfquery>
            <cfset auxano = ''>
			<cfset habSN = 'S'>
				
			<cfloop query="rsAval">
			   <cfset auxano = auxano & ' ' & rsAval.ano>
			</cfloop>	

		  	<cfset scor = 'f7f7f7'>		

          <tr bgcolor="#scor#" class="exibir">
            <td width="4%"><div align="center">#Und_Ano_Avaliar#</div></td>
            <td width="8%">#Und_Codigo#</td>
            <td width="24%">#Und_Descricao#</td>
            <td width="10%">#TUN_Descricao#</td>
            <td width="27%">#Und_NomeGerente#</td>
            <td><div align="center">#auxano#</div></td>
            </tr>
            <cfif scor eq 'f7f7f7'>
              <cfset scor = 'CCCCCC'>
              <cfelse>
              <cfset scor = 'f7f7f7'>
            </cfif>				
	</cfoutput>			
	          </table>		</td>
        </tr>
	
		<tr>
		<td colspan="10">
		  <div align="center">
			<input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
		</div>
		 <div align="right"></div></td>
		</tr>		
	</cfif>--->
</cfif> 

 	
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
 </table>
</form>	

  <!--- Término da área de conteúdo --->
</body>
</html>

