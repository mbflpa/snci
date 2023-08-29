<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfif isDefined("ckTipo") And ckTipo eq "inspecao">
  <cfset url.se = left(txtNum_Inspecao,2)>
<cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
<!--- ok! --->
<cfelse>  
  <cfset url.se = url.superSE>
</cfif>
<cfquery name="qDR" datasource="#dsn_inspecao#">
   SELECT Dir_Sigla 
   FROM Diretoria 
   WHERE Dir_Codigo = '#url.SE#'
</cfquery>
<cfset total=0>
<cfset auxdtmaxlimit = dateformat(now(),"YYYYMMDD")>
<cfset auxdtmaxlimit = CreateDate(Left(auxdtmaxlimit,4), Mid(auxdtmaxlimit,5,2), Right(auxdtmaxlimit,2))>
<cfif isDefined("ckTipo") And ckTipo eq "inspecao">
   <cfset url.dtInicio = CreateDate(year(now()),month(now()),day(now()))>
   <cfset url.dtFinal = CreateDate(year(now()),month(now()),day(now()))>
   <cfset url.superSE = " ">
   <cfset url.superMes = " ">
   <cfset url.superAno = " ">
   <!--- <cfset url.SE = " "> --->
   <cfset auxfiltro = "Nº do Relatório : " & txtNum_Inspecao & "         Superintendência : " & url.SE & " - " & #qDR.Dir_Sigla#>  
<cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
   <cfset url.superSE = " ">
   <cfset url.superMes = " ">
   <cfset url.superAno = " ">
   <cfset txtNum_Inspecao = "">
   <cfset url.dtInicio = CreateDate(Right(dtinic,4), Mid(dtinic,4,2), Left(dtinic,2))>
   <cfset url.dtFinal = CreateDate(Right(url.dtfim,4), Mid(url.dtfim,4,2), Left(url.dtfim,2))>
   <cfset auxfiltro = "Periodo/Superintendencia  -  Data Inicial : " & DateFormat(url.dtInicio,"dd/mm/yyyy") & "  -  Data Final : " & DateFormat(url.dtFinal,"dd/mm/yyyy") & "         Superintendência : " & url.SE & " - " & #qDR.Dir_Sigla#>
   <cfset auxdtmaxlimit = dateformat(url.dtFinal,"YYYYMMDD")>
   <cfset auxdtmaxlimit = CreateDate(Left(auxdtmaxlimit,4), Mid(auxdtmaxlimit,5,2), Right(auxdtmaxlimit,2))>
   <!--- <cfset auxtit = "(PERÍODO - Dt.Inicial: " & DateFormat(url.dtInicio,"dd/mm/yyyy") & "  -  Dt. Final: " & DateFormat(url.dtFinal,"dd/mm/yyyy") & ")"> --->
<cfelse>   
   <cfset txtNum_Inspecao = "">
  <!---  <cfset url.SE = " "> --->
   <cfset url.dtInicio = CreateDate(year(now()),month(now()),day(now()))>
   <cfset url.dtFinal = CreateDate(year(now()),month(now()),day(now()))>
   <cfset auxfiltro = "Superintendencia : " & url.SE & "  Mês : " &  url.superMes & "    Ano : " &  url.superAno & "           Superintendência : "  & url.SE & " - " & #qDR.Dir_Sigla#>
</cfif>
<cfoutput>
<cfquery name="rsItem" datasource="#dsn_inspecao#">
	SELECT And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, And_username, And_Area, INP_DtEncerramento, Usu_GrupoAcesso
	FROM Inspecao INNER JOIN Andamento ON (INP_Unidade = And_Unidade) AND (INP_NumInspecao = And_NumInspecao) INNER JOIN Usuarios ON And_username = Usu_Login
	WHERE And_Situacao_Resp IN (1,6,7,17,22) and 
	<cfif ckTipo eq "inspecao">
	   (And_NumInspecao = '#txtNum_Inspecao#') 
	<cfelseif ckTipo eq "periodo">
	   (INP_DtEncerramento BETWEEN #url.dtInicio# AND #url.dtFinal#) AND (left(And_Unidade,2) = '#url.SE#')
	<cfelseif ckTipo eq "inspetor">
	   (INP_DtEncerramento BETWEEN #url.dtIniinsp# AND #url.dtFiminsp#) and left(And_Unidade,2) = '#qDR.Usu_DR#'
	<cfelse>
	   (left(And_Unidade,2) = '#url.superSE#') AND (year(INP_DtEncerramento) = '#url.superAno#') AND (month(INP_DtEncerramento) = '#url.superMes#')
	</cfif>
		ORDER BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic
</cfquery>
</cfoutput>

 <cfif rsItem.recordcount lte 0>
  Não Há dados a serem relatados para o período informado!<br>
  <input type="button" class="botao" onClick="window.close()" value="Fechar">
  <cfabort> 
</cfif> 

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	SELECT Dir_codigo, Dir_Sigla FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo WHERE Und_Codigo = '#rsItem.And_Unidade#'
</cfquery>
<!--- <cfset auxfiltro = auxfiltro & '  ' & #qAcesso.Dir_codigo# & '-' & #qAcesso.Dir_Sigla#> --->

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
</head>
<body>
<script language="JavaScript">
//detectando navegador
sAgent = navigator.userAgent;
bIsIE = sAgent.indexOf("MSIE") > -1;
bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;
</script>
<!--- <table width="100%" align="center">
<tr>
<td valign="top" align="center"> --->
<!--- Área de conteúdo   --->
<table width="98%" height="10%" align="center" cellspacing="0">
  <tr>
    <td height="20" colspan="15">&nbsp;</td>
  </tr>

  <tr>
    <td height="10" colspan="15"><div align="center"><span class="titulo1"><strong>TEMPO - AN&Aacute;LISE DAS MANIFESTA&Ccedil;&Otilde;ES</strong></span></div>      
      <div align="center"></div></td>
  </tr>
  <tr>
    <td height="20" colspan="15">&nbsp;</td>
  </tr>
<tr>
    <td height="10" colspan="15" class="titulos">Filtros: <cfoutput>#auxfiltro#</cfoutput></td>
  </tr>
  <tr><td width="68"><!--- <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#txtNum_Inspecao#</cfoutput></div> ---></td></tr>

	  <tr class="titulosClaro">
	    <td colspan="15" class="exibir"><hr></td>
  </tr>
	  <tr class="titulosClaro">
		<td class="exibir"><div align="center">
		  <p> UNIDADE<br>
	      AVALIADA </p>
	    </div>		  <div align="center"></div></td>
		<td width="71" class="exibir"><div align="center"> <strong> RELAT&Oacute;RIO </strong> </div></td>
		<td width="52" class="exibir"><div align="center">GRUPO</div></td>
		<td width="39" class="exibir">ITEM</td>
		<td width="64" class="exibir"><div align="center">COD ORG<br> 
		  CONDUTOR</div></td>
		<td width="263" class="exibir"><div align="center">ORGAO <br>
CONDUTOR</div></td>
		<td width="82" class="exibir">DATA <br>
	    RECEBIMENTO</td>
		<td width="61" class="exibir">DATA <br>
	    RESPOSTA</td>
		<td width="61" class="exibir"><div align="center">HORA</div></td>
		<td width="52" class="exibir">  <div align="center">STATUS </div></td>
		<td width="110" class="exibir"><div align="left">GRUPOACESSO</div></td>
	    <td width="147" class="exibir"><div align="left">NOME</div></td>
	    <td width="73" class="exibir"><div align="center">DIAS (CORRIDOS)</div></td>
	    <td width="44" class="exibir"><div align="center">DIAS (&Uacute;TEIS)</div></td>
	    <td width="85" class="exibir"><div align="center">AN&Aacute;LISE PRAZO </div></td>
	  </tr> 

	<cfoutput query="rsItem">
      <cfset auxlinha = 0>
	  <cfset auxNumlinhaA = 0>
	  <cfset DIAS = 0>
	  <cfset UNID = "">
	  <cfset INSP = "">
	  <cfset GRUPO = "">
	  <cfset ITEM = "">
	  <cfset DTREC = CreateDate(year(rsItem.And_DtPosic),month(rsItem.And_DtPosic),day(rsItem.And_DtPosic))>
	  <cfset dsusp = 0>
	  <!---  --->
	  <cfset DTPO = CreateDate(year(rsItem.And_DtPosic),month(rsItem.And_DtPosic),day(rsItem.And_DtPosic))>
	  <cfquery name="rsDTLimite" datasource="#dsn_inspecao#">
		SELECT And_DtPosic, And_HrPosic
		FROM Andamento 
		WHERE And_Situacao_Resp in (1,6,7,17,22) and (And_Unidade = '#rsItem.And_Unidade#') AND (And_NumInspecao = '#rsItem.And_NumInspecao#') AND (And_NumGrupo = #rsItem.And_NumGrupo#) AND (And_NumItem = #rsItem.And_NumItem#) and (And_DtPosic > #DTPO#)
		order by And_DtPosic, And_HrPosic
	  </cfquery>
	  <!---  --->
	  <cfif rsDTLimite.recordcount gt 0>
	       <cfset DTPO = CreateDate(year(rsDTLimite.And_DtPosic),month(rsDTLimite.And_DtPosic),day(rsDTLimite.And_DtPosic))>
		   <cfquery name="rsGestor" datasource="#dsn_inspecao#">
			SELECT And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, And_username, And_Area, INP_DtEncerramento, Usu_GrupoAcesso, Usu_Matricula, Usu_Apelido
			FROM Inspecao INNER JOIN Andamento ON (INP_Unidade = And_Unidade) AND (INP_NumInspecao = And_NumInspecao) INNER JOIN Usuarios ON And_username = Usu_Login 
			WHERE And_Situacao_Resp IN (2,3,4,5,8,9,12,13,15,16,19,20,21,23,24,25,26,27) and (And_Unidade = '#rsItem.And_Unidade#') AND (And_NumInspecao = '#rsItem.And_NumInspecao#') AND (And_NumGrupo = #rsItem.And_NumGrupo#) AND (And_NumItem = #rsItem.And_NumItem#) and (And_DtPosic >= #DTREC#) and (And_DtPosic <= #DTPO#)
			ORDER BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic		
		  </cfquery>	
	  <cfelse>
		   <cfquery name="rsGestor" datasource="#dsn_inspecao#">
			SELECT And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic, And_Situacao_Resp, And_username, And_Area, INP_DtEncerramento, Usu_GrupoAcesso, Usu_Matricula, Usu_Apelido
			FROM Inspecao INNER JOIN Andamento ON (INP_Unidade = And_Unidade) AND (INP_NumInspecao = And_NumInspecao) INNER JOIN Usuarios ON And_username = Usu_Login 
			WHERE And_Situacao_Resp IN (2,3,4,5,8,9,12,13,15,16,19,20,21,23,24,25,26,27) and (And_Unidade = '#rsItem.And_Unidade#') AND (And_NumInspecao = '#rsItem.And_NumInspecao#') AND (And_NumGrupo = #rsItem.And_NumGrupo#) AND (And_NumItem = #rsItem.And_NumItem#) and (And_DtPosic >= #DTREC#)
			ORDER BY And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_HrPosic		
		  </cfquery>
	  </cfif>
 <cfif rsGestor.recordcount gt 0>	
  <cfloop query="rsGestor">	
      <cfif Ucase(trim(rsGestor.Usu_GrupoAcesso)) eq "GESTORES" or Ucase(trim(rsGestor.Usu_GrupoAcesso)) eq "INSPETORES">
		  <cfquery name="rsSTO" datasource="#dsn_inspecao#">
		     SELECT STO_Sigla, STO_Descricao FROM Situacao_Ponto WHERE STO_Codigo = #rsGestor.And_Situacao_Resp#
	      </cfquery>

		  <cfset HORA = rsGestor.And_HrPosic>		  
		  <cfset RSPT = rsGestor.And_Situacao_Resp & " - " & Ucase(trim(rsSTO.STO_Sigla))>
		  <cfset SIGLA = rsSTO.STO_Sigla>
		  <cfset GPACESSO = rsGestor.Usu_GrupoAcesso>
		  <cfset MATRICULA = rsGestor.Usu_Matricula>
		  <cfset NOME = left(rsGestor.Usu_Apelido,19)>		 
		  <!--- <cfset DIAS = 0> --->
<!---  --->
		<!--- <cfset auxposic = CreateDate(year(rsGestor.And_DtPosic),month(rsGestor.And_DtPosic),day(rsGestor.And_DtPosic))> --->
		<cfset DIAS = dateDiff("d", DTREC, CreateDate(year(rsGestor.And_DtPosic),month(rsGestor.And_DtPosic),day(rsGestor.And_DtPosic)))> 
		<cfset DTRESP = CreateDate(year(rsGestor.And_DtPosic),month(rsGestor.And_DtPosic),day(rsGestor.And_DtPosic))> 
		<cfset nCont = 1>
		<cfset dsusp = 0>
 	    <cfset auxdtnova = CreateDate(year(DTRESP),month(DTRESP),day(DTRESP))>
		<cfset auxDTFim = DateAdd("d", #dias#, #auxdtnova#)>
		<cfset DD_SD_Existe = 0>
		<!--- obter os sabados/domingos nos feriados nacionais --->
		 <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
			   SELECT Fer_Data FROM FeriadoNacional where Fer_Data between #auxdtnova# and #auxDTFim#
		 </cfquery>
		 <cfif rsFeriado.recordcount gt 0>
			   <cfset DD_SD_Existe = rsFeriado.recordcount>
			   <cfloop query="rsFeriado">
				   <cfset vDiaSem = DayOfWeek(rsFeriado.Fer_Data)>
				   <cfswitch expression="#vDiaSem#">
					  <cfcase value="1">
						 <cfset DD_SD_Existe = DD_SD_Existe - 1>
					  </cfcase>
					  <cfcase value="7">
						 <cfset DD_SD_Existe = DD_SD_Existe - 1>
					  </cfcase>
				   </cfswitch>
			   </cfloop>
		 </cfif>
		 <!--- Obter sabados e domingos entre as datas  --->
		<cfloop condition="nCont lte #dias#">
			   <cfset vDiaSem = DayOfWeek(auxdtnova)>
			   <cfswitch expression="#vDiaSem#">
				  <cfcase value="1">
					 <cfset dsusp = dsusp + 1>
				  </cfcase>
				  <cfcase value="7">
					 <cfset dsusp = dsusp + 1>
				  </cfcase>
			   </cfswitch>
			<cfset auxdtnova = DateAdd("d", 1, #auxdtnova#)>
			<cfset nCont = nCont + 1>
		</cfloop>
		<!---  --->
		<cfset dsusp = #dsusp# + #DD_SD_Existe#>
 
	           <!--- <cfset DTRESP = CreateDate(year(rsGestor.And_DtPosic),month(rsGestor.And_DtPosic),day(rsGestor.And_DtPosic))> --->
           <cfif UNID neq rsGestor.And_Unidade or INSP neq rsGestor.And_NumInspecao or GRUPO neq rsGestor.And_NumGrupo or ITEM neq rsGestor.And_NumItem>
			<tr>
		       <td colspan="15" align="center"><hr></td>
            </tr>
		  </cfif> 
		  <cfset UNID = rsGestor.And_Unidade>
		  <cfset AREA = rsGestor.And_Area>
		  <cfset INSP = rsGestor.And_NumInspecao>
		  <cfset GRUPO = rsGestor.And_NumGrupo>
		  <cfset ITEM = rsGestor.And_NumItem>
		  <!--- <cfset DTRESP = DateFormat(rsGestor.And_DtPosic,"YYYY/MM/DD")> --->
		  <cfset ORGCONDUTOR = "">
		  <cfif len(trim(area)) eq 8>
		   <!--- tabela area --->
		   <cfquery name="rsCondutor" datasource="#dsn_inspecao#">
			  SELECT Ars_Descricao FROM Areas WHERE Ars_Codigo = '#AREA#'
		   </cfquery>
		   <cfif rsCondutor.recordcount gt 0>
				<cfset ORGCONDUTOR = trim(rsCondutor.Ars_Descricao)>
		   <cfelse>
			   <!--- tabela DEPARTAMENTO --->
				<cfquery name="rsCondutor" datasource="#dsn_inspecao#">
				   SELECT Dep_Descricao FROM Departamento WHERE Dep_Codigo  = '#AREA#'
				</cfquery>
				<cfif rsCondutor.recordcount gt 0>
					 <cfset ORGCONDUTOR = trim(rsCondutor.Dep_Descricao)>
				<cfelse>
					<!--- tabela REOPS --->
					<cfquery name="rsCondutor" datasource="#dsn_inspecao#">
						SELECT Rep_Nome FROM Reops WHERE Rep_Codigo = '#AREA#'
					</cfquery>
					<cfif rsCondutor.recordcount gt 0>
						  <cfset ORGCONDUTOR = trim(rsCondutor.Rep_Nome)>
					<cfelse>
						  <!--- tabela UNIDADES --->
						  <cfquery name="rsCondutor" datasource="#dsn_inspecao#">
							 SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#AREA#'
						  </cfquery>
						  <cfif rsCondutor.recordcount gt 0>
							   <cfset ORGCONDUTOR = trim(rsCondutor.Und_Descricao)>		
						  </cfif>
					</cfif>
		        </cfif>
		  </cfif>
        </cfif>
			  
		  <tr class="exibir">
		  <td><div align="center">#UNID#</div>
		    <div align="center"></div>		    <div align="left"></div></td>
		  <td width="71"><div align="center">#INSP#</div></td>
		  <td width="52"><div align="center">#GRUPO#</div></td>
		  <td width="39"><div align="center">#ITEM#</div></td>
		  <td width="64"><div align="left">#AREA#</div></td>
		  <td width="263">#ORGCONDUTOR#</td>
		  <td width="82">#dateformat(DTREC,"DD/MM/YYYY")#</td>
		  <td width="61">#DateFormat(DTRESP,"DD/MM/YYYY")#</td>
		  <td width="61"><div align="center">#HORA#</div></td>
		  <td><div align="center">#RSPT#</div></td>
		  <td><div align="left">#GPACESSO#</div></td>
		  <cfset diasc = DIAS>
		  <cfif dsusp neq 0>
			  <cfset dias = dias - dsusp>
		  <cfelse>
		    <cfset dsusp = ""> 
			<cfset diasc = "">
		  </cfif>
		  <td><div align="left">#NOME#</div></td>
		  <td><div align="center">#diasc#</div></td>
		  <cfif dias gt 21>
			   <cfset auxclass = "red_titulo">
			   <cfset auxan_prz = "ACIMA DE 21">
		  <cfelse>
			   <cfset auxclass = "">
			   <cfset auxan_prz = "">			
		  </cfif>
		  <td><div align="center" class="#auxclass#">#DIAS#</div></td>
		  <td><div align="center" class="#auxclass#">#auxan_prz#</div></td>
		  </tr> 
		 </cfif>
		  <cfset dsusp = 0>
		  <!--- <cfset DTREC = CreateDate(year(rsGestor.And_DtPosic),month(rsGestor.And_DtPosic),day(rsGestor.And_DtPosic))> --->
		  <!--- <cfset DIAS = 0> --->
    	  		
		 <cfset DTREC = CreateDate(year(rsGestor.And_DtPosic),month(rsGestor.And_DtPosic),day(rsGestor.And_DtPosic))>  
  </cfloop>  	
 </cfif>
    </cfoutput> 
	
		<tr>
		  <td colspan="15" align="center">&nbsp;</td>
  </tr>
		<tr><td colspan="15" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
				<tr>
		  <td colspan="15" align="center"><hr></td>
  </tr>
</table>

<!--- Fim Área de conteúdo --->	<!---   </td>
  </tr>
</table> --->
<cfinclude template="rodape.cfm">
</body>
</html>