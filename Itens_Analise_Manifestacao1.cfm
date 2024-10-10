<cfprocessingdirective pageEncoding ="utf-8">
<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_DR, Usu_Coordena, Usu_Matricula 
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfquery name="qDR" datasource="#dsn_inspecao#">
   SELECT Dir_Sigla 
   FROM Diretoria 
   WHERE Dir_Codigo = '#url.SE#'
</cfquery>
<cfset total=0>
<cfset url.dtInicio = CreateDate(Right(dtinic,4), Mid(dtinic,4,2), Left(dtinic,2))>
<cfset url.dtFinal = CreateDate(Right(url.dtfim,4), Mid(url.dtfim,4,2), Left(url.dtfim,2))>
<cfset auxfiltro = "Período/Superintendência  -  Data Inicial : " & DateFormat(url.dtInicio,"dd/mm/yyyy") & "  -  Data Final : " & DateFormat(url.dtFinal,"dd/mm/yyyy") & "         Superintendência : " & url.SE & " - " & #qDR.Dir_Sigla#>
<cfset auxdtmaxlimit = dateformat(url.dtFinal,"YYYYMMDD")>
<cfset auxdtmaxlimit = CreateDate(Left(auxdtmaxlimit,4), Mid(auxdtmaxlimit,5,2), Right(auxdtmaxlimit,2))>
<cfoutput>
<cfquery name="rsItem" datasource="#dsn_inspecao#">
	SELECT Usu_Login, Usu_DR, Dir_Sigla, And_username, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, And_NumInspecao, And_Unidade, Und_Descricao, TUN_Descricao, And_NumGrupo, Grp_Descricao, And_NumItem, Itn_Descricao, convert(char,And_DtPosic,103) as AndDtPosic, And_HrPosic, And_Situacao_Resp, STO_Descricao
FROM Situacao_Ponto 
INNER JOIN ((((((Andamento INNER JOIN Unidades ON And_Unidade = Und_Codigo) 
INNER JOIN Inspecao ON And_NumInspecao = INP_NumInspecao AND And_Unidade = INP_Unidade
INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo) 
INNER JOIN Usuarios ON And_username = Usu_Login) 
INNER JOIN Diretoria ON Usu_DR = Dir_Codigo) 
INNER JOIN Grupos_Verificacao ON And_NumGrupo = Grp_Codigo and right(And_NumInspecao,4) = Grp_Ano) 
INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (And_NumItem = Itn_NumItem) AND (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo)) ON STO_Codigo = And_Situacao_Resp
WHERE (And_DtPosic BETWEEN #url.dtInicio# AND #url.dtFinal#) and (And_Situacao_Resp in (3,10,12,13,15,16,18,19,23,24,25,26,28,29,30,31)) and (trim(Usu_GrupoAcesso)= 'INSPETORES' Or trim(Usu_GrupoAcesso) = 'GESTORES' Or trim(Usu_GrupoAcesso) = 'ANALISTAS')
<cfif URL.gestor gt 0>
 and (And_username = '#url.gestor#')
<cfelseif grpacesso neq 'GESTORMASTER'>
 AND (left(And_NumInspecao,2) in (#trim(qUsuario.Usu_Coordena)#)) 
</cfif>
	ORDER BY Usu_Apelido, And_DtPosic, And_HrPosic, And_Unidade, And_NumInspecao, And_NumGrupo, And_NumItem
</cfquery>
</cfoutput>

 <cfif rsItem.recordcount lte 0>
  Não Há dados a serem relatados para o período informado!<br>
  <input type="button" class="botao" onClick="window.close()" value="Fechar">
  <cfabort> 
</cfif> 

<cfoutput>
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>

<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset diretorio = left(diretorio,Find('SNCI','#diretorio#')-1) & 'SNCI\'> 
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.csv'>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfdirectory name="qList" filter="*.csv" sort="name desc" directory="#slocal#">
<cfloop query="qList">
	<cfif (left(name,8) lt left(sdata,8)) or (mid(name,12,8) eq trim(qUsuario.Usu_Matricula))>
	  <cffile action="delete" file="#slocal##name#">
	</cfif>
</cfloop>
</cfoutput>

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
<!--- �rea de conte�do   --->
<table width="1455" height="10%" border="1" align="center" cellspacing="0">
  <tr>
    <td height="20" colspan="17">&nbsp;</td>
  </tr>

  <tr>
    <td height="10" colspan="17"><div align="center"><span class="titulo1">ANÁLISES  DAS MANIFESTAÇÕES</span></div>      
      <div align="center"></div></td>
  </tr>
  <tr>
    <td height="20" colspan="17">
	
    <table width="200" border="0">
      <tr>
        <td><div align="center" class="titulos">
          <button onClick="window.close()" class="botao">Fechar</button>
        </div></td>
        <td><div align="center"><a href="<cfoutput>#url_csvxls##sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
      </tr>
    </table></td>
  </tr>
<tr>
    <td height="10" colspan="14" class="titulo1">Total Geral.: <cfoutput>#rsItem.recordcount#</cfoutput><cfoutput>
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Per&iacute;odo:  #dateformat(url.dtInicio,"DD/MM/YYYY")#&nbsp;&nbsp;&nbsp;at&Eacute;&nbsp;&nbsp;&nbsp;#DATEFORMAT(url.dtFinal,"DD/MM/YYYY")#</span>
        </cfoutput></td>
  </tr>
  <tr><td width="70"></td></tr>

  <cfset Andusername = ''>
	<cfoutput query="rsItem">  
	  <cfquery name="rsGestor" dbtype = "query">
			SELECT count(And_username) as totaGestor FROM rsItem where And_username = '#rsItem.And_username#'
	  </cfquery>
	  <cfif Andusername neq ucase(trim(And_username))>
	   <cfset Andusername = ucase(trim(And_username))>
	  
	   <tr>
	     <td height="5" colspan="14" class="exibir">&nbsp;</td>
        </tr>
	   <tr bgcolor="##D9ECFA" class="titulosClaro">
	    <td colspan="14" bgcolor="##BFDAFC" class="exibir">&nbsp;Analista: #Usu_Apelido#&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp; #Usu_LotacaoNome# &nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Qtd. Reg.: #rsGestor.totaGestor#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="Itens_Analise_Manifestacao2.cfm?UsuApelido=#Usu_Apelido#&auxusername=#trim(Usu_Login)#&dtinic=#dtinic#&dtfim=#dtfim#&gestor=#gestor#" target="_blank"><span class="link1">(Clicar aqui => para Visualizar em Gr�fico)</span></a></td>
	    </tr>
	  <tr bgcolor="##BFDAFC" class="titulosClaro">
	  <td width="54" class="exibir">Data <br>
	    Avaliação</td>
	    <td width="63" class="exibir">Hora<br>
	      Avaliação</td>
		<td width="70" class="exibir"><div align="center">Nº Avaliação</div></td>
		<td width="205" class="exibir">Nome Unidade </td>
		<td width="48" class="exibir">Grupo</td>
		<td width="309" class="exibir">Grupo Descrição </td>
		<td width="48" class="exibir">Item</td>
		<td width="477" class="exibir"> Item Descrição</td>
	    <td width="143" class="exibir">Situação Descrição</td>
	    </tr> 
</cfif>
<!--- 	<cfoutput query="rsItem"> --->
		  <tr class="exibir">
		  <!--- <cfset auxcol = dateformat(AndDtPosic,"DD/MM/YYYY")> --->
		  <cfset auxcol = AndDtPosic>
		  <td><div align="left">#auxcol#</div></td>
		  <cfset auxcol = trim(And_HrPosic)>
		  <cfset auxcol = left(auxcol,2) & ':' & mid(auxcol,3,2) & ':' & mid(auxcol,5,2)>
		  <td><div align="center">#auxcol#</div></td>
		  <cfset auxcol = And_NumInspecao>
		  <td width="70"><div align="center">#auxcol#</div></td>
		  <td>#ucase(Und_Descricao)#</td>
		  <cfset auxcol = And_NumGrupo>
		  <td><div align="center">#auxcol#</div></td>
		  <td width="309"><div align="left">#Grp_Descricao#</div></td>
		  <cfset auxcol = And_NumItem>
		  <td><div align="center">#auxcol#</div></td>
		  <td><div align="left">#Itn_Descricao#</div></td>
		  <cfset auxcol = And_Situacao_Resp>
		  <td><div align="left">#STO_Descricao#</div></td>
		  </tr> 		  
    </cfoutput> 
		<tr>
		  <td colspan="14" align="center">&nbsp;</td>
  </tr>
		<tr><td colspan="17" align="center"><button onClick="window.close()" class="botao">Fechar</button></td>
	    </tr>
				<tr>
		  <td colspan="17" align="center"><hr></td>
  </tr>
</table>

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
    FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
    Query = rsItem,
	ColumnList = "Usu_DR,Dir_Sigla,And_username,Usu_Apelido,Usu_Lotacao,And_NumInspecao,And_Unidade,Und_Descricao,TUN_Descricao,And_NumGrupo,Grp_Descricao,And_NumItem,Itn_Descricao,AndDtPosic,And_HrPosic,And_Situacao_Resp,STO_Descricao",
	ColumnNames = "Cod_SE,Sigla_SE,Gestor_Login,Gestor_Nome,Gestor_Lotaçãoo,Avaliação,Unidade,Nome Unidade,Tipo Unidade,Grupo,Grupo Descrição,Item,Item Descrição,Posição,Hora,Situação,Situação Descrição",
	SheetName = "Gestão_Manifestacoes"
    ) />
<cfinclude template="rodape.cfm">
</body>
</html>